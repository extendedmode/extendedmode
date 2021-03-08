RegisterNetEvent('esx:onPlayerJoined')
AddEventHandler('esx:onPlayerJoined', function()
	if not ESX.Players[source] then
		onPlayerJoined(source)
	end
end)

function onPlayerJoined(playerId)
	local identifier
	local license
	
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, Config.PrimaryIdentifier) then
			identifier = v
		end
		if string.match(v, 'license:') then
			license = v
		end
	end

	if identifier then
		if ESX.GetPlayerFromIdentifier(identifier) then
			DropPlayer(playerId, ('there was an error loading your character!\nError code: identifier-active-ingame\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same Rockstar account.\n\nYour Rockstar identifier: %s'):format(identifier))
		else
			exports.ghmattimysql:scalar('SELECT 1 FROM users WHERE identifier = @identifier', {
				['@identifier'] = identifier
			}, function(result)
				if result then
					loadESXPlayer(identifier, playerId)
				else
					local accounts = {}

					for account,money in pairs(Config.StartingAccountMoney) do
						accounts[account] = money
					end

					exports.ghmattimysql:execute('INSERT INTO users (accounts, identifier, license) VALUES (@accounts, @identifier, @license)', {
						['@accounts'] = json.encode(accounts),
						['@identifier'] = identifier,
						['@license'] = license,						
					}, function(rowsChanged)
						loadESXPlayer(identifier, playerId)
					end)
				end
			end)
		end
	else
		DropPlayer(playerId, 'there was an error loading your character!\nError code: identifier-missing-ingame\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.')
	end
end

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
	deferrals.defer()
	local playerId, identifier = source
	Wait(100)

	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, Config.PrimaryIdentifier) then
			identifier = v
			break
		end
	end

	if not ExM.DatabaseReady then
		deferrals.update("The database is not initialized, please wait...")
		while not ExM.DatabaseReady do
			Wait(1000)
		end
	end

	if identifier then
		if ESX.GetPlayerFromIdentifier(identifier) then
			deferrals.done(('There was an error loading your character!\nError code: identifier-active\n\nThis error is caused by a player on this server who has the same identifier as you have. Make sure you are not playing on the same Rockstar account.\n\nYour Rockstar identifier: %s'):format(identifier))
		else
			deferrals.done()
		end
	else
		deferrals.done('There was an error loading your character!\nError code: identifier-missing\n\nThe cause of this error is not known, your identifier could not be found. Please come back later or report this problem to the server administration team.')
	end
end)


function loadESXPlayer(identifier, playerId)
	-- TODO: Implement other loading methods
	
	local userData = {
		accounts = {},
		inventory = {},
		job = {},
		loadout = {},
		playerName = GetPlayerName(playerId),
		weight = 0
	}

	exports.ghmattimysql:execute('SELECT accounts, job, job_grade, `group`, loadout, position, inventory FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		local job, grade, jobObject, gradeObject = result[1].job, tostring(result[1].job_grade)
		local foundAccounts, foundItems = {}, {}

		-- Accounts
		if result[1].accounts and result[1].accounts ~= '' then
			local accounts = json.decode(result[1].accounts)

			for account,money in pairs(accounts) do
				foundAccounts[account] = money
			end
		end

		for account,label in pairs(Config.Accounts) do
			table.insert(userData.accounts, {
				name = account,
				money = foundAccounts[account] or Config.StartingAccountMoney[account] or 0,
				label = label
			})
		end

		-- Job
		if ESX.DoesJobExist(job, grade) then
			jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]
		else
			print(('[ExtendedMode] [^3WARNING^7] Ignoring invalid job for %s [job: %s, grade: %s]'):format(identifier, job, grade))
			job, grade = 'unemployed', '0'
			jobObject, gradeObject = ESX.Jobs[job], ESX.Jobs[job].grades[grade]
		end

		userData.job.id = jobObject.id
		userData.job.name = jobObject.name
		userData.job.label = jobObject.label

		userData.job.grade = tonumber(grade)
		userData.job.grade_name = gradeObject.name
		userData.job.grade_label = gradeObject.label
		userData.job.grade_salary = gradeObject.salary

		userData.job.skin_male = {}
		userData.job.skin_female = {}

		if gradeObject.skin_male then userData.job.skin_male = json.decode(gradeObject.skin_male) end
		if gradeObject.skin_female then userData.job.skin_female = json.decode(gradeObject.skin_female) end

		-- Inventory (hsn-inventory)
		if result[1].inventory and result[1].inventory ~= '' then
			userData.inventory = json.decode(result[1].inventory)
		end

		-- Group
		if result[1].group then
			userData.group = result[1].group
		else
			userData.group = 'user'
		end

		-- Loadout
		if result[1].loadout and result[1].loadout ~= '' then
			local loadout = json.decode(result[1].loadout)

			for name,weapon in pairs(loadout) do
				local label = ESX.GetWeaponLabel(name)

				if label then
					if not weapon.components then weapon.components = {} end
					if not weapon.tintIndex then weapon.tintIndex = 0 end

					table.insert(userData.loadout, {
						name = name,
						ammo = weapon.ammo,
						label = label,
						components = weapon.components,
						tintIndex = weapon.tintIndex
					})
				end
			end
		end

		-- Position
		if result[1].position and result[1].position ~= '' then
			userData.coords = json.decode(result[1].position)
		else
			print('[ExtendedMode] [^3WARNING^7] Column "position" in "users" table is missing required default value. Using backup coords, fix your database.')
			userData.coords = Config.FirstSpawnCoords
		end

		-- Create Extended Player Object
		local xPlayer = CreateExtendedPlayer(playerId, identifier, userData.group, userData.accounts, userData.inventory, userData.weight, userData.job, userData.loadout, userData.playerName, userData.coords)
		ESX.Players[playerId] = xPlayer
		TriggerEvent('esx:playerLoaded', playerId, xPlayer)
		TriggerEvent('hsn-inventory:setplayerInventory', xPlayer.identifier, xPlayer.inventory)
		xPlayer.triggerEvent('esx:playerLoaded', {
			accounts = xPlayer.getAccounts(),
			coords = xPlayer.getCoords(),
			identifier = xPlayer.getIdentifier(),
			inventory = xPlayer.getInventory(),
			job = xPlayer.getJob(),
			loadout = xPlayer.getLoadout(),
			maxWeight = xPlayer.maxWeight,
			money = xPlayer.getMoney()
		})

		xPlayer.triggerEvent('esx:registerSuggestions', ESX.RegisteredCommands)
	end)
