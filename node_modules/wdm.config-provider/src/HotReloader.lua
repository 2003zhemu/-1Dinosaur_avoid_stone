-- 热更新
local rs = game:GetService("ReplicatedStorage")
local Rewire = require(rs.Packages.rewire)
local reloader = Rewire.HotReloader.new()

local module = {}
function throttle(func, delay)
	local lastCall = 0
	local executed = true
	local args = {}

	game["Run Service"].Heartbeat:Connect(function()
		if not executed and os.clock() - lastCall > delay then
			executed = true
			func(table.unpack(args))
		end
	end)

	return function(...)
		args = { ... }
		lastCall = os.clock()
		executed = false
	end
end

module.Watch = function(folder, handler)
	if game["Run Service"]:IsStudio() then
		local throttledFunction = throttle(handler, 0.2) -- 0.2秒节流
		reloader:scan(folder, function() end, throttledFunction)
	end
end

return module
