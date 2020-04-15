local isLoadoutLoaded, isPaused, isDead, isFirstSpawn, pickups = false, false, false, true, {}

CreateThread(function()
	while true do
		Wait(0)

		if NetworkIsPlayerActive(PlayerId()) then
			TriggerServerEvent('esx:onPlayerJoined')
			break
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	ESX.PlayerLoaded = true
	ESX.PlayerData = playerData
	
	-- Removed some unnecessary statement here checking if you were Michael, it did nothing really.
	-- Was also kind of broken because anyone who has a SP save no using Michael wouldn't even get it.

	local playerPed = PlayerPedId()

	if Config.EnablePvP then
		SetCanAttackFriendly(playerPed, true, false)
		NetworkSetFriendlyFireOption(true)
	end

	if Config.EnableHud then
		for k,v in ipairs(playerData.accounts) do
			local accountTpl = '<div><img src="img/accounts/' .. v.name .. '.png"/>&nbsp;{{money}}</div>'
			ESX.UI.HUD.RegisterElement('account_' .. v.name, k, 0, accountTpl, {money = ESX.Math.GroupDigits(v.money)})
		end

		local jobTpl = '<div>{{job_label}} - {{grade_label}}</div>'

		if playerData.job.grade_label == '' or playerData.job.grade_label == playerData.job.label then
			jobTpl = '<div>{{job_label}}</div>'
		end

		ESX.UI.HUD.RegisterElement('job', #playerData.accounts, 0, jobTpl, {
			job_label = playerData.job.label,
			grade_label = playerData.job.grade_label
		})
	end

	-- Using spawnmanager now to spawn the player, this is the right way to do it, and it transitions better.
	exports.spawnmanager:spawnPlayer({
		x = playerData.coords.x,
		y = playerData.coords.y,
		z = playerData.coords.z,
		heading = playerData.coords.heading,
		model = Config.DefaultPlayerModel,
		skipFade = false
	}, function()
		isLoadoutLoaded = true
		TriggerServerEvent('esx:onPlayerSpawn')
		TriggerEvent('esx:onPlayerSpawn')
		TriggerEvent('esx:restoreLoadout')
	end)
end)

RegisterNetEvent('esx:setMaxWeight')
AddEventHandler('esx:setMaxWeight', function(newMaxWeight) ESX.PlayerData.maxWeight = newMaxWeight end)

AddEventHandler('esx:onPlayerSpawn', function() isDead = false end)
AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('skinchanger:loadDefaultModel', function() isLoadoutLoaded = false end)

AddEventHandler('skinchanger:modelLoaded', function()
	while not ESX.PlayerLoaded do
		Wait(100)
	end

	TriggerEvent('esx:restoreLoadout')
end)

AddEventHandler('esx:restoreLoadout', function()
	local playerPed = PlayerPedId()
	local ammoTypes = {}

	RemoveAllPedWeapons(playerPed, true)

	for k,v in ipairs(ESX.PlayerData.loadout) do
		local weaponName = v.name

		GiveWeaponToPed(playerPed, weaponName, 0, false, false)
		SetPedWeaponTintIndex(playerPed, weaponName, v.tintIndex)

		local ammoType = GetPedAmmoTypeFromWeapon(playerPed, weaponName)

		for k2,v2 in ipairs(v.components) do
			local componentHash = ESX.GetWeaponComponent(weaponName, v2).hash

			GiveWeaponComponentToPed(playerPed, weaponName, componentHash)
		end

		if not ammoTypes[ammoType] then
			AddAmmoToPed(playerPed, weaponName, v.ammo)
			ammoTypes[ammoType] = true
		end
	end

	isLoadoutLoaded = true
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for k,v in ipairs(ESX.PlayerData.accounts) do
		if v.name == account.name then
			ESX.PlayerData.accounts[k] = account
			break
		end
	end

	if Config.EnableHud then
		ESX.UI.HUD.UpdateElement('account_' .. account.name, {
			money = ESX.Math.GroupDigits(account.money)
		})
	end
end)

