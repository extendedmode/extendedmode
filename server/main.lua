AddEventHandler('es:playerLoaded', function(source, _player)
	local _source = source
	local tasks   = {}

	local userData = {
		accounts     = {},
		inventory    = {},
		job          = {},
		loadout      = {},
		playerName   = GetPlayerName(_source),
		weight		 = 0,
		lastPosition = nil
	}

	TriggerEvent('es:getPlayerFromId', _source, function(player)

		-- Update user name in DB
		table.insert(tasks, function(cb)
			MySQL.Async.execute('UPDATE `users` SET `name` = @name WHERE `identifier` = @identifier', {
				['@identifier'] = player.getIdentifier(),
				['@name']       = userData.playerName
			}, function(rowsChanged)
				cb()
			end)
		end)

		-- Get accounts
		table.insert(tasks, function(cb)
			MySQL.Async.fetchAll('SELECT * FROM `user_accounts` WHERE `identifier` = @identifier', {
				['@identifier'] = player.getIdentifier()
			}, function(accounts)

				for i=1, #Config.Accounts, 1 do
					for j=1, #accounts, 1 do
						if accounts[j].name == Config.Accounts[i] then
							table.insert(userData.accounts, {
								name  = accounts[j].name,
								money = accounts[j].money,
								label = Config.AccountLabels[accounts[j].name]
							})
						end
					end
				end

				cb()
			end)
		end)

		-- Get inventory
		table.insert(tasks, function(cb)

			MySQL.Async.fetchAll('SELECT * FROM `user_inventory` WHERE `identifier` = @identifier', {
				['@identifier'] = player.getIdentifier()
			}, function(inventory)

				local tasks2 = {}

				for i=1, #inventory, 1 do
					table.insert(userData.inventory, {
						name      = inventory[i].item,
						count     = inventory[i].count,
						label     = ESX.Items[inventory[i].item].label,
						limit     = ESX.Items[inventory[i].item].limit,
						usable    = ESX.UsableItemsCallbacks[inventory[i].item] ~= nil,
						rare      = ESX.Items[inventory[i].item].rare,
						weight	  = ESX.Items[inventory[i].item].weight or 0,
						canRemove = ESX.Items[inventory[i].item].canRemove
					})

					if inventory[i].count > 0 then userData.weight = userData.weight + (ESX.Items[inventory[i].item].weight * inventory[i].count) end
				end

				Async.parallelLimit(tasks2, 5, function(results) end)

				table.sort(userData.inventory, function(a,b)
					return a.label < b.label
				end)

				cb()
			end)

		end)

		-- Get job and loadout
		table.insert(tasks, function(cb)

			local tasks2 = {}

			-- Get job name, grade and last position
			table.insert(tasks2, function(cb2)

				MySQL.Async.fetchAll('SELECT job, job_grade, loadout, position FROM `users` WHERE `identifier` = @identifier', {
					['@identifier'] = player.getIdentifier()
				}, function(result)
					userData.job['name']  = result[1].job
					userData.job['grade'] = result[1].job_grade

					if result[1].loadout ~= nil then
						userData.loadout = json.decode(result[1].loadout)
					end

					if result[1].position ~= nil then
						userData.lastPosition = json.decode(result[1].position)
					end

					cb2()
				end)

			end)

			-- Get job label
			table.insert(tasks2, function(cb2)
				MySQL.Async.fetchAll('SELECT * FROM `jobs` WHERE `name` = @name', {
					['@name'] = userData.job.name
				}, function(result)
					userData.job['label'] = result[1].label
					cb2()
				end)
			end)

			-- Get job grade data
			table.insert(tasks2, function(cb2)

				MySQL.Async.fetchAll('SELECT * FROM `job_grades` WHERE `job_name` = @job_name AND `grade` = @grade',
				{
					['@job_name'] = userData.job.name,
					['@grade']    = userData.job.grade
				}, function(result)

					userData.job['grade_name']   = result[1].name
					userData.job['grade_label']  = result[1].label
					userData.job['grade_salary'] = result[1].salary

					userData.job['skin_male']   = {}
					userData.job['skin_female'] = {}

					if result[1].skin_male ~= nil then
						userData.job['skin_male'] = json.decode(result[1].skin_male)
					end

					if result[1].skin_female ~= nil then
						userData.job['skin_female'] = json.decode(result[1].skin_female)
					end

					cb2()
				end)

			end)

			Async.series(tasks2, cb)

		end)

		-- Run Tasks
		Async.parallel(tasks, function(results)

			local xPlayer = CreateExtendedPlayer(player, userData.accounts, userData.inventory, userData.job, userData.loadout, userData.playerName, userData.lastPosition, userData.weight)

			xPlayer.getMissingAccounts(function(missingAccounts)

				if #missingAccounts > 0 then

					for i=1, #missingAccounts, 1 do
						table.insert(xPlayer.accounts, {
							name  = missingAccounts[i],
							money = 0,
							label = Config.AccountLabels[missingAccounts[i]]
						})
					end

					xPlayer.createAccounts(missingAccounts)
				end

				ESX.Players[_source] = xPlayer

				TriggerEvent('esx:playerLoaded', _source, ESX.Players[_source])

				TriggerClientEvent('esx:playerLoaded', _source, {
					identifier   = xPlayer.identifier,
					accounts     = xPlayer.getAccounts(),
					inventory    = xPlayer.getInventory(),
					job          = xPlayer.getJob(),
					loadout      = xPlayer.getLoadout(),
					lastPosition = xPlayer.getLastPosition(),
					money        = xPlayer.get('money')
				})

				xPlayer.player.displayMoney(xPlayer.get('money'))

			end)

		end)

	end)

end)

