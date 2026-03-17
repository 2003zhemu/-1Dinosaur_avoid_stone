local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.Input

function module:Load()
	self:SetSinked(true)

	-- self:BindAction("ShowPanel", Enum.KeyCode.ButtonB, "HUD", "MainScreen")

	self:BindAction(function()
		self.DataContext:HidePanel("HUD", "ControlPanel")
	end, Enum.KeyCode.ButtonB)
end

function module:OnShow_ControlPanel()
	self:SetActivated(true)
	self:EnableGamepadCursor()
end

function module:OnHide_ControlPanel()
	self:SetActivated(false)
	self:DisableGamepadCursor()
end

return module
