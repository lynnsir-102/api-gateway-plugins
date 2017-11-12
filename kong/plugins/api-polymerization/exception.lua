local exception = {}

exception.REQ_WAS_SUBREQUEST = { code = 120001, data = {}, msg = 'The request is subrequest' }
exception.CONFIG_DATA_FAIL = { code = 120002, data = {}, msg = 'The plugins config was failed' }

return exception