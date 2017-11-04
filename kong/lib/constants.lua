local constants = {}

constants.CONTENT_TYPE_WAS_NIL = { code = 100001, data = {}, msg = 'The contentType was nil' }
constants.BODY_MISS_DATA = { code = 100003, data = {}, msg = 'The body was missing data' }
constants.BODY_DATA_FAIL = { code = 100004, data = {}, msg = 'The body data was fail' }
constants.PARAMS_WAS_FAIL = { code = 100006, data = {}, msg = 'The query or bodys dataType was failed' }
constants.HTTP_LIB_ERROR = { code = 100007, data = {}, msg = 'The http and httpc was nil.' }
constants.REQUEST_WAS_FAIL = { code = 100008, data = {}, msg = "The request was fail" }

return constants