local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local SpeedHelper = require(game.ReplicatedStorage.Helper.SpeedHelper)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local RideHelper = require(game.ReplicatedStorage.Helper.RideHelper)
local ToolHelper = require(game.ReplicatedStorage.Helper.ToolHelper)
local unitConfig = require(game.ReplicatedStorage._genConfigs.battle_tbunit)
local rebornConfig = require(game.ReplicatedStorage._genConfigs.battle_tbreborn)
local userLevel = require(game.ReplicatedStorage._genConfigs.battle_tbplayerlevel)
local ContainerHelper = nil

local function SetUserLevel(player, exp)
	local level = 0
    local speed = 0
	local rebornTimes = player:GetAttribute("RebornTimes")
	if not rebornTimes then
		rebornTimes = 0
	end
	local rebornCfg = rebornConfig[`重生{rebornTimes}`]
	if not rebornCfg then
		rebornCfg = rebornConfig[`重生0`]
	end
	local maxLevel = rebornCfg.MaxLevel

    for _, config in pairs(userLevel) do
		if maxLevel == config.Id then
			if exp >= config.MinExp then
				level = config.Id
				speed = config.Speed
				break
			end
		end
        if exp >= config.MinExp and exp < config.MaxExp then
            level = config.Id
            speed = config.Speed
            break
        end
    end
	level = math.clamp(level, 0, maxLevel)
	speed = userLevel[level].Speed

	local rate = 1
	-- if player:GetAttribute("IsVip") then
	-- 	rate = 2
	-- end
    player:SetAttribute("UserLevel", level)
    player:SetAttribute("UserMaxSpeed", speed * rate)
	if level == 360 then
		player:SetAttribute("InMaxLevel", true)
	end
end

game.Players.PlayerAdded:Connect(function(player)
	--player:LoadCharacterAsync()
	ToolHelper.Init(player)
    SpeedHelper.Init(player)
    RideHelper.Init(player)
	player.CharacterAdded:Connect(function(character)
		character.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			repeat
				humanoid = character:FindFirstChild("Humanoid")
				task.wait(0.1)
			until humanoid
        end
		humanoid.BreakJointsOnDeath = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end)
	-- player.CharacterAdded:Connect(function(character)
	-- 	local humanoid = character:FindFirstChild("Humanoid")
	-- 	if not humanoid then
	-- 		repeat
	-- 			humanoid = character:FindFirstChild("Humanoid")
	-- 			task.wait(0.1)
	-- 		until humanoid
    --     end
	-- 	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	-- 	humanoid:GetPropertyChangedSignal("Health"):Connect(function()
	-- 		--玩家死亡时
	-- 		if humanoid.Health <= 0 then
				
	-- 		end
	-- 	end)
    -- end)
end)

local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
wukongServer.ConnectUserRegisterEvent(function(playerId)
	local player = Players:GetPlayerByUserId(playerId)
	if not player then
		return
	end

	if wukongServer.HasFacade(player.UserId) then
		local facade = wukongServer.GetFacade(player.UserId)
		
		--重生次数
		local rebornTimes = facade:ExecuteQuery("/属性/重生次数?属性数量")
		player:SetAttribute("RebornTimes", math.min(rebornTimes, 23))
		facade:RegisterSlotObserver("/属性/重生次数", function(slot, value)
			local rebornTimes = facade:ExecuteQuery("/属性/重生次数?属性数量")
			player:SetAttribute("RebornTimes", math.min(rebornTimes, 23))
			task.delay(0.1, function()
				local exp = facade:ExecuteQuery("/属性/经验?属性数量")
				exp = math.max(exp, 0)
				SetUserLevel(player, exp)
			end)
		end)

		--计算玩家等级
		local exp = facade:ExecuteQuery("/属性/经验?属性数量")
		exp = math.max(exp, 0)
		SetUserLevel(player, exp)

		--监听经验变化 刷新等级
		facade:RegisterSlotObserver("/属性/经验", function(slot, value)
			local exp = facade:ExecuteQuery("/属性/经验?属性数量")
			exp = math.max(exp, 0)
			SetUserLevel(player, exp)
		end)

		--骑乘恐龙
		local rideId = facade:ExecuteQuery("/属性/骑乘恐龙?属性数量")
		if not rideId or rideId == 0 then
			rideId = 1
		end
		player:SetAttribute("RideId", rideId)
		local config = unitConfig[rideId]
		if config then
			player:SetAttribute("RideBonus", config.ExpBonus)
		end
		facade:RegisterSlotObserver("/属性/骑乘恐龙", function(slot, value)
			local rideId = facade:ExecuteQuery("/属性/骑乘恐龙?属性数量")
			player:SetAttribute("RideId", rideId)
			config = unitConfig[rideId]
			if config then
				player:SetAttribute("RideBonus", config.ExpBonus)
			end
		end)

		--奖杯数
		local cups = facade:ExecuteQuery("/货币/奖杯?属性数量")
		player:SetAttribute("Cups", cups)
		local totalCups = facade:ExecuteQuery("/货币/奖杯?累计获得")
		player:SetAttribute("TotalCups", totalCups)
		facade:RegisterSlotObserver("/货币/奖杯", function(slot, value)
			local cups = facade:ExecuteQuery("/货币/奖杯?属性数量")
			player:SetAttribute("Cups", cups)
			task.delay(0.5, function()
				local totalCups = facade:ExecuteQuery("/货币/奖杯?累计获得")
				player:SetAttribute("TotalCups", totalCups)
			end)
		end)
		player:SetAttribute("wukongReady", true)
		local speed = SpeedHelper.GetSpeed(player)
		player:SetAttribute("RuningSpeed", speed)

		--装备特性
		local auraId = facade:ExecuteQuery("/属性/装备特性?属性数量")
		player:SetAttribute("AurasId", auraId)
		facade:RegisterSlotObserver("/属性/装备特性", function(slot, value)
			local auraId = facade:ExecuteQuery("/属性/装备特性?属性数量")
			player:SetAttribute("AurasId", auraId)
		end)

		--购买通行证
		for _, gamePass in pairs(Defines.GamePass) do
			local count = facade:ExecuteQuery(`{gamePass.Path}?获取已购买次数`)
			player:SetAttribute(gamePass.Key, count > 0)
			facade:RegisterSlotObserver(gamePass.Path, function(slot, value)
				local count = facade:ExecuteQuery(`{gamePass.Path}?获取已购买次数`)
				player:SetAttribute(gamePass.Key, count > 0)
			end)
		end
		
		--已解锁恐龙
		if not ContainerHelper then
			ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
		end
		local buyed = {}
		local suc, data = ContainerHelper.GetContainerValue(player.UserId, `属性`, `解锁恐龙`)
		if suc and data then
			buyed = HttpService:JSONDecode(data)
		end
		buyed["dino1"] = true
		player:SetAttribute("BuyedDinos", HttpService:JSONEncode(buyed))
	else
		SetUserLevel(player, 0)
		player:SetAttribute("RideId", 1)
	end
	player:SetAttribute("PlayerReady", true)
	--EventBus.FireClient(player, EventDefines["玩家初始化"])
end)


Players.PlayerRemoving:Connect(function(player)
	SpeedHelper.Destroy(player)
	RideHelper.Destroy(player)
	ToolHelper.Destroy(player)
end)
