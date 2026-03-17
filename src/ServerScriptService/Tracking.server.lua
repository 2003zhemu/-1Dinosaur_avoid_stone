local sdk = require(game.ReplicatedStorage.Packages.GameAnalytics)
sdk:configureAvailableCustomDimensions01({ "Mobile", "PC", "Gamepad" })

local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local function setCustomDimension(player, name, dimension)
	if name == "setCustomDimension01" then
		if table.find({ "Mobile", "PC", "Gamepad" }, dimension) then
			sdk:setCustomDimension01(player.UserId, dimension)
		end
	end
end
EventBus.ConnectC2S(setCustomDimension)
