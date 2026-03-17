local module = {}
local IS_SERVER = game:GetService("RunService"):IsServer()

local client, server
if IS_SERVER then
    server = require(script.server)
else
    client = require(script.client)
end
local function delivery(key)
    local m = nil
    if IS_SERVER then
        m = server
    else
        m = client
    end
    return m[key]
end

table.clear(module)
setmetatable(module, {
    __index = function(_, key)
        return delivery(key)
    end,
    __newindex = function()
        error("Attempt to update RankSystem")
    end
})

return module