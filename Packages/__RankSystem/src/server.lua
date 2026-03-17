local WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)

local event = script.Parent:WaitForChild("RemoteEvent")
local invoke = script.Parent:WaitForChild("RemoteFunction")

local SeasonProvider = require(script.Parent.SeasonProvider)
local Rewards = require(script.Parent.Rewards)

-- local GroupStore = require(script.Parent.DataStore.GroupStore)
local GlobalStore = require(script.Parent.DataStore.GlobalStore)

local module = {}

function module.InitPlayer(player)
	local facade  = WuKongServer.WaitFacade(player.UserId)
	if not facade then
		return
	end
end

function module.InitSeason(player)

end

function module.ReadyUpdate(player)
end

function module.GetPlayerValue(player)
	local value = GlobalStore.GetValue(player)
	if value then
		return value
	end
end

function module.Update(player, value)
	local function updateGlobal(player, value)
		return GlobalStore.Update(player, value)
	end

	-- local function updateGroup(player, value)
	-- 	return GroupStore.Update(player, value)
	-- end

	-- globalValue = globalValue or 0

	local facade = WuKongServer.WaitFacade(player.UserId)
	if facade then
		local currentSeasonIdx = SeasonProvider.GetCurrentSeasonIndex()
		local playerCurSeasonIdx = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季编号?属性数量")
		-- 玩家赛季未更新。且不是从第一层开始。不保存记录
		if playerCurSeasonIdx ~= currentSeasonIdx and value ~= 1 then
			return false, "SeasonEnd"
		else
			pcall(function()
				facade:ExecuteAction("/赛季系统/赛季数据/本赛季成绩?属性设为指定值", value)
			end)
			-- updateGroup(player, groupValue)
			updateGlobal(player, value)
			return true
		end
	end
end

-- function module.GetGroupRankList(player)
-- 	return GroupStore.GetGroupRankList(player)
-- end

-- function module.GetLastGroupRankList(player)
-- 	return GroupStore.GetLastGroupRankList(player)
-- end

function module.GetGlobalRankList(player)
	local playerScore
	if player then
		playerScore = GlobalStore.GetValue(player) or 0
	end
	print("RankSystem.GetGlobalRankList")
	return GlobalStore.GetGlobalRankList(), playerScore
end

function module.GetGlobalRank(player, useCache)
	return GlobalStore.GetGlobalRank(player, useCache)
end

function module.GetLastGlobalRankList()
	return GlobalStore.GetLastGlobalRankList()
end

function module.GetLastGlobalRank(player, useCache)
	return GlobalStore.GetPlayerLastRank(player, useCache)
end

-- function module.GetGlobalPresetRewards()
-- 	return Rewards.GetGlobalPresetRewards()
-- end

-- function module.GetGroupPresetRewards()
-- 	return Rewards.GetGroupPresetRewards()
-- end

-- function module.ReceiveLastSeasonGroupReward(player)
-- 	local lastSeasonIdx = SeasonProvider.GetLastSeasonIndex()
-- 	local facade = WuKongServer.WaitFacade(player.UserId)
-- 	if facade then
-- 		local playerLastSeasonIdx = facade:ExecuteQuery("/赛季系统/赛季数据/上赛季编号?属性数量")
-- 		if playerLastSeasonIdx == lastSeasonIdx then
-- 			local claimed = facade:ExecuteQuery("/赛季系统/赛季数据/上赛季分组奖励是否领取?属性数量") == playerLastSeasonIdx
-- 			if not claimed then
-- 				local list = GroupStore.GetLastGroupRankList(player)
-- 				if list == nil then
-- 					return -1
-- 				end
-- 				local idx = nil
-- 				for i, v in pairs(list) do
-- 					if v.UserId == player.UserId then
-- 						idx = i
-- 					end
-- 				end
-- 				if idx then
-- 					-- 给奖励
-- 					local reward = Rewards.GetGroupPresetRewards()[idx]
-- 					Rewards.Give(player, reward)
-- 					facade:ExecuteAction("/赛季系统/赛季数据/上赛季分组奖励是否领取?属性设为指定值", lastSeasonIdx)
-- 					return 1
-- 				end

-- 				return 0
-- 			end
-- 		end
-- 	end
-- 	return -1
-- end

function module.ReceiveLastSeasonGlobalReward(player)
	local lastSeasonIdx = SeasonProvider.GetLastSeasonIndex()
	local facade = WuKongServer.WaitFacade(player.UserId)
	if facade then
		local playerLastSeasonIdx = facade:ExecuteQuery("/赛季系统/赛季数据/上赛季编号?属性数量")
		if playerLastSeasonIdx == lastSeasonIdx then
			local claimed = facade:ExecuteQuery("/赛季系统/赛季数据/上赛季全局奖励是否领取?属性数量") == playerLastSeasonIdx
			if not claimed then
				local rank = GlobalStore.GetPlayerLastRank(player)
				if rank then
					-- 给奖励
					-- local reward = Rewards.GetGlobalPresetRewards()[idx]
					local suc, res = pcall(function()
						return Rewards.Give(player, rank)
					end)
					if suc and res then
						facade:ExecuteAction("/赛季系统/赛季数据/上赛季全局奖励是否领取?属性设为指定值", lastSeasonIdx)
						return 1, res
					end
				else
					return -1
				end
			end
		end
	end
	return -1
end

function module.ResetCurrentSeasonData(userId, container)
	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
	local currentSeasonIdx = SeasonProvider.GetCurrentSeasonIndex()
	local facade = WuKongServer.WaitFacade(player.UserId)
	if facade then
		local playerCurSeasonIdx = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季编号?属性数量")
		local levelrank = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季分组等级?属性数量")
		local groupIdx = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季分组编号?属性数量")
		local playerScore = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季成绩?属性数量")

		if playerCurSeasonIdx ~= currentSeasonIdx then
			facade:ExecuteAction("/赛季系统/赛季数据/本赛季编号?属性设为指定值", currentSeasonIdx)
			facade:ExecuteAction("/赛季系统/赛季数据/本赛季分组等级?属性设为指定值", 0)
			facade:ExecuteAction("/赛季系统/赛季数据/本赛季分组编号?属性设为指定值", 0)
			facade:ExecuteAction("/赛季系统/赛季数据/本赛季成绩?属性设为指定值", 0)

			local lastSeasonIdx = SeasonProvider.GetLastSeasonIndex()
			if playerCurSeasonIdx == lastSeasonIdx then
				facade:ExecuteAction("/赛季系统/赛季数据/上赛季编号?属性设为指定值", playerCurSeasonIdx)
				facade:ExecuteAction("/赛季系统/赛季数据/上赛季分组等级?属性设为指定值", levelrank)
				facade:ExecuteAction("/赛季系统/赛季数据/上赛季分组编号?属性设为指定值", groupIdx)
				facade:ExecuteAction("/赛季系统/赛季数据/上赛季成绩?属性设为指定值", playerScore)
			end
			
			facade:ExecuteAction("/赛季系统/赛季数据/上赛季分组奖励是否领取?属性设为指定值", 0)
			facade:ExecuteAction("/赛季系统/赛季数据/上赛季全局奖励是否领取?属性设为指定值", 0)
		end
	end
end

invoke.OnServerInvoke = function(player, ...)
	local args = {...}
	local funcName = table.remove(args, 1)
	local func = module[funcName]
	if func then
		return func(player, table.unpack(args))
	end
end

return module