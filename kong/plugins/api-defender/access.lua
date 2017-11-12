local access = {}

local utils = require 'kong.tools.utils'

local log = require 'kong.lib.log'
local params = require 'kong.lib.params'
local resData = require 'kong.lib.response'
local constants = require 'kong.plugins.api-defender.constants'
local exception = require 'kong.plugins.api-defender.exception'

local real_url = nil
local server_security = nil

local function postern(key, secret, args)
	if next(args) == nil then
		return false
	end
	for k,v in pairs(args) do
		if k == key and args[k] == secret then
			return true
		end
	end 
	return false
end

local function generate_security(args, first_key, second_key, salt)
	if args and args[first_key] and args[second_key] then
		return ngx.md5(args[first_key] .. args[second_key] .. salt)
	else
		resData(constants.DEFENDER_PARAMS_LACKING)
	end
end

local function check_exception(uri, exception)
	real_url = string.lower(uri) 
	if utils.table_contains(exception, real_url) then
		return true
	end
		return false
end

local function check_cache()
	local connections = require 'kong.lib.connections'
	local red = connections.redis_conn(1)
	local req_time_prefix = "security:md5:"
	local req_time_key = req_time_prefix .. ngx.md5(real_url .. server_security)
	local req_time_val = red:get(req_time_key)
	if '1' == req_time_val then
		resData(constants.DEFENDER_MORE)
	else
		local ok, err = red:set(req_time_key, '1')
		if not ok then
			log.err("Redis err:" .. err)
		end
		red:expire(req_time_key, 3600 * 10)
	end
end

local function check_security(deal_args, first_key, second_key, salt, security)
	server_security = generate_security(deal_args, first_key, second_key, salt)
	local client_security = deal_args[security]
	if server_security ~= client_security then
		resData(constants.DEFENDER_PARAMS_FAIL)
	end
	check_cache()
	return true
end

function access.execute(config)
	local params = params()
	local args, body = params.args, params.body
	local uri = ngx.var.uri
	local deal_args = utils.table_merge(args,body)

	local salt, security = config.salt_value, config.security_key_name
	local first_key, second_key = config.first_key_name, config.second_key_name
	local postern_key, postern_secret = config.postern_key_name, config.postern_secret_value

	if true == postern(postern_key, postern_secret, deal_args) then
		return
	end
	if true == check_exception(uri, exception) then
		return
	end
	if true == check_security(deal_args, first_key, second_key, salt, security) then
		return
	end
end

return access