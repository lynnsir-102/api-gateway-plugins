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
  'lua-resty-http ~> 0.11-0'
}

build = {
  type = "builtin",
  modules = {
    ["kong.lib.log"] = "./kong/lib/log.lua",
    ["kong.lib.common"] = "./kong/lib/common.lua",
    ["kong.lib.helper"] = "./kong/lib/helper.lua",
    ["kong.lib.params"] = "./kong/lib/params.lua",
    ["kong.lib.request"] = "./kong/lib/request.lua",
    ["kong.lib.response"] = "./kong/lib/response.lua",
    ["kong.lib.constants"] = "./kong/lib/constants.lua"
  }
}
