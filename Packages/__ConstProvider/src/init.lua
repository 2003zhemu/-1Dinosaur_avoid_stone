local ConfigProvider = require(game.ReplicatedStorage.Packages.ConfigProvider)
local module = {}

-- 获取数字常量
function module.GetConstValue(constName)
	local result = ConfigProvider.Get("core_tbconst")[constName]
	assert(result, "常量未配置:" .. constName)

	return result.Value
end

-- 获取字符串常量
function module.GetConstStringValue(constName)
	local result = ConfigProvider.Get("core_tbconst")[constName]
	assert(result, "常量未配置:" .. constName)
	return result.StringValue
end

return module
