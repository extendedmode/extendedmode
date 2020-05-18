local startMigrate = false
local migrationRunning = false
local totalCount = 0
local currentCount = 1
local allIdentifiers = {}
local allAccounts = {}

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
					MySQL.Async.execute('ALTER TABLE `items` ADD `weight` LONGTEXT NOT NULL DEFAULT 0;')
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
		totalCount = #identifiers
		for i = 1, #identifiers do
			allIdentifiers[identifiers[i].identifier] = true
			if i == #identifiers then
				processUsers()
			end
		end
	end)
end

function processUsers()
	for identKey, _ in pairs(allIdentifiers) do
		local inventTable = {}
		local accountTable = {}
		
		local oldInvent = MySQL.Sync.fetchAll('SELECT * FROM user_inventory WHERE identifier = @identifier', { ['@identifier'] = identKey })
		local oldAccounts = MySQL.Sync.fetchAll('SELECT * FROM user_accounts WHERE identifier = @identifier', { ['@identifier'] = identKey })
		local oldMoney = MySQL.Sync.fetchScalar('SELECT money FROM users WHERE identifier = @identifier', { ['@identifier'] = identKey })
		local oldBank = MySQL.Sync.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', { ['@identifier'] = identKey })
		
		for _, databaseRow in ipairs(oldInvent) do
			inventTable[databaseRow.item] = databaseRow.count
		end
		for _, databaseRow in ipairs(oldAccounts) do
			accountTable[databaseRow.name] = databaseRow.money
		end
		accountTable['money'] = oldMoney
		accountTable['bank'] = oldBank
		
		fillInventTable(identKey, inventTable)
		fillAccountsTable(identKey, accountTable)
		
		populateData(identKey)
		
		currentCount = currentCount + 1
		print("Processing " .. identKey .. " ^2" .. currentCount - 1 .. "/" .. totalCount .. "^0")
	end
end

function fillInventTable(identifier, values)
	allIdentifiers[identifier] = values
end

function fillAccountsTable(identifier, values)
	allAccounts[identifier] = values
end

function runDataSave(identifier, cb)
	MySQL.Sync.execute('UPDATE users SET inventory = @inventory, accounts = @accounts WHERE identifier = @identifier', {
		['@inventory'] = json.encode(allIdentifiers[identifier]),
		['@accounts'] = json.encode(allAccounts[identifier]),
		['@identifier'] = identifier
	}, cb)
end

function populateData(identifier)
	runDataSave(identifier, function(rowsChanged)
		if rowsChanged then
			allIdentifiers[identifier] = nil
			allAccounts[identifier] = nil
		end
	end)
end

CreateThread(function()
	while true do
		Wait(1000)
		if migrationRunning then
			if currentCount == totalCount + 1 then
				migrationRunning = false
				startMigrate = false
				print("^8----------------------------------------------------------------------------------^0")
				print("^2MIGRATION COMPLETE!^0 ^1IT IS HIGHLY RECOMMENDED THAT YOU NOW RESTART YOUR SERVER!^0")
				print("^8----------------------------------------------------------------------------------^0")
			end
		end
	end
end)