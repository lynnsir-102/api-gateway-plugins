local log = require 'kong.lib.log'
local params = require 'kong.lib.params'

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

local function exit_log(msg)
	log.err(msg)
	ngx.exit(500)
end

local function generate_security(args)
	if args and args["udid"] and args["time"] then
		local salt = "9d39516f2aa889f69842f8cae5af59f5"
		return ngx.md5(args["udid"] .. args["time"] .. salt)
	else
		exit_log("校验参数不足")
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

local function table_merge(fir_t,sec_t)
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

local function check_exception(uri,exception)
	local lower_url = nil
	lower_url = string.lower(uri) 
	if in_array(real_url, exception_url) then
	   return true
    end
    return false
end

local function check_security(deal_args)
	local server_security = generate_security(deal_args)
    local client_security = deal_args["security"]
    if server_security ~= client_security then
	    exit_log("加密字符串不正确!")
    end
    return true
end

function access.execute(config)
  local params = params()
  local args, body = params.args, params.body
  local uri = ngx.var.uri
  local deal_args = table_merge(args,body)

  local key = config.key
  local secret  = config.secret

  if true == postern(key, secret, deal_args) then
  	 return
  end
  if true == check_exception(uri,exception) then
  	 return
  end
  if true == check_security(deal_args) then
  	 return
  end
end

return access