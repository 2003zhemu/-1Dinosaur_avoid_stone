--[[
	查询好友信息，服务端和客户端接口一致，放心调用。
]]

local module = {}
local Cache = {}

local Players = game:GetService("Players")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local FriendInfo = require(script.Parent.FriendInfo)
local defines = require(script.Parent.Defines)

--循环处理分页数据 返回全部好友信息
local function _PageItems(pages)
    local list = {}
    while true do
        for _, item in ipairs(pages:GetCurrentPage()) do
            local info:FriendInfo.FriendInfo = FriendInfo.DoFriendInfo(item)
            list[item.Id] = info
        end
        if pages.IsFinished then
            break
        end
        pages:AdvanceToNextPageAsync()
    end
    return list
end

--通过接口Players:GetFriendsAsync 获取好友分页信息
local function _getFriendsByRobloxApi(player: Player)
    local success, friendPage = pcall(function()
        return Players:GetFriendsAsync(player.UserId)
    end)
    if not success or not friendPage then
        return
    end
    return _PageItems(friendPage)
end

--判断玩家是否在线
local function _IsOnline(player:Player)
    if not player then return end
    return Players:GetPlayerByUserId(player.UserId)
end

--获取好友数量
local function _friendsCount(player: Player)
    local sameServerFriendsCount,allFriendsCount = 0,0
    local friends = module.GetFriendList(player)
    if friends then
        for _,_ in pairs(friends) do
            allFriendsCount = allFriendsCount + 1
        end
       
        for _,v in pairs(Players:GetPlayers()) do
            if friends[v.UserId] then
                sameServerFriendsCount = sameServerFriendsCount + 1
            end
        end
    end
    return sameServerFriendsCount,allFriendsCount
end

local function _getFriends(player)
    local list = _getFriendsByRobloxApi(player)
    -- 玩家在线，才更新缓存 ，todo
    if _IsOnline(player) then
        Cache[player.UserId] = list  --当前玩家好友列表
        EventBus.FireClient(player, defines.EventSyncCache,Cache[player.UserId])  --同步好友到客户端

        for _,plr in pairs(Players:GetPlayers()) do
            if plr == player then continue end
            local friends = module.GetFriendList(plr)
            if friends and friends[player.UserId] then --同服好友数有变化
                local sameServerFriendsCount,allFriendsCount = _friendsCount(plr)
                
                local options:defines.FriendChangeOptions = {
                    SameServer = sameServerFriendsCount,
                    Total = allFriendsCount,
                    Player = plr,
                    ChangePlayer = player,
                    ChangeType = "online"
                }
                EventBus.FireClient(plr, defines.EventFriendChange,options)  --通知到客户端
                EventBus.Fire(defines.EventFriendChange,options) --通知到服务端
            end
        end
    end
end

-- 获取localplayer的好友列表，如果数据未加载完成返回nil
module.GetFriendList = function(player: Player):{[number]:FriendInfo.FriendInfo} | nil
    return Cache[player.UserId]
end

-- 获取player的同服务器好友列表，如果数据未加载完成返回nil
module.GetFriendListInSameServer = function(player: Player):{[number]:FriendInfo.FriendInfo} | nil
    local friends = module.GetFriendList(player)
    if not friends then
        return
    end

    local result = {}
    for _,v in pairs(Players:GetPlayers()) do
        if friends[v.UserId] then
            result[v.UserId] = v
        end
    end

    return result
end

--获取好友数量
module.GetFriendsCount = function(player: Player)
    return _friendsCount(player)
end

-- 当玩家上线时，更新好友列表
spawn(function()
	for i, v in pairs(game.Players:GetPlayers()) do
		_getFriends(v)
	end
end)

game.Players.PlayerAdded:Connect(function(player: Player)
    _getFriends(player)
end)

-- 玩家离开时清缓存
game.Players.PlayerRemoving:Connect(function(player: Player)
    Cache[player.UserId] = nil
    for _,plr in pairs(Players:GetPlayers()) do
        if plr == player then continue end
        local friends = module.GetFriendList(plr)
        if friends and friends[player.UserId] then --同服好友数有变化
            local sameServerFriendsCount,allFriendsCount = _friendsCount(plr)
            
            local options:defines.FriendChangeOptions = {
                SameServer = sameServerFriendsCount,
                Total = allFriendsCount,
                Player = plr,
                ChangePlayer = player,
                ChangeType = "offline"
            }
            EventBus.FireClient(plr, defines.EventFriendChange,options)  --通知到客户端
            EventBus.Fire(defines.EventFriendChange,options) --通知到服务端
        end
    end
end)

local function ConnectC2S(player: Player,eventName:string, doPlayer:Player)
	if eventName == defines.EventAddFriendSyncCache then  --添加好友
        local success,isFriend = pcall(function()
            return doPlayer:IsFriendsWith(player.UserId)
        end)
        if not success or not isFriend then
            wait(2)
            success,isFriend = pcall(function()
                return doPlayer:IsFriendsWith(player.UserId)
            end)
        end
        if success and isFriend then
            if not Cache[player.UserId] then --玩家下线时，好友列表会被清空
                return
            end
            Cache[player.UserId][doPlayer.UserId] = FriendInfo.DoFriendInfo(doPlayer)
            EventBus.FireClient(player, defines.EventSyncCache,Cache[player.UserId])  --同步好友到客户端

            local sameServerFriendsCount,allFriendsCount = _friendsCount(player)
            local options:defines.FriendChangeOptions = {
                SameServer = sameServerFriendsCount,
                Total = allFriendsCount,
                Player = player,
                ChangePlayer = doPlayer,
                ChangeType = "add"
            }
            EventBus.FireClient(player, defines.EventFriendChange,options)  --通知好友变动到客户端
            EventBus.Fire(defines.EventFriendChange,options) --通知好友变动到服务端
        end

    elseif eventName == defines.EventRemoveFriendSyncCache then  --移除好友
        if Cache[player.UserId] then
            Cache[player.UserId][doPlayer.UserId] = nil
            EventBus.FireClient(player, defines.EventSyncCache,Cache[player.UserId])  --同步好友到客户端

            local sameServerFriendsCount,allFriendsCount = _friendsCount(player)
            local options:defines.FriendChangeOptions = {
                SameServer = sameServerFriendsCount,
                Total = allFriendsCount,
                Player = player,
                ChangePlayer = doPlayer,
                ChangeType = "remove"
            }
            EventBus.FireClient(player, defines.EventFriendChange,options)  ----通知好友变动到客户端
            EventBus.Fire(defines.EventFriendChange,options) --通知好友变动到服务端
        end
    elseif eventName == defines.EventServerCanSync then
        _getFriends(player)
	end
end

EventBus.ConnectC2S(ConnectC2S)

return module