-- By: CatchMoon
-- 用于打印详细的警告、错误信息
-- 包含一些常见的检测

local DebugUtil = {}

DebugUtil.WarnType = {
	argTypeErr = "< 参数类型错误 >",
}

function DebugUtil.Warn(warnType: string, ...)
	local args = {...}
	if warnType == DebugUtil.WarnType.argTypeErr then
		-- TODO args check
		
		local argVal = args[1]
		local argType = typeof(argVal)
		warn("\n" .. warnType,
			"\n[type]: " .. argType,
			"\n[val]:\n", argVal,
			"\n[traceback]:\n", debug.traceback())
	end
end

return DebugUtil