--[=[
    @class LoggerManager
    @server
    @client

    LoggerManager 日志管理员

    :::caution 注意
    * 本模块会缓存所有相同名称的日志记录器, 从另一个方面说, 如果无限制的创建日志记录器, 会导致内存泄漏.
    * 在 studio 中, 默认等级为 "Verbose", 在游戏中, 默认等级为 "Info".
    :::
]=]

local cache = {}
local _settings = require(script.Settings)

-- 通过克隆的方式创建日志记录器, 这样可以使用其静态方法.
local function GetLogger(name: string)
	local clone = script.Logger:Clone()
	local module = require(clone)
	module.Init(name, _settings)
	module.Verbose(function(name: string)
		print(name, "Logger created")
	end)
	return module
end

local LoggerManager = {}

--[=[
    获取日志记录器
    @param name string --- 日志记录器名称
    @return Logger
]=]
function LoggerManager.GetLogger(name: string)
	assert(name)
	local result = cache[name]
	if result then
		return result
	end
	result = GetLogger(name)
	cache[name] = result
	return result
end

--[=[
    设置日志记录器的日志等级
    @param level "Verbose" | "Debug" | "Info" | "Warn" | "None" --- 日志等级
]=]
function LoggerManager.SetLevel(level: "Verbose" | "Debug" | "Info" | "Warn" | "None")
	if level == "Verbose" then
		_settings.Level = 1
	elseif level == "Debug" then
		_settings.Level = 2
	elseif level == "Info" then
		_settings.Level = 3
	elseif level == "Warn" then
		_settings.Level = 4
	elseif level == "None" then
		_settings.Level = 5
	else
		error("Invalid level")
	end
end

-- 设置日志等级 by environment
if game:GetService("RunService"):IsStudio() then
	LoggerManager.SetLevel("Verbose")
else
	LoggerManager.SetLevel("Info")
end

return LoggerManager
