local HttpService = game:GetService("HttpService")
local SocialService = game:GetService("SocialService")
local event: RemoteEvent = script.Parent:WaitForChild("RemoteEvent")
local invoke = script.Parent:WaitForChild("RemoteFunction")

local PLACEID = game.PlaceId

local module = {}

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

-- 获取自己的邀请码
function module.GetInviteCode(player)
	player = player or game.Players.LocalPlayer
	local inviteCode = player.UserId
	return inviteCode
end

-- 生成邀请二维码
local qrcodeObj = nil
function module.GenerateQRCode(width)
	if not qrcodeObj or qrcodeObj.Parent == nil then
		local inviteLink = module.GetInviteLink("QRCode")
		local scale = math.floor(width / 25)
		qrcodeObj = require(script.Parent.qrencode).creategui(inviteLink, scale)
	end
	return qrcodeObj
end

-- 获取邀请链接
function module.GetInviteLink(t)
	t = t or "link"
	local inviteCode = module.GetInviteCode()
	local link = "https://www.roblox.com/games/start?placeId=%d&launchData="
	link = string.format(link, PLACEID)
	return link .. '{\\"InviteCode\\":\\"' .. inviteCode .. '\\",\\"Type\\":\\"' .. t .. '\\"}'
end

local function canSendGameInvite(sendingPlayer)
	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	return success and canSend
end

-- 发送游戏邀请
function module.PromptInGameInvite(player, options)
	player = player or game.Players.LocalPlayer
	local data = {
		InviteCode = module.GetInviteCode(),
		Type = "prompt",
	}
	
	local launchData = HttpService:JSONEncode(data)
	local inviteOptions = Instance.new("ExperienceInviteOptions")
	inviteOptions.LaunchData = launchData

	if options and typeof(options) == "table" then
		for i, v in pairs(options) do
			pcall(function()
				inviteOptions[i] = v
			end)
		end
	end

	local canInvite = canSendGameInvite(player)
	if canInvite then
		local success, errorMessage = pcall(function()
			SocialService:PromptGameInvite(player, inviteOptions)
		end)
	end
end

local _invites = nil
local lastInviteTick = 0
-- 获取邀请的玩家列表
function module.GetInvites()
	if (not _invites) or (lastInviteTick - tick() > 10) then
		_invites = remoteInvoke("GetInvites")
		lastInviteTick = tick()
	end
	return _invites
end

function module.GetInvitesInstantly()
	return remoteInvoke("GetInvitesInstantly")
end

return module