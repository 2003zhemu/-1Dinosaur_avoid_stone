local cfg = require(script.Parent:WaitForChild("BootstrapConfig"))

local DebugOptions = require(game.ReplicatedStorage.Packages.DebugOptions)

local Bootstarp = require(game.ReplicatedStorage.Packages.BootstrapModule)
require(game.ReplicatedStorage.Configs.SettingLoggerCfg).Setlogger()

if DebugOptions.IsEnable("客户端调试开关") then
	warn("注意：客户端调试开关已打开，服务端业务没有启动")
else
	Bootstarp.Start(cfg)
end
