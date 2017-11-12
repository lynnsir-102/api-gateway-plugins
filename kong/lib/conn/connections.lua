local connections = {}

local log = require 'kong.lib.log'
local config = require 'kong.lib.config'

function connections.redis_conn(index)
	local redis = require "kong.lib.redis_iresty"
	local red = redis:new(config.redis)
    local _, err = red:select(index)
    if err then
    	log.err("Redis connection err:" .. err)
    end
    return red
end    

return connections