local module = {}
local _remoteEvent = script.Parent.RemoteEvent
local _sameGamePlaceIds

function module.SetGamePlaceIds(placeIds)
    assert(type(placeIds) == "table", "placeIds must be a table")
    _sameGamePlaceIds = placeIds
end


_remoteEvent.OnServerEvent:Connect(function(player, request)
    if request == "GetGamePlaceIds" then
        if _sameGamePlaceIds then
            _remoteEvent:FireClient(player, "SetGamePlaceIds", _sameGamePlaceIds)
        end
    end
end)

return module