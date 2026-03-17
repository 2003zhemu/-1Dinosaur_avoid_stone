--[=[
	@class ConfigPatcher
	@server
	@client

	ConfigPatcher 提供了一种为配置打补丁的方式:

	* 当需要为配置打补丁时，ConfigPatcher 将尝试从所有源中查找制定配置的相关节点.
	* 如果找到了，将使用该节点的值覆盖配置中的值.

	```lua
	-- 引用配置补丁器
	require(game.ReplicatedStorage.Packages.ConfigPatcher)
	```
]=]

local ConfigPatcher = {}

local patchedConfigs = require(script.PatchedConfigs)

local patcher = require(script.Patcher)

-- 补丁
local function patch(cfgName: string)
	-- 使用模块配置打补丁
	patcher.Patch(cfgName)
end

--- 对配置打补丁
function ConfigPatcher.PatchConfig(cfg: {}, configName: string)
	assert(configName)

	if patchedConfigs[configName] then
		error("已存在配置，无法打补丁:" .. configName)
	end

	patchedConfigs[configName] = cfg

	patch(configName)
end

--- 设置补丁源
--- @deprecated 废弃，请使用 .AddPatchSource()
function ConfigPatcher.AddModuleConfigSource(modulesRoot: Instance)
	return patcher.AddPatchSource(modulesRoot)
end

--- 设置补丁源
function ConfigPatcher.AddPatchSource(patchRoot: Instance)
	return patcher.AddPatchSource(patchRoot)
end

return ConfigPatcher
