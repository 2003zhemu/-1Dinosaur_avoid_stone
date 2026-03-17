--[=[
    @class UserDataStoreConfig

    `配置项` `可补丁`

    用户数据库配置

]=]

local module = {}

--[=[
    @prop ProductStore {Name:string}
    @within UserDataStoreConfig
    生产环境数据库
]=]
module.ProductStore = {
	Name = "ProductStore_1",
}

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module, script.Name)

return module
