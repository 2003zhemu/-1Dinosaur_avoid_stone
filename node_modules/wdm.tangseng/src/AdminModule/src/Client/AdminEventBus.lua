--[=[
    @class AdminEventBus
    @client
    @server

    管理员事件总线, 类似EventBus, 但是会对客户端提交到服务端的事件进行权限认证.
    


    ```lua
    -- 引用管理员事件总线
    require(game.ReplicatedStorage.Packages.AdminCore).EventBus
    ```

]=]

local AdminEventBus = {}

local eventBus = require(game.ReplicatedStorage.Packages.EventBus)

--- @client
function AdminEventBus.FireServer(eventName: string, ...: any)
	eventBus.FireServer(eventName, ...)
end

return AdminEventBus
