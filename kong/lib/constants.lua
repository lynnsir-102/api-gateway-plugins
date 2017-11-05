local constants = {}

constants.CONTENT_TYPE_WAS_NIL = { code = 100001, data = {}, msg = 'The contentType was nil' }
constants.PARAMS_WAS_FAIL = { code = 100002, data = {}, msg = 'The query or bodys dataType was failed' }
constants.REQUEST_WAS_FAIL = { code = 100003, data = {}, msg = "The request was fail" }
constants.JSON_DECODE_WAS_FAIL = { code = 100004, data = {}, msg = "Json decode was fail" }
constants.DEFENDER_PARAMS_LACKING = { code = 100005 ,data = {}, msg = "An internal server error has occurred on the server" }
constants.DEFENDER_PARAMS_FAIL = { code = 100006, data = {}, msg = "An internal server error has occurred on the server" }

return constants