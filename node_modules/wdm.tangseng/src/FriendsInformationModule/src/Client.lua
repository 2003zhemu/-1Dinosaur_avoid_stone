--[[
	查询好友信息，服务端和客户端接口一致，放心调用。
]]

local module = {}
local starterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local FriendInfo = require(script.Parent.FriendInfo)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local defines = require(script.Parent.Defines)
local Cache = nil

--添加好友到列表
local function _AddFriend(player)
	Cache[player.UserId] = FriendInfo.DoFriendInfo(player)
end

--从列表里移除
local function _RemoveFriend(player)
	Cache[player.UserId] = nil
end

-- 获取localplayer的好友列表，如果数据未加载完成返回nil
module.GetFriendList = function():{[number]:FriendInfo.FriendInfo} | nil
	return Cache
end

-- 获取player的同服务器好友列表，如果数据未加载完成返回nil
module.GetFriendListInSameServer = function(player: Player):{[number]:FriendInfo.FriendInfo} | nil
	local friends = module.GetFriendList()
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
module.GetFriendsCount = function():(number,number)
    local sameServerFriendsCount,allFriendsCount = 0,0
    local friends = module.GetFriendList()
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

local function ConnectS2C(eventName:string, args)
	if eventName == defines.EventSyncCache then  --同步好友
		Cache = {}
		if not args then
			return
		end
		for k, v in pairs(args) do
			Cache[tonumber(k)] = v
		end
	elseif eventName == defines.EventFriendChange then
		EventBus.Fire(defines.EventFriendChange, args)
	end
end

EventBus.ConnectS2C(ConnectS2C)

--监听添加好友事件  游戏中添加好友触发
starterGui:GetCore("PlayerFriendedEvent").Event:Connect(function(player:Player,...)
	if not Cache then
		return
	end
	if player then
		--_AddFriend(player)
		EventBus.FireServer(defines.EventAddFriendSyncCache, player)
	end
end)

--监听移除好友事件  游戏中移除好友触发
starterGui:GetCore("PlayerUnfriendedEvent").Event:Connect(function(player:Player,...)
	if not Cache then
		return
	end
	if player then
		--_RemoveFriend(player)
		EventBus.FireServer(defines.EventRemoveFriendSyncCache, player)
	end
end)

EventBus.FireServer(defines.EventServerCanSync)
return module