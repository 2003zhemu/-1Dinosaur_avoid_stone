local Slot = require(game.ReplicatedStorage.WuKong.Types.Slot)
local Container = require(game.ReplicatedStorage.WuKong.Types.Container)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local WuKongHelper = require(game.ReplicatedStorage.WuKong.WuKongHelper)
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
	if IS_SERVER then
		local facade = getFacade(userId)
		if facade then
			return true
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
		if facade then
			local SignedinCount = facade:ExecuteQuery("/活动/每日登录奖励/领取每日登录奖励?当前进度")
			 if SignedinCount == 2 then
			   facade:ExecuteAction("/背包系统/背包添加物品?购买", "__null__", "__null__", {
				[1] = "引擎四级"
			})
			elseif SignedinCount == 3 then
			   facade:ExecuteAction("/背包系统/背包添加物品?购买", "__null__", "__null__", {
				[1] = "尖刺护栏三级",
				[2]=3
			})
			elseif SignedinCount == 5 then
			   facade:ExecuteAction("/背包系统/背包添加物品?购买", "__null__", "__null__", {
				[1] = "装甲四级",
				[2]=3
			})
			elseif SignedinCount == 6 then
			   facade:ExecuteAction("/背包系统/背包添加物品?购买", "__null__", "__null__", {
				[1] = "方块五级",
				[2]=3
			})
			elseif SignedinCount == 7 then
			   facade:ExecuteAction("/背包系统/背包添加物品?购买", "__null__", "__null__", {
				[1] = "装甲五级",
				[2]=3
			})
			 end
		end
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
		local result = { Receive = {} }
		local facade = getFacade(userId)
		if facade then
		end
	end
end

return module
