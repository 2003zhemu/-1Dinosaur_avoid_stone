--[=[
	@class Pool
	@server
	@client

	对象池, 对象池管理器内部类.

]=]

Pool = {}
Pool.__index = Pool

local PoolConfig = require(script.Parent.PoolConfig)

function Pool.new(config: PoolConfig.Type)
	local newPool = {
		-- 以参数作为key的缓存
		__cacheByArg = {},
		-- 以实例作为key的缓存
		__cacheByInstance = {},
		__countAll = 0,
		__countRented = 0,
		__countAvailable = 0,
	}

	newPool.DefaultCount = config.DefaultCount
	newPool.CreateHandler = config.CreateHandler
	newPool.OnRentHandler = config.OnRentHandler
	newPool.OnReturnHandler = config.OnReturnHandler
	newPool.OnClearHandler = config.OnClearHandler

	setmetatable(newPool, Pool)

	-- ini
	if newPool.DefaultCount and newPool.DefaultCount > 0 then
		for i = 1, newPool.DefaultCount, 1 do
			newPool:__Create()
		end
	end

	return newPool
end

local function _assertObject(any)
	assert(any)
	assert(type(any) == "table" or type(any) == "userdata")
end

local nullKey = {}

local function getKey(...)
	local args = { ... }

	for i, v in ipairs(args) do
		local t = type(v)
		assert(t == "string" or t == "number")
		return table.concat(args, ":")
	end
	return nullKey
end

function Pool:__TryGetCacheNode(...)
	local key = getKey(...)
	local node = self.__cacheByArg[key]
	if not node then
		node = {}
		self.__cacheByArg[key] = node
	end
	return node
end

-- 创建
function Pool:__Create(...)
	local ins = self.CreateHandler(...)
	_assertObject(ins)
	local node = self:__TryGetCacheNode(...)
	local cache = {
		object = ins,
		isRent = false,
	}

	node[ins] = cache
	self.__cacheByInstance[ins] = cache
	self.__countAvailable = self.__countAvailable + 1
	self.__countAll = self.__countAll + 1
	return node[ins]
end

function Pool:__rent(...: number | string): (any, any)
	local result, canCount
	canCount = true

	-- 从现有参数缓存出借
	local isFromArgsCache = false
	local node = self:__TryGetCacheNode(...)
	for k, v in node do
		if not v.isRent then
			v.isRent = true
			isFromArgsCache = true
			result = v.object
			break
		end
	end

	-- 新建然后出借
	if not isFromArgsCache then
		local newIns = self:__Create(...)
		newIns.isRent = true
		result = newIns.object
	end

	-- count
	if canCount then
		self.__countAvailable = self.__countAvailable - 1
		self.__countRented = self.__countRented + 1
	end

	-- handler
	if self.OnRentHandler and canCount then
		self.OnRentHandler(result)
	end

	return result
end

--- 出借, 参数为标识, 将在创建新实例时传给指定回调.
--- 返回的为tuple, 第一个为出借对象,第二个为借据证明,以后可以凭借该证明,借到相同对象.
function Pool:Rent(...: number | string): (any, any)
	return self:__rent(...)
end

--- 归还
function Pool:Return(object: any)
	_assertObject(object)
	local node = self.__cacheByInstance[object]
	if not node then
		error("该对象并未在池中")
	end

	if node.isRent == false then
		error("该对象并未出借")
	end

	node.isRent = false
	-- count
	self.__countAvailable = self.__countAvailable + 1
	self.__countRented = self.__countRented - 1

	-- handler
	if self.OnReturnHandler then
		self.OnReturnHandler(object)
	end
end

--[=[
	已租借数量, 根据参数 `by`, 返回值有以下几种变数:
	- nil: 返回所有数量
	- "all": 返回所有数量
	- "rented": 返回已租借数量
	- "not rented": 返回未租借数量
	- "notrented": 返回未租借数量
	@param by nil | "all"? | "rented"? | "not rented"? | "notrented"?
]=]
function Pool:Count(by: nil | "all"? | "rented"? | "not rented"? | "notrented"?): number
	if not by or by == "all" then
		return self.__countAll
	elseif by == "rented" then
		return self.__countRented
	else
		return self.__countAvailable
	end
end

--- 回收所有借出物
function Pool:AllocateAll()
	for _, v1 in pairs(self.__cacheByArg) do
		for _, v2 in pairs(v1) do
			if v2.isRent then
				self:Return(v2.object)
			end
		end
	end
end

--- 清空对象池, 会首先自动调用 AllocateAll()
function Pool:Clear()
	self:AllocateAll()
	for _, v1 in pairs(self.__cacheByArg) do
		for _, v2 in pairs(v1) do
			if self.OnClearHandler then
				self.OnClearHandler(v2.object)
			end
		end
	end
	self.__cacheByArg = {}
	self.__cacheByInstance = {}
end

export type Type = typeof(Pool.new())

return Pool
