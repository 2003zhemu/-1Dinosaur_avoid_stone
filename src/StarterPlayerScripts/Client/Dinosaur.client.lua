local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Zone = require(game.ReplicatedStorage.Packages.Zone)
local unitConfig = require(game.ReplicatedStorage._genConfigs.battle_tbunit)
local HttpService = game:GetService("HttpService")
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Dinosaurs = game.Workspace:WaitForChild("Dinosaurs", 10)
local wukong = require(game.ReplicatedStorage.WuKong)

for _, dinosaur in pairs(Dinosaurs:GetChildren()) do
    task.spawn(function()
        local zonePart = dinosaur:FindFirstChild("Zone")
        if not zonePart then
            repeat
                zonePart = dinosaur:FindFirstChild("Zone")
                task.wait(0.1)
            until zonePart
        end
        local Region = Zone.new(zonePart)
        Region.playerEntered:Connect(function(player)
            if player == localPlayer then  --玩家请求切换骑乘恐龙
                local rideId = player:GetAttribute("RideId")  --当前骑乘的恐龙
				local currentId = tonumber(dinosaur.Name)
                if rideId and rideId == currentId then  --已经在骑乘了
                    return
                end
                local config = unitConfig[currentId]
                if not config then
                    return
                end
                if currentId == 11 then  --付费恐龙
                    if not player:GetAttribute(Defines.GamePass["付费恐龙"].Key) then
                        --弹出购买页面
                        wukong:ExecuteQuery(`/现金/通行证/付费恐龙?弹出购买窗口`)
                        return
                    end
                    EventBus.FireServer(EventDefines["切换骑乘恐龙"], { RideId = currentId })
                else
                    local unlocked = {}
                    local unlockedStr = localPlayer:GetAttribute("BuyedDinos")
                    if unlockedStr then
                        unlocked = HttpService:JSONDecode(unlockedStr)
                    end
                    if unlocked[`dino{currentId}`] then
                        EventBus.FireServer(EventDefines["切换骑乘恐龙"], { RideId = currentId })
                    else
                        local needCups = config.NeedCups
                        local hasCups = player:GetAttribute("Cups")
                        if hasCups and needCups and hasCups >= needCups then
                            EventBus.FireServer(EventDefines["玩家解锁恐龙"], { DinoId = currentId })
                        end
                    end
                end
            end
        end)
    end)
end

--双倍奖杯
 local zonePart = game.Workspace.Map.DoubleCups:FindFirstChild("Zone")
if not zonePart then
    repeat
        zonePart = game.Workspace.Map.DoubleCups:FindFirstChild("Zone")
        task.wait(0.1)
    until zonePart
end
local Region = Zone.new(zonePart)
Region.playerEntered:Connect(function(player)
    if player == localPlayer then
        if not localPlayer:GetAttribute(Defines.GamePass["双倍奖杯"].Key) then
            wukong:ExecuteQuery(`/现金/通行证/双倍奖杯?弹出购买窗口`)
        end
    end
end)
