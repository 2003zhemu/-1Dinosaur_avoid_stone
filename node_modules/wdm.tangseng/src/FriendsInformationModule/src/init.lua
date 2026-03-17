--[=[
    查询好友信息，服务端和客户端接口一致，放心调用。
    @class FriendsInformation
    @server
    @client
    :::info 好友变更时，抛出事件
    当有好友变更时，服务端抛出事件"EventFriendsInformationFriendChange"供服务端和客户端监听，事件参数一致，参数如下：
    * SameServer number --同服在线好友数量
    * Total number --好友总数量
    * Player Player --有好友变动的玩家
    * ChangePlayer Player --变动的好友
    * ChangeType "online"|"offline"|"add"|"remove" --好友变动类型（上线|下线|添加|移除）
    :::
]=]

local FriendsInformation = {}
local FriendInfo = require(script.FriendInfo)
local UIManagerDefines = require(game.ReplicatedStorage.Packages.UIManager.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local defines = require(script.Defines)
local viewConfig = require(script.FriendsAdditionPanel.view.FriendsAdditionViewConfig)
--初始化好友信息
local requireModule = nil
local uIManager = nil
local isInit = false
local buttonOrigin = script:WaitForChild("FriendsAdditionButton",10)

--[=[
    初始化，必须首先调用
]=]

function FriendsInformation.Init()
    if game["Run Service"]:IsServer() then
        requireModule = require(script.Server)
    else
        requireModule = require(script.Client)
        uIManager = require(game.ReplicatedStorage.Packages.UIManager)
    end
    buttonOrigin.Image = viewConfig.EntryBackground
    buttonOrigin.Icon.Image = viewConfig.EntryIcon
    isInit = true
end

--[=[
    获取player的好友列表，如果数据未加载完成返回nil
    @param player Player  --要获取好友列表的player
    @return {[number]:FriendInfo} | nil --好友信息列表
]=]
function FriendsInformation.GetFriendList(player: Player):{[number]:FriendInfo.FriendInfo} | nil
    if isInit then
        return requireModule.GetFriendList(player)
    end
end

--[=[
    获取player的同服务器好友列表，如果数据未加载完成返回nil
    @param player Player  --要获取同一服务器好友的player
    @return {[number]:FriendInfo} | nil --好友信息列表
]=]
function FriendsInformation.GetFriendListInSameServer(player: Player):{[number]:FriendInfo.FriendInfo} | nil
    if isInit then
        return requireModule.GetFriendListInSameServer(player)
    end
end

--[=[
    获取player的好友数量
    @param player Player  --要获取同一服务器好友的player
    @return number|nil,number|nil --同服在线好友数量，全部好友数量
]=]
function FriendsInformation.GetFriendsCount(player: Player):(number|nil,number|nil)
    if isInit then
        return requireModule.GetFriendsCount(player)
    end
end

--[=[
    获取好友加成按钮，点击后打开好友加成面板，返回一个显示好友数量的button 
    @client
    @param parent Instance --按钮父节点
    @return GuiButton
]=]
function FriendsInformation.GetButton(parent):GuiButton
    if game["Run Service"]:isServer() then
        return
    end
    assert(buttonOrigin,"获取好友加成模块入口按钮失败")
    local buttonCopy = buttonOrigin:Clone()
    buttonCopy.MouseButton1Click:Connect(function()
        uIManager.OpenPanel("好友加成")
    end)
    EventBus.ConnectS2C(function(eventName,options)
        if eventName == defines.EventFriendChange then
            buttonCopy.Count.Text = options.SameServer
        end
    end)
    if parent then
        task.spawn(function()
            while not requireModule do
                wait(1)
            end
            local count,_ = requireModule.GetFriendsCount(game.Players.LocalPlayer)
            buttonCopy.Count.Text = count
            buttonCopy.Parent = parent
        end)
    else
        assert(requireModule)
        local count,_ = requireModule.GetFriendsCount(game.Players.LocalPlayer)
        buttonCopy.Count.Text = count
        return buttonCopy
    end
    
end

--[=[
    打开官方邀请好友面板
    @client
]=]
function FriendsInformation.InviteFriends()
    if game["Run Service"]:isServer() then
        return
    end
    local player = game.Players.LocalPlayer
    local res, canSend = pcall(function()
        return game:GetService("SocialService"):CanSendGameInviteAsync(player)
    end)
    if not res then return end
    if not canSend then return end
    pcall(function()
        game:GetService("SocialService"):PromptGameInvite(player)
    end)
end


-- 适配 UIManager,返回 name,module,panelOptions(可忽略)
function FriendsInformation.GetPanelConfig():(UIManagerDefines.Panel, UIManagerDefines.PanelOptions)
	return "好友加成",require(script.FriendsAdditionPanel),{Layer="弹窗层"}
end

return FriendsInformation