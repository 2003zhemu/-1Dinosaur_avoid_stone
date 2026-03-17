local cfg = require(script.Parent:WaitForChild("BootstrapConfig"))
local Bootstarp = require(game.ReplicatedStorage.Packages.BootstrapModule)
require(game.ReplicatedStorage.Configs.SettingLoggerCfg).Setlogger()
Bootstarp.Start(cfg)
