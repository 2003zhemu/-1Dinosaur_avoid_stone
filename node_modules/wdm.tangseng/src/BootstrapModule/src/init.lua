--[=[
    @class BootstrapModule
    @server
    @client

    启动模块, 用于管理服务端和客户端的启动业务.

]=]

local BootstrapModule = {}

local eventBus = require(game.ReplicatedStorage.Packages.EventBus)
local logger = require(game.ReplicatedStorage.Packages.LoggerManager).GetLogger("BootstrapModule")

--[=[
	@interface BootstrapConfig
	.ModuleConfigSources {string} -- 模块配置源，数组成员为容纳配置的目录
	.ModuleScripts {string|ModuleScript} -- 模块脚本列表
	.OnBootstraped (modules: {string}) -> () -- 成功启动后的回调
	@within BootstrapModule
	启动配置
]=]

export type BootstrapConfig = {
	ModuleConfigSources: { string },
	ModuleScripts: { string },
	OnBootstraped: (modules: { string }) -> nil,
}

--[=[
	@interface ModuleInfo
	.ModuleName string  -- 模块名称
	.Module {} -- 模块
	@within BootstrapModule
	模块信息
]=]
export type ModuleInfo = {
	ModuleName: string,
	Module: any,
}

--- 开始启动
function BootstrapModule.Start(cfg: BootstrapConfig): { ModuleInfo }
	logger.Info(function(name)
		print(name, "开始启动")
	end)

	-- 设置ConfigPatcher
	local configPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)

	if cfg.ModuleConfigSources then
		-- 设置Config源
		for k, v in cfg.ModuleConfigSources do
			configPatcher.AddModuleConfigSource(v)
		end
	else
		logger.warn(function(name)
			warn(name, "未设置配置补丁源, 请设置 BootstrapConfig.ModuleConfigSources 属性")
		end)
	end

	logger.info(function(name)
		print(name, "设置补丁源成功")
	end)

	-- 加载模块
	local loader = require(game.ReplicatedStorage.Packages.ModuleLoader)
	local modules = loader.LoadModules(cfg.ModuleScripts)

	-- init
	for k, v in pairs(modules) do
		if v.Module["Init"] then
			local logger = require(game.ReplicatedStorage.Packages.LoggerManager).GetLogger(v.ModuleName)
			v.Module["Init"](modules, logger)
		end
	end

	logger.info(function(name)
		print(name, "初始化所有模块成功")
	end)

	-- trigger
	if game["Run Service"]:IsServer() then
		eventBus.Fire("服务端启动成功", modules)
	else
		eventBus.Fire("客户端启动成功", modules)
	end

	if cfg.OnBootstraped then
		cfg.OnBootstraped(modules)
	end

	logger.info(function(name)
		print(name, "启动成功")
	end)
end

return BootstrapModule
