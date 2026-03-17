local event: RemoteEvent = script.Parent:WaitForChild("RemoteEvent")
local invoke = script.Parent:WaitForChild("RemoteFunction")

local SeasonProvider = require(script.Parent.SeasonProvider)

local module = {}
local _banned = true

local function remote(...)
	if event == nil then
		event = script.Parent:WaitForChild("RemoteEvent")
	end
	event:FireServer(...)
end

local function remoteInvoke(...)
	if invoke == nil then
		invoke = script.Parent:WaitForChild("RemoteFunction")
	end
	return invoke:InvokeServer(...)
end

function module.Update(value)
	return remoteInvoke("Update", value)
end

function module.GetGroupRankList()
	return remoteInvoke("GetGroupRankList")
end

function module.GetLastGroupRankList()
	return remoteInvoke("GetLastGroupRankList")
end

function module.GetGlobalRankList()
	return remoteInvoke("GetGlobalRankList")
end

function module.GetLastGlobalRankList()
	return remoteInvoke("GetLastGlobalRankList")
end

function module.GetSeasonTimeToString()
	return SeasonProvider.GetSeasonTimeToString()
end

function module.GetLastSeasonTimeToString()
	return SeasonProvider.GetLastSeasonTimeToString()
end

function module.GetLastGlobalRank()
	return remoteInvoke("GetLastGlobalRank")
end

function module.GetGlobalRank(useCache)
	return remoteInvoke("GetGlobalRank", useCache)
end
-- function module.GetGlobalPresetRewards()
-- 	return Rewards.GetGlobalPresetRewards()
-- end

-- function module.GetGroupPresetRewards()
-- 	return Rewards.GetGroupPresetRewards()
-- end

-- function module.ReceiveLastSeasonGroupReward()
-- 	return remoteInvoke("ReceiveLastSeasonGroupReward")
-- end

function module.ReceiveLastSeasonGlobalReward()
	return remoteInvoke("ReceiveLastSeasonGlobalReward")
end

function module.GetLeftDayToString()
	return SeasonProvider.GetLeftDayToString()
end

event.OnClientEvent:Connect(function(...)
	local args = {...}
	if args[1] == "Banned" then
		_banned = args[2]
	end
end)

return module