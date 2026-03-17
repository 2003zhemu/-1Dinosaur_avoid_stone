local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.Input

function module:Load()
	self:SetSinked(true)

	self:BindAction(function()
		self.DataContext:HidePanel("HUD", "Rebirth")
	end, Enum.KeyCode.ButtonB)
end

function module:OnShow_Rebirth()
	self:SetActivated(true)
	self:EnableGamepadCursor()
end

function module:OnHide_Rebirth()
	self:SetActivated(false)
	self:DisableGamepadCursor()
end

return module
