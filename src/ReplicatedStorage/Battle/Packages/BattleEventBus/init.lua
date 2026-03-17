--[=[
    @class EventBus
    @server
    @client

    EventBus 提供了统一的事件总线，整合了以下业务：

    * 客户端-客户端
    * 服务端-服务端
    * 客户端-服务端
    * 服务单-客户端

    事件的发送方和接收方不再需要创建/查找事件实体。

    ```lua
    -- 引用事件总线
    require(game.ReplicatedStorage.EventBus)
    ```
]=]

local EventBus = {}

local bindableEvent = script:FindFirstChild("BindableEvent")

local remoteEvent = script:FindFirstChild("RemoteEvent")

--[=[
	抛出事件,客户端对客户端，或者服务端对服务端
]=]
function EventBus.Fire(eventName: string, ...: any)
	if typeof(eventName) ~= "string" then
		warn("EventName 必须为字符串. ", debug.traceback("", 1))
		return
	end

	local args = {}

	if game["Run Service"]:IsServer() then
		print("server -> server", eventName, unpack(args))
	else
		print("client -> client", eventName, unpack(args))
	end

	bindableEvent:Fire(eventName, ...)
end

--[=[
	客户端发送事件给服务端
	@client
]=]
function EventBus.FireServer(eventName: string, ...: any)
	local args = {}

	-- print("client -> server", eventName, unpack(args))

	remoteEvent:FireServer(eventName, ...)
end

--[=[
	服务端发送事件给客户端
	@server
]=]
function EventBus.FireClient(player: Player, eventName: string, ...: any)
	local args = {}
	print("server -> client", eventName, unpack(args))
	remoteEvent:FireClient(player, eventName, ...)
end

--[=[
	服务端发送事件给所有客户端
	@server
]=]
function EventBus.FireAllClients(eventName: string, ...: any)
	local args = {}
	print("server -> all clients", eventName, unpack(args))
	remoteEvent:FireAllClients(eventName, ...)
end

--[=[
    注册事件,可以接受如下事件
    * 客户端内部
    * 服务端内部
]=]
function EventBus.Connect(func: (eventName: string, ...any) -> ()): RBXScriptConnection
	return bindableEvent.Event:Connect(func)
end

--[=[
	注册客户端发送给服务端事件
	@server
]=]
function EventBus.ConnectC2S(func: (player: Player, eventName: string, ...any) -> ()): RBXScriptConnection
	return remoteEvent.OnServerEvent:Connect(func)
end

--[=[
	注册服务端发送给客户端事件
	@client
]=]
function EventBus.ConnectS2C(func: (eventName: string, ...any) -> ()): RBXScriptConnection
	return remoteEvent.OnClientEvent:Connect(func)
end

--[=[
	远程事件
	@within EventBus
	@prop RemoteEvent RemoteEvent
]=]
EventBus.RemoteEvent = remoteEvent

--[=[
	绑定事件
	@within EventBus
	@prop BindableEvent BindableEvent
]=]
EventBus.BindableEvent = bindableEvent

table.freeze(EventBus)

return EventBus
