local module = {}
local model = require(script.Parent.Model)
local view = require(script.Parent.view)
local UIManager =require(game.ReplicatedStorage.Packages.UIManager)
local FriendsInformation = require(game.ReplicatedStorage.Packages.FriendsInformationModule)
local SocialService = game:GetService("SocialService")

local function _closePanel()
    UIManager.ClosePanel("好友加成")
end

module.Init = function()
    view.Init()
end

module.Show = function(isShow)
    local friendCount = 0
    if isShow then
        friendCount = FriendsInformation.GetFriendsCount(game.Players.LocalPlayer)
    end
    view.Show(isShow,friendCount)
end

view.CloseBtnClick(function()
    _closePanel()
end)

view.InviteBtnClick(function()
    local player = game.Players.LocalPlayer
    local res, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(player)
	end)
    if not res then return end
    if not canSend then return end
    local success, _ = pcall(function()
        SocialService:PromptGameInvite(player)
    end)
    if success then
        _closePanel()
    end
end)

module.Gui = view.Gui
return module