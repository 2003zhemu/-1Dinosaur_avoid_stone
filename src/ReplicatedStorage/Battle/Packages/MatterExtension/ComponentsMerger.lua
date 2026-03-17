--[=[
	@class ComponentsMerger

	合并 Componets, 供Matter使用
]=]
local ComponentsMerger = {}
ComponentsMerger.__index = ComponentsMerger
local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)

--[=[
	@interface ComponentConfig
	@within ComponentsMerger
	.Default {}? -- default value of component
	.Sync boolean? -- whether this component should be sync to client
]=]
export type ComponentConfig = {
	Default: any?,
	Sync: boolean?,
}

--[=[
	合并table组件和文件组件
	@param componentConfigs { [string]: ComponentConfig } -- 组件配置字典,key为组件名称,value为组件配置
	@param containers { Instance } -- 包含组件配置的目录数组, 将递归其子项,如果其为ModuleScript 且以 `Component` 结尾,则视其为组件配置
	@return {} -- 组件字典, key为组件名称, value为组件
]=]
function ComponentsMerger.Merge(configs: { [string]: ComponentConfig }, containers: { Instance })
	local result = {}
	local configs = table.clone(configs)

	-- 合并Container内的组件配置
	if containers then
		for _, container in containers do
			for _, instance in container:GetDescendants() do
				-- instance.Name end with 'Component'
				if instance:IsA("ModuleScript") and string.sub(instance.Name, -9) == "Component" then
					assert(
						string.len(instance.Name) > 9,
						"不能仅仅命名为 'Component', 需要前缀作为组件名称."
					)
					local moduleName = string.sub(instance.Name, 1, -10)
					local componentConfig = require(instance)
					assert(not configs[moduleName], "component config already exist:" .. moduleName)
					configs[moduleName] = componentConfig
				end
			end
		end
	end
	

	-- 生成组件
	for k, v in pairs(configs) do
		local default = v.Default
		if not default then
			default = {}
		end
		result[k] = Matter.component(k, default)
	end

	return result, configs
end

--[=[
	合并table组件
	@param configs1 { [string]: ComponentConfig } -- 组件配置字典,key为组件名称,value为组件配置
	@param configs2 { Instance } -- 组件配置字典,key为组件名称,value为组件配置
	@return {} -- 组件字典, key为组件名称, value为组件
]=]
function ComponentsMerger.MergeComponents(configs1: { [string]: ComponentConfig },configs2: { [string]: ComponentConfig })
	-- 生成组件
	if configs2 then
		for k, v in pairs(configs2) do
			--如果result已经有了，报错
			assert(not configs1[k], "component config already exist:" .. k)
			configs1[k] = v
		end
	end
	return configs1
end

return ComponentsMerger
