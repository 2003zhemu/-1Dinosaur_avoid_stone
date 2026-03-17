local merger = require(game.ReplicatedStorage.Battle.Packages.MatterExtension.ComponentsMerger)

local module: { [string]: merger.ComponentConfig } = {
	GameTimer = { Sync = true, Default = { Time = 0 } },
	Transform = { Sync = true, Default = { CFrame = nil } },
	Signals = {
		Sync = false,
		Default = { Value = {} },
	},
	TimerDelay = {
		Sync = false,
		Default = {
			TriggerTime = nil,
			Func = nil,
			Params = nil,
		},
	},
	--循环调用时间
	TimerLoop = {
		Sync = false,
		Default = {
			TriggerTime = nil, --下一次调用时间
			Interval = nil, --调用间隔时间
			Func = nil,
			Params = nil,
		},
	},
}

return module