RegisterNetEvent('esx:addInventoryItem')
AddEventHandler('esx:addInventoryItem', function(item, count, showNotification)
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == item then
			ESX.UI.ShowInventoryItemNotification(true, v.label, count - v.count)
			ESX.PlayerData.inventory[k].count = count
			break
		end
	end

	if showNotification then
		ESX.UI.ShowInventoryItemNotification(true, item, count)
	end

	if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

RegisterNetEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(item, count, showNotification)
	for k,v in ipairs(ESX.PlayerData.inventory) do
		if v.name == item then
			ESX.UI.ShowInventoryItemNotification(false, v.label, v.count - count)
			ESX.PlayerData.inventory[k].count = count
			break
		end
	end

	if showNotification then
		ESX.UI.ShowInventoryItemNotification(false, item, count)
	end

	if ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
		ESX.ShowInventory()
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:addWeapon')
AddEventHandler('esx:addWeapon', function(weaponName, ammo)
	-- Removed PlayerPedId() from being stored in a variable, not needed
	-- when it's only being used once, also doing it in a few
	-- functions below this one
	GiveWeaponToPed(PlayerPedId(), weaponName, ammo, false, false)
end)

RegisterNetEvent('esx:addWeaponComponent')
AddEventHandler('esx:addWeaponComponent', function(weaponName, weaponComponent)
	local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash
	GiveWeaponComponentToPed(PlayerPedId(), weaponName, componentHash)
end)

RegisterNetEvent('esx:setWeaponAmmo')
AddEventHandler('esx:setWeaponAmmo', function(weaponName, weaponAmmo)
	SetPedAmmo(PlayerPedId(), weaponName, weaponAmmo)
end)

RegisterNetEvent('esx:setWeaponTint')
AddEventHandler('esx:setWeaponTint', function(weaponName, weaponTintIndex)
	SetPedWeaponTintIndex(PlayerPedId(), weaponName, weaponTintIndex)
end)

RegisterNetEvent('esx:removeWeapon')
AddEventHandler('esx:removeWeapon', function(weaponName)
	local playerPed = PlayerPedId()
	RemoveWeaponFromPed(playerPed, weaponName)
	SetPedAmmo(playerPed, weaponName, 0) -- remove leftover ammo
end)

RegisterNetEvent('esx:removeWeaponComponent')
AddEventHandler('esx:removeWeaponComponent', function(weaponName, weaponComponent)
	local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash
	RemoveWeaponComponentFromPed(PlayerPedId(), weaponName, componentHash)
end)

RegisterNetEvent('esx:teleport')
AddEventHandler('esx:teleport', function(coords)
	-- The coords x, y and z were having 0.0 added to them here to make them floats
	-- Since we are forcing vectors in the teleport function now we don't need to do it
	ESX.Game.Teleport(PlayerPedId(), coords)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	if Config.EnableHud then
		ESX.UI.HUD.UpdateElement('job', {
			job_label   = job.label,
			grade_label = job.grade_label
		})
	end
end)

RegisterNetEvent('esx:spawnVehicle')
AddEventHandler('esx:spawnVehicle', function(vehicle)
	if IsModelInCdimage(vehicle) then
		local playerPed = PlayerPedId()
		local playerCoords, playerHeading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)

		ESX.Game.SpawnVehicle(vehicle, playerCoords, playerHeading, function(vehicle)
			TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		end)
	else
		TriggerEvent('chat:addMessage', { args = { '^1SYSTEM', 'Invalid vehicle model.' } })
	end
end)

