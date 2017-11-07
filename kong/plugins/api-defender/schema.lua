return {
  fields = {
    salt_value = {type = "string", required = true},
    first_key_name = {type = "string", required = true},
    second_key_name = {type = "string", required = true},
    security_key_name = {type = "string", required = true},
    postern_key_name = {type = "string", required = false, default = 'lynn-secret'},
    postern_secret_value = {type = "string", required = false, default = 'whosyourdaddy'}
  }
}