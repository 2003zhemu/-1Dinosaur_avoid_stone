local wukong = require(game.ReplicatedStorage.WuKong)

local module = {
	RefreshDaliyFrame = false,
	SignedinCount = wukong:ExecuteQuery("/活动/每日登录奖励/领取每日登录奖励?当前进度"),
	Panel = 1,
	UpdatePanel = false,
	RewardDay = nil,
	ClaimCount = nil,
	OpenDailyFrame = false,
}

--获取已签到次数（天数）
function module:GetSignedinCount()
	local suc, res = pcall(function()
		return wukong:ExecuteQuery("/活动/每日登录奖励/领取每日登录奖励?当前进度")
	end)
	if suc and res then
		return res
	end
end

function module:GetDailyRewardList()
	local suc, res = pcall(function()
		return wukong:ExecuteQuery("/活动/每日登录奖励/领取每日登录奖励?获取产品信息")
	end)
	return res
end

function module:GetRefreshTime()
	-- 计算东七区五点距离现在的时间
	local diff =
		wukong:ExecuteQuery("/活动/每日登录奖励/领取每日登录奖励?获取距离下次刷新(秒)")
	return diff
end

function module:VerifyCanGet()
	local suc, res = pcall(function()
		return wukong:ExecuteValidate(
			"/活动/每日登录奖励/领取每日登录奖励?购买验证",
			"__null__",
			"__null__"
		)
	end)
	if suc then
		-- warn(res)
	end
	return not res["HasError"]
end

function module:GetCurrentDaily()
	return wukong:ExecuteQuery("/活动/每日登录奖励/领取每日登录奖励?当前进度")
end

function module:GetCanAttendanceState(day)
	local info = self:GetDailyRewardList()
	for index, value in pairs(info[tonumber(day)]["MoreInfo"]) do
		if index ~= "RequireProgress" then
			return index
		else
			return value
		end
	end
end

function module:GetRewardStarAndEnd()
	return self.RewardDay - self.ClaimCount + 1, self.RewardDay
end

return module
