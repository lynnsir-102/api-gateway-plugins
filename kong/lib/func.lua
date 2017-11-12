local func = {}

local json = require 'json'

local resData = require 'kong.lib.response'
local exception = require 'kong.lib.exception'

function func.json_decode(str)
    local data = nil
    status, data = pcall(function(str) return json.decode(str) end, str)
    if false == status then
    	resData(exception.JSON_DECODE_WAS_FAIL)
    end
    return data
end

return func