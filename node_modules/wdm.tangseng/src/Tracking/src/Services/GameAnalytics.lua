local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 需要确保事件发生前, sdk已经被Init了
local sdk = require(ReplicatedStorage.Packages.GameAnalytics)

local GameAnalytics = {}
GameAnalytics.__index = GameAnalytics

-- new GameAnalytics
function GameAnalytics:new()
	local self = setmetatable({}, GameAnalytics)
	return self
end
-- 错误：参数... 始终只能接收一个，为了不改动原有代码，新规定参数只能传一个字符串 以冒号 : 分割
function GameAnalytics:ReportEventDesign(userId: number, eventName: string, ...)
	local args = {...}
	local value = nil
	local info = string.split(eventName, ":")
	for i = 1, 3 do
		if not info[i] then
			local extra = table.remove(args, 1)
			if not extra then
				break
			end
			table.insert(info, extra)
		end
	end
	if #info ~= 3 then
		error("eventName is invalid")
	end
	eventName = table.concat(info, ":")
	value = args[1]

	sdk:addDesignEvent(userId, {
		eventId = eventName,
		value = value,
	})
end

local function reportProgression(userId: number, progressionStatus: string, ...: any)
	local args = { ... }
	if not args[1] then
		error("progression01 is nil")
	end

	sdk:addProgressionEvent(userId, {
		progressionStatus = progressionStatus,
		progression01 = args[1],
		progression02 = args[2],
		progression03 = args[3],
		score = args[4],
	})
end

function GameAnalytics:ReportEventProgressionStart(userId: number, ...)
	reportProgression(userId, sdk.EGAProgressionStatus.Start, ...)
end

function GameAnalytics:ReportEventProgressionComplete(userId: number, ...)
	reportProgression(userId, sdk.EGAProgressionStatus.Complete, ...)
end

function GameAnalytics:ReportEventProgressionFail(userId: number, ...)
	reportProgression(userId, sdk.EGAProgressionStatus.Fail, ...)
end

return GameAnalytics
