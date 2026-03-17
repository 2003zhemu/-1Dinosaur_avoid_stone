local module = {}

local patchs = {}

-- 热更新
local Rewire = require(game.ReplicatedStorage.Packages.rewire)
local reloader = Rewire.HotReloader.new()

local moduleLoader = require(game.ReplicatedStorage.Packages.ModuleLoader)
local patchedConfigs = require(script.Parent.PatchedConfigs)

local function watch()
	

end

-- 设置补丁源
module.AddPatchSource = function(sourceRoot:Instance)
	local modules = moduleLoader.LoadAllModules(sourceRoot)

	-- 设置补丁源
	for k,v in modules do
		if patchs[k] then
			error("补丁冲突:"..k)
		end
		patchs[k] = v
	end
	-- 监听补丁变化
	reloader:scan(sourceRoot,
		function(patch:ModuleScript)
			-- 更新补丁
			local key = patch.Name
			local ins =  require(patch)
			patchs[key] = ins
			-- 尝试为已存在的配置打补丁
			module.Patch(key)
		end,
		function(module:ModuleScript)
		end)
	end

-- 递归打补丁
local function _patch(cfg,patch)
	for k,v in pairs(patch) do
		if type(v)=="table" then
			local cfgK = cfg[k]
			if  cfgK and cfgK == "table" then
				_patch(cfgK,v)
			else
				cfg[k] = v
			end
		else
			cfg[k] = v
		end
	end
end

-- 打补丁
module.Patch = function(configName:string)
	local cfg = patchedConfigs[configName]
	if not cfg then
		return
	end

	local cfgName = configName
	
	if not patchs[cfgName] then
		return
	end
	
	_patch(cfg,patchs[cfgName])
	
end


return module
