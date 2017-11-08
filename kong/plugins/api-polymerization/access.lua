local params = require 'kong.lib.params'
local request = require 'kong.lib.request'
local resData = require 'kong.lib.response'

local constants = require 'kong.plugins.api-polymerization.constants'
local access = {}

local function check(config)
	local names = config.request_config.names
	local urls  = config.request_config.urls
	local types = config.request_config.types

	if ngx.is_subrequest then
		resData(constants.REQ_WAS_SUBREQUEST)
	end
	if #names ~= #urls or #names ~= #types then
		resData(constants.CONFIG_DATA_FAIL)
	end
end

local function init(config, args, body)
	local resps = {}

	for i, v in ipairs(config.request_config.names) do
		local name = config.request_config.names[i]
		local url = config.request_config.urls[i]
		local method = config.request_config.methods[i]
		local type = config.request_config.types[i]
		local subData = body[name]
		local options = {}

		options['method'] = method
		if(type == 'json') then
			options['headers'] = {
				['Content-Type'] = 'application/json;charset=UTF-8'
			}
		end
		if(type == 'form') then
			options['headers'] = {
				['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
			}
		end

		if(method == 'GET') then
			resps[name] = request(url..'?'..ngx.encode_args(args), options)
		end
		if(method == 'POST') then
			options['body'] = ngx.encode_args(body)
			resps[name] = request(url, options)
		end
		options = {}
	end
	resData({ code = 1, data = resps, msg = '' })
end

function access.execute(config)
	local params = params()
	local args, body = params.args, params.body
	local data = nil

	check(config)
	init(config, args, body)
end

return access