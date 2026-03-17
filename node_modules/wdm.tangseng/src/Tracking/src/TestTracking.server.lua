-- -- 临时使用, 回头改为单元测试
-- local sdk = require(game.ReplicatedStorage.Packages.GameAnalytics)

-- sdk:setEnabledInfoLog(true)
-- sdk:setEnabledVerboseLog(true)

-- sdk:initServer("e7ef535f316327bebe3cfd654242ab8a", "71befc6b9846948aad497355ad89e5503c7fa757")

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
-- 	["客户端事件"] = { Id = "客户端事件", IsClient = true, EventType = { _type_ = "EventProgressionStart" } },
-- 	["关卡开始"] = { Id = "关卡开始", IsClient = false, EventType = { _type_ = "EventProgressionStart" } },
-- 	["关卡胜利"] = { Id = "关卡胜利", IsClient = false, EventType = { _type_ = "EventProgressionComplete" } },
-- 	["关卡失败"] = { Id = "关卡失败", IsClient = false, EventType = { _type_ = "EventProgressionFail" } },
-- })

-- -- wait(20) -- 必须等待一会, 等待GA准备好, 这就很奇怪, 可以 优化
-- -- print("start test tracking")

-- -- Tracking.Fire(3703873374, "加载开始", 3)

-- -- Tracking.Fire(3703873374, "关卡胜利", "world1", "stage1", "level1", 5)
-- -- Tracking.Fire(3703873374, "关卡胜利", "world2")

-- -- local EventBus = require(game.ReplicatedStorage.Packages.EventBus)

-- -- EventBus.Fire("埋点", 3703873374, "关卡失败", "world4")
