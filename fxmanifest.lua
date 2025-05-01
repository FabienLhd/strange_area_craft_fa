shared_script '@esx_ambulancejob/shared_fg-obfuscated.lua'
shared_script '@esx_ambulancejob/ai_module_fg-obfuscated.lua'
fx_version 'cerulean'
game 'gta5'

author 'CartonSlip'
description 'Strange area craft fa'

dependencies {
    'oxmysql',
    'es_extended',
}

client_scripts {
	"src/RageUI/RMenu.lua",
    "src/RageUI/menu/RageUI.lua",
    "src/RageUI/menu/Menu.lua",
    "src/RageUI/menu/MenuController.lua",
    "src/RageUI/components/*.lua",
    "src/RageUI/menu/elements/*.lua",
    "src/RageUI/menu/items/*.lua",
    "src/RageUI/menu/panels/*.lua",
    "src/RageUI/menu/windows/*.lua",

    'src/RageUIv1/RMenu.lua',
    'src/RageUIv1/menu/RageUI.lua',
    'src/RageUIv1/menu/Menu.lua',
    'src/RageUIv1/menu/MenuController.lua',
    'src/RageUIv1/components/*.lua',
    'src/RageUIv1/menu/elements/*.lua',
    'src/RageUIv1/menu/items/*.lua',
    'src/RageUIv1/menu/panels/*.lua',
    'src/RageUIv1/menu/windows/*.lua',
	'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

shared_script 'config.lua'