AddEventHandler('playerDropped', function(reason)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if xPlayer ~= nil then
		TriggerEvent('esx:playerDropped', _source, reason)

		ESX.SavePlayer(xPlayer, function()
			ESX.Players[_source]        = nil
			ESX.LastPlayerData[_source] = nil
		end)
	end
end)

RegisterServerEvent('esx:updateLoadout')
AddEventHandler('esx:updateLoadout', function(loadout)
	local xPlayer   = ESX.GetPlayerFromId(source)
	xPlayer.loadout = loadout
end)

RegisterServerEvent('esx:updateLastPosition')
AddEventHandler('esx:updateLastPosition', function(position)
	local xPlayer        = ESX.GetPlayerFromId(source)
	xPlayer.lastPosition = position
end)

RegisterServerEvent('esx:giveInventoryItem')
AddEventHandler('esx:giveInventoryItem', function(target, type, itemName, itemCount)
	local _source = source

	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if type == 'item_standard' then

		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		local targetItem = targetXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and sourceItem.count >= itemCount then

			if targetItem.limit ~= -1 and (targetItem.count + itemCount) > targetItem.limit then
				TriggerClientEvent('esx:showNotification', _source, _U('ex_inv_lim', targetXPlayer.name))
			else
				sourceXPlayer.removeInventoryItem(itemName, itemCount)
				targetXPlayer.addInventoryItem   (itemName, itemCount)
				
				TriggerClientEvent('esx:showNotification', _source, _U('gave_item', itemCount, ESX.Items[itemName].label, targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target,  _U('received_item', itemCount, ESX.Items[itemName].label, sourceXPlayer.name))
			end

		else
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_quantity'))
		end

	elseif type == 'item_money' then

		if itemCount > 0 and sourceXPlayer.getMoney() >= itemCount then

			sourceXPlayer.removeMoney(itemCount)
			targetXPlayer.addMoney   (itemCount)

			TriggerClientEvent('esx:showNotification', _source, _U('gave_money', ESX.Math.GroupDigits(itemCount), targetXPlayer.name))
			TriggerClientEvent('esx:showNotification', target,  _U('received_money', ESX.Math.GroupDigits(itemCount), sourceXPlayer.name))

		else
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
		end

	elseif type == 'item_account' then

		if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then

			sourceXPlayer.removeAccountMoney(itemName, itemCount)
			targetXPlayer.addAccountMoney   (itemName, itemCount)

			TriggerClientEvent('esx:showNotification', _source, _U('gave_account_money', ESX.Math.GroupDigits(itemCount), Config.AccountLabels[itemName], targetXPlayer.name))
			TriggerClientEvent('esx:showNotification', target,  _U('received_account_money', ESX.Math.GroupDigits(itemCount), Config.AccountLabels[itemName], sourceXPlayer.name))

		else
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
		end

	elseif type == 'item_weapon' then

		if not targetXPlayer.hasWeapon(itemName) then

			sourceXPlayer.removeWeapon(itemName)
			targetXPlayer.addWeapon(itemName, itemCount)

			local weaponLabel = ESX.GetWeaponLabel(itemName)

			if itemCount > 0 then
				TriggerClientEvent('esx:showNotification', _source, _U('gave_weapon_ammo', weaponLabel, itemCount, targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target,  _U('received_weapon_ammo', weaponLabel, itemCount, sourceXPlayer.name))
			else
				TriggerClientEvent('esx:showNotification', _source, _U('gave_weapon', weaponLabel, targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target,  _U('received_weapon', weaponLabel, sourceXPlayer.name))
			end

		else
			TriggerClientEvent('esx:showNotification', _source, _U('gave_weapon_hasalready', targetXPlayer.name, weaponLabel))
			TriggerClientEvent('esx:showNotification', _source, _U('received_weapon_hasalready', sourceXPlayer.name, weaponLabel))
		end

	end

end)

RegisterServerEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(type, itemName, itemCount)
	local _source = source

	if type == 'item_standard' then

		if itemCount == nil or itemCount < 1 then
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_quantity'))
		else

			local xPlayer = ESX.GetPlayerFromId(source)
			local xItem = xPlayer.getInventoryItem(itemName)

			if (itemCount > xItem.count or xItem.count < 1) then
				TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_quantity'))
			else
				xPlayer.removeInventoryItem(itemName, itemCount)

				local pickupLabel = ('~y~%s~s~ [~b~%s~s~]'):format(xItem.label, itemCount)
				ESX.CreatePickup('item_standard', itemName, itemCount, pickupLabel, _source)
				TriggerClientEvent('esx:showNotification', _source, _U('threw_standard', itemCount, xItem.label))
			end

		end

	elseif type == 'item_money' then

		if itemCount == nil or itemCount < 1 then
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
		else

			local xPlayer = ESX.GetPlayerFromId(source)
			local playerCash = xPlayer.getMoney()

			if (itemCount > playerCash or playerCash < 1) then
				TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
			else
				xPlayer.removeMoney(itemCount)

				local pickupLabel = ('~y~%s~s~ [~g~%s~s~]'):format(_U('cash'), _U('locale_currency', ESX.Math.GroupDigits(itemCount)))
				ESX.CreatePickup('item_money', 'money', itemCount, pickupLabel, _source)
				TriggerClientEvent('esx:showNotification', _source, _U('threw_money', ESX.Math.GroupDigits(itemCount)))
			end

		end

	elseif type == 'item_account' then

		if itemCount == nil or itemCount < 1 then
			TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
		else

			local xPlayer = ESX.GetPlayerFromId(source)
			local account = xPlayer.getAccount(itemName)

			if (itemCount > account.money or account.money < 1) then
				TriggerClientEvent('esx:showNotification', _source, _U('imp_invalid_amount'))
			else
				xPlayer.removeAccountMoney(itemName, itemCount)

				local pickupLabel = ('~y~%s~s~ [~g~%s~s~]'):format(account.label, _U('locale_currency', ESX.Math.GroupDigits(itemCount)))
				ESX.CreatePickup('item_account', itemName, itemCount, pickupLabel, _source)
				TriggerClientEvent('esx:showNotification', _source, _U('threw_account', ESX.Math.GroupDigits(itemCount), string.lower(account.label)))
			end

		end

	elseif type == 'item_weapon' then

		local xPlayer = ESX.GetPlayerFromId(source)
		local loadout = xPlayer.getLoadout()

		for i=1, #loadout, 1 do
			if loadout[i].name == itemName then
				itemCount = loadout[i].ammo
				break
			end
		end

		if xPlayer.hasWeapon(itemName) then
			local weaponLabel, weaponPickup = ESX.GetWeaponLabel(itemName), 'PICKUP_' .. string.upper(itemName)

			xPlayer.removeWeapon(itemName)

			if itemCount > 0 then
				TriggerClientEvent('esx:pickupWeapon', _source, weaponPickup, itemName, itemCount)
				TriggerClientEvent('esx:showNotification', _source, _U('threw_weapon_ammo', weaponLabel, itemCount))
			else
				-- workaround for CreateAmbientPickup() giving 30 rounds of ammo when you drop the weapon with 0 ammo
				TriggerClientEvent('esx:pickupWeapon', _source, weaponPickup, itemName, 1)
				TriggerClientEvent('esx:showNotification', _source, _U('threw_weapon', weaponLabel))
			end
		end

	end

end)

RegisterServerEvent('esx:useItem')
AddEventHandler('esx:useItem', function(itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local count   = xPlayer.getInventoryItem(itemName).count

	if count > 0 then
		ESX.UseItem(source, itemName)
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('act_imp'))
	end
end)

RegisterServerEvent('esx:onPickup')
AddEventHandler('esx:onPickup', function(id)
	local _source = source
	local pickup  = ESX.Pickups[id]
	local xPlayer = ESX.GetPlayerFromId(_source)

	if pickup.type == 'item_standard' then

		local item      = xPlayer.getInventoryItem(pickup.name)
		local canTake   = ((item.limit == -1) and (pickup.count)) or ((item.limit - item.count > 0) and (item.limit - item.count)) or 0
		local total     = pickup.count < canTake and pickup.count or canTake
		local remaining = pickup.count - total

		TriggerClientEvent('esx:removePickup', -1, id)

		if total > 0 then
			xPlayer.addInventoryItem(pickup.name, total)
		end

		if remaining > 0 then
			TriggerClientEvent('esx:showNotification', _source, _U('cannot_pickup_room', item.label))

			local pickupLabel = ('~y~%s~s~ [~b~%s~s~]'):format(item.label, remaining)
			ESX.CreatePickup('item_standard', pickup.name, remaining, pickupLabel, _source)
		end

	elseif pickup.type == 'item_money' then
		TriggerClientEvent('esx:removePickup', -1, id)
		xPlayer.addMoney(pickup.count)
	elseif pickup.type == 'item_account' then
		TriggerClientEvent('esx:removePickup', -1, id)
		xPlayer.addAccountMoney(pickup.name, pickup.count)
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
		lastPosition = xPlayer.getLastPosition(),
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
		lastPosition = xPlayer.getLastPosition(),
		money        = xPlayer.getMoney()
	})
end)

