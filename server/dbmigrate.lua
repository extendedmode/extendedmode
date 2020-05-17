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
					MySQL.Async.execute('ALTER TABLE `users` ADD `accounts` LONGTEXT NULL DEFAULT NULL, ADD `inventory` LONGTEXT NULL DEFAULT NULL;')
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

function fillInventTable(identifier, values)
	allIdentifiers[identifier] = values
end

function fillAccountsTable(identifier, values)
	allAccounts[identifier] = values
end

function processUsers()
	for identKey, _ in pairs(allIdentifiers) do
		MySQL.Async.fetchAll('SELECT * FROM user_inventory WHERE identifier = @identifier', { ['@identifier'] = identKey }, function(items)
			local inventTable = {}
			for _, databaseRow in ipairs(items) do
				inventTable[databaseRow.item] = databaseRow.count
			end
			
			fillInventTable(identKey, inventTable)
		end)
		
		MySQL.Async.fetchAll('SELECT * FROM user_accounts WHERE identifier = @identifier', { ['@identifier'] = identKey }, function(accounts)
			local accountTable = {}
			for _, databaseRow in ipairs(accounts) do
				accountTable[databaseRow.name] = databaseRow.money
			end
			
			local oldMoney = MySQL.Sync.fetchScalar('SELECT money FROM users WHERE identifier = @identifier', { ['@identifier'] = identKey })
			local oldBank = MySQL.Sync.fetchScalar('SELECT bank FROM users WHERE identifier = @identifier', { ['@identifier'] = identKey })
			accountTable['money'] = oldMoney
			accountTable['bank'] = oldBank
			
			fillAccountsTable(identKey, accountTable)
		end)
	end
	populateData()
end

function runDataSave(identifier, cb)
	MySQL.Async.execute('UPDATE users SET inventory = @inventory, accounts = @accounts WHERE identifier = @identifier', {
		['@inventory'] = json.encode(allIdentifiers[identifier]),
		['@accounts'] = json.encode(allAccounts[identifier]),
		['@identifier'] = identifier
	}, cb)
end

function populateData()
	for identifier, _ in pairs(allIdentifiers) do
		runDataSave(identifier, function(rowsChanged)
			if rowsChanged then
				allIdentifiers[identifier] = nil
				currentCount = currentCount + 1
				print("Completed " .. identifier .. " ^2" .. currentCount - 1 .. "/" .. totalCount .. "^0")
			end
		end)
	end
end

CreateThread(function()
	while true do
		Wait(1000)
		if migrationRunning then
			if currentCount == totalCount then
				migrationRunning = false
				startMigrate = false
				print("^8----------------------------------------------------------------------------------^0")
				print("^2MIGRATION COMPLETE!^0 ^1IT IS HIGHLY RECOMMENDED THAT YOU NOW RESTART YOUR SERVER!^0")
				print("^8----------------------------------------------------------------------------------^0")
			end
		end
	end
end)