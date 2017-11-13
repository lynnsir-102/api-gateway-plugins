local exception = {}

exception.CONTENT_TYPE_WAS_NIL = { code = 100001, data = {}, msg = "The contentType was nil" }
exception.PARAMS_WAS_FAIL = { code = 100002, data = {}, msg = "The query or bodys dataType was failed" }
exception.REQUEST_WAS_FAIL = { code = 100003, data = {}, msg = "The request was fail" }
exception.JSON_DECODE_WAS_FAIL = { code = 100004, data = {}, msg = "Json decode was fail" }
exception.BOUNDARY_WAS_NIL = { code = 100005, data = {}, msg = "Boundary was nil" }

return exception