RegisterNetEvent('esx:createPickup')
AddEventHandler('esx:createPickup', function(pickupId, label, playerId, type, name, components, tintIndex)
	local playerPed = GetPlayerPed(GetPlayerFromServerId(playerId))
	local entityCoords, forward, pickupObject = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
	local objectCoords = (entityCoords + forward * 1.0)

	if type == 'item_weapon' then
		ESX.Streaming.RequestWeaponAsset(GetHashKey(name))
		pickupObject = CreateWeaponObject(GetHashKey(name), 50, objectCoords, true, 1.0, 0)
		SetWeaponObjectTintIndex(pickupObject, tintIndex)

		for k,v in ipairs(components) do
			local component = ESX.GetWeaponComponent(name, v)
			GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
		end
	else
		ESX.Game.SpawnLocalObject('prop_money_bag_01', objectCoords, function(obj)
			pickupObject = obj
		end)

		while not pickupObject do
			Wait(10)
		end
	end

	SetEntityAsMissionEntity(pickupObject, true, false)
	PlaceObjectOnGroundProperly(pickupObject)
	FreezeEntityPosition(pickupObject, true)
	-- Remove the pickup collisions, also done the same in the local one below
	SetEntityCollision(pickupObject, false, true)

	pickups[pickupId] = {
		id = pickupId,
		obj = pickupObject,
		label = label,
		inRange = false,
		coords = objectCoords
	}
end)

RegisterNetEvent('esx:createMissingPickups')
AddEventHandler('esx:createMissingPickups', function(missingPickups)
	for pickupId,pickup in pairs(missingPickups) do
		local pickupObject = nil

		if pickup.type == 'item_weapon' then
			ESX.Streaming.RequestWeaponAsset(GetHashKey(pickup.name))
			pickupObject = CreateWeaponObject(GetHashKey(pickup.name), 50, pickup.coords.x, pickup.coords.y, pickup.coords.z, true, 1.0, 0)
			SetWeaponObjectTintIndex(pickupObject, pickup.tintIndex)

			for k,componentName in ipairs(pickup.components) do
				local component = ESX.GetWeaponComponent(pickup.name, componentName)
				GiveWeaponComponentToWeaponObject(pickupObject, component.hash)
			end
		else
			ESX.Game.SpawnLocalObject('prop_money_bag_01', pickup.coords, function(obj)
				pickupObject = obj
			end)

			while not pickupObject do
				Wait(10)
			end
		end

		SetEntityAsMissionEntity(pickupObject, true, false)
		PlaceObjectOnGroundProperly(pickupObject)
		FreezeEntityPosition(pickupObject, true)
		SetEntityCollision(pickupObject, false, true)

		pickups[pickupId] = {
			id = pickupId,
			obj = pickupObject,
			label = pickup.label,
			inRange = false,
			coords = vector3(pickup.coords.x, pickup.coords.y, pickup.coords.z)
		}
	end
end)

RegisterNetEvent('esx:registerSuggestions')
AddEventHandler('esx:registerSuggestions', function(registeredCommands)
	for name,command in pairs(registeredCommands) do
		if command.suggestion then
			TriggerEvent('chat:addSuggestion', ('/%s'):format(name), command.suggestion.help, command.suggestion.arguments)
		end
	end
end)

RegisterNetEvent('esx:removePickup')
AddEventHandler('esx:removePickup', function(id)
	if pickups[id] and pickups[id].obj then
		ESX.Game.DeleteObject(pickups[id].obj)
		pickups[id] = nil
	end
end)

RegisterNetEvent('esx:deleteVehicle')
AddEventHandler('esx:deleteVehicle', function(radius)
	local playerPed = PlayerPedId()

	if radius and tonumber(radius) then
		radius = tonumber(radius) + 0.01
		local vehicles = ESX.Game.GetVehiclesInArea(GetEntityCoords(playerPed), radius)

		for k,entity in ipairs(vehicles) do
			local attempt = 0

			while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
				Wait(100)
				NetworkRequestControlOfEntity(entity)
				attempt = attempt + 1
			end

			if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
				ESX.Game.DeleteVehicle(entity)
			end
		end
	else
		local vehicle, attempt = ESX.Game.GetVehicleInDirection(), 0

		if IsPedInAnyVehicle(playerPed, true) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		end

		while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
			Wait(100)
			NetworkRequestControlOfEntity(vehicle)
			attempt = attempt + 1
		end

		if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
			ESX.Game.DeleteVehicle(vehicle)
		end
	end
end)

