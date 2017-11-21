local access = {}

local utils = require 'kong.tools.utils'

local log = require 'kong.lib.log'
local params = require 'kong.lib.params'
local resData = require 'kong.lib.response'
local redis_key = require 'kong.lib.redis_key'
local redis_index = require 'kong.lib.redis_index'

local special = require 'kong.plugins.api-defender.special'
local exception = require 'kong.plugins.api-defender.exception'

local ngxReq = ngx.req

local args = {}
local real_url = nil
local server_security = nil

local function get_all_args()
    local all_args = {}
    local headers = ngxReq.get_headers()
    
    if "POST" == ngxReq.get_method() and headers['Content-Type'] and 
        string.find(headers['Content-Type'], 'multipart/form%-data') then
        ngxReq.read_body()
        local body_data = ngx.req.get_body_data()
        local multipart = require("kong.lib.multipart")
        local multipart_data = multipart(body_data, headers["content-type"])
        all_args = multipart_data:get_all()
    else
        local params = params()
        all_args = utils.table_merge(params.args, params.body)
    end
    return all_args
end

local function check_postern(key, secret)
    if next(args) == nil then
        return false
    end
    for k, v in pairs(args) do
        if k == key and args[k] == secret then
            return true
        end
    end 
    return false
end

local function check_limit(limit_key, num)
    if args and args[limit_key] then
        local req_limit_key = redis_index.REQUEST_LIMIT .. ngx.md5(real_url .. args[limit_key])
        local req_limit_val, err = red:get(req_limit_key)
        if err then
            log.err("Redis get limit value err:" .. err)
        end
        if req_limit_val then
            if tonumber(req_limit_val) < num then
                red:incr(req_limit_key)
                red:expire(req_limit_key, 1)
            else
                resData(exception.DEFENDER_LIMIT)
            end
        else
            local _, err = red:set(req_limit_key, 1)
            if err then
                log.err("Redis set err:" .. err)
            end
            red:expire(req_limit_key, 1)
        end
        
    end
end

local function check_filter(red)
    local req_filter_key = redis_key.FILTER_REPEATED .. ngx.md5(real_url .. server_security)
    local req_filter_val = red:get(req_filter_key)
    if '1' == req_filter_val then
        resData(exception.DEFENDER_MORE)
    else
        local _, err = red:set(req_filter_key, '1')
        if err then
            log.err("Redis set err:" .. err)
        end
        red:expire(req_filter_key, 3600 * 10)
    end
end


local function check_special(uri, special)
    real_url = string.lower(uri) 
    if utils.table_contains(special, real_url) then
        return true
    end
    return false
end

local function generate_security(first_key, second_key, salt)
    if args and args[first_key] and args[second_key] then
        return ngx.md5(args[first_key] .. args[second_key] .. salt)
    else
        resData(exception.DEFENDER_PARAMS_LACKING)
    end
end

local function check_cache(limit_key, limit_num)
    local connections = require 'kong.lib.connections'
    local red = connections.redis_conn(redis_index.API_DEFENDER)
    
    check_limit(red)
    check_filter(red, limit_key, limit_num)
end


local function check_security(first_key, second_key, salt, security)
    server_security = generate_security(first_key, second_key, salt)
    local client_security = args[security]
    if server_security ~= client_security then
        resData(exception.DEFENDER_PARAMS_FAIL)
    end
    check_cache(limit_key, limit_num)
    return true
end

function access.execute(config)
    args = get_all_args()
    
    local uri = ngx.var.uri
    local limit_config = config.limit_config
    local defender_config = config.defender_config
    
    local limit_key, limit_num = limit_config.limit_key, limit_config.limit_num_per_second
    
    local salt, security = defender_config.salt_value, defender_config.security_key_name
    local first_key, second_key = defender_config.first_key_name, defender_config.second_key_name
    local postern_key, postern_secret = defender_config.postern_key_name, defender_config.postern_secret_value
    
    if true == check_postern(postern_key, postern_secret) then
        return
    end
    if true == check_special(uri, special) then
        return
    end
    
    if true == check_security(first_key, second_key, salt, security) then
        return
    end
end

return access

