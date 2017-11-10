local json = require 'json'

local resData = require 'kong.lib.response'
local constants = require 'kong.lib.constants'

local func = {}

function func.json_decode(str)
    local data = nil
    status, data = pcall(function(str) return json.decode(str) end, str)
    if false == status then
    	resData(constants.JSON_DECODE_WAS_FAIL)
    end
    return data
end

return func