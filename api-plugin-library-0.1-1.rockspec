package = "api-plugin-library"

version = "0.1-1"

supported_platforms = { "linux", "macosx" }

source = { 
	url = 'https://github.com/lynnsir-102/api-gateway-plugins',
	branch = 'master'
}

description = {
	license = "Apache 2.0",
	summary = "the basic library of the api-gateway plugins"
}

dependencies = {
	'lua ~> 5.1',
	'luajson ~> 1.3.4-1',
	'luarestyredis',
	'lua-resty-http ~> 0.11-0'
}

build = {
	type = "builtin",
	modules = {
        ["kong.lib.log"] = "./kong/lib/log.lua",
        ["kong.lib.func"] = "./kong/lib/func.lua",
        ["kong.lib.debug"] = "./kong/lib/debug.lua",
        ["kong.lib.config"] = "./kong/lib/config/config.lua",
        ["kong.lib.params"] = "./kong/lib/http-lib/params.lua",
        ["kong.lib.request"] = "./kong/lib/http-lib/request.lua",
        ["kong.lib.exception"] = "./kong/lib/enums/exception.lua",
        ["kong.lib.response"] = "./kong/lib/http-lib/response.lua",
        ["kong.lib.connections"] = "./kong/lib/conn/connections.lua",
        ["kong.lib.redis_index"] = "./kong/lib/enums/redis_index.lua",
        ["kong.lib.redis_iresty"] = "./kong/lualib/resty/redis_iresty.lua"
	}
}