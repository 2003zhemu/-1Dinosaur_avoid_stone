local module = {}

local defines = require(script.Parent.Defines)

local animations:{[string]:defines.AnimationConfig & {ModuleAnimation:Animation}} = {}

local moduleLoader = require(game.ReplicatedStorage.Packages.ModuleLoader)

-- 预处理 animationConfigs
module.__processConfigs = function(animationConfigs:defines.AnimationConfigs):{defines.AnimationConfig}
   local result = {}
   for i,v in pairs(animationConfigs) do
       if typeof(v)=="string" or (typeof(v)=="Instance" and v.ClassName == "ModuleScript") then
            table.insert(result,{
                ModuleScript = v
            })
       elseif typeof(v)=="table" then
        assert(v.ModuleScript,"animationConfigs must have ModuleScript")
            table.insert(result,v)
            else
                warn("invalid config",v)
                error("invalid config")
       end
   end
   return result
end


-- 初始化
module.Init = function(animationConfigs:defines.AnimationConfigs)
    -- 预处理配置,放入缓存
    local processed = module.__processConfigs(animationConfigs)

    -- load all animations
    for k,v in ipairs(processed) do
        local m = moduleLoader.LoadModule(v.ModuleScript)
        v.ModuleAnimation = m.Module
        animations[m.ModuleName] = v
    end
end

-- 是否存在动画
module.HasAnimation = function(name:string):boolean
	return animations[name]~=nil
end

-- 播放动画
module.PlayFadeIn = function(
	activePanel:defines.ActivedPanel)
    
    -- 忽略测试Panel
    if typeof(activePanel.Panel)~="Instance" then
        return
    end
end


-- 播放动画
module.PlayFadeOut = function(
    activePanel:defines.ActivedPanel)

    -- 忽略测试Panel
    if typeof(activePanel.Panel)~="Instance" then
        return
    end
    
end

module.__playAnimation = function(gui:GuiObject,module:defines.Animation)
    module.Play(gui)
end

return module
