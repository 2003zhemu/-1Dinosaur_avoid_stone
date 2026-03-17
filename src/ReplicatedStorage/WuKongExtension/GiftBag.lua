local IS_SERVER = game:GetService("RunService"):IsServer()
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
-- local PartStore = require(game.ReplicatedStorage._genConfigs.battle_tbshopreward)
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

return function(userId, container, arg)
	local player = game.Players:GetPlayerByUserId(userId)
	local facade = getFacade(userId)
	if not facade then
		return
	end
	local targetItem = nil
	-- for _, item in pairs(PartStore) do
	-- 	if item.Index == arg then
	-- 		targetItem = item
	-- 		break
	-- 	end
	-- end
	-- local partName = targetItem.Reward
	-- if not partName then
	-- 	return
	-- end
	local RewardList = {
		[1] = {
			[1] = { id = "引擎三级", count = 3 },
			[2] = { id = "推进器一级", count = 2 },
			[3] = { id = "方块3", count = 5 },
			[4] = { id = "轮胎三级", count = 2 },
		},
		[2] = {
			[1] = { id = "引擎四级", count = 3 },
			[2] = { id = "推进器二级", count = 3 },
			[3] = { id = "方块四级", count = 5 },
			[4] = { id = "轮胎四级", count = 2 },
			[5] = { id = "火焰锤二级", count = 1 },
		},
		[3] = {
			[1] = { id = "引擎五级", count = 3 },
			[2] = { id = "推进器三级", count = 3 },
			[3] = { id = "方块五级", count = 8 },
			[4] = { id = "轮胎五级", count = 4 },
			[5] = { id = "火箭锤三级", count = 3 },
			[6] = { id = "电击塔三级", count = 3 },
		},
	}
	for idx, value in pairs(RewardList[tonumber(arg)]) do
		facade:ExecuteAction("/背包系统/背包添加物品?购买", "__null__", "__null__", {
			[1] = value.id,
			[2] = value.count,
		})
	end
	-- 零件发放逻辑
	EventBus.FireClient(player, "GiftBag")
end
