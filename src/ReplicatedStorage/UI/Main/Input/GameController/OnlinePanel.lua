local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.Input

function module:Load()
	self:SetSinked(true)

	self:BindAction(function()
		self.DataContext:HidePanel("HUD", "OnlinePanel")
	end, Enum.KeyCode.ButtonB)
end

function module:OnShow_OnlinePanel()
	self:SetActivated(true)
	self:EnableGamepadCursor()
end

function module:OnHide_OnlinePanel()
	self:SetActivated(false)
	self:DisableGamepadCursor()
end

return module
