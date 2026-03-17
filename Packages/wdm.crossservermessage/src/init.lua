local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "MessagingService can only be used on the server")

local MessagingService = game:GetService("MessagingService")
local MESSAGE_TOPIC = game.JobId
if MESSAGE_TOPIC == "" then
    MESSAGE_TOPIC = "Studio"
end

local module = {}
local _callbacks = {}

function module.SendWithJobId(jobId, message)
    local suc, res = pcall(function()
        return MessagingService:PublishAsync(jobId, message)
    end)
    return suc, res
end

function module.OnReceived(callback)
    table.insert(_callbacks, callback)
end

print("MessagingService initialized with topic: " .. MESSAGE_TOPIC)
MessagingService:SubscribeAsync(MESSAGE_TOPIC, function(message)
    for _, callback in ipairs(_callbacks) do
        spawn(function()
            pcall(callback, message.Data)
        end)
    end
end)

return module