local module = {}
--[=[
    @interface FriendInfo
    .DisplayName string --用户显示名称
    .UserId number --用户id
    .Name string --用户名
    @within FriendsInformation
    好友信息类型
]=]

export type FriendInfo = {
    DisplayName:string,
    UserId:number,
    Name:string
}

module.DoFriendInfo = function(obj:{} | Player):FriendInfo
    local info:FriendInfo = {}
	info.DisplayName = obj.DisplayName
	if typeof(obj) == "table" then
        info.UserId = obj.Id
		info.Name = obj.Username
    else
        info.UserId = obj.UserId
		info.Name = obj.Name
    end
	return info
end

return module