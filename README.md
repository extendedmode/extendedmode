# extendedmode
extendedmode is a community edition fork of es_extended and will be maintained by various trusted members of the fivem community.

## Primary goals for this project
- Allow even versions of ESX scripts pre 1.2 to continue to function with as few edits as possible.
- Ensure backwards compatibility/new features at the same time as adding optimisations and general other boosts.

## About es_extended
es_extended is a roleplay framework for FiveM. ESX is short for EssentialMode Extended. The to-go framework for creating an economy based roleplay server on FiveM and most popular on the platform, too!

ESX was initially developed by Gizz back in 2017 for his friend as the were creating an FiveM server and there wasn't any economy roleplaying frameworks available. The original code was written within a week or two and later open sourced, it has ever since been improved and parts been rewritten to further improve on it.

## Links & Read more

- [FiveM Native Reference](https://runtime.fivem.net/doc/reference.html)

## Features

- Weight based inventory system
- Weapons support, including support for attachments and tints
- Supports different money accounts (defaulted with cash, bank and black money)
- Many official resources available in our GitHub
- Job system, with grades and clothes support
- Supports multiple languages, most strings are localized
- Easy to use API for developers to easily integrate EX to their projects
- Register your own commands easily, with argument validation, chat suggestion and using FXServer ACL

## Extendedmode Exclusive Features

We have made some exclusive features for extendedmode only, find them all here; [Functions](FUNCTIONS.md)

## Requirements

- [mysql-async](https://github.com/brouznouf/fivem-mysql-async)
- [async](https://github.com/ESX-Org/async)

### Using Git

- cd resources
- git clone https://github.com/extendedmode/extendedmode extendedmode
- git clone https://github.com/ESX-Org/esx_menu_default [ex]/[ui]/esx_menu_default
- git clone https://github.com/ESX-Org/esx_menu_dialog [ex]/[ui]/esx_menu_dialog
- git clone https://github.com/ESX-Org/esx_menu_list [ex]/[ui]/esx_menu_list

### Manually

- Download https://github.com/extendedmode/extendedmode/releases/latest
- Put it in the `resource/[extended]` directory
- Download https://github.com/ESX-Org/esx_menu_default/releases/latest
- Put it in the `resource/[ex]/[ui]` directory
- Download https://github.com/ESX-Org/esx_menu_dialog/releases/latest
- Put it in the `resource/[ex]/[ui]` directory
- Download https://github.com/ESX-Org/esx_menu_list/releases/latest
- Put it in the `resource/[ex]/[ui]` directory

### Installation

- Import `extendedmode.sql` in your database
- Configure your `server.cfg` to look like this

```
add_principal group.admin group.user
add_ace resource.extendedmode command.add_ace allow
add_ace resource.extendedmode command.add_principal allow
add_ace resource.extendedmode command.remove_principal allow

start mysql-async
start extendedmode

start esx_menu_default
start esx_menu_list
start esx_menu_dialog
```

## Legal

### License

# extendedmode - es_extended community fork

All changes after 04/04/2020 are provided by their respective authors under the GNUGPLv3 license.

# es_extended
es_extended - EssentialMode Extended framework for FiveM

Copyright (C) 2015-2020 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
