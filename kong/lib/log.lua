local log = {}

function log.alert(message)
  ngx.log(ngx.ALERT, message)
end

function log.debug(message)
  ngx.log(ngx.DEBUG, message)
end

function log.err(message)
  ngx.log(ngx.ERR, message)
end

function log.info(message)
  ngx.log(ngx.INFO, message)
end

function log.notice(message)
  ngx.log(ngx.NOTICE, message)
end

function log.warn(message)
  ngx.log(ngx.WARN, message)
end

return log