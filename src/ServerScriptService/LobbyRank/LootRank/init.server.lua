local controller = require(script.Controller)
local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
-- find instance
local levelRankList = game.Workspace.Rank["ExpRank"].Main.SurfaceGui.Frame:WaitForChild("ScrollingFrame")

local viewConfig = {
	["/货币/奖杯?属性数量"] = levelRankList, -- 此处填写地址对应Board实例
}

controller.InitView(viewConfig)

-- 更新冷数据
local function updateColdRanks()
	for path, v in pairs(viewConfig) do
		controller.UpdateColdRank(path)
	end
end

-- 更新排行榜
local function updateBoard()
	for path, v in pairs(viewConfig) do
		controller.UpdateBoard(path)
	end
end

local showrankflag = true
local function StartShowRank()
	if showrankflag then
		showrankflag = false
		task.spawn(function()
			while true do
				updateColdRanks()
				wait(10 * 60) -- 冷数据10分钟更新一次
			end
		end)

		task.spawn(function()
			while true do
				updateBoard()
				wait(30) -- 排行榜5秒更新一次
			end
		end)
	end
end

wukongServer.ConnectUserRegisterEvent(StartShowRank)
