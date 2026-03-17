local module = {}


-- 管理员UserId列表
module.AdminList = {
	[3703873374] = true,
	[4447945316] = true,
	[4442552551] = true,
}



module.BlackListSystemConfig = require(script.BlackListSystemConfig)


-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module,script.Name)


return module
