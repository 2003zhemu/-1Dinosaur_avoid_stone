local module = {}

local config = require(script.Parent.Parent.AdminSystemConfig)

module.IsAdmin = function(player:Player)
    
    player = player or game.Players.LocalPlayer
    if config.AdminList[player.UserId] then
        return true
    end

end


return module
