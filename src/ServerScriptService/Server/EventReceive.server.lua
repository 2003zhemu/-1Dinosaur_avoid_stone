local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local Follow = require(game.ReplicatedStorage.Modules.Follow)
local HttpService = game:GetService("HttpService")
local RagdollHelper = require(game.ReplicatedStorage.Helper.RagdollHelper)
local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local SpeedHelper = require(game.ReplicatedStorage.Helper.SpeedHelper)
local unitConfig = require(game.ReplicatedStorage._genConfigs.battle_tbunit)
local auraConfig = require(game.ReplicatedStorage._genConfigs.battle_tbaura)
local stageConfigs = require(game.ReplicatedStorage._genConfigs.battle_tbstage)
local rebirthConfig = require(game.ReplicatedStorage._genConfigs.battle_tbreborn)

local ContainerHelper = nil
local RuningRate = {
    ["3倍跑步机"] = 3,
    ["9倍跑步机"] = 9,
    ["25倍跑步机"] = 25,
    ["跑步机1"] = 0,
    ["跑步机2"] = 0,
    ["2倍跑步机"] = 1,
}
local treadMillPass = {
    ["3倍跑步机"] = "三倍跑步机",
    ["9倍跑步机"] = "九倍跑步机",
    ["25倍跑步机"] = "25倍跑步机"
}
local treadMillCup = {
    ["2倍跑步机"] = 500
}
local lastClickTime = {}
EventBus.ConnectC2S(function(player, eventName, params)
    if eventName == EventDefines["玩家步数增加"] then  --增加玩家经验
        if not wukongServer.HasFacade(player.UserId) then
            return
        end
        if lastClickTime[player.UserId] and os.clock() - lastClickTime[player.UserId] < 0.3 then
            return
        end
        lastClickTime[player.UserId] = os.clock()
        local facade = wukongServer.GetFacade(player.UserId)
        if facade then
            local currentSpeed = SpeedHelper.GetSpeed(player)
            player:SetAttribute("RuningSpeed", currentSpeed)
           -- warn("玩家步数增加", currentSpeed, rate, player:GetAttribute("RideBonus"), player:GetAttribute("AuraBonus"), player:GetAttribute("RebornTimes"))
            facade:ExecuteAction("/属性/经验?属性增加", currentSpeed)
        end
    end

    if eventName == EventDefines["玩家重生"] then  --玩家重生
        if not wukongServer.HasFacade(player.UserId) then
            return
        end
        local facade = wukongServer.GetFacade(player.UserId)
        if facade then
            local curRebornTimes = player:GetAttribute("RebornTimes") --当前重生次数
            local curConfig = rebirthConfig["重生" .. curRebornTimes]
		    local maxLevel = curConfig.MaxLevel
            local curLevel = player:GetAttribute("UserLevel")
            if curLevel < maxLevel then
                return
            end
            facade:ExecuteAction("/属性/重生次数?属性增加", 1)
            task.delay(0.1,function()
                facade:ExecuteAction("/属性/经验?属性设为指定值", 0)
            end)
        end
    end

    -- if eventName == EventDefines["切换骑乘恐龙"] then  --切换骑乘恐龙
    --     local rideId = params.RideId
    --     if not rideId then
    --         return
    --     end
    --     if rideId == 11 then  --付费恐龙 检测通行证
    --         local pass = player:GetAttribute(Defines.GamePass["付费恐龙"].Key)
    --         if not pass then
    --             return
    --         end
    --     else
    --         if not ContainerHelper then
    --             ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
    --         end
    --         local buyed = {}
    --         local suc, data = ContainerHelper.GetContainerValue(player.UserId, `属性`, `解锁恐龙`)
    --         if suc and data then
    --             buyed = HttpService:JSONDecode(data)
    --         end
    --         buyed["dino1"] = true
    --         if not buyed[`dino{rideId}`] then
    --             return
    --         end
    --     end
         
    --     --切换骑乘恐龙
    --     if not wukongServer.HasFacade(player.UserId) then
    --         return
    --     end
    --     local facade = wukongServer.GetFacade(player.UserId)
    --     if facade then
    --         facade:ExecuteAction("/属性/骑乘恐龙?属性设为指定值", rideId)
    --     end

    --     -- local unitConfig = unitConfig[rideId]
    --     -- if not unitConfig then
    --     --     return
    --     -- end
    --     -- local needCups = unitConfig.NeedCups
    --     -- local hasCups = player:GetAttribute("TotalCups")
    --     -- if hasCups and needCups and hasCups >= needCups then
            
    --     -- end
    -- end

    -- if eventName == EventDefines["进入跑步机"] then  --进入跑步机
    --     local treadMill = params.TreadMill
    --     if not treadMill then
    --         return
    --     end
    --     if not wukongServer.HasFacade(player.UserId) then
    --         return
    --     end
    --     --TODO 检测玩家是否符合跑步机要求
    --     local facade = wukongServer.GetFacade(player.UserId)
    --     if not facade then
    --         return
    --     end
    --     local pass = treadMillPass[treadMill.Name]
    --     if pass then  --验证通行证
    --         local purchaseCount = facade:ExecuteQuery(`/现金/通行证/{pass}?获取已购买次数`)
    --         if purchaseCount == 0 then
    --             return
    --         end
    --     end
    --     local cup = treadMillCup[treadMill.Name]
    --     if cup then  --验证奖杯
    --         if player:GetAttribute("TotalCups") < cup then
    --             return
    --         end
    --     end

    --     player:SetAttribute("RuningRate", RuningRate[treadMill])
    -- end

    -- if eventName == EventDefines["退出跑步机"] then  --退出跑步机
    --     player:SetAttribute("RuningRate", 0)
    -- end

    if eventName == EventDefines["玩家死亡"] then  --死亡，进入布娃娃状态
        player:SetAttribute("IsDead", true)
        RagdollHelper.EnableRagdoll(player)
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
            end
        end
       -- warn("设置玩家死亡", player.Name)
    end
    
    if eventName == EventDefines["取消复活"] then  --回到出生点
        RagdollHelper.DisableRagdoll(player)

        local allPlayers = {player}  --需要处理的全部玩家
        for _, follower in pairs(Follow.GetFollowers(player)) do
            table.insert(allPlayers, follower)
        end
        --解除全部跟随
        Follow.RemoveAllFollowers(player)
        task.wait()
        --全部回到出生点
        for _, plr in pairs(allPlayers) do
            if plr.Character then
               -- warn("回到出生点", plr.Name)
                local rootPart = plr.Character.PrimaryPart or plr.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart.AssemblyLinearVelocity = Vector3.zero
                    rootPart.AssemblyAngularVelocity = Vector3.zero
                    rootPart.Anchored = true
                end
                plr.Character:PivotTo(Defines.RespawnCFrames[1])
                EventBus.FireClient(plr, EventDefines["回到出生点"], {CFrame = Defines.RespawnCFrames[1]})
                plr:SetAttribute("InLobby", true)
                plr:SetAttribute("InStage", nil)
                task.delay(0.2, function()
                    if rootPart then
                        rootPart.Anchored = false
                    end
                end)
            end
        end
       -- warn("取消复活，传送回原点", Defines.RespawnCFrames[1])
        player:SetAttribute("InLobby", true)
        player:SetAttribute("InStage", nil)
        player:SetAttribute("IsDead", false)
    end

    if eventName == EventDefines["奖杯复活"] then  --复活
        local curStage = player:GetAttribute("InStage")  --当前关卡
        if not curStage then return end
        local stageConfig = stageConfigs[curStage]
        if not stageConfig then return end
        local costCup = stageConfig.CostCup  --复活需要的奖杯数
        if not costCup then return end
        if not wukongServer.HasFacade(player.UserId) then
            return
        end
        local facade = wukongServer.GetFacade(player.UserId)
        if not facade then return end
        local hasCups = facade:ExecuteQuery("/货币/奖杯?属性数量")
        if hasCups and hasCups >= costCup then
            facade:ExecuteAction("/货币/奖杯?属性减少", costCup)
            RagdollHelper.DisableRagdoll(player)
            Follow.UpdateFollowPlayers(player)
            task.wait()
            --回到关卡起点
            local goCFrame = Defines.RespawnCFrames[curStage]
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
            
            if curStage == 1 then
                player:SetAttribute("InLobby", true)
                player:SetAttribute("InStage", nil)
            else
                player:SetAttribute("InLobby", false)
                player:SetAttribute("InStage", curStage - 1)
            end
            player:SetAttribute("IsDead", false)
        end
    end

    if eventName == EventDefines["免疫时受到伤害"] then  --免疫时受到伤害
        local damage = params.Damage
        if not player:GetAttribute("InImmuneTool") then  --如果不在免疫状态
            local Character = player.Character
            if not Character then return end
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if not Humanoid then return end
            Humanoid:TakeDamage(damage)
            return
        end
        if damage >= 100 then  --传送到关卡起始点
            RagdollHelper.DisableRagdoll(player)
            Follow.UpdateFollowPlayers(player)
            task.wait()
            local curStage = player:GetAttribute("InStage")  --当前关卡
            if not curStage then return end
            local goCFrame = Defines.RespawnCFrames[curStage]
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
            if curStage == 1 then
                player:SetAttribute("InLobby", true)
                player:SetAttribute("InStage", nil)
            else
                player:SetAttribute("InLobby", false)
                player:SetAttribute("InStage", curStage - 1)
            end
            player:SetAttribute("IsDead", false)
        end
    end

    if eventName == EventDefines["玩家掉落死亡"] then  --玩家掉落死亡
        local curStage = player:GetAttribute("InStage")  --当前关卡
        if not curStage then return end
        local stageConfig = stageConfigs[curStage]
        if not stageConfig then return end

        RagdollHelper.DisableRagdoll(player)
        Follow.UpdateFollowPlayers(player)
        task.wait()
        --回到关卡起点
        local goCFrame = Defines.RespawnCFrames[curStage]
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
        player:SetAttribute("IsDead", false)
    end

    if eventName == EventDefines["自定义速度"] then  --自定义速度
        local speed = params.CustomSpeed
        if speed then
            local suc, result = pcall(function()
                return tonumber(speed)
            end)
            if not suc then
                speed = 0
            end
            speed = result
            player:SetAttribute("UserCustomSpeed", speed)
        end
    end

    if eventName == EventDefines["奖杯购买特性"] then  --购买特性
        local id = params.Id
        if not id then return end
        local auraId = id
        local config = auraConfig[auraId]
        if not config then return end
        local hasCups = player:GetAttribute("Cups")
        local cost = config.CostCup
        
        if hasCups and cost and hasCups >= cost then
            if not wukongServer.HasFacade(player.UserId) then
                return
            end
            local facade = wukongServer.GetFacade(player.UserId)
            if facade then
                facade:ExecuteAction("/货币/奖杯?属性减少", cost)
            end  
            if not ContainerHelper then
                ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
            end
            local buyed = {}
            local suc, data = ContainerHelper.GetContainerValue(player.UserId, `属性`, `购买特性`)
            if suc and data then
                buyed = HttpService:JSONDecode(data)
            end
            buyed[config.Name] = true
            ContainerHelper.SetContainerValue(player.UserId, `属性`, `购买特性`, HttpService:JSONEncode(buyed))
            --装备当前购买的特性
            facade:ExecuteAction("/属性/装备特性?属性设为指定值", id)
        end
    end

    if eventName == EventDefines["装备特性"] then  --装备特性
        local id = params.Id
        if id == nil then return end

        --检查特性是否解锁
        if id > 0 then
            local config = auraConfig[id]
            if not config then return end
            if not ContainerHelper then
                ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
            end
            local buyed = {}
            local suc, data = ContainerHelper.GetContainerValue(player.UserId, `属性`, `购买特性`)
            if suc and data then
                buyed = HttpService:JSONDecode(data)
            end
            if not buyed[config.Name] then
                return
            end
        end
        if not wukongServer.HasFacade(player.UserId) then
            return
        end
        local facade = wukongServer.GetFacade(player.UserId)
        if facade then
            facade:ExecuteAction("/属性/装备特性?属性设为指定值", id)
        end  
    end 

    -- if eventName == EventDefines["玩家解锁恐龙"] then  --解锁恐龙
    --      local dinoId = params.DinoId
    --     if not dinoId then
    --         return
    --     end
    --     local unitConfig = unitConfig[dinoId]
    --     if not unitConfig then
    --         return
    --     end
    --     local needCups = unitConfig.NeedCups
    --     local hasCups = player:GetAttribute("Cups")
    --     if not (hasCups and hasCups >= needCups) then
    --         return
    --     end
    --     if not ContainerHelper then
    --         ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
    --     end
    --     local buyed = {}
    --     local suc, data = ContainerHelper.GetContainerValue(player.UserId, `属性`, `解锁恐龙`)
    --     if suc and data then
    --         buyed = HttpService:JSONDecode(data)
    --     end
    --     buyed["dino1"] = true
    --     buyed[`dino{dinoId}`] = true
    --     local buyedStr = HttpService:JSONEncode(buyed)
    --     ContainerHelper.SetContainerValue(player.UserId, `属性`, `解锁恐龙`, buyedStr)
    --     player:SetAttribute("BuyedDinos", buyedStr)

    --     --解锁后直接切换骑乘恐龙
    --     if wukongServer.HasFacade(player.UserId) then
    --         local facade = wukongServer.GetFacade(player.UserId)
    --         if facade then
    --             facade:ExecuteAction("/属性/骑乘恐龙?属性设为指定值", dinoId)
    --         end
    --     end
    -- end

    if eventName == EventDefines["邀请拒绝"] then  --拒绝xx的邀请
        player:SetAttribute("InviteStatus", 0)  --恢复状态
        local refusePlayerId = params.PlayerId
        if not refusePlayerId then
            return
        end
        local refusePlayer = game.Players:GetPlayerByUserId(refusePlayerId)
        if refusePlayer then  --一键邀请时 被拒绝就恢复状态
            if refusePlayer:GetAttribute("InviteStatus") == 3 then
                refusePlayer:SetAttribute("InviteStatus", 0)
            end
            EventBus.FireClient(refusePlayer, EventDefines["服务端消息提示"], {Type = "Info", Text = `You refuse invite by {player.Name}`})
        end
    end

    if eventName == EventDefines["同意邀请"] then  --同意xx的邀请
        local invitePlayerId = params.PlayerId
        if not invitePlayerId then
            if player:GetAttribute("InviteStatus") == 3 then
                player:SetAttribute("InviteStatus", 0)
            end
            return
        end
        local invitePlayer = game.Players:GetPlayerByUserId(invitePlayerId)
        if invitePlayer then
            player:SetAttribute("InviteStatus", 2)
            player:SetAttribute("FollowPlayerId", invitePlayerId)
            Follow.AddFollower(invitePlayer, player)
            EventBus.FireClient(player, EventDefines["进入跟随状态"])
        end
    end
    
    if eventName == EventDefines["取消跟随状态"] then  --取消跟随状态
        --获取当前所在关卡
        local followPlayerId = player:GetAttribute("FollowPlayerId")
        if not followPlayerId then
            return
        end
        local followPlayer = game.Players:GetPlayerByUserId(followPlayerId)
        if not followPlayer then
            return
        end
        local stage = followPlayer:GetAttribute("InStage")
        if not stage then
            stage = 1
        end
        player:SetAttribute("InStage", stage)  --玩家当前所在关卡
        Follow.RemoveFollower(followPlayer, player)
        task.wait()
        --主动解除后，回到当前所在关卡的初始点
        if player.Character then
            player.Character:PivotTo(Defines.RespawnCFrames[stage])
        end
    end
end)

