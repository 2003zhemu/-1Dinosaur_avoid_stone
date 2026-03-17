local Players = game:GetService("Players")

local _friendsInformationModule
return function(userId, container, arg)
	if not _friendsInformationModule then
		_friendsInformationModule = require(game.ReplicatedStorage.Packages.FriendsInformationModule)
		_friendsInformationModule.Init()
	end
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		return 0
	end
	local onlineFriendCount = _friendsInformationModule.GetFriendsCount(player) or 0
	return onlineFriendCount
end
