local json = require 'json'

local log = require 'kong.lib.log'

local function response(data)
  if data.code ~= 0 and data.code ~= 1 then
    log.err("code:"..data.code..",".."message:"..data.msg)
  end
  ngx.say(json.encode(data))
  ngx.exit(ngx.HTTP_OK)
end

return response
