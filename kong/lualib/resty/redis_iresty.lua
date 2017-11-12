local redis_c = require "resty.redis"

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
		new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 155)
_M._VERSION = '0.01'

local commands = {
		"append",            "auth",              "bgrewriteaof",
		"bgsave",            "bitcount",          "bitop",
		"blpop",             "brpop",
		"brpoplpush",        "client",            "config",
		"dbsize",
		"debug",             "decr",              "decrby",
		"del",               "discard",           "dump",
		"echo",
		"eval",              "exec",              "exists",
		"expire",            "expireat",          "flushall",
		"flushdb",           "get",               "getbit",
		"getrange",          "getset",            "hdel",
		"hexists",           "hget",              "hgetall",
		"hincrby",           "hincrbyfloat",      "hkeys",
		"hlen",
		"hmget",              "hmset",      "hscan",
		"hset",
		"hsetnx",            "hvals",             "incr",
		"incrby",            "incrbyfloat",       "info",
		"keys",
		"lastsave",          "lindex",            "linsert",
		"llen",              "lpop",              "lpush",
		"lpushx",            "lrange",            "lrem",
		"lset",              "ltrim",             "mget",
		"migrate",
		"monitor",           "move",              "mset",
		"msetnx",            "multi",             "object",
		"persist",           "pexpire",           "pexpireat",
		"ping",              "psetex",            "psubscribe",
		"pttl",
		"publish",      --[[ "punsubscribe", ]]   "pubsub",
		"quit",
		"randomkey",         "rename",            "renamenx",
		"restore",
		"rpop",              "rpoplpush",         "rpush",
		"rpushx",            "sadd",              "save",
		"scan",              "scard",             "script",
		"sdiff",             "sdiffstore",
		"select",            "set",               "setbit",
		"setex",             "setnx",             "setrange",
		"shutdown",          "sinter",            "sinterstore",
		"sismember",         "slaveof",           "slowlog",
		"smembers",          "smove",             "sort",
		"spop",              "srandmember",       "srem",
		"sscan",
		"strlen",       --[[ "subscribe",  ]]     "sunion",
		"sunionstore",       "sync",              "time",
		"ttl",
		"type",         --[[ "unsubscribe", ]]    "unwatch",
		"watch",             "zadd",              "zcard",
		"zcount",            "zincrby",           "zinterstore",
		"zrange",            "zrangebyscore",     "zrank",
		"zrem",              "zremrangebyrank",   "zremrangebyscore",
		"zrevrange",         "zrevrangebyscore",  "zrevrank",
		"zscan",
		"zscore",            "zunionstore",       "evalsha"
}

local mt = { __index = _M }

local function is_redis_null( res )
		if type(res) == "table" then
				for k,v in pairs(res) do
						if v ~= ngx.null then
								return false
						end
				end
				return true
		elseif res == ngx.null then
				return true
		elseif res == nil then
				return true
		end

		return false
end

function _M.connect_mod(self)
	local redis, err = redis_c:new()
	if not redis or err then
		return nil, err
	end

	redis:set_timeout(self.timeout)
	local ok, err = redis:connect(self.host, self.port)
	if not ok or err then
		return nil, err
	end

	if self.password then
		local times, err = redis:get_reused_times()
		if times == 0 then
			local ok, err = redis:auth(self.password)
			if not ok or err then
				return nil, err
			end
		elseif err then
			return nil, err
		end
	end

	return redis, nil
end


function _M.set_keepalive_mod(self, redis)
	return redis:set_keepalive(self.keepalive, self.pool_size)
end


function _M.init_pipeline(self)
	self._reqs = {}
end


function _M.commit_pipeline(self)
	local reqs = self._reqs

	if reqs == nil or #reqs == 0 then
		return {}, 'no pipeline'
	else
		self._reqs = nil
	end

	local redis, err = self:connect_mod()
	if not redis or err then
		return {}, err
	end

	redis:init_pipeline()
	for _, v in ipairs(reqs) do
		local method = redis[v[1]]
		table.remove(v, 1)
		method(redis, unpack(v))
	end

	local results, err = redis:commit_pipeline()
	if not results or err then
		return {}, err
	end

	if is_redis_null(results) then
		results = {}
	end

	local ok, err = self:set_keepalive_mod(redis)
	if not ok or err then
		return {}, err
	end

	for k, v in ipairs(results) do
		if is_redis_null(v) then
			results[k] = nil
		end
	end

	return results, nil
end


function _M.subscribe(self, channel)
	local redis, err = self:connect_mod()
	if not redis or err then
		return {}, err
	end

	local res, err = redis:subscribe(channel)
	if not res or err then
		return nil, err
	end

	local function do_read_func(do_read)
		if do_read == nil or do_read == true then
			local res, err = redis:read_reply()
			if not res or err then
				return nil, err
			end
			return res
		end

		redis:unsubscribe(channel)
		self.set_keepalive_mod(redis)
		return
	end

	return do_read_func
end

local function do_command(self, cmd, ...)
	if self._reqs then
		self._reqs:insert({cmd, ...})
		return
	end

	local redis, err = self:connect_mod()
	if not redis or err then
		return {}, err
	end

	local method = redis[cmd]
	local result, err = method(redis, ...)
	if not result or err then
		return nil, err
	end

	if is_redis_null(result) then
		result = nil
	end

	local ok, err = self:set_keepalive_mod(redis)
	if not ok or err then
		return nil, err
	end

	return result, nil
end

function _M.new(self, opts)
	opts.host = opts.host or '127.0.0.1'
	opts.port = opts.port or 6379
	opts.db = opts.db or 0
	opts.password = opts.password or nil
	opts.timeout = opts.timeout or 1000
	opts.keepalive = opts.keepalive or 60000
	opts.pool_size = opts.pool_size or 100
	opts._reqs = nil

	for i = 1, #commands do
		local cmd = commands[i]
		_M[cmd] =
			function (self, ...)
				return do_command(self, cmd, ...)
			end
	end

	return setmetatable(opts, mt)
end

return _M