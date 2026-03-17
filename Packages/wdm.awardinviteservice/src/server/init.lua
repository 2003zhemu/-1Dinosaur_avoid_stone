local HttpService = game:GetService("HttpService")

local event = script.Parent:WaitForChild("RemoteEvent")
local invoke = script.Parent:WaitForChild("RemoteFunction")

local inviteStore = require(script.Store)

local ATTEMPT_LIMIT = 10
local RETRY_DELAY = 1

local module = {} :: {
	dataProvider: (userId: number) -> { [string]: any }
}

local function checkJoinData(player)
    local launchData
    for i = 1, ATTEMPT_LIMIT do
        task.wait(RETRY_DELAY)
        local joinData = player:GetJoinData()
        if joinData.LaunchData ~= "" then
            launchData = joinData.LaunchData
            break
        end
    end

    if launchData and player and player.Parent == game.Players then
        launchData = string.gsub(launchData, "\\", "")
        local data = HttpService:JSONDecode(launchData)
        local inviteCode = data.InviteCode
        if inviteCode then
            local inviteType = data.Type
			local inviteUserId = data.InviteCode
			return inviteType, tonumber(inviteUserId)
        end
    end
end

local function getInvitedInfo(player)
	local playerData
	repeat
		playerData = module.dataProvider and module.dataProvider(player.UserId)
		if not playerData then
			task.wait(RETRY_DELAY)
		end
	until playerData or player.Parent ~= game.Players
	if not playerData then
		return
	end
	local t, userId = checkJoinData(player)
	if t and userId then
		local inviteData = playerData.Data.AwardInvite
		local beInvited = inviteData and inviteData.BeInvited
		if (not inviteData) then
			playerData.Data.AwardInvite = {
				Invites = {},
			}
		end
		
		if (not beInvited) or typeof(beInvited) ~= "table" then
			playerData.Data.AwardInvite.BeInvited = {}
			beInvited = playerData.Data.AwardInvite.BeInvited
		end
		-- 如果没有被邀请过
		if (not table.find(beInvited, userId)) then
			table.insert(beInvited, userId)
			spawn(function()
				inviteStore.AddToPlayerInvites(userId, player.UserId)
			end)
		end
	end
end

function module.SetDataProvider(dataProvider)
	module.dataProvider = dataProvider
end

function module.GetInvites(player)
	local playerData = module.dataProvider and module.dataProvider(player.UserId)
	if not playerData then
		return {}
	end
	if not playerData.Data.AwardInvite then
		playerData.Data.AwardInvite = {
			Invites = {},
		}
	end
	local invites = playerData.Data.AwardInvite.Invites

	-- 获取待领取的邀请
	local storeInvites = inviteStore.GetInvitesAndClean(player.UserId)
	-- 合并邀请
	for i, v in ipairs(storeInvites) do
		if not table.find(invites, v) then
			table.insert(invites, v)
		end
	end

	return invites
end

function module.GetInvitesInstantly(player)
	local playerData = module.dataProvider and module.dataProvider(player.UserId)
	if not playerData then
		return {}
	end
	if not playerData.Data.AwardInvite then
		playerData.Data.AwardInvite = {
			Invites = {},
		}
	end
	task.spawn(module.GetInvites, player)
	return playerData.Data.AwardInvite.Invites
end

for i, player in pairs(game.Players:GetPlayers()) do
	task.spawn(getInvitedInfo, player)
end

game.Players.PlayerAdded:Connect(function(player)
	getInvitedInfo(player)
end)

invoke.OnServerInvoke = function(player, ...)
	local args = {...}
	local funcName = table.remove(args, 1)
	local func = module[funcName]
	if func then
		return func(player, table.unpack(args))
	end
end

return module