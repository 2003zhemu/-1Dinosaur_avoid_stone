local ClickHelper = {}
ClickHelper.__index = ClickHelper

local cache = {}

function ClickHelper.CanActivate(actionId, cooldownTime)
    cooldownTime = cooldownTime or 0.3
	local currentTime = tick()
    if not cache[actionId] then
        cache[actionId] = 0
    end
	if currentTime - cache[actionId] < cooldownTime then
		return false
	end
	cache[actionId] = currentTime
	return true
end

return ClickHelper