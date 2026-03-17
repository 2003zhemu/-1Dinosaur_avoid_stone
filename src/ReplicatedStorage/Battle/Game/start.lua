local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage.Battle.Packages
local Matter = require(Packages.Matter)
local Plasma = require(Packages.plasma)
local HotReloader = require(Packages.rewire).HotReloader
local env = require(game.ReplicatedStorage.Packages.Environment)
local envName = env.EnvName()
local standAlone = env.IsDevClient()

local function isEcsSystem(name, module: {})
	-- is function and not end with ".spec.lua"
	if type(module) == "function" then
		if string.sub(name, -5) == ".spec" then
			return false
		else
			return true
		end
	end

	if type(module) ~= "table" then
		return
	end

	-- 必须有 system.system
	if not module.system then
		return
	end

	local config = module
	local envConfigs = module.env
	if envConfigs and envConfigs[envName] then
		config = envConfigs[envName]
	end

	-- disable server
	if game["Run Service"]:IsClient() then
		if config.onlyServer then
			return
		end
		-- 如果是单机模式,服务端系统也需要启动
		if config.disableClient and not standAlone then
			return
		end
		-- disable client
	elseif game["Run Service"]:IsServer() then
		-- 纯客户端系统不启动
		if config.disableServer then
			return
		end
	end

	return true
end

local function start(containers, state, context)
	-- 如果是客户端,则需要逆序世界,保证与服务端id不冲突
	local isReversed = false
	if game["Run Service"]:IsClient() then
		isReversed = true
	end
	local world = Matter.World.new(isReversed)
	local debugger = Matter.Debugger.new(Plasma)
	debugger.findInstanceFromEntity = function(id)
		if not world:contains(id) then
			return
		end

		local model = world:get(id, context.Components.Model)
		return model and model.Value or nil
	end

	debugger.authorize = function(player)
		return true
	end

	local loop = Matter.Loop.new(world, state, context, debugger:getWidgets(), debugger)

	-- Set up hot reloading

	local hotReloader = HotReloader.new()

	local firstRunSystems = {}
	local systemsByModule = {}

	local function loadModule(module, context)
		local originalModule = context.originalModule

		local ok, system = pcall(require, module)

		if not ok then
			warn("Error when hot-reloading system", module.name, system)
			return
		end

		if not isEcsSystem(module.Name, system) then
			if systemsByModule[originalModule] then
				loop:evictSystem(systemsByModule[originalModule])
				systemsByModule[originalModule] = nil
			end
			return
		end

		if firstRunSystems then
			table.insert(firstRunSystems, system)
		elseif systemsByModule[originalModule] then
			loop:replaceSystem(systemsByModule[originalModule], system)
			debugger:replaceSystem(systemsByModule[originalModule], system)
		else
			loop:scheduleSystem(system)
		end

		systemsByModule[originalModule] = system
	end

	local function unloadModule(_, context)
		if context.isReloading then
			return
		end

		local originalModule = context.originalModule
		if systemsByModule[originalModule] then
			loop:evictSystem(systemsByModule[originalModule])
			systemsByModule[originalModule] = nil
		end
	end

	-- ignore if debug and client only
	local isIgnore = false
	if game["Run Service"]:IsStudio() then
		local DebugOptions = require(game.ReplicatedStorage.Packages.DebugOptions)
		if DebugOptions.IsEnable("客户端调试开关") and game["Run Service"]:IsServer() then
			warn("client debug only, server ecs not start!")
			isIgnore = true
		end
	end

	-- 单机模式 服务端不启动
	if standAlone and game["Run Service"]:IsServer() then
		isIgnore = true
	end

	if not isIgnore then
		for _, container in containers do
			hotReloader:scan(container, loadModule, unloadModule)
		end
	end

	loop:scheduleSystems(firstRunSystems)
	firstRunSystems = nil

	debugger:autoInitialize(loop)
	--客户端 根据时间组件来同步不走这里
	-- if standAlone or game["Run Service"]:IsServer() then
	context.GameTime.ListenStepped()
	-- end

	loop:begin({
		default = RunService.Heartbeat, --渲染系统
		Stepped = RunService.Stepped, --玩家输入检测等，比heartbeat频率更高一点
		FixedUpdate = context.GameTime.OnFixedUpdate, --逻辑系统
		Update = context.GameTime.OnUpdate, --TODO: 渲染和逻辑频率之间是否需要一个系统
	})

	if RunService:IsClient() then
		UserInputService.InputBegan:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.F4 then
				debugger:toggle()
				state.debugEnabled = debugger.enabled
			end
		end)
	end

	return world, state
end

return start