-- Pause menu disables HUD display
if Config.EnableHud then
	CreateThread(function()
		while true do
			Wait(300)

			if IsPauseMenuActive() and not isPaused then
				isPaused = true
				ESX.UI.HUD.SetDisplay(0.0)
			elseif not IsPauseMenuActive() and isPaused then
				isPaused = false
				ESX.UI.HUD.SetDisplay(1.0)
			end
		end
	end)
end

-- Keep track of ammo usage
CreateThread(function()
	while true do
		Wait(0)

		if isDead then
			Wait(500)
		else
			local playerPed = PlayerPedId()

			if IsPedShooting(playerPed) then
				local _, weaponHash = GetCurrentPedWeapon(playerPed, true)
				local weapon = ESX.GetWeaponFromHash(weaponHash)

				if weapon then
					local ammoCount = GetAmmoInPedWeapon(playerPed, weaponHash)
					TriggerServerEvent('esx:updateWeaponAmmo', weapon.name, ammoCount)
				end
			end
		end
	end
end)

CreateThread(function()
	while true do
		Wait(0)

		if IsControlJustReleased(0, 289) then
			if IsInputDisabled(0) and not isDead and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
				ESX.ShowInventory()
			end
		end
	end
end)

-- Disable wanted level
if Config.DisableWantedLevel then
	-- Previous they were creating a contstantly running loop to check if the wanted level
	-- changed and then setting back to 0. This is all thats needed to disable a wanted level.
	SetMaxWantedLevel(0)
end

-- Pickups
CreateThread(function()
	while true do
		Wait(0)
		local playerPed = PlayerPedId()
		local playerCoords, letSleep = GetEntityCoords(playerPed), true
		-- For whatever reason there was a constant check to get the closest player here when it
		-- wasn't even being used

		for k,v in pairs(pickups) do
			local distance = #(playerCoords - v.coords)

			if distance < 5 then
				local label = v.label
				letSleep = false

				if distance < 1 then
					if IsControlJustReleased(0, 38) then
						-- Removed the closestDistance check here, not needed
						if IsPedOnFoot(playerPed) and not v.inRange then
							v.inRange = true

							local dict, anim = 'weapons@first_person@aim_rng@generic@projectile@sticky_bomb@', 'plant_floor'
							ESX.Streaming.RequestAnimDict(dict)
							TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
							Wait(1000)

							TriggerServerEvent('esx:onPickup', v.id)
							PlaySoundFrontend(-1, 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET', false)
						end
					end

					label = ('%s~n~%s'):format(label, _U('threw_pickup_prompt'))
				end

				ESX.Game.Utils.DrawText3D(vec(v.coords.x, v.coords.y, v.coords.z + 0.25), label, 1.2, 1)
			elseif v.inRange then
				v.inRange = false
			end
		end

		if letSleep then
			Wait(500)
		end
	end
end)

-- Update current player coords
CreateThread(function()
	-- wait for player to restore coords
	while not isLoadoutLoaded do
		Wait(1000)
	end
	
	local previousCoords = vector3(ESX.PlayerData.coords.x, ESX.PlayerData.coords.y, ESX.PlayerData.coords.z)
	local playerHeading = ESX.PlayerData.heading
	local formattedCoords = {x = ESX.Math.Round(previousCoords.x, 1), y = ESX.Math.Round(previousCoords.y, 1), z = ESX.Math.Round(previousCoords.z, 1), heading = playerHeading}

	while true do
		-- update the players position every second instead of a configed amount otherwise
		-- serverside won't catch up
		Wait(1000)
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		local distance = #(playerCoords - previousCoords)

		if distance > 10 then
			previousCoords = playerCoords
			playerHeading = ESX.Math.Round(GetEntityHeading(playerPed), 1)
			formattedCoords = {x = ESX.Math.Round(playerCoords.x, 1), y = ESX.Math.Round(playerCoords.y, 1), z = ESX.Math.Round(playerCoords.z, 1), heading = playerHeading}
			TriggerServerEvent('esx:updateCoords', formattedCoords)
			if distance > 1 then
				TriggerServerEvent('esx:updateCoords', formattedCoords)
			end
		end
	end
end)
