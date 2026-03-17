local defines = require(game.ReplicatedStorage.Packages.UIManager.Defines)

-- 设置配置
local module: defines.UIManagerConfig = {
	Layers = {
		{
			Index = 0,
			Name = "最底层",
			LayerCollectorHandler = function()
				return game.Players.LocalPlayer.PlayerGui:WaitForChild("最底层")
			end,
		},
		{
			Index = 20,
			Name = "主业务层",
			LayerCollectorHandler = function()
				return game.Players.LocalPlayer.PlayerGui:WaitForChild("主业务层")
			end,
		},
		{
			Index = 30,
			Name = "消息层",
			Mode = "multiple",
			LayerCollectorHandler = function()
				return game.Players.LocalPlayer.PlayerGui:WaitForChild("消息层")
			end,
		},
		{
			Index = 40,
			Name = "弹窗层",
			LayerCollectorHandler = function()
				return game.Players.LocalPlayer.PlayerGui:WaitForChild("弹窗层")
			end,
		},
	},
	Panels = {},
	Animations = {},
	DefaultPanelConfig = {
		FadeIn = -1, -- 默认打开动画
		FadeOut = -1, -- 默认关闭动画
		Layer = 20, -- 默认层
	},
	LayerPanelStorageHander = function(panelName)
		return game.ReplicatedStorage.Panels
	end,
	ErrorHandlers = {
		OnOpenPanelError = function(panelName: string)
			error("Panel UI is preparing :" .. panelName)
		end,
	}, -- 错误回调集合
}

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module, script.Name)

return module
