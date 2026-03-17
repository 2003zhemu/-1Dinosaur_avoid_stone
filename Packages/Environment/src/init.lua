--[=[
	@class Environment

	运行环境的定义
]=]
local Environment = {}
Environment.__index = Environment
local RunService = game["Run Service"]
local DebugOptions = require(game.ReplicatedStorage.Packages.DebugOptions)

--[=[
	生产环境
	@prop IsProduction boolean
	@within Environment
]=]
Environment.IsProduction = function()
	return RunService:IsStudio() == false
end

--[=[
	客户端研发环境
	@prop IsDevClient boolean
	@within Environment
]=]
Environment.IsDevClient = function()
	--TODO: 如果是主播弹幕模式也认为是开发环境，可以本地跑
	return not Environment.IsProduction() and DebugOptions.IsEnable("客户端调试开关")
end

--[=[
	研发环境
	@prop IsDev boolean
	@within Environment
]=]
Environment.IsDev = function()
	return not Environment.IsProduction() and not DebugOptions.IsEnable("客户端调试开关")
end

local _env = nil
Environment.EnvName = function()
	if _env then
		return _env
	end
	if Environment.IsProduction() then
		_env = "production"
	elseif Environment.IsDevClient() then
		_env = "devClient"
	elseif Environment.IsDev() then
		_env = "dev"
	else
		error("impossible")
	end
	return _env
end

return Environment
