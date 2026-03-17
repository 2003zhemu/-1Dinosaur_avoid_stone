local wukong = require(game.ReplicatedStorage.WuKong)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local module = {
	Isbuy = 0,
}

function module:GetCanGetLikeReward()
	if not (game.Players:GetPlayerByUserId(game.Players.LocalPlayer.UserId):GetRankInGroup(212251875) > 0) then
		return false
	end
	local purchaseCount = wukong:ExecuteQuery("/活动/群组奖励/群组每日奖励?获取已购买次数")
	if purchaseCount == 1 then
		return false
	end
	return true
end

function module:GetLikeReward()
	local pass = self:GetCanGetLikeReward()
	if not pass then
		return
	end
	local suc, res = pcall(function(...)
		return wukong:ExecuteAction("/活动/群组奖励/群组每日奖励?购买")
	end)
	if suc then
		self.Isbuy += 1
	end
	return suc, res
end

function module:GetLikeRewardStatus()
	if not (game.Players:GetPlayerByUserId(game.Players.LocalPlayer.UserId):GetRankInGroup(212251875) > 0) then
		return "GroupFalse"
	end
	local purchaseCount = wukong:ExecuteQuery("/活动/群组奖励/群组每日奖励?获取已购买次数")
	if purchaseCount == 1 then
		return "PurchaseCountFalse"
	end
	return true
end

function module:GetTodayIsGet()
	return wukong:ExecuteQuery("/活动/群组奖励/群组每日奖励?获取已购买次数") == 1
end

function module:PlayerInGroup()
	return game.Players:GetPlayerByUserId(game.Players.LocalPlayer.UserId):GetRankInGroup(212251875) > 0
end

function module:GetNextGetTime()
	return wukong:ExecuteQuery("/活动/群组奖励/群组每日奖励?获取距离下次刷新(秒)")
end

return module
