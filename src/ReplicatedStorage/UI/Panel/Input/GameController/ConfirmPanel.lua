local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
-- local Auras = require(script.Parent.Parent.Parent.View.Auras)
local Confirm = require(script.Parent.Parent.Parent.View.Confirm)
local module = {} :: defines.Input

function module:Load()
	self:SetSinked(true)

	local AuraIcon = self:GetUI("PlayerGui.HUD.InviteFollow.Bottom.Accept.Xbox")
	self:BindAction(function()
		Confirm:AcceptBtn()
	end, Enum.KeyCode.ButtonY):SetIcon(AuraIcon)

	local AuraIcon = self:GetUI("PlayerGui.HUD.InviteFollow.Xbox")
	self:BindAction(function()
		Confirm:CloseBtn()
	end, Enum.KeyCode.ButtonB):SetIcon(AuraIcon)
end

function module:OnShow_Confirm()
	self:SetActivated(true)
	self:EnableGamepadCursor()
end

function module:OnHide_Confirm()
	self:SetActivated(false)
	self:DisableGamepadCursor()
end

return module
