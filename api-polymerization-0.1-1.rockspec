package = "api-polymerization"

version = "0.1-1"

supported_platforms = { "linux", "macosx" }

source = { 
	url = 'https://github.com/lynnsir-102/api-gateway-plugins',
	branch = 'master'
}

description = {
	license = "Apache 2.0",
	summary = "api-polymerization plugin",
}

dependencies = {
	'lua ~> 5.1',
	'luajson ~> 1.3.4-1',
	'lua-resty-http ~> 0.11-0',
	'api-plugin-library ~> 0.1-1'
}

local pluginName = "api-polymerization"

build = {
	type = "builtin",
	modules = {
		["kong.plugins."..pluginName..".access"] = "./kong/plugins/"..pluginName.."/access.lua",
		["kong.plugins."..pluginName..".schema"] = "./kong/plugins/"..pluginName.."/schema.lua",
		["kong.plugins."..pluginName..".handler"] = "./kong/plugins/"..pluginName.."/handler.lua",
		["kong.plugins."..pluginName..".exception"] = "./kong/plugins/"..pluginName.."/exception.lua"
	}
}
