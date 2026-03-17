local module = {}
local _remoteEvent = script.Parent.RemoteEvent
local _sameGamePlaceIds = {}
local _player = game.Players.LocalPlayer
local _placeId = game.PlaceId

local EXPIRATION_TIME = 30

local _inGameFriendsCache = {
    LastUpdated = 0,
    Friends = {},
    Others = {}
}

function module.SetExpirationTime(time)
    assert(type(time) == "number", "time must be a number")
    EXPIRATION_TIME = time
end

function module.SetGamePlaceIds(placeIds)
    assert(type(placeIds) == "table", "placeIds must be a table")
    _sameGamePlaceIds = placeIds
end

function module.GetInGameFriendListInstantly()
    return module.GetInGameFriendList(true)
end

function module.GetInGameFriendList(inst)
    if (_inGameFriendsCache.LastUpdated - os.time() >= EXPIRATION_TIME) and not inst then
        return _inGameFriendsCache.Friends, _inGameFriendsCache.LastUpdated, _inGameFriendsCache.Others
    end
    table.clear(_inGameFriendsCache.Friends)
    table.clear(_inGameFriendsCache.Others)
    local success, friends = pcall(_player.GetFriendsOnline, _player, 200)
    if success then
        _inGameFriendsCache.LastUpdated = os.time()
        for _, friend in pairs(friends) do
            -- print(friend.UserName, friend.LocationType, friend.PlaceId, friend.GameId)
            if friend.LocationType == 0 or friend.LocationType == 2 then -- Website, or mobile site
                table.insert(_inGameFriendsCache.Others, {
                    UserId = friend.VisitorId,
                    Name = friend.UserName,
                    DisplayName = friend.DisplayName,
                    PlaceId = friend.PlaceId,
                    JobId = friend.GameId,
                    LocationType = friend.LocationType,
                    SamePlace = false,
                })
            elseif friend.LocationType == 3 or friend.LocationType == 6 then -- Studio
                -- table.insert(_inGameFriendsCache.Others, {
                --     UserId = friend.VisitorId,
                --     Name = friend.UserName,
                --     DisplayName = friend.DisplayName,
                --     PlaceId = friend.PlaceId,
                --     JobId = friend.GameId,
                --     LocationType = friend.LocationType,
                --     SamePlace = false,
                -- })
            elseif friend.LocationType == 4 or friend.LocationType == 1 then -- InGame (PC Client) or Mobile Client
                local placeId = friend.PlaceId
                if table.find(_sameGamePlaceIds, placeId) then
                    table.insert(_inGameFriendsCache.Friends, {
                        UserId = friend.VisitorId,
                        Name = friend.UserName,
                        DisplayName = friend.DisplayName,
                        PlaceId = placeId,
                        JobId = friend.GameId,
                        LocationType = friend.LocationType,
                        SamePlace = placeId == _placeId,
                    })
                else
                    table.insert(_inGameFriendsCache.Others, {
                        UserId = friend.VisitorId,
                        Name = friend.UserName,
                        DisplayName = friend.DisplayName,
                        PlaceId = placeId,
                        JobId = friend.GameId,
                        LocationType = friend.LocationType,
                        SamePlace = false,
                    })
                end
            elseif friend.LocationType == 5 then -- XBox
                local placeId = friend.PlaceId
                if table.find(_sameGamePlaceIds, placeId) then
                    table.insert(_inGameFriendsCache.Friends, {
                        UserId = friend.VisitorId,
                        Name = friend.UserName,
                        DisplayName = friend.DisplayName,
                        PlaceId = placeId,
                        JobId = friend.GameId,
                        LocationType = friend.LocationType,
                        SamePlace = placeId == _placeId,
                        Console = true
                    })
                else
                    table.insert(_inGameFriendsCache.Others, {
                        UserId = friend.VisitorId,
                        Name = friend.UserName,
                        DisplayName = friend.DisplayName,
                        PlaceId = placeId,
                        JobId = friend.GameId,
                        LocationType = friend.LocationType,
                        SamePlace = false,
                    })
                end
            end
        end
    end
    

    return _inGameFriendsCache.Friends, _inGameFriendsCache.LastUpdated, _inGameFriendsCache.Others
end

_remoteEvent:FireServer("GetGamePlaceIds")
_remoteEvent.OnClientEvent:Connect(function(request, placeIds)
    if request == "SetGamePlaceIds" then
        module.SetGamePlaceIds(placeIds)
    end
end)

return module