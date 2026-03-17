local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local module = {} :: defines.View

function module:CloseReward()
	self.Panel.Info = false
end

return module
