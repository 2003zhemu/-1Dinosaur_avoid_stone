local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
-- local Auras = require(script.Parent.Parent.Parent.View.Auras)
local Invite = require(script.Parent.Parent.Parent.View.Invite)
local module = {} :: defines.Input

function module:Load()
	self:SetSinked(true)

	local AuraIcon = self:GetUI("PlayerGui.HUD.InviteFollow.Bottom.Accept.Xbox")
	self:BindAction(function()
		Invite:Accept()
	end, Enum.KeyCode.ButtonY):SetIcon(AuraIcon)

	local AuraIcon = self:GetUI("PlayerGui.HUD.InviteFollow.Xbox")
	self:BindAction(function()
		Invite:Cancel()
	end, Enum.KeyCode.ButtonB):SetIcon(AuraIcon)
end

function module:OnShow_InviteFollow()
	self:SetActivated(true)
	self:EnableGamepadCursor()
end

function module:OnHide_InviteFollow()
	self:SetActivated(false)
	self:DisableGamepadCursor()
end

return module
