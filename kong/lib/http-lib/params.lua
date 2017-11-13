local json = require 'json'

local resData = require 'kong.lib.response'
local exception = require 'kong.lib.exception'

local ngxReq = ngx.req

local function init()
	ngxReq.read_body()
end

local function exec()
	local method = ngxReq.get_method()
	local headers = ngxReq.get_headers()
	local args, body = nil, nil

	args = ngxReq.get_uri_args()
	if method == 'GET' then
		return { args = args, body = {} }
	end
	if headers['Content-Type'] == nil then
		resData(exception.CONTENT_TYPE_WAS_NIL)
	end
	if string.find(headers['Content-Type'], 'application/x%-www%-form%-urlencoded') then
		body = ngxReq.get_post_args()
	elseif string.find(headers['Content-Type'], 'multipart/form%-data') then
		local body_data = ngx.req.get_body_data()
		local multipart = require("kong.lib.multipart")
		local multipart_data = multipart(body_data, headers["content-type"])
		body = multipart_data:get_all()
	else
		body = json.decode(ngxReq.get_body_data())
	end
	if type(args) ~= 'table' or type(body) ~= 'table' then
		resData(exception.PARAMS_WAS_FAIL)
	end
	return { args = args, body = body }
end

local function params()
	init()
	return exec()
end

return params
