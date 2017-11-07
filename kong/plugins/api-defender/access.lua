local params = require 'kong.lib.params'
local resData = require 'kong.lib.response'
local constants = require 'kong.lib.constants'
local exception = require 'kong.plugins.api-defender.exception'

local access = {}

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

local function in_array(val, list)
	if not list then
		return false
	end
	for k, v in pairs(list) do
		if v == val then 
			return true
		end
	end
end

local function table_merge(fir_t, sec_t)
	if next(fir_t) == nil then
    fir_t = {}
  end
  if next(sec_t) == nil then
    sec_t = {}
  end
	for k,v in pairs(sec_t) do  
    fir_t[k] = v
  end
  return fir_t
end

local function check_exception(uri, exception)
	local lower_url = nil
	lower_url = string.lower(uri) 
	if in_array(real_url, exception_url) then
	  return true
  end
    return false
end

local function check_security(deal_args, first_key, second_key, salt, security)
	local server_security = generate_security(deal_args, first_key, second_key, salt)
    local client_security = deal_args[security]
  if server_security ~= client_security then
    resData(constants.DEFENDER_PARAMS_FAIL)
  end
  return true
end

function access.execute(config)
  local params = params()
  local args, body = params.args, params.body
  local uri = ngx.var.uri
  local deal_args = table_merge(args,body)

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