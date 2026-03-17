local MailConfig = require(script.Parent.MailConfig)
local module = {}
local _handler = MailConfig.AttachmentHandler

function module.Set(func: (userId: number, senderId: number, attachment: {[string]: any}) -> any)
    _handler = func
end

function module.Handle(userId: number, senderId: number, attachment: {[string]: any})
    return _handler and _handler(userId, senderId, attachment)
end

return module