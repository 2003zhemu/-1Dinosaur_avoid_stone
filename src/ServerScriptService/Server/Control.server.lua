local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local ToolHelper = require(game.ReplicatedStorage.Helper.ToolHelper)

local PlayerCache = {}

EventBus.ConnectC2S(function(player, eventName, params)
    if eventName == "ControlEditSpeed" then  --管理员编辑速度
        local speed = params
        if not player:GetAttribute(Defines.GamePass["控制台"].Key) then
            return
        end
        if speed and speed > 0 then
            player:SetAttribute("ControlSpeed", speed)
        end
    end

    if eventName == "ControlEditStage" then  --管理员编辑关卡
        local stage = params
        if not stage or stage <= 0 then
            return
        end
        if not player:GetAttribute(Defines.GamePass["控制台"].Key) then
            return
        end
        --传送到指定关卡
        local goCFrame = Defines.RespawnCFrames[stage]
        if goCFrame and player.Character then
            local rootPart = player.Character.PrimaryPart or player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.AssemblyLinearVelocity = Vector3.zero
                rootPart.AssemblyAngularVelocity = Vector3.zero
                rootPart.Anchored = true
            end
            player.Character:PivotTo(goCFrame)
            task.wait(0.2)
            if rootPart then
                rootPart.Anchored = false
            end
        end
        
        if stage == 1 then
            player:SetAttribute("InLobby", true)
            player:SetAttribute("InStage", nil)
        else
            player:SetAttribute("InLobby", false)
            player:SetAttribute("InStage", stage - 1)
        end
    end

    if eventName == "SpawnMode" then  --编辑工具生成模式
        local spawnType = params
        if not player:GetAttribute(Defines.GamePass["控制台"].Key) then
            return
        end
        if not PlayerCache[player.UserId] then
            PlayerCache[player.UserId] = {}
        end
        if spawnType == "All" then
            PlayerCache[player.UserId].SpawnType = "All"
        elseif spawnType == "Current" then
            PlayerCache[player.UserId].SpawnType = "Current"
        end
    end

    if eventName == "SpawnItem_Owen" then  --管理员自己装备道具
        local itemId = params
        if not itemId or itemId <= 0 then
            return
        end
        if not player:GetAttribute(Defines.GamePass["控制台"].Key) then
            return
        end
        ToolHelper.UseTool(player, itemId)
    end

    if eventName == "SpawnItem_All" then  --管理员生成场景道具
        local itemId = params
        if not itemId or itemId <= 0 then
            return
        end
        if PlayerCache[player.UserId] and PlayerCache[player.UserId].SpawnTime and os.clock() - PlayerCache[player.UserId].SpawnTime < 1 then
            return
        end
        if not player:GetAttribute(Defines.GamePass["控制台"].Key) then
            return
        end
        local inStage = player:GetAttribute("InStage") or 1
        local spawnType = "Current"
        if PlayerCache[player.UserId] and PlayerCache[player.UserId].SpawnType then
            spawnType = PlayerCache[player.UserId].SpawnType
        end
        if not spawnType then
            return
        end
        if spawnType == "All" then
            --全部关卡里随机一个
            inStage = math.random(1, Defines.StageCount)
        end
        if not PlayerCache[player.UserId] then
            PlayerCache[player.UserId] = {}
        end
        PlayerCache[player.UserId].SpawnTime = os.clock()
        EventBus.Fire("ControlSpawnTool", {
            Stage = inStage,
            ToolIndex = itemId,
        })
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
	PlayerCache[player.UserId] = nil
end)