end

AddEventHandler('playerDropped', function(reason)
	local playerId = source
	local xPlayer = ESX.GetPlayerFromId(playerId)

	if xPlayer then
		TriggerEvent('esx:playerDropped', playerId, reason)

		ESX.SavePlayer(xPlayer, function()
			ESX.Players[playerId] = nil
		end)
	end
end)

RegisterNetEvent('esx:updateCoords')
AddEventHandler('esx:updateCoords', function(coords)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer then
		xPlayer.updateCoords(coords)
	end
end)

RegisterNetEvent('esx:useItem')
AddEventHandler('esx:useItem', function(source, itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local item = xPlayer.getInventoryItem(itemName)
	if item.count > 0 then
		if item.closeonuse then TriggerClientEvent("hsn-inventory:client:closeInventory", source) end
		ESX.UseItem(source, itemName)
	end
end)

ESX.RegisterServerCallback('esx:getPlayerData', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	cb({
		identifier   = xPlayer.identifier,
		accounts     = xPlayer.getAccounts(),
		inventory    = xPlayer.getInventory(),
		job          = xPlayer.getJob(),
		loadout      = xPlayer.getLoadout(),
		money        = xPlayer.getMoney()
	})
end)

ESX.RegisterServerCallback('esx:getOtherPlayerData', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)

	cb({
		identifier   = xPlayer.identifier,
		accounts     = xPlayer.getAccounts(),
		inventory    = xPlayer.getInventory(),
		job          = xPlayer.getJob(),
		loadout      = xPlayer.getLoadout(),
		money        = xPlayer.getMoney()
	})
end)

ESX.RegisterServerCallback('esx:getPlayerNames', function(source, cb, players)
	players[source] = nil

	for playerId,v in pairs(players) do
		local xPlayer = ESX.GetPlayerFromId(playerId)

		if xPlayer then
			players[playerId] = xPlayer.getName()
		else
			players[playerId] = nil
		end
	end

	cb(players)
end)

-- Add support for EssentialMode >6.4.x
AddEventHandler("es:setMoney", function(user, value) ESX.GetPlayerFromId(user).setMoney(value, true) end)
AddEventHandler("es:addMoney", function(user, value) ESX.GetPlayerFromId(user).addMoney(value, true) end)
AddEventHandler("es:removeMoney", function(user, value) ESX.GetPlayerFromId(user).removeMoney(value, true) end)
AddEventHandler("es:set", function(user, key, value) ESX.GetPlayerFromId(user).set(key, value, true) end)

AddEventHandler("es_db:doesUserExist", function(identifier, cb)
	cb(true)
end)

AddEventHandler('es_db:retrieveUser', function(identifier, cb, tries)
	tries = tries or 0

	if(tries < 500)then
		tries = tries + 1
		local player = ESX.GetPlayerFromIdentifier(identifier)

		if player then
			cb({permission_level = 0, money = player.getMoney(), bank = 0, identifier = player.identifier, license = player.get("license"), group = player.group, roles = ""}, false, true)
		else
			Citizen.SetTimeout(100, function()
				TriggerEvent("es_db:retrieveUser", identifier, cb, tries)
			end)
		end
	end
end)
