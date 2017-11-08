return {
	no_consumer = false,
	fields = {
		request_config = {
			type = 'table',
			schema = {
				fields = {
					names = { type = 'array', required = true, unique = true },
					urls = { type = 'array', required = true },
					methods = { type = 'array', required = true, enum = { 'GET', 'POST' } },
					types = { type = 'array', required = true, enum = { 'json', 'form' } }
				}
			}
		}
	},
	self_check = function (schema, plugin_t, dao, is_updating)
		return true
	end
}