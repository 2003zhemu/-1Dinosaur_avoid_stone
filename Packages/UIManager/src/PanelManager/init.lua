local defines = require(script.Parent.Defines)

local moduleLoader = require(game.ReplicatedStorage.Packages.ModuleLoader)

local layerManager = require(script.Parent.LayerManager)

local optionsProvider = require(script.PanelOptionsProvider)

local tableUtil = require(game.ReplicatedStorage.Packages.Utils.TableUtil)

local animationManager = require(script.Parent.AnimationManager)

-- 面板配置
local panelOptionsDict: { [string]: defines.PanelOptions } = {}

-- 面板模块列表
local panelModules: { [string]: defines.PanelModule } = {}

local eventBus = require(game.ReplicatedStorage.Packages.EventBus)

local module = {}

local function _addActivePanel(
	name: string,
	panel: defines.ViewObject | GuiObject,
	options: defines.PanelOptions
): defines.ActivedPanel
	local result = {
		Name = name,
		Panel = panel,
		Options = options,
	}

	-- 自动关闭
	if options.AutoCloseAfter then
		task.spawn(function()
			wait(options.AutoCloseAfter)
			layerManager.RemoveActivePanel(result)
		end)
	end

	-- 激活面板
	layerManager.AddActivePanel(result)

	return result
end

-- 打开ViewObject
local function _open(panel: defines.Panel, options, ...)
	-- panel
	if panel["Show"] then
		panel["Show"](true, ...)
	end

	local vo = panel.GetViewObject()
	local gui = nil
	if typeof(vo) == "Instance" then
		gui = vo
		eventBus.Fire(defines.EventBeforeOpen, panel.Name, gui, options, ...)
		vo.Visible = true
	else
		gui = vo.Gui
		eventBus.Fire(defines.EventBeforeOpen, panel.Name, gui, options, ...)
		vo.Open(...)
	end
	eventBus.Fire(defines.EventAfterOpen, panel.Name, gui, options, ...)
end

-- 关闭ViewObject
local function _close(panel: defines.Panel)
	-- panel
	if panel["Show"] then
		panel["Show"](false)
	end

	local gui = nil
	local vo = panel.GetViewObject()
	if typeof(vo) == "Instance" then
		gui = vo
		eventBus.Fire(defines.EventBeforeClose, panel.Name, gui)
		vo.Visible = false
	else
		gui = vo
		eventBus.Fire(defines.EventBeforeClose, panel.Name, gui)
		vo.Close()
	end
	eventBus.Fire(defines.EventAfterClose, panel.Name, gui)
end

-- 打开新面板
local function _openNewPanel(panelName: string, panel: defines.Panel, options: defines.PanelOptions, ...)
	local activePanel = _addActivePanel(panelName, panel, options)
	animationManager.PlayFadeIn(activePanel)
	_open(panel, options, ...)
end

-- 关闭激活面板
local function _closeActivePanel(activePanel: defines.ActivedPanel)
	-- 如果存在 AutoCloseAfter 属性，则不能关闭
	if activePanel.Options and activePanel.Options.AutoCloseAfter then
		return
	end
	assert(activePanel.Options)
	assert(activePanel.Options.Layer)
	layerManager.RemoveActivePanel(activePanel)
	animationManager.PlayFadeOut(activePanel)
	_close(activePanel.Panel)
end

-- 替换面板
local function _replacePanelWithSingle(
	activedPanel: defines.ActivedPanel,
	panelName: string,
	panelModule: defines.PanelModule,
	panelOptions: defines.PanelOptions,
	...
)
	-- 如果已激活面板的模态是true，则报错
	if activedPanel.Options.IsModal then
		error("已激活面板为模态，不能替换")
	end
	-- 关闭已激活面板
	local name = activedPanel.Options.Name
	assert(name)
	_closeActivePanel(activedPanel)
	-- 打开新面板
	_openNewPanel(panelName, panelModule, panelOptions, ...)
end

-- 从缓存中获取面板模块
local function _getPanelModule(name: string): defines.PanelModule
	local panelModule = panelModules[name]
	if not panelModule then
		error("不存在面板模块:" .. name)
	end
	return panelModule
end

-- 分析面板信息
local function _parsePanelInfo(panelConfig: string | ModuleScript | defines.PanelConfig): {
	moduleName: string?,
	moduleScript: ModuleScript | string,
	panelOptions: defines.PanelOptions,
}
	if typeof(panelConfig) == "Instance" then
		assert(panelConfig.ClassName == "ModuleScript", "PanelConfig 的 Instance 必须为 ModuleScript类型")
		return {
			moduleScript = panelConfig,
			moduleName = panelConfig.Name,
			panelOptions = optionsProvider.BuildOptions({
				Name = panelConfig.Name,
			}),
		}
	end

	if type(panelConfig) == "string" then
		return {
			moduleScript = panelConfig,
			panelOptions = optionsProvider.BuildOptions({}),
		}
	end

	assert(panelConfig.ModuleScript, "面板配置必须包含 ModuleScript成员")

	return {
		moduleScript = panelConfig.ModuleScript,
		moduleName = panelConfig.Name,
		panelOptions = optionsProvider.BuildOptions(panelConfig),
	}
end

local function _asssertPanelModule(panel, panelName)
	assert(panel["Init"], "面板模块未包含 Init() 方法:" .. panelName)
	assert(panel["GetViewObject"], "面板模块未包含 GetViewObject() 方法:" .. panelName)
end

local function _updateCache(panel, panelOptions)
	local panelName = panelOptions.Name
	panelModules[panelName] = panel
	panelOptionsDict[panelName] = panelOptions
end

