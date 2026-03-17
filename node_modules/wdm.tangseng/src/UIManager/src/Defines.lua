--!strict

local module = {}

module.EventBeforeOpen = "打开界面之前"

module.EventBeforeClose = "关闭界面之前"

module.EventAfterOpen = "打开界面之后"

module.EventAfterClose = "关闭界面之后"

--[=[
	@interface Animation
	.Play (gui:GuiBase) -> () -- 播放动画
	@within UIManager
	动画
]=]
export type Animation = {
	Play: (gui: GuiBase) -> (),
}

--[=[
	@interface AnimationOptions
	.Name string -- 动画名称,如果为空，使用其脚本名称作为面板名称
	.Context any? -- 上下文，将在调用动画时，作为最后一个参数传递
	@within UIManager
	面板动画可选参数
]=]
export type AnimationOptions = {
	Name: string?,
	Context: any?,
}

--[=[
	@interface AnimationConfig
	.ModuleScript ModuleScript -- 动画对应的模块脚本
	@within UIManager
	面板动画配置
]=]
export type AnimationConfig = {
	ModuleScript: ModuleScript | string,
} & AnimationOptions

--[=[
	@type AnimationConfigs {AnimationConfig}
	@within UIManager
	面板动画配置数组
	如果成员为字符串或者模块脚本，则代表动画对应的模块脚本，并使用该脚本名称作为动画名称
]=]
export type AnimationConfigs = { string | ModuleScript | AnimationConfig }

--[=[
	@interface LayerConfig
	.Index number -- 层级索引
	. Name string -- 层级名称
	.LayerCollectorHandler ()->(LayerCollector) -- 回调，获取层级容器
	.Mode "single"|"multiple"|nil 

	层级配置

	Mode 参数有三种选项:
	* "single",默认，仅允许打开一个面板，只能容纳 AutoCloseAfter 为 nil 的面板
	* "multiple",该层级是否允许存在多个激活项 ，只能容纳 AutoCloseAfter 不A为 nil 的面板
	* nil,默认		
	@within UIManager
]=]
export type LayerConfig = {
	Index: number, -- 层级索引
	Name: string, -- 层级名称
	LayerCollectorHandler: () -> LayerCollector, -- 回调，获取层级容器
	Mode: "single" | "multiple" | nil,
}

--[=[
	@type LayerConfigs {LayerConfig}
	@within UIManager
	层级配置数组
]=]
export type LayerConfigs = { LayerConfig }

--[=[
	@interface PanelOptions
	.Name string? -- 面板名称
	.Layer number|string? -- 面板归属层级
	.FadeIn number|string|AnimationOptions? -- 进入动画，-1  代表无动画
	.FadeOut number|string|AnimationOptions? -- 退出动画，-1  代表无动画
	.IsModal boolean? -- 是否模态，如果某层不允许多个激活项，且其激活窗口是模态，则尝试打开其他窗口时，会报错并拒绝打开。
	.PrevFadeOut number|string|AnimationOptions? -- 打开本面板时，如果存在冲突面板，设置其退出动画，-1  代表无动画
	.NextFadeIn number|string|AnimationOptions? -- 关闭本面板时，如果设置其下个面板，则覆盖其打开动画，-1  代表无动画
	.AutoCloseAfter number? -- 在指定秒后自动关闭,具有该属性的面板，手动关闭业务将忽略之.
	.Next PanelOptions? -- 当本面板关闭后，下一个自动打开的面板,-1 代表自动打开上一个关闭的面板
	@within UIManager
	面板可选参数
]=]
export type PanelOptions = {
	Name: string?, -- 面板名称
	Layer: nil | number | string, -- 面板归属层级
	FadeIn: nil | number | string | AnimationOptions, -- 进入动画，-1  代表无动画
	FadeOut: nil | number | string | AnimationOptions, -- 退出动画，-1  代表无动画
	IsModal: boolean?, -- 是否模态，如果某层不允许多个激活项，且其激活窗口是模态，则尝试打开其他窗口时，会报错并拒绝打开。
	PrevFadeOut: nil | number | string | AnimationOptions, -- 打开本面板时，如果存在冲突面板，设置其退出动画，-1  代表无动画
	NextFadeIn: nil | number | string | AnimationOptions, -- 关闭本面板时，如果设置其下个面板，则覆盖其打开动画，-1  代表无动画
	AutoCloseAfter: number?, -- 在指定秒后自动关闭,具有该属性的面板，手动关闭业务将忽略之.
	Next: PanelOptions?, -- 当本面板关闭后，下一个自动打开的面板,-1 代表自动打开上一个关闭的面板
}