-- ESX 1.2 compat stuff (would need some rewrite as this handler kind of sucks)
ESX.RegisterCommand = function(name, group, cb, allowConsole, suggestion)
	if type(name) == 'table' then
		for k,v in ipairs(name) do
			ESX.RegisterCommand(v, group, cb, allowConsole, suggestion)
		end

		return
	end

	if ESX.RegisteredCommands[name] then
		print(('[es_extended] [^3WARNING^7] An command "%s" is already registered'):format(name))
	else
		if suggestion then
			if not suggestion.arguments then suggestion.arguments = {} end
			if not suggestion.help then suggestion.help = '' end
		end

		ESX.RegisteredCommands[name] = {group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion}

		RegisterCommand(name, function(playerId, args, rawCommand)
			local command = ESX.RegisteredCommands[name]

			if not command.allowConsole and playerId == 0 then
				print('[es_extended] [^3WARNING^7] That command can not be run from console')
			else
				local xPlayer, error = ESX.GetPlayerFromId(playerId), nil

				if command.suggestion then
					if command.suggestion.validate then
						if #args ~= #command.suggestion.arguments then
							error = ('Argument count mismatch (passed %s, wanted %s)'):format(#args, #command.suggestion.arguments)
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
										error = ('Argument #%s type mismatch (passed string, wanted number)'):format(k)
									end
								elseif v.type == 'player' then
									local targetPlayer = tonumber(args[k])

									if targetPlayer then
										local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)

										if xTargetPlayer then
											newArgs[v.name] = xTargetPlayer
										else
											error = 'Player not online'
										end
									else
										error = ('Argument #%s type mismatch (passed string, wanted number)'):format(k)
									end
								elseif v.type == 'string' then
									newArgs[v.name] = args[k]
								elseif v.type == 'item' then
									if ESX.Items[args[k]] then
										newArgs[v.name] = args[k]
									else
										error = _U('invalid_item')
									end
								elseif v.type == 'weapon' then
									if ESX.GetWeapon(args[k]) then
										newArgs[v.name] = string.upper(args[k])
									else
										error = 'Invalid weapon'
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
						print(('[es_extended] [^3WARNING^7] %s^7'):format(error))
					else
						xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', error}})
					end
				else
					cb(xPlayer, args, function(msg)
						if playerId == 0 then
							print(('[es_extended] [^3WARNING^7] %s^7'):format(msg))
						else
							xPlayer.triggerEvent('chat:addMessage', {args = {'^1SYSTEM', msg}})
						end
					end)
				end
			end
		end, true)

		ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
	end
end

TriggerEvent("es:addGroup", "jobmaster", "user", function(group) end)

ESX.StartDBSync()
ESX.StartPayCheck()
