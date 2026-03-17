local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local Auras = require(script.Parent.Parent.Parent.View.Auras)
local module = {} :: defines.Input

function module:Load()
	self:SetSinked(true)

	self:BindAction(function()
		self.DataContext:HidePanel("HUD", "Auras")
	end, Enum.KeyCode.ButtonB)

	local AuraIcon = self:GetUI("PlayerGui.HUD.Auras.Content.Right.Bottom.Button.xbox")
	self:BindAction(function()
		Auras:EquipAura()
	end, Enum.KeyCode.ButtonX):SetIcon(AuraIcon)
end

function module:OnShow_Auras()
	self:SetActivated(true)
	self:EnableGamepadCursor()
end

function module:OnHide_Auras()
	self:SetActivated(false)
	self:DisableGamepadCursor()
end

return module
