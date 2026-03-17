--[=[
    @class AntiOfflineModule
    @server
    @client

    防掉线模块, 本模块职责:
    * 用户挂机过长时, 会被踢出服务器.
    * 本模块检测用户发呆时间, 超过阈值后, 将用户传送至其他服务器.
    * 传送后，客户端提交的数据将被序列化，放置在 Player的 TeleportData 属性中
]=]

local dataProvider = require(script.TeleportDataProvider)

local AntiOfflineModule = {}

if game["Run Service"]:IsServer() then
	require(script.ServerInit)
end

--- 客户端请求传送
--- @return boolean -- 返回true：服务端已经准备传送, 返回false: 服务端传送失败
function AntiOfflineModule.RequestTeleport(options: any): boolean
	local rf = game.ReplicatedStorage.Packages.TeleportModule.TeleportRequestEvent

	print("Request Teleport")
	local isSuccess, result = rf:InvokeServer(options)
	print("Response for teleport request:", isSuccess, result)

	return isSuccess, result
end

--- 设置传送数据
function AntiOfflineModule.SetTeleportData(player: Player, data: any)
	return dataProvider.SetTeleportData(player, data)
end

--- 获取传送数据
function AntiOfflineModule.GetTeleportData(player: Player)
	return dataProvider.GetTeleportData(player)
end

-- 给传送数据打补丁，返回完整数据
function AntiOfflineModule.PatchTeleportData(player: Player, patch: any)
	return dataProvider.PatchTeleportData(player, patch)
end

return AntiOfflineModule
