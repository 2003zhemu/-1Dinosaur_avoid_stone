local module = {}

local wukong = require(game.ReplicatedStorage.WuKong)

module.GetCommandIds = function()
	return wukong:GetCommandIds()
end

module.ExecuteCommand = function(id)
	wukong:ExecuteCommand(id)
end

return module
