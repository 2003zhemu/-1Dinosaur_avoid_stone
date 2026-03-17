local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Zone = require(game.ReplicatedStorage.Packages.Zone)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local localPlayer = Players.LocalPlayer
local TreadMills = game.Workspace:FindFirstChild("TreadMills")
if not TreadMills then
    repeat
        TreadMills = game.Workspace:FindFirstChild("TreadMills")
        task.wait(0.1)
    until TreadMills
end
local wukong = nil
local treadMillPass = {
    ["3倍跑步机"] = "三倍跑步机",
    ["9倍跑步机"] = "九倍跑步机",
    ["25倍跑步机"] = "25倍跑步机"
}
local treadMillCup = {
    ["2倍跑步机"] = 500
}

for k, treadMill in pairs(TreadMills:GetChildren()) do
   task.spawn(function()
        local zonePart = treadMill:FindFirstChild("Zone")
        if not zonePart then
            repeat
                zonePart = treadMill:FindFirstChild("Zone")
                task.wait(0.1)
            until zonePart
        end
        local Region = Zone.new(zonePart)
        Region.playerEntered:Connect(function(player)
            if player == localPlayer then  --玩家进入跑步机
                if not wukong then
                    wukong = require(game.ReplicatedStorage.WuKong)
                end
				--TODO 检测玩家是否符合跑步机要求
                local pass = treadMillPass[treadMill.Name]
                if pass then  --验证通行证
                    local purchaseCount = wukong:ExecuteQuery(`/现金/通行证/{pass}?获取已购买次数`)
                    if purchaseCount == 0 then
                        wukong:ExecuteQuery(`/现金/通行证/{pass}?弹出购买窗口`)
                        return
                    end
                end
                local cup = treadMillCup[treadMill.Name]
                if cup then  --验证奖杯
                    if localPlayer:GetAttribute("TotalCups") < cup then
                        return
                    end
                end

				--warn("玩家进入跑步机")
                localPlayer:SetAttribute("InRuning", true)
                local Wind = treadMill:FindFirstChild("Wind")
                if Wind then
                    for _, child in pairs(Wind:GetDescendants()) do
                        if child:IsA("ParticleEmitter") then
                            child.Enabled = true
                        end
                    end
                end
				--通知服务器玩家在跑步机上
				EventBus.FireServer(EventDefines["进入跑步机"], {TreadMill = treadMill.Name})
            end
        end)
		Region.playerExited:Connect(function(player)
            if player == localPlayer then  --玩家退出跑步机
				--warn("玩家退出跑步机")
                 local Wind = treadMill:FindFirstChild("Wind")
                if Wind then
                    for _, child in pairs(Wind:GetDescendants()) do
                        if child:IsA("ParticleEmitter") then
                            child.Enabled = false
                        end
                    end
                end
                localPlayer:SetAttribute("InRuning", false)
				EventBus.FireServer(EventDefines["退出跑步机"])
            end
        end)
    end)
end
