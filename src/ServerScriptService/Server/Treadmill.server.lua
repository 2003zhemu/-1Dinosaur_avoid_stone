local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Zone = require(game.ReplicatedStorage.Packages.Zone)
local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local TreadMills = game.Workspace:FindFirstChild("TreadMills")
if not TreadMills then
    repeat
        TreadMills = game.Workspace:FindFirstChild("TreadMills")
        task.wait(0.1)
    until TreadMills
end

local treadMillPass = {
    ["3倍跑步机"] = "三倍跑步机",
    ["9倍跑步机"] = "九倍跑步机",
    ["25倍跑步机"] = "25倍跑步机"
}
local treadMillCup = {
    ["2倍跑步机"] = 500
}
local RuningRate = {
    ["3倍跑步机"] = 3,
    ["9倍跑步机"] = 9,
    ["25倍跑步机"] = 25,
    ["跑步机1"] = 0,
    ["跑步机2"] = 0,
    ["2倍跑步机"] = 1,
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
            --TODO 检测玩家是否符合跑步机要求
            local pass = treadMillPass[treadMill.Name]
            if pass then  --验证通行证
                if wukongServer.HasFacade(player.UserId) then
                    local facade = wukongServer.GetFacade(player.UserId)
                    local purchaseCount = facade:ExecuteQuery(`/现金/通行证/{pass}?获取已购买次数`)
                    if purchaseCount == 0 then
                        facade:ExecuteQuery(`/现金/通行证/{pass}?弹出购买窗口`)
                        return
                    end
                end
            end
            local cup = treadMillCup[treadMill.Name]
            if cup then  --验证奖杯
                if player:GetAttribute("TotalCups") < cup then
                    return
                end
            end

            --warn("玩家进入跑步机")
            player:SetAttribute("InRuning", true)
            player:SetAttribute("RuningRate", RuningRate[treadMill.Name])

            EventBus.FireClient(player, EventDefines["进入跑步机"], {TreadMill = treadMill.Name})
        end)

		Region.playerExited:Connect(function(player)
            player:SetAttribute("InRuning", false)
            player:SetAttribute("RuningRate", 0)
            EventBus.FireClient(player, EventDefines["退出跑步机"], {TreadMill = treadMill.Name})
        end)
    end)
end
