local module = {}

local MessagingService = game:GetService("MessagingService")

--订阅消息
MessagingService:SubscribeAsync("WebInformation", function(message)
    local key = message.Data.Type
    local ins = script.parent.parent:FindFirstChild(key)
    ins.Value = message.Data.Data
    print("WebInformation",key,message.Data.Data)
end)

return module