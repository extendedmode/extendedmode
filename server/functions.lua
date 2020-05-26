ESX.Trace = function(msg)
	if Config.EnableDebug then
		print(('[ExtendedMode] [^2TRACE^7] %s^7'):format(msg))
	end
end

ESX.SetTimeout = function(msec, cb)
	local id = ESX.TimeoutCount + 1

	SetTimeout(msec, function()
		if ESX.CancelledTimeouts[id] then
			ESX.CancelledTimeouts[id] = nil
		else
			cb()
		end
	end)

	ESX.TimeoutCount = id

	return id
end

ESX.RegisterCommand = function(name, group, cb, allowConsole, suggestion)
	if type(name) == 'table' then
		for k,v in ipairs(name) do
			ESX.RegisterCommand(v, group, cb, allowConsole, suggestion)
		end

		return
	end

	if ESX.RegisteredCommands[name] then
		print(('[ExtendedMode] [^3WARNING^7] An command "%s" is already registered, overriding command'):format(name))

		if ESX.RegisteredCommands[name].suggestion then
			TriggerClientEvent('chat:removeSuggestion', -1, ('/%s'):format(name))
		end
	end

	if suggestion then
		if not suggestion.arguments then suggestion.arguments = {} end
		if not suggestion.help then suggestion.help = '' end

		TriggerClientEvent('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
	end

	ESX.RegisteredCommands[name] = {group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion}

	RegisterCommand(name, function(playerId, args, rawCommand)
		local command = ESX.RegisteredCommands[name]

		if not command.allowConsole and playerId == 0 then
			print(('[ExtendedMode] [^3WARNING^7] %s'):format(_U('commanderror_console')))
		else
			local xPlayer, error = ESX.GetPlayerFromId(playerId), nil

			if command.suggestion then
				if command.suggestion.validate then
					if #args ~= #command.suggestion.arguments then
						error = _U('commanderror_argumentmismatch', #args, #command.suggestion.arguments)
					end
				end

				if not error and command.suggestion.arguments then
					local newArgs = {}

					for k,v in ipairs(command.suggestion.arguments) do
						if v.type then
							if v.type == 'number' then
								local newArg = tonumber(args[k])

								if newArg then
									newArgs[v.name] = newArg
								else
									error = _U('commanderror_argumentmismatch_number', k)
								end
							elseif v.type == 'player' or v.type == 'playerId' then
								local targetPlayer = tonumber(args[k])

								if args[k] == 'me' then targetPlayer = playerId end

								if targetPlayer then
									local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)

									if xTargetPlayer then
										if v.type == 'player' then
											newArgs[v.name] = xTargetPlayer
										else
											newArgs[v.name] = targetPlayer
										end
									else
										error = _U('commanderror_invalidplayerid')
									end
								else
									error = _U('commanderror_argumentmismatch_number', k)
								end
							elseif v.type == 'string' then
								newArgs[v.name] = args[k]
							elseif v.type == 'item' then
								if ESX.Items[args[k]] then
									newArgs[v.name] = args[k]
								else
									error = _U('commanderror_invaliditem')
								end
							elseif v.type == 'weapon' then
								if ESX.GetWeapon(args[k]) then
									newArgs[v.name] = string.upper(args[k])
								else
									error = _U('commanderror_invalidweapon')
								end
							elseif v.type == 'any' then
								newArgs[v.name] = args[k]
							end
						end

						if error then break end
					end

					args = newArgs
				end
			end

			if error then
				if playerId == 0 then
					print(('[ExtendedMode] [^3WARNING^7] %s^7'):format(error))
				else
					xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', error}})
				end
			else
				cb(xPlayer or false, args, function(msg)
					if playerId == 0 then
						print(('[ExtendedMode] [^3WARNING^7] %s^7'):format(msg))
					else
						xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', msg}})
					end
				end)
			end
		end
	end, true)

	if type(group) == 'table' then
		for k,v in ipairs(group) do
			ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
		end
	else
		ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
	end
end

ESX.ClearTimeout = function(id)
	ESX.CancelledTimeouts[id] = true
end

ESX.RegisterServerCallback = function(name, cb)
	ESX.ServerCallbacks[name] = cb
end

ESX.TriggerServerCallback = function(name, requestId, source, cb, ...)
	if ESX.ServerCallbacks[name] then
		ESX.ServerCallbacks[name](source, cb, ...)
	else
		print(('[ExtendedMode] [^3WARNING^7] Server callback "%s" does not exist. Make sure that the server sided file really is loading, an error in that file might cause it to not load.'):format(name))
	end
end

ESX.SavePlayer = function(xPlayer, cb)
	if ExM.DatabaseType == "es+esx" then
		-- Nothing yet ;)
	elseif ExM.DatabaseType == "newesx" then
		MySQL.Async.execute('UPDATE users SET accounts = @accounts, job = @job, job_grade = @job_grade, `group` = @group, loadout = @loadout, position = @position, inventory = @inventory WHERE identifier = @identifier', {
			['@accounts'] = json.encode(xPlayer.getAccounts(true)),
			['@job'] = xPlayer.job.name,
			['@job_grade'] = xPlayer.job.grade,
			['@group'] = xPlayer.getGroup(),
			['@loadout'] = json.encode(xPlayer.getLoadout(true)),
			['@position'] = json.encode(xPlayer.getCoords()),
			['@identifier'] = xPlayer.getIdentifier(),
			['@inventory'] = json.encode(xPlayer.getInventory(true))
		}, cb)
	end
