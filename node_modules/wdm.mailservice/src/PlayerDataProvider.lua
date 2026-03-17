local MailConfig = require(script.Parent.MailConfig)
local module = {}
local _provider = MailConfig.DataProvider

function module.Set(func: (userId: number) -> any)
    _provider = func
end

function module.Get(userId: number)
    return _provider and _provider(userId)
end

return module