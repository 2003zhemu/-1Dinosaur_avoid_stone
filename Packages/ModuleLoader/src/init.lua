--[=[
	@class ModuleLoader
	@server
	@client

	ModuleLoader 提供了若干种加载模块的方式.

	```lua
	-- 引用模块加载器
	require(game.ReplicatedStorage.Packages.ModuleLoader)
	```
]=]

local ModuleLoader = {}

local loader = require(script.Loader)

--[=[
    给定Instance，加载其子孙所有模块，
    参数：
    1. 需要加载子模块的实例，可以为任何类型
    规则：
    1. 如果子节点是目录，则递归
    2. 如果子节点是ModuleScript,且名称在列表内，则加载
    3. 忽略其他类型
    返回字典，key：模块名称，Name：模块对象
    报错：如果模块名称重复，则报错
]=]
function ModuleLoader.LoadAllModules(ins: Instance)
	local result = {}
	loader.LoadAllModules(ins, result)
	return result
end

--[=[
    加载所有指定模块
    返回字典，key：模块名称，Name：模块对象
    报错：如果加载的模块名称重复，则报错
]=]
function ModuleLoader.LoadModules(modules: { string | ModuleScript }): {
	{
		ModuleName: string,
		Module: any,
	}
}
	local result = {}
	loader.LoadModules(modules, result)
	return result
end

--[=[
    加载指定模块，
    返回模块名称，模块对象
]=]

function ModuleLoader.LoadModule(module: string | ModuleScript): {
	ModuleName: string,
	Module: any,
}
	local result = {}
	loader.LoadModules({ module }, result)

	for k, v in result do
		return v
	end
end

return ModuleLoader
