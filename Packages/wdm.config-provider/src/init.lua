local HotReloader = require(game.ReplicatedStorage.Packages.rewire)
local reloader = HotReloader.HotReloader.new()
local _genConfigs = game.ReplicatedStorage:FindFirstChild("_genConfigs")
local callbacks = {}

local ConfigProvider = {}

local cache = {}

--[=[
    @method Get
    @param {string} configName
    @returns {table}
    @description Get the config by name
    @example
    local config = ConfigProvider:Get("configName")
    print(config)
    -- output: { key = "value" }
]=]
function ConfigProvider.Get(configName: string)
	local hit = cache[configName]
	-- 此时, hotreload还未执行
	if not hit then
		hit = require(_genConfigs[configName]:Clone())
		cache[configName] = hit
		return hit
	end
	assert(hit, "can't get config:" .. configName)
	return hit
end

--[=[
    @method Register
    @param {function} callback
    @description Register a callback function
    @example
    ConfigProvider:Register(function()
        print("Config updated")
    end)
]=]
function ConfigProvider.Register(callback: (modulescript: ModuleScript, context: { isReloading: boolean }) -> ())
	if typeof(callback) == "function" then
		table.insert(callbacks, callback)
	end
end

function ConfigProvider.Unregister(callback: () -> ())
	for i, v in pairs(callbacks) do
		if v == callback then
			table.remove(callbacks, i)
		end
	end
end

reloader:scan(_genConfigs, function(moduleScript, context)
	if not context.isReloading then
		return
	end
	cache[moduleScript.Name] = require(moduleScript)
	for k, v in callbacks do
		v(moduleScript, context)
	end
end, function(moduleScript, context) end)

return ConfigProvider
