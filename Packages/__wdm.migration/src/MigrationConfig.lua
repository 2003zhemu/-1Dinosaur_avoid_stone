--[=[
    @class MigrationConfig

    `配置项` `可补丁`

    数据迁移配置

]=]

local module = {}

--[=[
    @prop Migrations {Name:table}
    @within MigrationConfig
    迁移配置列表
]=]
module.Migrations = {} :: { ModuleScript }

-- 获取用户数据的委托
module.UserDataProvider = function(userId) end

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module, script.Name)

local versionCompare = require(script.Parent.VersionCompare)

for i, v in pairs(module.Migrations) do
	-- 判断是否为ModuleScript
	assert(v:IsA("ModuleScript"), "MigrationConfig.Migrations[" .. i .. "] must be a ModuleScript")

	-- 判断版本号是否合法
	local version = v.Name
	local versionList = string.split(version, ".")
	for _, num in ipairs(versionList) do
		assert(tonumber(num), "MigrationConfig.Migrations[" .. i .. "] version is invalid")
	end

	-- 判断是版本号是否从小到大
end

for i = 1, #module.Migrations do
	local v = module.Migrations[i]

	-- 判断是否为ModuleScript
	assert(v:IsA("ModuleScript"), "MigrationConfig.Migrations[" .. i .. "] must be a ModuleScript")

	-- 判断版本号是否合法
	local version = v.Name
	local versionList = string.split(version, ".")
	for _, num in ipairs(versionList) do
		assert(tonumber(num), "MigrationConfig.Migrations[" .. i .. "] version is invalid")
	end

	-- 判断是版本号是否从大到小
	if i > 1 then
		local preVersion = module.Migrations[i - 1].Name
		assert(
			versionCompare(preVersion, version) == 1,
			"MigrationConfig.Migrations["
				.. i - 1
				.. "] version must be greater than MigrationConfig.Migrations["
				.. i
				.. "] version"
		)
	end
end

return module
