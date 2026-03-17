local RunService = game:GetService("RunService")
if not RunService:IsServer() then
	return {}
end
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local unitConfig = require(game.ReplicatedStorage._genConfigs.battle_tbunit)
local toolModels = game.ServerStorage.ToolModels
local ToolHelper = {}
ToolHelper.__index = ToolHelper
local MaxRideId = 12
local wukongServer = nil

local function GetRandomRideId(curRideId)
	if curRideId >= MaxRideId then
		return curRideId
	end
	local randomTable = {}
	for i = curRideId + 1, MaxRideId do
		if i ~= 11 then
			table.insert(randomTable, i)
		end
	end
	if #randomTable > 0 then
		return randomTable[math.random(1, #randomTable)]
	end

	return curRideId
end

local DefaultConfigs = {
	[Defines.Tools["Fly"]] = {
		Duration = 15,
		OnStart = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("InFlyTool", true)
			EventBus.FireClient(player, "FlyStatus", { InFlyTool = true })
			--穿戴饰品
			if toolModels then
				local wing = toolModels:FindFirstChild("Wing")
				local character = player.Character
				if wing and character then
					local Humanoid = character:FindFirstChild("Humanoid")
					if Humanoid then
						wing = wing:Clone()
						Humanoid:AddAccessory(wing)
						status.Models = { wing }
					end
				end
			end
		end,
		OnEnd = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("InFlyTool", false)
			EventBus.FireClient(player, "FlyStatus", { InFlyTool = false })
			EventBus.FireClient(player, "UnequipTool", { ToolName = "Fly" })
			--卸下饰品
			if status.Models then
				for _, model in pairs(status.Models) do
					model:Destroy()
				end
			end
		end,
	},
	[Defines.Tools["Dash"]] = { --提升玩家速度
		Duration = 15,
		UpSpeed = 0.5,
		OnStart = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("ToolDashUpSpeed", status.Config.UpSpeed)
		end,
		OnEnd = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("ToolDashUpSpeed", nil)
			EventBus.FireClient(player, "UnequipTool", { ToolName = "Dash" })
		end,
	},
	[Defines.Tools["Jump"]] = {
		Duration = 30,
		UpJump = 0.5,
		OnStart = function(status)
			local player = status.Player
			if not player then
				return
			end
			local Character = player.Character
			if not Character then
				return
			end
			local Humanoid = Character:FindFirstChild("Humanoid")
			if Humanoid then
				Humanoid.JumpHeight = Humanoid.JumpHeight * (1 + status.Config.UpJump)
			end
			EventBus.FireClient(player, "ShowJumpEffect")
		end,
		OnEnd = function(status)
			local player = status.Player
			if not player then
				return
			end
			local Character = player.Character
			if not Character then
				return
			end
			local Humanoid = Character:FindFirstChild("Humanoid")
			if Humanoid then
				Humanoid.JumpHeight = 7.2
			end
			EventBus.FireClient(player, "UnequipTool", { ToolName = "Jump" })
		end,
	},
	[Defines.Tools["Immune"]] = {
		Duration = 30,
		OnStart = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("InImmuneTool", true)
		end,
		OnEnd = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("InImmuneTool", nil)
			EventBus.FireClient(player, "UnequipTool", { ToolName = "Immune" })
		end,
	},
	[Defines.Tools["DinoBigger"]] = {
		Duration = 30,
		OnStart = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("RideShape", 2)
		end,
		OnEnd = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("RideShape", nil)
			EventBus.FireClient(player, "UnequipTool", { ToolName = "DinoBigger" })
		end,
	},
	[Defines.Tools["DinoSmaller"]] = {
		Duration = 30,
		OnStart = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("RideShape", 1)
		end,
		OnEnd = function(status)
			local player = status.Player
			if not player then
				return
			end
			player:SetAttribute("RideShape", nil)
			EventBus.FireClient(player, "UnequipTool", { ToolName = "DinoSmaller" })
		end,
	},
	[Defines.Tools["DinoRandom"]] = {
		Duration = 60,
		OnStart = function(status)
			local player = status.Player
			if not player then
				return
			end
			local curRideId = player:GetAttribute("RideId") or 1
			local randomDinoId = GetRandomRideId(curRideId)
			player:SetAttribute("RideId", randomDinoId)
			local config = unitConfig[randomDinoId]
			if config then
				player:SetAttribute("RideBonus", config.ExpBonus or 0)
			end
		end,
		OnEnd = function(status)
			local player = status.Player
			if not player then
				return
			end
			if not wukongServer then
				wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
			end
			if wukongServer.HasFacade(player.UserId) then
				local facade = wukongServer.GetFacade(player.UserId)
				--骑乘恐龙
				local rideId = facade:ExecuteQuery("/属性/骑乘恐龙?属性数量")
				if not rideId or rideId == 0 then
					rideId = 1
				end
				player:SetAttribute("RideId", rideId)
				local config = unitConfig[rideId]
				if config then
					player:SetAttribute("RideBonus", config.ExpBonus or 0)
				end
			end
			EventBus.FireClient(player, "UnequipTool", { ToolName = "DinoRandom" })
		end,
	},
}

local PlayerTools = {} --玩家工具缓存

RunService.Heartbeat:Connect(function()
	for player, tool in pairs(PlayerTools) do
		for key, status in pairs(tool.Status) do
			if status.InUse and game.Workspace:GetServerTimeNow() >= status.ExpireTime then
				ToolHelper.EndTool(player, key)
			end
		end
	end
end)

function ToolHelper.Init(player)
	local self = setmetatable({}, ToolHelper)
	self.Player = player
	self.Status = {}
	self.EquipTool = nil
	for key, config in pairs(DefaultConfigs) do
		self.Status[key] = {
			Config = config,
			Player = player,
			InUse = false,
			ExpireTime = 0,
			Conn = nil,
		}
	end
	PlayerTools[player] = self
	return self
end

function ToolHelper.UseTool(player, key)
	if not player or not key then
		return
	end
	local self = PlayerTools[player]
	if not self then
		self = ToolHelper.Init(player)
	end
	local status = self.Status[key]
	if not status then
		return
	end
	--购买了通行证  无时间限制
	if player:GetAttribute(Defines.GamePass["控制台"].Key) then
		status.Config.Duration = 24 * 60 * 60
	end

	if status.InUse then --已经在使用该道具 刷新过期时间
		local expireTime = game.Workspace:GetServerTimeNow() + status.Config.Duration
		status.ExpireTime = expireTime
		player:SetAttribute("EquipedToolExpire", expireTime)
		return
	end
	if self.EquipTool then --有装备道具 先结束
		ToolHelper.EndTool(player, self.EquipTool)
	end

	status.InUse = true
	self.EquipTool = key
	local expireTime = game.Workspace:GetServerTimeNow() + status.Config.Duration
	player:SetAttribute("EquipedTool", key)
	player:SetAttribute("EquipedToolExpire", expireTime)
	status.ExpireTime = expireTime
	status.Config.OnStart(status)
end

function ToolHelper.EndTool(player, key)
	if not player or not key then
		return
	end
	local self = PlayerTools[player]
	if not self then
		self = ToolHelper.Init(player)
	end
	local status = self.Status[key]
	if not status then
		return
	end
	if not status.InUse then
		return
	end
	status.InUse = false
	status.ExpireTime = 0
	self.EquipTool = nil
	player:SetAttribute("EquipedTool", nil)
	player:SetAttribute("EquipedToolExpire", nil)
	status.Config.OnEnd(status)
end

function ToolHelper.Destroy(player)
	local self = PlayerTools[player]
	if self then
		for key, status in pairs(self.Status) do
			if status.InUse then
				ToolHelper.EndTool(player, key)
			end
		end
	end
	PlayerTools[player] = nil
end

return ToolHelper
