
local controller = require(script.Controller)
local UIManagerDefines = require(game.ReplicatedStorage.Packages.UIManager.Defines)
local module = {}
--[=[
	好友加成面板,显示好友数量和好友加成数据，可邀请好友
	@class FriendsAdditionPanel
	@client
	:::info 调用方式
	两种方式显示好友加成面板：
	* 使用UIManager.OpenPanel("好友加成")显示
	* 使用FriendsInformation.GetButton()获取好友加成按钮，点击后显示
	:::
]=]
module.Name = "好友加成"

controller.Init()

module.Show = function(isShow)
    controller.Show(isShow)
end

--获取界面
module.GetViewObject = function()
	return controller.Gui
end
	
-- 适配 UIManager,返回 name,module,panelOptions(可忽略)
module.GetPanelConfig = function():(UIManagerDefines.Panel, UIManagerDefines.PanelOptions)
	return module.Name,module,{Layer="弹窗层"}
end

return module