--[=[
	@interface ViewObject
	.Visible boolean -- 是否可见
	.Gui GuiBase -- 面板对象
	.Close ()->() -- 关闭面板
	.Open ()->() -- 打开面板
	@within UIManager
	面板对象
]=]
export type ViewObject = {
	Visible: boolean,
	Gui: GuiBase,
	Close: () -> (),
	Open: () -> (),
}

--[=[
	@interface Panel
	.Name string -- 面板名称
	.Init ()->() -- 初始化
	.GetViewObject ()->(ViewObject|GuiBase) -- 获取面板对象
	@within UIManager
	面板
]=]

export type Panel = {
	Name: string,
	Init: () -> (),
	GetViewObject: () -> ViewObject | GuiBase,
}

--[=[
	@interface ActivedPanel
	.Name string -- 面板名称
	.Panel Panel -- 面板对象
	.Options PanelOptions -- 面板可选参数
	@within UIManager
	已激活面板
]=]
export type ActivedPanel = {
	Name: string,
	Panel: Panel,
	Options: PanelOptions,
}

--[=[
	@interface PanelConfig
	.ModuleScript ModuleScript & PanelOptions -- 面板对应的模块脚本，存在于嵌套中时，可以为空
	@within UIManager
	面板配置
]=]
export type PanelConfig = {
	ModuleScript: { ModuleScript } | string, -- 面板对应的模块脚本，存在于嵌套中时，可以为空
} & PanelOptions

--[=[
	@type PanelConfigs {string|ModuleScript|PanelConfig}
	@within UIManager
	面板配置数组
	如果成员为字符串或者模块脚本，则代表面板对应的模块脚本，并使用该脚本名称作为面板名称
]=]
export type PanelConfigs = { string | ModuleScript | PanelConfig }

--[=[
	@interface DefaultPanelConfig
	.FadeIn string|number -- 默认面板打开动画，-1代表无动画
	.FadeOut string|number -- 默认面板关闭动画，-1代表无动画
	.Layer number|string -- 默认面板归属层级
	@within UIManager
	默认面板配置
]=]
export type DefaultPanelConfig = {
	FadeIn: string | number, -- 默认面板打开动画，-1代表无动画
	FadeOut: string | number, -- 默认面板关闭动画，-1代表无动画
	Layer: number | string, -- 默认面板归属层级
}

--[=[
	@interface UIManagerConfig
	.Layers LayerConfigs -- 层级配置
	.Panels PanelConfigs -- 面板配置
	.Animations AnimationConfigs -- 动画配置
	.TextInfoPanel string -- 文字消息面板名称
	.MessageBoxPanel string -- 对话框面板名称
	.InputBoxPanel string -- 输入框面板名称
	.DefaultPanelConfig DefaultPanelConfig -- 默认面板配置
	.LayerPanelStorageHander (string)->(LayerCollector) -- 面板储藏层
	@within UIManager
	UIManager Api
]=]
export type UIManagerConfig = {
	Layers: LayerConfigs,
	Panels: PanelConfigs,
	Animations: AnimationConfigs,
	TextInfoPanel: string, -- 文字消息面板名称
	MessageBoxPanel: string, -- 对话框面板名称
	InputBoxPanel: string, -- 输入框面板名称
	DefaultPanelConfig: DefaultPanelConfig, -- 默认面板配置
	LayerPanelStorageHander: (string) -> LayerCollector, -- 面板储藏层
	ErrorHandlers: {
		OnOpenPanelError: (panelName: string) -> (),
	}, -- 错误回调集合
}

return module
