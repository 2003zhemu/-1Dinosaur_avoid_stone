--[=[
	@class UIManager
	@server
	@client
	界面管理员
]=]
local UIManager = {}

local defines = require(script.Defines)

local panelManager = require(script.PanelManager)
local quickOpenHelper = require(script.QuickOpenHelper)

local cfgValidator = require(script.ConfigValidator)
local layerManager = require(script.LayerManager)
local animationManager = require(script.AnimationManager)
local panelManager = require(script.PanelManager)
local cfg = require(script.UIManagerConfig)

--[=[
	是否已经初始化
	@within UIManager
	@prop IsInit boolean
]=]
UIManager.IsInit = false

--- 添加面板配置
function UIManager.AddPanelConfig(
	panelName: string,
	panel: defines.Panel,
	panelOptions: defines.PanelOptions?,
	isOverwrite: boolean?
)
	assert(panelName, "Panel Name can not be nil")
	return panelManager.AddPanelConfig(panelName, panel, panelOptions, isOverwrite)
end

--- 打开指定面板
function UIManager.OpenPanel(panelName: string, ...: any)
	return panelManager.OpenPanel(panelName, ...)
end

--- 使用补丁打开指定面板
function UIManager.OpenPanelWithOption(panelName: string, panelOptions: defines.PanelOptions, ...: any)
	return panelManager.OpenPanelWithOption(panelName, panelOptions, ...)
end

--- 获取已激活面板列表,返回面板名称数组
--- 参数为空时，返回所有激活面板，否则返回指定层级激活面板
function UIManager.GetActivePanels(indexOrName: number | string | nil): { defines.ActivedPanel }
	return panelManager.GetActivePanels(indexOrName)
end

--- 获取所有面板列表,返回面板名称数组
function UIManager.GetAllPanels(): { string }
	return panelManager.GetAllPanels()
end

--- 关闭面板
function UIManager.ClosePanel(panelName: string): ()
	return panelManager.ClosePanel(panelName)
end

--- 清空指定层级，关闭其所有激活面板
--- 参数为层级编号或者名称
function UIManager.ClearLayer(indexOrName: number | string): ()
	return panelManager.ClearLayer(indexOrName)
end

-- 展示文字消息，该消息会慢慢消失
-- 参数1: 消息内容
-- 参数2: 面板名称，该面板必须为消息类型面板，将使用该面板展示消息.
-- 参数3: 面板中将展示该ui对象，如果参数为数字，将使用该数字创建Image,并传递给面板
function UIManager.ShowTextInfo(text: string, panelName: string?, uiObject: GuiBase | number | nil, ...: any): ()
	return quickOpenHelper.ShowTextInfo(text, panelName, uiObject, ...)
end

--- 展示文字消息，该消息会慢慢消失
--- 参数按照顺序为： panelName:string,text:string,uiObject:GuiBase?|number?,...any
function UIManager.ShowTextInfoByArray(options: {}): ()
	return quickOpenHelper.ShowTextInfoByArray(options)
end

-- 展示提示信息
function UIManager.ShowMessageBox(message: string, title: string?, hasCancle: boolean?, ...: any): boolean
	return quickOpenHelper.ShowMessageBox(message, title, hasCancle, ...)
end

--- 展示输入信息
--- 用户输入并提交后，返回结果
--- 如果用户取消输入，则返回空
function UIManager.ShowInputBox(message: string, title: string?, hasCancle: boolean?, ...: any): string
	return quickOpenHelper.ShowInputBox(message, title, hasCancle)
end

--[=[
	初始化UIManager
	@param modules {}? -- 模块列表，如果这些模块中包含 `GetPanelConfig()`, 则会调用该方法获取面板配置

	GetPanelConfig() 返回的参数, 应该为 UIManager.AddPanelConfig() 所需要的参数.
]=]
function UIManager.Init(modules: {}?)
	-- validator configs
	cfgValidator.ValidateConfig(cfg)

	-- init
	animationManager.Init(cfg.Animations)
	layerManager.Init(cfg.Layers, cfg.LayerPanelStorageHander)
	panelManager.Init(cfg.Panels, cfg.DefaultPanelConfig, cfg.ErrorHandlers)

	-- add all panels
	for k, v in modules do
		if v.Module["GetPanelConfig"] then
			UIManager.AddPanelConfig(v.Module["GetPanelConfig"]())
		end
	end

	UIManager.IsInit = true
	table.freeze(UIManager)
end

return UIManager
