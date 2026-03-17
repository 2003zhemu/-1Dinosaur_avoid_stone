local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local localPlayer = game.Players.LocalPlayer

EventBus.ConnectS2C(function(eventName, params)
    if eventName == EventDefines["进入跑步机"] then
        local TreadMillName = params.TreadMill
        local path = game.Workspace:FindFirstChild("TreadMills")
        if not path then return end

        local TreadMill = path:FindFirstChild(TreadMillName)
        if not TreadMill then return end

        local Wind = TreadMill:FindFirstChild("Wind")
        if Wind then
            for _, child in pairs(Wind:GetDescendants()) do
                if child:IsA("ParticleEmitter") then
                    child.Enabled = true
                end
            end
        end
    end

    if eventName == EventDefines["退出跑步机"] then
        local TreadMillName = params.TreadMill
        local path = game.Workspace:FindFirstChild("TreadMills")
        if not path then return end

        local TreadMill = path:FindFirstChild(TreadMillName)
        if not TreadMill then return end

        local Wind = TreadMill:FindFirstChild("Wind")
        if Wind then
            for _, child in pairs(Wind:GetDescendants()) do
                if child:IsA("ParticleEmitter") then
                    child.Enabled = false
                end
            end
        end
    end
end)