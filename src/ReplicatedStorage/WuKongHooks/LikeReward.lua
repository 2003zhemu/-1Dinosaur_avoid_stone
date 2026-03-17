local Slot = require(game.ReplicatedStorage.WuKong.Types.Slot)
local Container = require(game.ReplicatedStorage.WuKong.Types.Container)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Players = game:GetService("Players")
local IS_SERVER = game:GetService("RunService"):IsServer()
local WuKong, WuKongServer
local function getFacade(userId: number)
	local facade
	if IS_SERVER then
		if not WuKongServer then
			WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
		end
		facade = WuKongServer.HasFacade(userId) and WuKongServer.GetFacade(userId)
	else
		if not WuKong then
			WuKong = require(game.ReplicatedStorage.WuKong)
		end
		facade = WuKong
	end
	return facade
end
local module = {}

module.HookExtraLogic = function(
	userId: number, -- 用户ID
	vendorSlot: Slot.Type, -- 商人容器
	context: { [string]: any }, -- 上下文
	targetContainer: Container.Type?, -- 标的物容器
	accessoryContainers: { Container.Type }?, -- 附属物容器列表
	args: {}
)
	local facade = getFacade(userId)
	if facade then
		if game.Players:GetPlayerByUserId(userId):GetRankInGroup(212251875) > 0 then
			return true
		else
			return false
		end
	end
end
module.GetFacade = getFacade
-- 发货业务后调用
module.HookPurchased = function(
	userId: number, -- 用户ID5
	vendorSlot: Slot.Type, -- 商人容器
	context: { [string]: any }, -- 上下文
	targetContainer: Container.Type?, -- 标的物容器
	accessoryContainers: { Container.Type }?, -- 附属物容器列表
	args: {}, -- 购买参数列表
	purchaseResult: {} -- 购买结果
)
	if IS_SERVER then
		local facade = getFacade(userId)
		--facade:ExecuteAction("/货币/金币?属性增加", 500)
		facade:ExecuteAction("/属性/经验?属性增加", 20000)

		EventBus.FireClient(Players:GetPlayerByUserId(userId), "LikeReward", {
			type = "Speed",
			value = 20000,
		})
	end
end

module.HookReplaceReward = function(
	userId: number, -- 用户ID
	vendorSlot: Slot.Type, -- 商人容器
	context: { [string]: any }, -- 上下文
	targetContainer: Container.Type?, -- 标的物容器
	accessoryContainers: { Container.Type }?, -- 附属物容器列表
	args: {}, -- 购买参数列表
	purchaseResult: {} -- 购买结果
)
	if IS_SERVER then
		local facade = getFacade(userId)
		if facade then
		end
	end
end

return module
