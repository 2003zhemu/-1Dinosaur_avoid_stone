local EventTimeHelper = {}
local EventStartTimeCfg = require(game.ReplicatedStorage.Configs.EventStartTimeCfg)
local CYCLE_DURATION = 7 * 24 * 60 * 60 -- 每周循环（秒）
local EVENT_DURATION = 1 * 60 * 60 -- 活动时长 1 小时（秒）

-- 活动是否开启（任意时段开启即返回 true）
function EventTimeHelper.IsEventActive()
	local now = game.Workspace:GetServerTimeNow()
	for _, ref in ipairs(EventStartTimeCfg) do
		local elapsed = now - ref
		if elapsed >= 0 then
			local cycleElapsed = elapsed % CYCLE_DURATION
			if cycleElapsed < EVENT_DURATION then
				return true
			end
		end
	end
	return false
end

return EventTimeHelper