EventBus.Connect(function(eventName, params)
    if eventName == EventDefines["切换骑乘恐龙"] then  --切换骑乘恐龙
        local rideId = params.RideId
        local player = params.Player
        if not rideId or not player then
            return
        end
        if rideId == 11 then  --付费恐龙 检测通行证
            local pass = player:GetAttribute(Defines.GamePass["付费恐龙"].Key)
            if not pass then
                return
            end
        else
            if not ContainerHelper then
                ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
            end
            local buyed = {}
            local suc, data = ContainerHelper.GetContainerValue(player.UserId, `属性`, `解锁恐龙`)
            if suc and data then
                buyed = HttpService:JSONDecode(data)
            end
            buyed["dino1"] = true
            if not buyed[`dino{rideId}`] then
                return
            end
        end
         
        --切换骑乘恐龙
        if not wukongServer.HasFacade(player.UserId) then
            return
        end
        local facade = wukongServer.GetFacade(player.UserId)
        if facade then
            facade:ExecuteAction("/属性/骑乘恐龙?属性设为指定值", rideId)
        end
    end

    if eventName == EventDefines["玩家解锁恐龙"] then  --解锁恐龙
         local dinoId = params.DinoId
         local player = params.Player
        if not dinoId or not player then    
            return
        end
        local unitConfig = unitConfig[dinoId]
        if not unitConfig then
            return
        end
        local needCups = unitConfig.NeedCups
        local hasCups = player:GetAttribute("Cups")
        if not (hasCups and hasCups >= needCups) then
            return
        end
        if not ContainerHelper then
            ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
        end
        local buyed = {}
        local suc, data = ContainerHelper.GetContainerValue(player.UserId, `属性`, `解锁恐龙`)
        if suc and data then
            buyed = HttpService:JSONDecode(data)
        end
        buyed["dino1"] = true
        buyed[`dino{dinoId}`] = true
        local buyedStr = HttpService:JSONEncode(buyed)
        ContainerHelper.SetContainerValue(player.UserId, `属性`, `解锁恐龙`, buyedStr)
        player:SetAttribute("BuyedDinos", buyedStr)

        --解锁后直接切换骑乘恐龙
        if wukongServer.HasFacade(player.UserId) then
            local facade = wukongServer.GetFacade(player.UserId)
            if facade then
                facade:ExecuteAction("/属性/骑乘恐龙?属性设为指定值", dinoId)
            end
        end
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
	lastClickTime[player.UserId] = nil
end)