end

ESX.SavePlayers = function(finishedCB)
	CreateThread(function()
		local savedPlayers = 0
		local playersToSave = #ESX.Players
		local maxTimeout = 20000
		local currentTimeout = 0
	
		-- Save Each player
		for _, xPlayer in ipairs(ESX.Players) do
			ESX.SavePlayer(xPlayer, function(rowsChanged)
				if rowsChanged == 1 then
					savedPlayers = savedPlayers	+ 1
				end
			end)
		end

		-- Call the callback when done
		while true do
			Citizen.Wait(500)
			currentTimeout = currentTimeout + 500
			if playersToSave == savedPlayers then
				finishedCB(true)
				break
			elseif currentTimeout >= maxTimeout then
				finishedCB(false)
				break
			end
		end
	end)
end

ESX.StartDBSync = function()
	function saveData()
		ESX.SavePlayers(function(result)
			if result then
				print('[ExtendedMode] [^2INFO^7] Automatically saved all player data')
			else
				print('[ExtendedMode] [^3WARNING^7] Failed to automatically save player data! This may be caused by an internal error on the MySQL server.')
			end
		end)
		SetTimeout(10 * 60 * 1000, saveData)
	end

	SetTimeout(10 * 60 * 1000, saveData)
end

ESX.GetPlayers = function()
	local sources = {}

	for k,v in pairs(ESX.Players) do
		table.insert(sources, k)
	end

	return sources
end

ESX.GetPlayerFromId = function(source)
	return ESX.Players[tonumber(source)]
end

ESX.GetPlayerFromIdentifier = function(identifier)
	for k,v in pairs(ESX.Players) do
		if v.identifier == identifier then
			return v
		end
	end
end

ESX.RegisterUsableItem = function(item, cb)
	ESX.UsableItemsCallbacks[item] = cb
end

ESX.UseItem = function(source, item)
	ESX.UsableItemsCallbacks[item](source)
end

ESX.GetItemLabel = function(item)
	if ESX.Items[item] then
		return ESX.Items[item].label
	end
end

ESX.CreatePickup = function(type, name, count, label, playerId, components, tintIndex)
    local pickupId = (ESX.PickupId == 65635 and 0 or ESX.PickupId + 1)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local pedCoords
    
    if ExM.IsInfinity then
        pedCoords = GetEntityCoords(GetPlayerPed(playerId))
    end

    ESX.Pickups[pickupId] = {
        type  = type,
        name  = name,
        count = count,
        label = label,
        coords = xPlayer.getCoords(),
    }

    if type == 'item_weapon' then
        ESX.Pickups[pickupId].components = components
        ESX.Pickups[pickupId].tintIndex = tintIndex
    end

    TriggerClientEvent('esx:createPickup', -1, pickupId, label, playerId, type, name, components, tintIndex, ExM.IsInfinity, pedCoords)
    ESX.PickupId = pickupId
end

ESX.DoesJobExist = function(job, grade)
	grade = tostring(grade)

	if job and grade then
		if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end

if ExM.IsOneSync then
	ExM.Game = {}

	ExM.Game.SpawnVehicle = function(model, coords)
		local vector = type(coords) == "vector4" and coords or type(coords) == "vector3" and vector4(coords, 0.0)
		return CreateVehicle(model, vector.xyzw, true, false)
	end

	ExM.Game.CreatePed = function(pedModel, pedCoords, pedType)
		local vector = type(pedCoords) == "vector4" and pedCoords or type(pedCoords) == "vector3" and vector4(pedCoords, 0.0)
		pedType = pedType ~= nil and pedType or 4
		return CreatePed(pedType, pedModel, vector.xyzw, true)
	end

	ExM.Game.SpawnObject = function(model, coords, dynamic)
		model = type(model) == 'number' and model or GetHashKey(model)
		dynamic = dynamic ~= nil and true or false
		return CreateObjectNoOffset(model, coords.xyz, true, dynamic)
	end
end