
--[=[
    @interface FriendChangeOptions
    .SameServer number --同服在线好友数量
    .Total number --好友总数量
    .Player Player --有好友变动的玩家
    .ChangePlayer Player --变动的好友
    .ChangeType "online"|"offline"|"add"|"remove" --好友变动类型（上线|下线|添加|移除）
    @within FriendsInformation

    有好友变动时客户端和服务端都会触发事件带的参数
]=]
export type FriendChangeOptions = {
	SameServer:number,  --同服在线好友数量
    Total:number,  --好友总数量
    Player:Player, --有好友变动的玩家
    ChangePlayer:Player,  --变动的好友
    ChangeType:"online"|"offline"|"add"|"remove"  --好友变动类型（上线|下线|添加|移除）
}

return {
    EventSyncCache = "EventFriendsInformationSyncCache",
    EventAddFriendSyncCache = "EventFriendsInformationAddFriendSyncCache",
    EventRemoveFriendSyncCache = "EventFriendsInformationRemoveFriendSyncCache",
    EventFriendChange = "EventFriendsInformationFriendChange",
    EventServerCanSync = "EventFriendsInformationServerCanSync"
}