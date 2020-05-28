local startMigrate = false
local migrationRunning = false
local totalCount = 0
local currentCount = 0
local allIdentifiers = {}

RegisterCommand("migratedb", function(source, args)
	if source == 0 then
		if not migrationRunning then
			if startMigrate then
				if ExM.DatabaseType == "newesx" then
					initiateMigration()
				else
					print("^8----------------------------------------------------------------------------------^0")
					print("^4CREATING MISSING DATABASE FIELDS^0")
					print("^8YOU MAY SEE ERRORS HERE IF THESE DATABASE FIELDS ALREADY EXIST. JUST IGNORE THEM^0")
					MySQL.Async.execute('ALTER TABLE `users` ADD `accounts` LONGTEXT NULL DEFAULT NULL, ADD `inventory` LONGTEXT NULL DEFAULT NULL;')
					Wait(100)
					MySQL.Async.execute('ALTER TABLE `items` ADD `weight` INT NOT NULL DEFAULT 1;')
					Wait(100)
					initiateMigration()
				end
			else
				print("^8----------------------------------------------------------------------------------^0")
				print("^3INVENTORY AND ACCOUNT MIGRATION^0")
				print("^8----------------------------------------------------------------------------------^0")
				print("MAKE SURE THERE ARE ^1NO PLAYERS^0 ON YOUR SERVER AND YOU HAVE ^1BACKED UP YOUR DATABASE^0 BEFORE STARTING THE MIGRATION PROCESS. TYPE ^2migratedb^0 AGAIN TO START!^0")
				print("^8----------------------------------------------------------------------------------^0")
				startMigrate = true
			end
		end
	else
		print("This command can only be ran from the server console!")
	end
end, false)

function initiateMigration()
	migrationRunning = true
	print("^8----------------------------------------------------------------------------------^0")
	print("^2MIGRATION STARTED^0. THIS COULD TAKE A WHILE DEPENDING ON THE SIZE OF YOUR DATABASE.")
	print("^8YOU MAY SEE HITCH WARNINGS DURING THIS PROCESS, THAT IS EXPECTED FOR LARGER DATABASE.^0")
	print("YOU WILL BE NOTIFIED ONCE THE MIGRATION PROCESS IS COMPLETE!")
	print("^8----------------------------------------------------------------------------------^0")
	MySQL.Async.fetchAll('SELECT identifier FROM users', { }, function(identifiers)
		for _, ident in ipairs(identifiers) do
			allIdentifiers[#allIdentifiers + 1] = ident.identifier
		end
		totalCount = #allIdentifiers
		print("^3Total Users: " .. totalCount .. "^0")
		processUsers()
	end)
end

inventTable = {}
accountTable = {}

function getOldInventory(identifier)
	MySQL.Async.fetchAll('SELECT * FROM user_inventory WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(oldInvent)
		if oldInvent ~= nil then
			for _, databaseRow in ipairs(oldInvent) do
				inventTable[databaseRow.item] = databaseRow.count
			end
		end
	end)
end

function getOldAccounts(identifier)
	MySQL.Async.fetchAll('SELECT * FROM user_accounts WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(oldAccounts)
		if oldAccounts ~= nil then
			for _, databaseRow in ipairs(oldAccounts) do
				accountTable[databaseRow.name] = databaseRow.money
			end
		end
	end)
end

function getOldUserAccounts(identifier)
	MySQL.Async.fetchAll('SELECT bank, money FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(oldUserAccounts)
		if oldUserAccounts ~= nil then
			accountTable['bank'] = oldUserAccounts[1].bank
			accountTable['money'] = oldUserAccounts[1].money
		end
	end)
end

function processUsers()
	for _, identKey in ipairs(allIdentifiers) do
		local alreadyDone = false
		MySQL.Async.fetchAll('SELECT inventory, accounts FROM users WHERE identifier = @identifier', {
			['@identifier'] = identKey
		}, function(oldAccounts)
			if oldAccounts ~= nil then
				alreadyDone = true
			end
		end)
		
		if not alreadyDone then
			inventTable = {}
			accountTable = {}
		
			getOldInventory(identKey)
			Wait(100)
			getOldAccounts(identKey)
			Wait(100)
			getOldUserAccounts(identKey)
			Wait(100)
			
			MySQL.Async.execute('UPDATE users SET inventory = @inventory, accounts = @accounts WHERE identifier = @identifier', {
				['@inventory'] = json.encode(inventTable),
				['@accounts'] = json.encode(accountTable),
				['@identifier'] = identKey
			}, function(rowsChanged)
				currentCount = currentCount + 1
				print("Processing " .. identKey .. " ^2" .. currentCount .. "/" .. totalCount .. "^0")
			end)
		end
	end
end

CreateThread(function()
	while true do
		Wait(1000)
		if migrationRunning then
			if currentCount == totalCount and currentCount ~= 0 then
				migrationRunning = false
				startMigrate = false
				print("^8----------------------------------------------------------------------------------^0")
				print("^2MIGRATION COMPLETE!^0 ^1IT IS HIGHLY RECOMMENDED THAT YOU NOW RESTART YOUR SERVER!^0")
				print("^8----------------------------------------------------------------------------------^0")
			end
		end
	end
end)
