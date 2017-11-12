local func = require 'kong.lib.func'
local resData = require 'kong.lib.response'
local exception = require 'kong.lib.exception'

local http = nil

local function init()
	local httpc = nil

	if http == nil then
		http = require 'resty.http'
	end
	httpc = http.new()
	httpc:connect('0.0.0.0', 8000)
	return httpc
end

local function exec(url, params, httpc)
	local res, err = httpc:request_uri(url, params)
	local body = nil
	if not res then
		resData(exception.REQUEST_WAS_FAIL)
	end
	body = res.body
	body = func.json_decode(body)
	httpc:close()
	return body
end

local function request(url, option)
	local httpc = init()
	local params = option

	return exec(url, params, httpc)
end

return request
