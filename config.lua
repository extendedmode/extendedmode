Config = {}
Config.Locale = 'en'

Config.Accounts = {
	bank = _U('account_bank'),
	black_money = _U('account_black_money'),
	money = _U('account_money')
}

Config.StartingAccountMoney = {bank = 50000}

Config.EnableSocietyPayouts = false -- pay from the society account that the player is employed at? Requirement: esx_society
Config.DisableWantedLevel   = true
Config.EnableHud            = false -- enable the default hud? Display current job and accounts (black, bank & cash)
Config.EnablePvP            = true -- enable pvp?
Config.MaxWeight            = 24000   -- the max inventory weight without backpack(this is in grams, not kg!)

Config.PaycheckInterval     = 60 * 60000 -- how often to recieve pay checks in milliseconds

Config.EnableDebug          = false
Config.PrimaryIdentifier	= "steam" -- Options: steam, license (social club), fivem, discord, xbl, live (default steam, recommended: fivem) this SHOULD function with most older scripts too!

-- The default player model you will use if no other scripts control your player model
-- We have set a MP ped as default since if you use another script that controls your player model
-- then this will make them invisible until the actual outfit/model has loaded, this looks better than
-- loading another model then changing it immediately after
Config.DefaultPlayerModel	= `mp_m_freemode_01` 

Config.DefaultPickupModel = `prop_money_bag_01`