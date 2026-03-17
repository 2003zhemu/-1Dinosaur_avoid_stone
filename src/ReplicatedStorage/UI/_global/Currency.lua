local wukong = require(game.ReplicatedStorage.WuKong)

local all = {
	Cups = "奖杯",
}

local module = {}

for i, v in pairs(all) do
	module[i] = wukong:ExecuteQuery("/货币/" .. v .. "?属性数量")
	wukong:RegisterSlotObserver("/货币/" .. v, function()
		module[i] = wukong:ExecuteQuery("/货币/" .. v .. "?属性数量")
	end)
end

return module
