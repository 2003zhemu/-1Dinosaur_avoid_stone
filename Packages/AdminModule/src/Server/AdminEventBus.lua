local module = {}

local eventBus = require(game.ReplicatedStorage.Packages.EventBus)

local validator = require(script.Parent.PermissionValidator)

--[=[
    注册客户端管理员事件，收到事件后进行权限验证
    @within AdminEventBus
    @server
    @error 没有管理员权限 -- 验证失败时抛出异常
]=]
function module.Connect(func: (player: Player, eventName: string, args) -> ())
	return eventBus.ConnectC2S(function(player, eventName, ...)
		assert(validator.IsAdmin(player), "没有管理员权限")
		print("收到管理员指令:", player.UserId, eventName, ...)
		func(player, eventName, ...)
	end)
end

return module
