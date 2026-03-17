--[=[
    @interface Logger
    .getName ()->string -- 日志记录器名称
    .Verbose (handler: (name: string) -> ()) -> ()   -- 杂项日志, 需使用 `print()` 输出
    .Debug (handler: (name: string) -> ()) -> ()     -- 调试日志, 需使用 `print()` 输出
    .Info (handler: (name: string) -> ()) -> ()      -- 信息日志, 需使用 `print()` 输出
    .Warn (handler: (name: string) -> ()) -> ()      -- 警告日志, 需使用 `warn()` 输出
    @within LoggerManager
    日志记录器

    * 为方便使用, Logger没有使用面向对象的方式, 而是使用了静态方法.
    * 为方便日志调试, 调用时, 需要传入一个函数, 该函数负责输出日志, 比如:
    ```lua

    local logger = LoggerManager.GetLogger("TestLogger")
    logger.Info(function(name: string)
        print(name,"this is a test")
    end)
    

    ```
]=]

local Logger = {}
local _settings = {}

Logger.__name = nil
Logger.__nameBrackets = nil

-- 初始化
function Logger.Init(name: string, setting: {})
	assert(name)
	assert(not Logger.__name, "Logger name can only be set once")
	Logger.__name = name
	Logger.__nameBrackets = "[" .. name .. "]"
	_settings = setting
end

-- 日志记录器名称
function Logger.getName()
	return Logger.__nameBrackets
end

-- 杂项日志
function Logger.Verbose(handler: (name: string) -> ())
	if _settings.Level <= 1 then
		handler(Logger.__nameBrackets)
	end
end

-- 调试日志
function Logger.Debug(handler: (name: string) -> ())
	if _settings.Level <= 2 then
		handler(Logger.__nameBrackets)
	end
end

-- 信息日志
function Logger.Info(handler: (name: string) -> ())
	if _settings.Level <= 3 then
		handler(Logger.__nameBrackets)
	end
end

-- 警告日志
function Logger.Warn(handler: (name: string) -> ())
	if _settings.Level <= 4 then
		handler(Logger.__nameBrackets)
	end
end


-- 杂项日志
function Logger.verbose(handler: (name: string) -> ())
	if _settings.Level <= 1 then
		handler(Logger.__nameBrackets)
	end
end

-- 调试日志
function Logger.debug(handler: (name: string) -> ())
	if _settings.Level <= 2 then
		handler(Logger.__nameBrackets)
	end
end

-- 信息日志
function Logger.info(handler: (name: string) -> ())
	if _settings.Level <= 3 then
		handler(Logger.__nameBrackets)
	end
end

-- 警告日志
function Logger.warn(handler: (name: string) -> ())
	if _settings.Level <= 4 then
		handler(Logger.__nameBrackets)
	end
end

return Logger
