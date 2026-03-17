local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.Input

function module:Load()
	self.TopBar = self:GetUI("PlayerGui.TopBar")
end

function module:Start()
	self.TopBar.Enabled = true
end

return module
