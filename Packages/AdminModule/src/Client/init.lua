local module = {}

module.Console = require(script.AdminConsole)


module.Window = require(script.AdminWindow)


module.EventBus = require(script.AdminEventBus)


module.Config =require(script.Parent.AdminSystemConfig)

module.PermissionValidator = require(script.PermissionValidator)

module.IsAdmin = function(player:Player)
    return module.PermissionValidator.IsAdmin(player)
end

return module
