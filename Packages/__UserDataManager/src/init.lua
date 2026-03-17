--[=[
	@class UserDataManager
	@server

	用户数据模块, 本模块职责:
	* 用户登陆时,加载悟空容器和其他数据.
	* 用户退出时,清理内存.

]=]

local UserDataManager = {}

-- 库：https://madstudioroblox.github.io/ProfileService/
-- 官方案例，稍微改动一下：https://madstudioroblox.github.io/ProfileService/tutorial/basic_usage/

local DebugOptions = require(game.ReplicatedStorage.Packages.DebugOptions)

if DebugOptions.IsEnable("禁用数据库存储") then
	warn("注意：由于禁用数据存储，将使用新用户数据并不再存储!")
else
	require(script.WatchUser)
end

local userDatas = require(script.UserDatas)

--[=[
	获取用户数据

	当获得用户数据表后, 我们可以直接修改其内容, 当用户退出时, 将会自动保存.

	@return {}? -- 用户数据, 为空代表未加载该用户数据
]=]

function UserDataManager.GetData(userId: number): {}?
	return userDatas.GetData(userId)
end

--- 注册加载用户数据事件
function UserDataManager.ConnectLoadUserDataEvent(handler: (userId: number) -> ()): RBXScriptConnection
	userDatas.setDataEvent.Event:Connect(handler)
end

--- 注册销毁用户数据事件
function UserDataManager.ConnectDeletelUserDataEvent(handler: (userId: number) -> ()): RBXScriptConnection
	userDatas.deleteDataEvent.Event:Connect(handler)
end

return UserDataManager
