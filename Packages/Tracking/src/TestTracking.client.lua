-- -- 临时使用, 回头改为单元测试
-- local sdk = require(game.ReplicatedStorage.Packages.GameAnalytics)

-- sdk:initClient()

-- local Tracking = require(game.ReplicatedStorage.Packages.Tracking)

-- --- 初始化
-- Tracking.Init({
-- 	["加载开始"] = {
-- 		Id = "加载开始",
-- 		IsClient = false,
-- 		EventType = {
-- 			_type_ = "EventDesign",
-- 			Name = "game:load:start",
-- 		},
-- 	},
-- 	["客户端事件"] = { Id = "关卡开始", IsClient = true, EventType = { _type_ = "EventProgressionStart" } },
-- })

-- wait(10) -- 必须等待一会, 等待GA准备好, 这就很奇怪, 可以 优化
-- print("start test tracking")

-- local EventBus = require(game.ReplicatedStorage.Packages.EventBus)

-- EventBus.FireServer("埋点", "客户端事件", "world4")
