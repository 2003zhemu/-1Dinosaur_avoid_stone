-- by: CatchMoon
-- 检测函数耗时

local runService = game:GetService("RunService")

local TimeUtil = {}

-- 打印函数执行的时间
function TimeUtil.PrintTimeCost(func: () -> (), appendInfo: string)
	if runService:IsStudio() then
		local st = os.clock()
		func()
		warn((appendInfo .. "\t[耗时]: %dms"):format((os.clock() - st) * 1000))
	else
		func()
	end
end

return TimeUtil