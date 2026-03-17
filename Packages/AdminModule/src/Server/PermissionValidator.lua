local module = {}

local config = require(script.Parent.Parent.AdminSystemConfig)

module.IsAdmin = function(player:Player)
    
    if config.AdminList[player.UserId] then
        return true
    end
    
end


return module
