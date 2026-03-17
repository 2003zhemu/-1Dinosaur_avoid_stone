--!strict

local module = {}
local defines = require(script.Parent.Defines)

local cacheByName: { [string]: defines.LayerConfig } = {}

local cacheByIndex: { [number]: defines.LayerConfig } = {}

-- 已激活缓存
-- key: 层级名称
-- value: 已激活面板对象列表
local activeCache: { [string]: { defines.ActivedPanel } } = {}

local _configs: defines.LayerConfigs = nil

local _layerPanelStorageHandler: (string) -> LayerCollector = nil

-- 初始化,缓存LayerConfigs到字典
module.Init = function(layerConfigs: defines.LayerConfigs, layerPanelStorageHander: (string) -> LayerCollector)
	_configs = layerConfigs

	_layerPanelStorageHandler = layerPanelStorageHander

	-- 验证配置，尝试抛出错误
	local layerConfigsValidator = require(script.Parent.ConfigValidator.LayersValidator)
	local success, err = layerConfigsValidator.Validate(layerConfigs)
	if not success then
		error(err)
	end

	-- 缓存配置
	for _, layerConfig in ipairs(layerConfigs) do
		cacheByName[layerConfig.Name] = layerConfig
	end

	-- 缓存配置
	for _, layerConfig in ipairs(layerConfigs) do
		cacheByIndex[layerConfig.Index] = layerConfig
	end
end

-- 获取所有层级名称
module.GetAllLayers = function(): { string }
	local layers = {}
	for name, _ in pairs(cacheByName) do
		table.insert(layers, name)
	end
	return layers
end

-- 存在层级配置
module.HasLayerConfig = function(indexOrName: string | number): boolean
	if type(indexOrName) == "number" then
		return cacheByIndex[indexOrName] ~= nil
	end

	return cacheByName[indexOrName] ~= nil
end

-- 获取层级配置,如果其不存在,会抛出错误
module.GetLayerConfig = function(indexOrName: string | number): defines.LayerConfig
	-- 如果不存在，抛出错误
	if not module.HasLayerConfig(indexOrName) then
		error("不存在层级配置:" .. tostring(indexOrName))
	end

	if type(indexOrName) == "number" then
		return cacheByIndex[indexOrName]
	end

	return cacheByName[indexOrName]
end

-- 设置激活面板
module.SetActivePanel = function(indexOrName: string | number, panelName)
	local cfg = module.GetLayerConfig(indexOrName)
	if not activeCache[cfg.Name] then
		activeCache[cfg.Name] = {}
	end
	activeCache[cfg.Name] = panelName
end

-- 指定层级是否允许多个面板
module.AllowMultiple = function(indexOrName: string | number)
	local layerConfig = module.GetLayerConfig(indexOrName)
	return layerConfig.Mode == "multiple"
end

-- 根据层级索引，获取层级名称
module.GetNameByIndex = function(index: number): string
	local config = module.GetLayerConfig(index)
	return config.Name
end

-- 根据层级名称，获取层级索引
module.GetIndexByName = function(name: string)
	local config = module.GetLayerConfig(name)
	return config.Index
end

-- 指定层中面板是否激活
module.IsPanelActive = function(layerNameOrIndex: string | number, panelName: string)
	local layerName = module.GetLayerConfig(layerNameOrIndex).Name
	local activePanels = activeCache[layerName]
	if not activePanels then
		return false
	end

	for k, v in pairs(activePanels) do
		if v.Name == panelName then
			return true
		end
	end
	return false
end

-- 获取面板列表，参数不为空：获取指定层中所有激活面板，参数为空：获取所有面板
module.GetActivePanels = function(layerNameOrIndex: string | number | nil): { defines.ActivedPanel }
	-- 获取所有面板
	if not layerNameOrIndex then
		local result = {}
		for _, panels in activeCache do
			for _, panel in panels do
				table.insert(result, panel)
			end
		end
		return result
	end

	-- 获取指定层级面板
	assert(layerNameOrIndex)
	local layerName = module.GetLayerConfig(layerNameOrIndex).Name
	local activePanels = activeCache[layerName]
	if not activePanels then
		activePanels = {}
	end
	return activePanels
end

-- 已激活面板数量
module.GetActivePanelsCount = function(layerNameOrIndex: string | number): number
	return #module.GetActivePanels(layerNameOrIndex)
end

-- 向层中添加激活面板，如果不符合allowMultipe规则，会报错
module.AddActivePanel = function(activePanel: defines.ActivedPanel)
	local layerNameOrIndex = activePanel.Options.Layer
	assert(layerNameOrIndex)
	local actives = module.GetActivePanels(layerNameOrIndex)
	local allowMultiple = module.AllowMultiple(layerNameOrIndex)
	local cfg = module.GetLayerConfig(layerNameOrIndex)

	if not allowMultiple and #actives > 0 then
		error("层级不允许叠加:" .. tostring(layerNameOrIndex))
	end
	if not activeCache[cfg.Name] then
		activeCache[cfg.Name] = {}
	end

	table.insert(activeCache[cfg.Name], activePanel)

	-- set parent
	if cfg.LayerCollectorHandler then
		local layerContainer = cfg.LayerCollectorHandler()

		local vo = activePanel.Panel.GetViewObject()
		if typeof(vo) == "Instance" then
			vo.Parent = layerContainer
		else
			local gui = vo.Gui
			gui.Parent = layerContainer
		end
	end
end

-- 在层中移除激活面板，如果面板不存在，会报错
module.RemoveActivePanel = function(activePanel: defines.ActivedPanel)
	assert(activePanel.Options.Layer)
	local cfg = module.GetLayerConfig(activePanel.Options.Layer)
	local panels = activeCache[cfg.Name] or {}

	local index = nil
	for i, v in ipairs(panels) do
		if v == activePanel then
			index = i
			break
		end
	end

	assert(index, "未找到需要移除的面板:" .. activePanel.Name)
	table.remove(panels, index)

	-- 回收
	if cfg.LayerCollectorHandler then
		local layerContainer = _layerPanelStorageHandler(cfg.Name)

		local vo = activePanel.Panel.GetViewObject()
		if typeof(vo) == "Instance" then
			vo.Parent = layerContainer
		else
			local gui = vo.Gui
			gui.Parent = nil
		end
	end
end

return module
