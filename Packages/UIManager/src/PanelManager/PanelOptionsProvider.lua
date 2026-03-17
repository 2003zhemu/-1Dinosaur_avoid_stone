local module = {}
local defines = require(script.Parent.Parent.Defines)
local tableUtil = require(game.ReplicatedStorage.Packages.Utils.TableUtil)

local _optionsBuilder:(patch:defines.PanelOptions)->(defines.PanelOptions) = nil

module.Init = function(defaultConfig:defines.DefaultPanelConfig)
    assert(defaultConfig)
    _optionsBuilder = function(patch:defines.PanelOptions)
        
        local result = tableUtil.DeepClone(defaultConfig)
        tableUtil.DeepPatch(patch,result)
        return result
        
    end
end

module.BuildOptions = function(patch:defines.PanelOptions):defines.PanelOptions
    assert(_optionsBuilder)
 
    return _optionsBuilder(patch)
end

return module
