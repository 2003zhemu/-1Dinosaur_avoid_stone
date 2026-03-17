local module = {}
local ReplicatedStorage = game.ReplicatedStorage
module.IsRequireWuKong = false
local eventbus = require(game.ReplicatedStorage.Packages.EventBus)
local NezaUI = require(game.ReplicatedStorage.Packages.Neza)
module.OnBootstraped = function(modules)
	-- 开启悟空调试器 （目前只有开发环境才会开启）
	task.spawn(function()
		require(ReplicatedStorage.WuKong).EnableDebugger(function()
			local RunService = game:GetService("RunService")
			if RunService:IsStudio() then
				return true
			end
		end)
	end)

	spawn(function()
		local cfg = require(script.Parent.NezaBootstrapConfig)
		NezaUI:Boot(cfg)
	end)
end

-- 模块配置源，数组成员为容纳配置的目录
module.ModuleConfigSources = {
	game.ReplicatedStorage.Configs,
}

module.ModuleScripts = {
	-- 核心
	-- "ReplicatedStorage.Packages.AntiOfflineModule", -- 防掉线模块
	--"ReplicatedStorage.Modules.Core.ProcedureModule",       -- 流程模块

	-- 管理系统
	-- "ReplicatedStorage.Packages.AdminModule",
	-- "ReplicatedStorage.Packages.DeveloperModule",
}

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module, script.Name)

return module
