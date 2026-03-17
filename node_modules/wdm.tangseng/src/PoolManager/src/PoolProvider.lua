local module = {}

local Pool = require(script.Parent.Pool)

local PoolConfig = require(script.Parent.PoolConfig)

module.GetPool = function(poolConfig: PoolConfig.Type)
	return Pool.new(poolConfig)
end

return module
