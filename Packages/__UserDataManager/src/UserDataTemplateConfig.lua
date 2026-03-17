--[=[
    @class UserDataTemplateConfig

    `配置项` `可补丁`

    用户数据模板配置

]=]

local module = {}

--[=[
    @prop UserDateTemplate {}
    @within UserDataTemplateConfig
    用户数据模板, 创建用户时, 将使用该模板的数据进行初始化.

    :::caution

    `.Container` 是悟空的保留字段, 不可以在模板中使用. 

    :::

]=]

module.UserDateTemplate = {}

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module, script.Name)

return module
