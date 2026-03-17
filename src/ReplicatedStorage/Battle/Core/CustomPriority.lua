local CustomPriority = {
	ClientSyncComponent = -math.huge + 1000, --客户端创建服务端不同步的冗余组件
	CoreHighestPriority = -math.huge + 2000,
	CommonHigheshPriority = -math.huge + 3000, --常用最高优先级
	CommonLowestPriority = math.huge - 2000, --常用最低优先级
	CoreLowestPriority = -math.huge + 2000,
	ServerReplication = math.huge, --服务端同步组件
}

table.freeze(CustomPriority)

return CustomPriority
