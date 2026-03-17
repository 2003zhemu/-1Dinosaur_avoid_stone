local UserInputService = game:GetService("UserInputService")
local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.Input

function module:Load()
	self:SetSinked(true)

	self:Connect("Panel.Info", self.UpdateInfo)
end

function module:UpdateInfo(val)
	if val then
		self:SetActivated(true)
		self:EnableGamepadCursor()
	else
		self:DisableGamepadCursor()
		self:SetActivated(false)
	end
end

return module
