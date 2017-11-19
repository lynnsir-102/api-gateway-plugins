return {
    fields = {
        defender_config = {
            type = 'table', 
            schema = {
                fields = {
                    salt_value = {type = "string", required = true}, 
                    first_key_name = {type = "string", required = true}, 
                    second_key_name = {type = "string", required = true}, 
                    security_key_name = {type = "string", required = true}, 
                    postern_key_name = {type = "string", required = false, default = 'lynn-secret'}, 
                    postern_secret_value = {type = "string", required = false, default = 'whosyourdaddy'}
                }
            }
        }, 
        limit_config = {
            type = 'table', 
            schema = {
                fields = {
                    limit_key = {type = "string", required = true}, 
                    limit_num_per_second = {type = "number", required = false, default = 5}
                }
            }
        }
    }, 
    self_check = function (schema, plugin_t, dao, is_updating)
        return true
    end
}
