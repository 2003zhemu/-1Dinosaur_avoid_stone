--[=[
	@class PoolManager
	@server
	@client

	对象池管理器

	```lua
	-- 引用对象池管理器
	require(game.ReplicatedStorage.Packages.ModuleLoader)
	```
]=]

local PoolManager = {}

local PoolProvider = require(script.PoolProvider)
local PoolConfig = require(script.PoolConfig)
local Pool = require(script.Pool)
local pools = {}

--- 设置对象池
--- @param poolConfig PoolConfig & { Name: string }
--- @return Pool
function PoolManager.SetPool(poolConfig: PoolConfig.Type & { Name: string }): Pool.Type
	local pool = PoolProvider.GetPool(poolConfig)
	pools[poolConfig.Name] = pool
	return pool
end

--- 获取对象池
--- @return Pool
function PoolManager.GetPool(name: string): Pool.Type
	assert(name)
	local pool = pools[name]
	assert(pool, "不存在对象池:" .. name)
	return pool
end

--- 销毁对象池
--- @return Pool
function PoolManager.DestroyPool(name: string)
	assert(name)
	local pool = pools[name]
	assert(pool, "不存在对象池:" .. name)
	pool:Clear()
	pools[name] = nil
end

return PoolManager