local function _loadModules(panelConfigs)
	-- 加载模块到缓存
	local moduleToLoads = {}
	local panelInfos = {}

	for _, m in ipairs(panelConfigs) do
		local panelInfo = _parsePanelInfo(m)
		table.insert(moduleToLoads, panelInfo.moduleScript)
		table.insert(panelInfos, panelInfo)
	end

	local moduleResults = moduleLoader.LoadModules(moduleToLoads)

	for index, moduleResult in ipairs(moduleResults) do
		local module = moduleResult.Module
		local panelName = panelInfos[index].moduleName or moduleResult.ModuleName

		assert(not panelModules[panelName], "面板已注册:" .. panelName)

		_asssertPanelModule(module, panelName)

		-- 配置缓存
		panelInfos[index].panelOptions.Name = panelName
		_updateCache(module, panelInfos[index].panelOptions)
	end
end

local module = {}

local _isInit = false

-- 错误回调
local _errorHandlers = nil

-- 初始化
module.Init = function(
	panelConfigs: defines.PanelConfigs,
	defaultPanelConfig: defines.DefaultPanelConfig,
	errorHandlers: {}?
)
	assert(not _isInit)
	_isInit = true
	_errorHandlers = errorHandlers or {}

	optionsProvider.Init(defaultPanelConfig)

	-- 验证配置
	local panelsValidator = require(script.Parent.ConfigValidator.PanelsValidator)

	local success, err = panelsValidator.ValidatePanelConfigs(panelConfigs)

	if not success then
		error(err)
	end

	tableUtil.Reverse(panelConfigs)

	_loadModules(panelConfigs)
end

-- 获取面板配置
module.GetPanelOption = function(panelName: string): defines.PanelOptions
	return panelOptionsDict[panelName]
end

-- 获取所有面板列表,返回面板名称数组
module.GetAllPanels = function(): { string }
	local panels = {}
	for name, _ in pairs(panelOptionsDict) do
		table.insert(panels, name)
	end
	return panels
end

-- 使用配置打开面板
local function _openPanelWithOption(panelName: string, panelOptions: defines.PanelOptions, ...)
	-- 获取面板模块
	local panelModule = _getPanelModule(panelName)

	-- 如果含有 TryPrepareUI, 则判断其是否准备好
	if panelModule["TryPrepareUI"] and not panelModule.TryPrepareUI() then
		if _errorHandlers["OnOpenPanelError"] then
			_errorHandlers["OnOpenPanelError"](panelName)
			return
		else
			error("Panel UI is preparing:" .. panelName)
		end
	end

	assert(panelOptions.Layer)
	local layerConfig = layerManager.GetLayerConfig(panelOptions.Layer)
	-- 获取面板层级
	local layerNameOrIndex = layerConfig.Name

	-- 检查该层级是否允许Multiple
	local allowMultiple = layerManager.AllowMultiple(layerNameOrIndex)

	-- 获取该层级激活面板数量
	local activePanelsCount = layerManager.GetActivePanelsCount(layerNameOrIndex)

	-- 多重打开
	if allowMultiple then
		_openNewPanel(panelName, panelModule, panelOptions, ...)
	-- 单个打开，没有面板激活
	elseif activePanelsCount == 0 then
		_openNewPanel(panelName, panelModule, panelOptions, ...)
	-- 单个打开，本面板已经激活
	elseif layerManager.IsPanelActive(layerNameOrIndex, panelName) then
	-- 单个打开，需要替换面板
	else
		local activedPanel = layerManager.GetActivePanels(layerNameOrIndex)[1]
		_replacePanelWithSingle(activedPanel, panelName, panelModule, panelOptions, ...)
	end
end

-- 打开指定面板
module.OpenPanel = function(panelName: string, ...)
	-- 获取默认配置
	local panelConfig = module.GetPanelOption(panelName)
	if not panelConfig then
		error("不存在面板配置:" .. panelName)
	end

	return _openPanelWithOption(panelName, panelConfig, ...)
end

-- 使用补丁打开指定面板
module.OpenPanelWithOption = function(panelName: string, patch: defines.PanelOptions, ...)
	-- 获取默认配置
	local panelOption = module.GetPanelOption(panelName)
	if not panelOption then
		error("不存在面板配置:" .. panelName)
	end

	local patched = optionsProvider.BuildOptions(patch)

	return _openPanelWithOption(panelName, patched, ...)
end

-- 获取已激活面板列表,返回面板名称数组
-- 参数为空时，返回所有激活面板，否则返回指定层级激活面板
module.GetActivePanels = function(layerNameOrIndex): { defines.ActivedPanel }
	return layerManager.GetActivePanels(layerNameOrIndex)
end

-- 关闭面板
module.ClosePanel = function(panelName: string): ()
	-- 获取已激活面板实例列表
	local actives = module.GetActivePanels()

	for _, panel in ipairs(actives) do
		if panel.Options.Name == panelName then
			_closeActivePanel(panel)
		end
	end
end

-- 清空指定层级，关闭其所有激活面板
-- 参数为层级编号或者名称
module.ClearLayer = function(indexOrName: number | string): ()
	for k, v in layerManager.GetActivePanels(indexOrName) do
		_closeActivePanel(v)
	end
end

-- 添加面板配置，第 3 个参数为是否覆盖原配置
module.AddPanelConfig = function(
	panelName: string,
	panel: defines.Panel,
	panelOptions: defines.PanelOptions?,
	isOverwrite: boolean?
)
	if panelModules[panelName] and not isOverwrite then
		return
	end

	assert(_isInit)

	local options = optionsProvider.BuildOptions(panelOptions or {})

	options.Name = panelName

	_updateCache(panel, options)
end

return module
