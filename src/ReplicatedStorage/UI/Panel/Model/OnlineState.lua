local wukong = require(game.ReplicatedStorage.WuKong)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local module = {
	RewardShow = 0,
}

function module:GetOnlineTimeStr(args)
	local t = wukong:ExecuteQuery("/数据/在线时长?本日累计激活秒数")
	local hour = math.floor(t / 3600)
	local min = math.floor((t - hour * 3600) / 60)
	local sec = t - hour * 3600 - min * 60
	local str = string.format("%02d:%02d:%02d", hour, min, sec)
	return str
end

function module:FormatTime(totalSec)
	local t = totalSec or 0
	local h = math.floor(t / 3600)
	local m = math.floor((t - h * 3600) / 60)
	local s = t - h * 3600 - m * 60
	if h > 0 then
		return string.format("%02d:%02d:%02d", h, m, s)
	-- elseif m > 0 then
	-- 	return string.format("%02d:%02d", m, s)
	else
		return string.format("%02d:%02d", m, s)
	end
	-- totalSec = totalSec or 0 -- nil → 0
	-- local hour = math.floor(totalSec / 3600)
	-- local min = math.floor(totalSec / 60) % 60
	-- local sec = totalSec % 60
	-- return string.format("%dH:%dM:%dS", hour, min, sec)
end

function module:GetList()
	local res
	pcall(function()
		res = wukong:ExecuteQuery("/活动/在线时长奖励/在线时长奖励1?获取产品信息")
	end)
	return res
end

function module:GetUpdateTime()
	local res
	pcall(function()
		res = wukong:ExecuteQuery("/活动/在线时长奖励/在线时长奖励1?获取距离下次刷新(秒)")
	end)
	return res
end

function module:GetCanClaimRewards()
	local list = self:GetList()
	local rewards = {}
	for i, v in ipairs(list) do
		if v.MoreInfo.CanGet then
			table.insert(rewards, { ["Id"] = v.Id, ["Count"] = v.Count })
		end
	end
	local res = pcall(function()
		return wukong:ExecuteAction("/活动/在线时长奖励/在线时长奖励1?购买", "__null__", "__null__")
	end)
	return rewards
end

return module
