--[=[
	@class CertPool
	@server
	@client

	凭证对象池, 可以使用凭证获取缓存对象.

]=]

local Pool = require(script.Parent.Pool)
local PoolConfig = require(script.Parent.PoolConfig)
local CertPool = {}
CertPool.__index = CertPool

function CertPool.new(config: PoolConfig.Type)
	if not config then
		return nil
	end
	local super = Pool.new(config)
	local self = {}

	self.__cacheByCert = {}
	local clone = table.clone(CertPool)
	clone.__index = clone
	setmetatable(clone, { __index = super })
	setmetatable(self, clone)
	return self
end

--- 提供凭据后,出借对象
--- 如果不存在该凭据,则使用该凭据创建新对象, 否则返回已缓存对象(无论该对象是否已出借)
--- 返回的为tuple, 第一个为出借对象,第二个为借据证明,以后可以凭借该证明,借到相同对象.
function CertPool:RentWithCertification(certification: any, ...: number | string): (any, any)
	assert(certification)
	local hit = self.__cacheByCert[certification]
	if not hit then
		hit = self:Rent(...)
		self.__cacheByCert[certification] = hit
	end
	return hit
end

--- 尝试根据凭据回收出借物
--- @return boolean 是否成功回收(如果凭据不存在或者未借出,则返回false)
function CertPool:TryAllocateByCertification(certification: any): boolean
	assert(certification)
	local cache = self.__cacheByCert[certification]
	if not cache then
		return false
	end
	self:Return(cache)
	self.__cacheByCert[certification] = nil
	return true
end

--- 通过凭据检查是否已出借
--- @return boolean 是否出借
function CertPool:IsRentCertification(certification: any): boolean
	assert(certification)
	local cache = self.__cacheByCert[certification]
	if not cache then
		return false
	end
	return true
end

return CertPool
