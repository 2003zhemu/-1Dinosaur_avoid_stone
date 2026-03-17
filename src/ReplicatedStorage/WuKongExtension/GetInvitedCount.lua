local Players = game:GetService("Players")

local _module
return function(userId, container, arg)
	if not _module then
        _module = require(game.ReplicatedStorage.Packages.AwardInviteService)
    end
    local player = Players:GetPlayerByUserId(userId)
    if not player then
        return 0
    end
    local suc, invites = pcall(function()
        return _module.GetInvitesInstantly(player)
    end)
    if not suc then
        return 0
    end
    return #invites
end