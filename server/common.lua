ESX = {}
ESX.Players = {}
ESX.UsableItemsCallbacks = {}
ESX.Items = {}
ESX.ServerCallbacks = {}
ESX.TimeoutCount = -1
ESX.CancelledTimeouts = {}
ESX.Pickups = {}
ESX.PickupId = 0
ESX.Jobs = {}
ESX.RegisteredCommands = {}

-- Add a seperate table for ExtendedMode functions, but using metatables to limit feature usage on the ESX table
-- This is to provide backward compatablity with ESX but not add new features to the old ESX tables.
-- Note: Please add all new namespaces to ExM _after_ this block
do
    local function processTable(thisTable)
        local thisObject = setmetatable({}, {
            __index = thisTable
        })
        for key, value in pairs(thisTable) do
            if type(value) == "table" then
                thisObject[key] = processTable(value)
            end
        end
        return thisObject
    end
    ExM = processTable(ESX)
end

AddEventHandler('esx:getSharedObject', function(cb)
	cb(ESX)
end)

exports("getSharedObject", function()
	return ESX
end)

exports("getExtendedModeObject", function()
	return ExM
end)

-- Globals to check if OneSync or Infinity for exclusive features
ExM.IsOneSync = GetConvar('onesync_enabled', false) == 'true'
ExM.IsInfinity = GetConvar('onesync_enableInfinity', false) == 'true'

ExM.DatabaseReady = false
ExM.DatabaseType = nil

print('[ExtendedMode] [^2INFO^7] Starting up...')

MySQL.ready(function()
	print('[ExtendedMode] [^2INFO^7] Checking your database...')
	
	-- Check the information schema for the tables that match the esx ones
	MySQL.Async.fetchAll("SELECT TABLE_NAME AS 't', COLUMN_NAME AS 'c' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'users' or TABLE_NAME = 'user_inventory' or TABLE_NAME = 'user_accounts'", {}, function(informationSchemaResult)
		local databaseCheckFunction = function()
			-- Ensure we have a result that we can iterate
			if type(informationSchemaResult) ~= "table" then
				print('[ExtendedMode] [^1ERROR^7] Your database is not compatible with ExtendedMode!\nIf this is a fresh installation, you may have forgotten to import the SQL template.')
				error()
			end

			-- Coagulate table columns from results
			local tableMatchings = {}
			for _, data in ipairs(informationSchemaResult) do
				tableMatchings[data.t] = tableMatchings[data.t] or {}
				tableMatchings[data.t][data.c] = true
			end

			-- Check for invalid scenarios
			if not tableMatchings["users"] then
				print("[ExtendedMode] [^1ERROR^7] Your database is not compatible with ExtendedMode!\nYou do not have a users table. Please import the SQL template found in the resource directory.")
				error()
			else
				if tableMatchings["users"]["inventory"] and tableMatchings["users"]["accounts"] then
					ExM.DatabaseType = "newesx"
				elseif tableMatchings["user_inventory"] and tableMatchings["user_accounts"] then
					ExM.DatabaseType = "es+esx"
				else
					print("[ExtendedMode] [^1ERROR^7] Your database is not compatible with ExtendedMode!\nYou do not have anywhere for either the inventory or account info to be stored.\nRe-importing the SQL template may fix this!")
					error()
				end
			end

			-- Do some other database type validation... (this is temporary!)
			if ExM.DatabaseType then
				if ExM.DatabaseType == "es+esx" then
					print("[ExtendedMode] [^1ERROR^7] Your database is using the 'es+esx' storage format.\nThis version of ExtendedMode is not yet fully compatible with that storage format.\nYou can try to automatically migrate your database to the correct format using the ^4`migratedb`^0 command directly in your server console.")
					error()
				elseif ExM.DatabaseType == "newesx" then -- redundant check as there are no other database types but oh well, future proofing I guess
					print(("[ExtendedMode] [^2INFO^7] Your database is using the '%s' storage format, starting..."):format(ExM.DatabaseType))
				else
					print(("[ExtendedMode] [^2INFO^7] Your database is using the '%s' storage format, this is ^1not^7 compatible with ExtendedMode!"):format(ExM.DatabaseType))
					error()
				end
			else
				print("[ExtendedMode] [^1ERROR^7] An unknown error occured while determining your database storage format!")
				error()
			end
		end

		if pcall(databaseCheckFunction) then
			MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
				for k,v in ipairs(result) do
					ESX.Items[v.name] = {
						label = v.label,
						weight = v.weight,
						rare = v.rare,
						limit = v.limit,
						canRemove = v.can_remove
					}
				end
			end)
		
			MySQL.Async.fetchAll('SELECT * FROM jobs', {}, function(jobs)
				for k,v in ipairs(jobs) do
					ESX.Jobs[v.name] = v
					ESX.Jobs[v.name].grades = {}
				end
		
				MySQL.Async.fetchAll('SELECT * FROM job_grades', {}, function(jobGrades)
					for k,v in ipairs(jobGrades) do
						if ESX.Jobs[v.job_name] then
							ESX.Jobs[v.job_name].grades[tostring(v.grade)] = v
						else
							print(('[ExtendedMode] [^3WARNING^7] Ignoring job grades for "%s" due to missing job'):format(v.job_name))
						end
					end
		
					for k2,v2 in pairs(ESX.Jobs) do
						if ESX.Table.SizeOf(v2.grades) == 0 then
							ESX.Jobs[v2.name] = nil
							print(('[ExtendedMode] [^3WARNING^7] Ignoring job "%s" due to no job grades found'):format(v2.name))
						end
					end
				end)
			end)
	
			-- Wait for the db sync function to be ready incase it isn't ready yet somehow.
			if not ESX.StartDBSync or not ESX.StartPayCheck then
				print('[ExtendedMode] [^2INFO^7] ExtendedMode has been initialized')
				while not ESX.StartDBSync and not ESX.StartPayCheck do
					Wait(1000)
				end
			end
	
			ExM.DatabaseReady = true
	
			-- Start DBSync and the paycheck
			ESX.StartDBSync()
			ESX.StartPayCheck()
	
			print('[ExtendedMode] [^2INFO^7] ExtendedMode has been initialized')
		else
			print('[ExtendedMode] [^1ERROR^7] ExtendedMode was unable to intialise the database and cannot continue, please see above for more information.')
		end
	end)
end)

RegisterServerEvent('esx:clientLog')
AddEventHandler('esx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[ExtendedMode] [^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('esx:triggerServerCallback')
AddEventHandler('esx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	ESX.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('esx:serverCallback', playerId, requestId, ...)
	end, ...)
end)
