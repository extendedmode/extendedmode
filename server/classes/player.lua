function CreateExtendedPlayer(player, accounts, inventory, job, loadout, name, lastPosition)
	local self = {}

	self.player       = player
	self.accounts     = accounts
	self.inventory    = inventory
	self.job          = job
	self.loadout      = loadout
	self.name         = name
	self.lastPosition = lastPosition

	self.source     = self.player.get('source')
	self.identifier = self.player.get('identifier')

	self.setMoney = function(money)
		money = ESX.Math.Round(money)

		if money >= 0 then
			self.player.setMoney(money)
		else
			print(('es_extended: %s attempted exploiting! (reason: player tried setting -1 cash balance)'):format(self.identifier))
		end
	end

	self.getMoney = function()
		return self.player.get('money')
	end

	self.setBankBalance = function(money)
		money = ESX.Math.Round(money)

		if money >= 0 then
			self.player.setBankBalance(money)
		else
			print(('es_extended: %s attempted exploiting! (reason: player tried setting -1 bank balance)'):format(self.identifier))
		end
	end

	self.getBank = function()
		return self.player.get('bank')
	end

	self.getCoords = function()
		return self.player.get('coords')
	end

	self.setCoords = function(x, y, z)
		self.player.coords = {x = x, y = y, z = z}
	end

	self.kick = function(r)
		self.player.kick(r)
	end

	self.addMoney = function(money)
		money = ESX.Math.Round(money)

		if money >= 0 then
			self.player.addMoney(money)
		else
			print(('es_extended: %s attempted exploiting! (reason: player tried adding -1 cash balance)'):format(self.identifier))
		end
	end

	self.removeMoney = function(money)
		money = ESX.Math.Round(money)

		if money >= 0 then
			self.player.removeMoney(money)
		else
			print(('es_extended: %s attempted exploiting! (reason: player tried removing -1 cash balance)'):format(self.identifier))
		end
	end

	self.addBank = function(money)
		money = ESX.Math.Round(money)

		if money >= 0 then
			self.player.addBank(money)
		else
			print(('es_extended: %s attempted exploiting! (reason: player tried adding -1 bank balance)'):format(self.identifier))
		end
	end

	self.removeBank = function(money)
		money = ESX.Math.Round(money)

		if money >= 0 then
			self.player.removeBank(money)
		else
			print(('es_extended: %s attempted exploiting! (reason: player tried removing -1 bank balance)'):format(self.identifier))
		end
	end

	self.displayMoney = function(money)
		self.player.displayMoney(money)
	end

	self.displayBank = function(money)
		self.player.displayBank(money)
	end

	self.setSessionVar = function(key, value)
		self.player.setSessionVar(key, value)
	end

	self.getSessionVar = function(k)
		return self.player.getSessionVar(k)
	end

	self.getPermissions = function()
		return self.player.getPermissions()
	end

	self.setPermissions = function(p)
		self.player.setPermissions(p)
	end

	self.getIdentifier = function()
		return self.player.getIdentifier()
	end

	self.getGroup = function()
		return self.player.getGroup()
	end

	self.set = function(k, v)
		self.player.set(k, v)
	end

	self.get = function(k)
		return self.player.get(k)
	end

	self.getPlayer = function()
		return self.player
	end

	self.getAccounts = function()
		local accounts = {}

		for i=1, #Config.Accounts, 1 do
			if Config.Accounts[i] == 'bank' then

				table.insert(accounts, {
					name  = 'bank',
					money = self.get('bank'),
					label = Config.AccountLabels['bank']
				})

			else

				for j=1, #self.accounts, 1 do
					if self.accounts[j].name == Config.Accounts[i] then
						table.insert(accounts, self.accounts[j])
					end
				end

			end
		end

		return accounts
	end

	self.getAccount = function(a)
		if a == 'bank' then
			return {
				name  = 'bank',
				money = self.get('bank'),
				label = Config.AccountLabels['bank']
			}
		end

		for i=1, #self.accounts, 1 do
			if self.accounts[i].name == a then
				return self.accounts[i]
			end
		end
	end

	self.getInventory = function()
		return self.inventory
	end

	self.getJob = function()
		return self.job
	end

	self.getLoadout = function()
		return self.loadout
	end

	self.getName = function()
		return self.name
	end

	self.setName = function(newName)
		self.name = newName
	end

	self.getLastPosition = function()
		if self.lastPosition then
			self.lastPosition.x = ESX.Math.Round(self.lastPosition.x, 1)
			self.lastPosition.y = ESX.Math.Round(self.lastPosition.y, 1)
			self.lastPosition.z = ESX.Math.Round(self.lastPosition.z, 1)
		end

		return self.lastPosition
	end

	self.getMissingAccounts = function(cb)
		MySQL.Async.fetchAll('SELECT * FROM `user_accounts` WHERE `identifier` = @identifier', {
			['@identifier'] = self.getIdentifier()
		}, function(result)
			local missingAccounts = {}

			for i=1, #Config.Accounts, 1 do
				if Config.Accounts[i] ~= 'bank' then
					local found = false

					for j=1, #result, 1 do
						if Config.Accounts[i] == result[j].name then
							found = true
							break
						end
					end

					if not found then
						table.insert(missingAccounts, Config.Accounts[i])
					end
				end
			end

			cb(missingAccounts)
		end)
	end

	self.createAccounts = function(missingAccounts, cb)
		for i=1, #missingAccounts, 1 do
			MySQL.Async.execute('INSERT INTO `user_accounts` (identifier, name) VALUES (@identifier, @name)',
			{
				['@identifier'] = self.getIdentifier(),
				['@name']       = missingAccounts[i]
			}, function(rowsChanged)
				if cb ~= nil then
					cb()
				end
			end)
		end
	end

	self.setAccountMoney = function(acc, money)
		if money < 0 then
			print(('es_extended: %s attempted exploiting! (reason: player tried setting -1 account balance)'):format(self.identifier))
			return
		end

		local account   = self.getAccount(acc)
		local prevMoney = account.money
		local newMoney  = ESX.Math.Round(money)

		account.money = newMoney

		if acc == 'bank' then
			self.set('bank', newMoney)
		end

		TriggerClientEvent('esx:setAccountMoney', self.source, account)
	end

	self.addAccountMoney = function(acc, money)
		if money < 0 then
			print(('es_extended: %s attempted exploiting! (reason: player tried adding -1 account balance)'):format(self.identifier))
			return
		end

		local account  = self.getAccount(acc)
		local newMoney = account.money + ESX.Math.Round(money)

		account.money = newMoney

		if acc == 'bank' then
			self.set('bank', newMoney)
		end

		TriggerClientEvent('esx:setAccountMoney', self.source, account)
	end

	self.removeAccountMoney = function(a, m)
		if m < 0 then
			print(('es_extended: %s attempted exploiting! (reason: player tried removing -1 account balance)'):format(self.identifier))
			return
		end

		local account  = self.getAccount(a)
		local newMoney = account.money - m

		account.money = newMoney

		if a == 'bank' then
			self.set('bank', newMoney)
		end

		TriggerClientEvent('esx:setAccountMoney', self.source, account)
	end

	self.getInventoryItem = function(name)
		for i=1, #self.inventory, 1 do
			if self.inventory[i].name == name then
				return self.inventory[i]
			end
		end

		local item = ESX.Items[name]

		if (item) then
			newItem = {
				name = name,
				count = 0,
				label = item.label,
				limit = item.limit,
				usable = ESX.UsableItemsCallbacks[name] ~= nil,
				rare = item.rare,
				weight = item.weight || 0,
				canRemove = item.canRemove
			}

			table.insert(self.inventory, newItem)

			MySQL.Async.execute('INSERT INTO user_inventory (identifier, item, count) VALUES (@identifier, @item, @count)',
			{
				['@identifier'] = self.identifier,
				['@item']       = name,
				['@count']      = 0
			}, function(rowsChanged)end)

			return newItem
		end
	end

	self.addInventoryItem = function(name, count)
		local item     = self.getInventoryItem(name)
		local newCount = item.count + count
		item.count     = newCount

		TriggerEvent("esx:onAddInventoryItem", self.source, item, count)
		TriggerClientEvent("esx:addInventoryItem", self.source, item, count)
	end

	self.removeInventoryItem = function(name, count)
		local item     = self.getInventoryItem(name)
		local newCount = item.count - count
		item.count     = newCount

		if(item.count == 0) then
			local index = 0
			for i=1, #self.inventory, 1 do
				if self.inventory[i].name == name then
					index = i
				end
			end

			table.remove(self.inventory, index)
			
			MySQL.Async.execute('DELETE FROM user_inventory WHERE identifier=@identifier AND item=@item',
			{
				['@identifier'] = self.identifier,
				['@item']       = name
			}, function(rowsChanged)end)
		end

		TriggerEvent("esx:onRemoveInventoryItem", self.source, item, count)
		TriggerClientEvent("esx:removeInventoryItem", self.source, item, count)
	end

	self.setInventoryItem = function(name, count)
		local item     = self.getInventoryItem(name)
		local oldCount = item.count
		item.count     = count

		if oldCount > item.count  then
			TriggerEvent("esx:onRemoveInventoryItem", self.source, item, oldCount - item.count)
			TriggerClientEvent("esx:removeInventoryItem", self.source, item, oldCount - item.count)
		else
			TriggerEvent("esx:onAddInventoryItem", self.source, item, item.count - oldCount)
			TriggerClientEvent("esx:addInventoryItem", self.source, item, item.count - oldCount)
		end
	end

	self.setJob = function(name, grade)
		local lastJob = json.decode(json.encode(self.job))

		MySQL.Async.fetchAll('SELECT * FROM `jobs` WHERE `name` = @name', {
			['@name'] = name
		}, function(result)

			self.job['id']    = result[1].id
			self.job['name']  = result[1].name
			self.job['label'] = result[1].label

			MySQL.Async.fetchAll('SELECT * FROM `job_grades` WHERE `job_name` = @job_name AND `grade` = @grade', {
				['@job_name'] = name,
				['@grade']    = grade
			}, function(result)
				self.job['grade']        = grade
				self.job['grade_name']   = result[1].name
				self.job['grade_label']  = result[1].label
				self.job['grade_salary'] = result[1].salary

				self.job['skin_male']    = nil
				self.job['skin_female']  = nil

				if result[1].skin_male ~= nil then
					self.job['skin_male'] = json.decode(result[1].skin_male)
				end

				if result[1].skin_female ~= nil then
					self.job['skin_female'] = json.decode(result[1].skin_female)
				end

				TriggerEvent("esx:setJob", self.source, self.job, lastJob)
				TriggerClientEvent("esx:setJob", self.source, self.job)
			end)
		end)
	end

	self.addWeapon = function(weaponName, ammo)
		local weaponLabel = ESX.GetWeaponLabel(weaponName)

		if not self.hasWeapon(weaponName) then
			table.insert(self.loadout, {
				name = weaponName,
				ammo = ammo,
				label = weaponLabel,
				components = {}
			})
		end

		TriggerClientEvent('esx:addWeapon', self.source, weaponName, ammo)
		TriggerClientEvent('esx:addInventoryItem', self.source, {label = weaponLabel}, 1)
	end

	self.addWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if self.hasWeaponComponent(weaponName, weaponComponent) then
			return
		end

		table.insert(self.loadout[loadoutNum].components, weaponComponent)

		TriggerClientEvent('esx:addWeaponComponent', self.source, weaponName, weaponComponent)
	end

	self.removeWeapon = function(weaponName, ammo)
		local weaponLabel

		for i=1, #self.loadout, 1 do
			if self.loadout[i].name == weaponName then
				weaponLabel = self.loadout[i].label

				table.remove(self.loadout, i)
				break
			end
		end

		if weaponLabel then
			TriggerClientEvent('esx:removeWeapon', self.source, weaponName, ammo)
			TriggerClientEvent('esx:removeInventoryItem', self.source, {label = weaponLabel}, 1)
		end
	end

	self.removeWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)
		
		if not weapon then
			return
		end

		for i=1, #self.loadout[loadoutNum].components, 1 do
			if self.loadout[loadoutNum].components.name == weaponComponent then
				table.remove(self.loadout[loadoutNum].components, i)
				break
			end
		end

		TriggerClientEvent('esx:removeWeaponComponent', self.source, weaponName, weaponComponent)
	end

	self.hasWeaponComponent = function(weaponName, weaponComponent)
		local loadoutNum, weapon = self.getWeapon(weaponName)

		if not weapon then
			return false
		end

		for i=1, #weapon.components, 1 do
			if weapon.components[i] == weaponComponent then
				return true
			end
		end

		return false
	end

	self.hasWeapon = function(weaponName)
		for i=1, #self.loadout, 1 do
			if self.loadout[i].name == weaponName then
				return true
			end
		end

		return false
	end

	self.getWeapon = function(weaponName)
		for i=1, #self.loadout, 1 do
			if self.loadout[i].name == weaponName then
				return i, self.loadout[i]
			end
		end

		return nil
	end

	return self
end
