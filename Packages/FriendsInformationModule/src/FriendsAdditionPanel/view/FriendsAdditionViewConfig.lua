--[=[
	* 面板图片配置
	@interface ViewImage
	.Close string --关闭按钮图片ID
	.TitleBackground string --标题栏背景图片ID
	.Invite string --邀请按钮图片ID
	.ContentBackground string --内容背景图片ID
	.Icon string --好友图标图片ID

	@within FriendsAdditionPanel
]=]
export type ViewImage = {
	Close: string, --关闭按钮图片ID
	TitleBackground: string, --标题栏背景图片ID
	Invite: string, --邀请按钮图片ID
	ContentBackground: string, --内容背景图片ID
	Icon: string, --好友图标图片ID
}

--[=[
	* 好友加成奖励
	@interface Award
	.Item string --奖励的物品
	.Count string --奖励的数值

	@within FriendsAdditionPanel
]=]
export type Award = {
	Item: string, --奖励的物品（20个字符以内）
	Count: string, --奖励的数值
}

--[=[
	* 面板配置
	@interface ViewConfig
	.ViewImage ViewImage --面板图片配置
	.Callback (count: number) -> {Award} --根据好友数量返回好友加成奖励列表，最多显示四个奖励
	.EntryBackground string --入口背景图片ID
	.EntryIcon string --入口按钮图标ID

	@within FriendsAdditionPanel
]=]
export type ViewConfig = {
	ViewImage: ViewImage,
	Callback: (count: number) -> { Award }, --根据好友数量返回好友加成奖励列表
	EntryBackground :string, --入口背景图片ID
	EntryIcon:string --入口按钮图标ID
}
--[=[
	* 模块启动后，会自动遍历该配置，根据配置的ViewImage设置面板图片Id
	* 面板显示时，会根据Callback返回的数据设置面板显示加成内容
	* 每个游戏通过打补丁单独配置
	@prop ViewConfig ViewConfig
	@within FriendsAdditionPanel
]=]

local FriendsAdditionViewConfig = {
	ViewImage = {
		Close = "rbxassetid://15014658609", --关闭按钮
		TitleBackground = "rbxassetid://15031458620", --标题栏背景
		Invite = "rbxassetid://15014750192", --邀请按钮
		ContentBackground = "rbxassetid://15014736098", --内容背景
		Icon = "rbxassetid://15014849322", --好友图标
	},

	Callback = function(count: number): { Award } --根据好友数量返回好友加成奖励列表
		--count = math.random(0,10)
		if count <= 0 then
			return {{ Item = "0个好友没有加成:", Count = "+ 0%" }}
		elseif count > 0 and count <= 2 then
			return { { Item = "1~2个好友金币加成:", Count = "+ 10%" }, { Item = "1~2个好友经验加成:", Count = "+ 20%" } }
		elseif count > 2 and count <= 10 then
			return { { Item = "2~10个好友金币加成:", Count = "+ 20%" }, { Item = "2~10个好友经验加成:", Count = "+ 30%" } }
		else
			return { { Item = "最多加成:", Count = "+ 100%" }}
		end
	end,

	EntryBackground = "rbxassetid://15040996627", --入口背景图片ID
	EntryIcon = "rbxassetid://15041003987", --入口按钮图标ID
}

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(FriendsAdditionViewConfig, script.Name)

return FriendsAdditionViewConfig
