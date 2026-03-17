--[=[
	@class MoreGameModule
	@client
	@server
	提供**跳转至更多游戏的按钮及窗口**(需要在客户端与服务器都引用该模块才能生效)
	
	*`Config`*文件用于提供其它游戏的基本信息(*`PlaceId`*)
	
	使用GetButton()可以获取默认的**更多游戏窗口打开\关闭按钮**并修改其属性

	使用SetButton()可以设置自定义的**更多游戏窗口打开\关闭按钮**
]=]
local MoreGameModule = {}

if game["Run Service"]:IsServer() then
	MoreGameModule = require(script.Server)
else
	MoreGameModule = require(script.Client)
end

MoreGameModule.Name = "MoreGamePanel"

MoreGameModule.GetViewObject = function ()
	return game.Players.LocalPlayer.PlayerGui:WaitForChild("MainScreen"):FindFirstChild("DisplayFrame")
		or game.Players.LocalPlayer.PlayerGui:WaitForChild("主业务层"):FindFirstChild("DisplayFrame")
end

-- 适配 UIManager,返回 name,module,panelOptions(可忽略)
MoreGameModule.GetPanelConfig = function()
    return MoreGameModule.Name, MoreGameModule
end

return MoreGameModule