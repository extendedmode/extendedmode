Locales['lt'] = {
    -- Inventory
    ['inventory'] = 'Inventorius %s / %s',
    ['use'] = 'Panaudoti',
    ['give'] = 'Duoti',
    ['remove'] = 'Išmesti',
    ['return'] = 'Atgal',
    ['give_to'] = 'Duoti',
    ['amount'] = 'Kiekis',
    ['giveammo'] = 'Duoti kulkas',
    ['amountammo'] = 'Kulku kiekis',
    ['noammo'] = 'Jus neturite pakankamai kulkų!',
    ['gave_item'] = 'Jūs davetė ~y~%sx~s~ ~b~%s~s~ ~y~%s~s~',
    ['received_item'] = 'Jūs gavote ~y~%sx~s~ ~b~%s~s~ iš ~b~%s~s~',
    ['gave_weapon'] = 'Jūs davetė ~b~%s~s~ ~y~%s~s~',
    ['gave_weapon_ammo'] = 'Tu davei ~o~%sx %s~s~ ginklui ~b~%s~s~ Zaidejui ~y~%s~s~',
    ['gave_weapon_withammo'] = 'Tu davei ~b~%s~s~ su ~o~%sx %s~s~ Zaidejui ~y~%s~s~',
    ['gave_weapon_hasalready'] = '~y~%s~s~ Jau turi ~y~%s~s~',
    ['gave_weapon_noweapon'] = '~y~%s~s~ Neturi tokio ginklo',
    ['received_weapon'] = 'Tu gavai ~b~%s~s~ is ~b~%s~s~',
    ['received_weapon_ammo'] = 'Tu gavai ~o~%sx %s~s~ tavo ~b~%s~s~ is ~b~%s~s~',
    ['received_weapon_withammo'] = 'Tu gavai ~b~%s~s~ su ~o~%sx %s~s~ is ~b~%s~s~',
    ['received_weapon_hasalready'] = '~b~%s~s~ Pabande tau duoti ~y~%s~s~, bet tu jau turi',
    ['received_weapon_noweapon'] = '~b~%s~s~ Bande tau duoti kulku ginklui ~y~%s~s~, bet tu neturi',
    ['gave_account_money'] = 'Tu davei ~g~$%s~s~ (%s) Zaidejui ~y~%s~s~',
    ['received_account_money'] = 'Tu gavai ~g~$%s~s~ (%s) is ~b~%s~s~',
    ['amount_invalid'] = 'Netinkama suma',
    ['players_nearby'] = 'Nera zaideju salia',
    ['ex_inv_lim'] = 'Veiksmas neimanomas, pasiektas inventoriaus limitas ~y~%s~s~',
    ['imp_invalid_quantity'] = 'Veiksmas neimanomas, netinkamas kiekis',
    ['imp_invalid_amount'] = 'Veiksmas neimanoams, netinkamas kiekis',
    ['threw_standard'] = 'Tu ismetei ~y~%sx~s~ ~b~%s~s~',
    ['threw_account'] = 'Tu ismetei ~g~$%s~s~ ~b~%s~s~',
    ['threw_weapon'] = 'Tu ismetei ~b~%s~s~',
    ['threw_weapon_ammo'] = 'Tu ismetei ~b~%s~s~ su ~o~%sx %s~s~',
    ['threw_weapon_already'] = 'Tu jau turi si ginkla',
    ['threw_cannot_pickup'] = 'Tu negali to paimti, nes neturi vietos inventoriuje!',
    ['threw_pickup_prompt'] = 'Paspausk ~y~E~s~ kad paimtum',
    ['standard_pickup_prompt'] = '~y~E:~s~ Paimti',
  
    -- Key mapping
    ['keymap_showinventory'] = 'Parodyti inventoriu',
  
    -- Salary related
    ['received_salary'] = 'Tu gavai alga: ~g~$%s~s~',
    ['received_help'] = 'Tu gavai pasalpa: ~g~$%s~s~',
    ['company_nomoney'] = 'Kompanija kurioje jus dirbate yra skurdi, del to jums negali ismoketi algos',
    ['received_paycheck'] = 'Gavai saskaita',
    ['bank'] = 'SwedBank',
    ['account_bank'] = 'bankas',
    ['account_black_money'] = 'Nesvarus pinigai',
    ['account_money'] = 'Grynieji',
  
    ['act_imp'] = 'Veiksmas neimanomas',
    ['in_vehicle'] = 'Tu negali duoti nieko kai zaidejas automobilyje',
  
    -- Commands
    ['command_car'] = 'atspawninti automobili',
    ['command_car_car'] = 'Automobilio spawn kodas arba hash kodas',
    ['command_cardel'] = 'Istrinti automobili',
    ['command_cardel_radius'] = ' istrtinti automobili pasirinktame spindulyje',
    ['command_clear'] = 'Istrinti chata',
    ['command_clearall'] = 'Istrinti chata visiems',
    ['command_clearinventory'] = 'Istrinti zaidejo inventoriu',
    ['command_clearloadout'] = 'Istrinti zaidejo ginklus',
    ['command_giveaccountmoney'] = 'Duoti pinigu',
    ['command_giveaccountmoney_account'] = 'Tinkamas saskaitos pavadinimas',
    ['command_giveaccountmoney_amount'] = 'Pinigu kiekis',
    ['command_giveaccountmoney_invalid'] = 'Netinkamas saskaitos pavadinimas',
    ['command_giveitem'] = 'Duoti zaidejui daigta',
    ['command_giveitem_item'] = 'Daigto pavadinimas',
    ['command_giveitem_count'] = 'Daigto kiekis',
    ['command_giveweapon'] = 'Duoti zaidejui ginkla',
    ['command_giveweapon_weapon'] = 'Ginklo pavadinimas',
    ['command_giveweapon_ammo'] = 'Kulku kiekis',
    ['command_giveweapon_hasalready'] = 'Zaidejas jau turi toki ginkla',
    ['command_giveweaponcomponent'] = 'Duoti ginklo komponenta',
    ['command_giveweaponcomponent_component'] = 'Komponento pavadinimas',
    ['command_giveweaponcomponent_invalid'] = 'Netinkamas komponento pavadinimas',
    ['command_giveweaponcomponent_hasalready'] = 'Zaidejas jau turi komponenta',
    ['command_giveweaponcomponent_missingweapon'] = 'Zaidejas neturi tokio ginklo',
    ['command_save'] = 'Issaugoti zaideja databazeje',
    ['command_saveall'] = 'Issaugoti visus zaidejus databazeje',
    ['command_setaccountmoney'] = 'set account money for a player',
    ['command_setaccountmoney_amount'] = 'kiekis kiek pinigu nustatyti',
    ['command_setcoords'] = 'teleportuotis i koordinates',
    ['command_setcoords_x'] = 'x axis',
    ['command_setcoords_y'] = 'y axis',
    ['command_setcoords_z'] = 'z axis',
    ['command_setjob'] = 'nustatyti zaidejo darba',
    ['command_setjob_job'] = 'Darbo pavadinimas',
    ['command_setjob_grade'] = 'Darbo laipsnis',
    ['command_setjob_invalid'] = 'Darbas, arba darbo laipsnis netinkamas',
    ['command_setgroup'] = 'Nustatyti zaidejo grupe',
    ['command_setgroup_group'] = 'Grupes pavadinimas',
    ['commanderror_argumentmismatch'] = 'argument count mismatch (passed %s, wanted %s)',
    ['commanderror_argumentmismatch_number'] = 'argument #%s type mismatch (passed string, wanted number)',
    ['commanderror_invaliditem'] = 'Netinkamas daigto pavadinimas',
    ['commanderror_invalidweapon'] = 'Netinkamas ginklas',
    ['commanderror_console'] = 'that command can not be run from console',
    ['commanderror_invalidcommand'] = '^3%s^0 is not an valid command!',
    ['commanderror_invalidplayerid'] = 'there is no player online matching that server id',
    ['commandgeneric_playerid'] = 'Zaidejo ID',
  
    -- Locale settings
    ['locale_digit_grouping_symbol'] = ',',
    ['locale_currency'] = '$%s',
  
    -- Weapons
    ['weapon_knife'] = 'Peilis',
    ['weapon_nightstick'] = 'Bananas',
    ['weapon_hammer'] = 'Plaktukas',
    ['weapon_bat'] = 'Lazda',
    ['weapon_golfclub'] = 'Golfo lazda',
    ['weapon_crowbar'] = 'Lauztuvas',
    ['weapon_pistol'] = 'Pistoletas',
    ['weapon_combatpistol'] = 'Kovinis pistoletas',
    ['weapon_appistol'] = 'AP pistoletas',
    ['weapon_pistol50'] = 'pistoletas .50',
    ['weapon_microsmg'] = 'Mazas SMG',
    ['weapon_smg'] = 'SMG',
    ['weapon_assaultsmg'] = 'Sturmo SMG',
    ['weapon_assaultrifle'] = 'Puolimo sautuvas',
    ['weapon_carbinerifle'] = 'Karabinas',
    ['weapon_advancedrifle'] = 'Pazenges ginklas',
    ['weapon_mg'] = 'MG',
    ['weapon_combatmg'] = 'combat MG',
    ['weapon_pumpshotgun'] = 'Pompa',
    ['weapon_sawnoffshotgun'] = 'Nupjautavamze Pompa',
    ['weapon_assaultshotgun'] = 'puolimo šautuvas',                     -- needs UTF translation
    ['weapon_bullpupshotgun'] = 'jaučio kulkosvaidis',                  -- needs UTF translation
    ['weapon_stungun'] = 'tazeris',
    ['weapon_sniperrifle'] = 'snaiperio šautuvas',                      -- needs UTF translation
    ['weapon_heavysniper'] = 'sunkusis snaiperis',                      -- needs UTF translation
    ['weapon_grenadelauncher'] = 'granatsvaidis',                       -- needs UTF translation
    ['weapon_rpg'] = 'raketos paleidėjas',                              -- needs UTF translation
    ['weapon_minigun'] = 'minigun',                                     -- needs UTF translation
    ['weapon_grenade'] = 'granata',                                     -- needs UTF translation
    ['weapon_stickybomb'] = 'lipni bomba',                              -- needs UTF translation
    ['weapon_smokegrenade'] = 'dūmų granata',                           -- needs UTF translation
    ['weapon_bzgas'] = 'bz gas',                                        -- needs UTF translation
    ['weapon_molotov'] = 'molotovo Kokteilis',
    ['weapon_fireextinguisher'] = 'Gesintuvas',
    ['weapon_petrolcan'] = 'Kuro bakelis',
    ['weapon_ball'] = 'kamuolys',                                       -- needs UTF translation
    ['weapon_snspistol'] = 'Sns pistoletas',
    ['weapon_bottle'] = 'Butelys',
    ['weapon_gusenberg'] = 'gusenberg sweeper',
    ['weapon_specialcarbine'] = 'special carbine',
    ['weapon_heavypistol'] = 'Sunkusis pistoletas',
    ['weapon_bullpuprifle'] = 'bullpup rifle',
    ['weapon_dagger'] = 'Durklas',
    ['weapon_vintagepistol'] = 'vintage pistol',                        -- needs UTF translation
    ['weapon_firework'] = 'firework',                                   -- needs UTF translation
    ['weapon_musket'] = 'musket',                                       -- needs UTF translation
    ['weapon_heavyshotgun'] = 'heavy shotgun',                          -- needs UTF translation
    ['weapon_marksmanrifle'] = 'marksman rifle',                        -- needs UTF translation
    ['weapon_hominglauncher'] = 'homing launcher',                      -- needs UTF translation
    ['weapon_proxmine'] = 'proximity mine',                             -- needs UTF translation
    ['weapon_snowball'] = 'snow ball',                                  -- needs UTF translation
    ['weapon_flaregun'] = 'flaregun',                                   -- needs UTF translation
    ['weapon_combatpdw'] = 'combat pdw',                                -- needs UTF translation
    ['weapon_marksmanpistol'] = 'marksman pistol',                      -- needs UTF translation
    ['weapon_knuckle'] = 'Kastetas',
    ['weapon_hatchet'] = 'Kirvis',
    ['weapon_railgun'] = 'railgun',                                     -- needs UTF translation
    ['weapon_machete'] = 'mecete',
    ['weapon_machinepistol'] = 'machine pistol',                        -- needs UTF translation
    ['weapon_switchblade'] = 'switchblade',                             -- needs UTF translation
    ['weapon_revolver'] = 'heavy revolver',                             -- needs UTF translation
    ['weapon_dbshotgun'] = 'Dvivamzde pompa',
    ['weapon_compactrifle'] = 'compact rifle',                          -- needs UTF translation
    ['weapon_autoshotgun'] = 'auto shotgun',                            -- needs UTF translation
    ['weapon_battleaxe'] = 'Kovinis kirvis',
    ['weapon_compactlauncher'] = 'compact launcher',                    -- needs UTF translation
    ['weapon_minismg'] = 'Mazasis SMG',
    ['weapon_pipebomb'] = 'pipe bomb',                                  -- needs UTF translation
    ['weapon_poolcue'] = 'pool cue',                                    -- needs UTF translation
    ['weapon_wrench'] = 'pipe wrench',                                  -- needs UTF translation
    ['weapon_flashlight'] = 'Zibintuvelis',
    ['gadget_parachute'] = 'parachute',                                 -- needs UTF translation
    ['weapon_flare'] = 'flare gun',                                     -- needs UTF translation
    ['weapon_doubleaction'] = 'Dvigubo veiksmo revolveris ',
    ['weapon_pistol_mk2'] = 'pistol Mk2',                               -- needs UTF translation
    ['weapon_smg_mk2'] = 'SMG Mk2',                                     -- needs UTF translation
    ['weapon_assaultrifle_mk2'] = "assault rifle Mk2",                  -- needs UTF translation
    ['weapon_carbinerifle_mk2'] = 'carbine rifle Mk2',                  -- needs UTF translation
    ['weapon_combatmg_mk2'] = 'combat MG Mk2',                          -- needs UTF translation
    ['weapon_pumpshotgun_mk2'] = 'pump shotgun mk2',                    -- needs UTF translation
    ['weapon_heavysniper_mk2'] = 'heavy sniper Mk2',                    -- needs UTF translation
    ['weapon_snspistol_mk2'] = 'sns pistol Mk2',                        -- needs UTF translation
    ['weapon_specialcarbine_mk2'] = 'special carbine Mk2',              -- needs UTF translation
    ['weapon_bullpuprifle_mk2'] = 'bullpup rifle Mk2',                  -- needs UTF translation
    ['weapon_marksmanrifle_mk2'] = 'marksman rifle Mk2',                -- needs UTF translation
    ['weapon_revolver_mk2'] = 'heavy revolver Mk2',                     -- needs UTF translation
  
    -- Weapon Components
    ['component_clip_default']      = 'Paprasta apkaba',
    ['component_clip_extended']     = 'Prailginta apkaba',
    ['component_clip_drum']         = 'Vidutine apkaba',
    ['component_clip_box']          = 'Geriausia apkaba',
  
    -- Flashlight
    ['component_flashlight']        = 'Zibintuvelis',
    
    -- Scopes
    ['component_scope']             = 'Optika',
    ['component_scope_small']       = 'Maza optika',
    ['component_scope_macro']       = 'Macro Optika',
    ['component_scope_medium']      = 'Vidutine Optika',
    ['component_scope_mounted']     = 'Primontuota Optika',
    ['component_scope_advanced']    = 'Pazengusi Optika',
    ['component_scope_zoom']        = 'Prailgina Optika',
    ['component_scope_large']       = 'Didele Optika',
    ['component_scope_nightvison']  = 'Naktinio matymo Optika',
    ['component_scope_thermal']     = 'Silumine Optika',
  
    -- Barrels / Suppressors
    ['component_barrel']            = 'Vamzdis',
    ['component_barrel_heavy']      = 'Sunkusis vamzdis',
    ['component_suppressor']        = 'Supresorius',
    ['component_compensator']       = 'Compensatorius',
    
    -- Grips
    ['component_grip']              = 'Rankena',
  
    -- Muzzles
    ['component_muzzle_flat']       = 'Flat Muzzle Brake',          -- needs UTF translation
    ['component_muzzle_tatical']    = 'Tactical Muzzle Brake',      -- needs UTF translation
    ['component_muzzle_fat']        = 'Fat-End Muzzle Brake',       -- needs UTF translation
    ['component_muzzle_precision']  = 'Precision Muzzle Brake',     -- needs UTF translation
    ['component_muzzle_heavy']      = 'Heavy Duty Muzzle Brake',    -- needs UTF translation
    ['component_muzzle_slanted']    = 'Slanted Muzzle Brake',       -- needs UTF translation
    ['component_muzzle_split']      = 'Split-End Muzzle Brake',     -- needs UTF translation
    ['component_muzzle_squared']    = 'Square Muzzle Brake',        -- needs UTF translation
    ['component_muzzle_bellend']    = 'Bell-End Muzzle Brake',      -- needs UTF translation
  
    -- Weapon Skins
    ['component_skin_camo']         = 'Skaitmeninis Camo',
    ['component_skin_brushstroke']  = 'Teptuko smugio Camo',
    ['component_skin_woodland']     = 'Miskinis Camo',
    ['component_skin_skull']        = 'Kaukuole',
    ['component_skin_sessanta']     = 'Sesiasdesimt devyni',
    ['component_skin_perseus']      = 'Perseus',
    ['component_skin_leopard']      = 'Leopardas',
    ['component_skin_zebra']        = 'Zebras',
    ['component_skin_geometric']    = 'Geometriskas',
    ['component_skin_boom']         = 'Boom!',
    ['component_skin_patriotic']    = 'Patriotiskas',
    ['component_luxary_finish']     = 'Prabanga',
  
    -- Weapon Ammo
    ['ammo_rounds'] = 'Kulka(os)',
    ['ammo_shells'] = 'shell(s)',
    ['ammo_charge'] = 'charge',
    ['ammo_petrol'] = 'Litrai degalu',
    ['ammo_firework'] = 'firework(s)',                              -- needs UTF translation
    ['ammo_rockets'] = 'rocket(s)',                                 -- needs UTF translation
    ['ammo_grenadelauncher'] = 'grenade(s)',                        -- needs UTF translation
    ['ammo_grenade'] = 'grenade(s)',                                -- needs UTF translation
    ['ammo_stickybomb'] = 'bomb(s)',                                -- needs UTF translation
    ['ammo_pipebomb'] = 'bomb(s)',                                  -- needs UTF translation
    ['ammo_smokebomb'] = 'bomb(s)',                                 -- needs UTF translation
    ['ammo_molotov'] = 'cocktail(s)',                               -- needs UTF translation
    ['ammo_proxmine'] = 'mine(s)',                                  -- needs UTF translation
    ['ammo_bzgas'] = 'can(s)',                                      -- needs UTF translation
    ['ammo_ball'] = 'ball(s)',                                      -- needs UTF translation
    ['ammo_snowball'] = 'snowball(s)',                              -- needs UTF translation
    ['ammo_flare'] = 'flare(s)',                                    -- needs UTF translation
    ['ammo_flaregun'] = 'flare(s)',                                 -- needs UTF translation
  
    -- Weapon Tints
    ['tint_default'] = 'Paprasta',
    ['tint_green'] = 'Zalia',
    ['tint_gold'] = 'Auksine',
    ['tint_pink'] = 'Rozine',
    ['tint_army'] = 'Armija',
    ['tint_lspd'] = 'Melyna',
    ['tint_orange'] = 'Oranzine',
    ['tint_platinum'] = 'Platinumo',
  }