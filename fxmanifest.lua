fx_version 'bodacious'
games { 'gta5' }

description 'ExtendedMode'

version '1.1.0'

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',

	'locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/fr.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/cs.lua',

	'config.lua',
	'config.weapons.lua',

	'server/common.lua',
	'server/classes/player.lua',
	'server/functions.lua',
	'server/paycheck.lua',
	'server/main.lua',
	'server/commands.lua',

	'shared/modules/math.lua',
	'shared/modules/table.lua',
	'shared/functions.lua'
}

client_scripts {
	'locale.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/fr.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/cs.lua',

	'config.lua',
	'config.weapons.lua',

	'client/common.lua',
	'client/entityiter.lua',
	'client/functions.lua',
	'client/wrapper.lua',
	'client/main.lua',

	'client/modules/death.lua',
	'client/modules/scaleform.lua',
	'client/modules/streaming.lua',

	'shared/modules/math.lua',
	'shared/modules/table.lua',
	'shared/functions.lua'
}

ui_page {
	'html/ui.html'
}

files {
	'locale.js',
	'html/ui.html',

	'html/css/app.css',

	'html/js/mustache.min.js',
	'html/js/wrapper.js',
	'html/js/app.js',

	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',

	'html/img/accounts/bank.png',
	'html/img/accounts/black_money.png'
}

exports {
	'getSharedObject'
}

server_exports {
	'getSharedObject'
}

dependencies {
	'essentialmode',
	'mysql-async',
	'async'
}
