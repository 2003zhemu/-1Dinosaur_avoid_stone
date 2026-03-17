local module = {}

module.MessagePanelFrame = script.Parent.MessagePanelFrame

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module,script.Name)

return module