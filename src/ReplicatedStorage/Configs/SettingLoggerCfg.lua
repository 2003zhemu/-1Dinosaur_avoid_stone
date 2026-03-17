local module = {}

module.Setlogger = function()
	local logger = require(game.ReplicatedStorage.Packages.LoggerManager).SetLevel("None")
end

return module
