local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.View

function module:Load()
	self.HUDContainer = self:GetUI("PlayerGui.HUD")
	self:SetContent(self.HUDContainer)
	self:RegisterAs("Container", "HUD")
end

return module
