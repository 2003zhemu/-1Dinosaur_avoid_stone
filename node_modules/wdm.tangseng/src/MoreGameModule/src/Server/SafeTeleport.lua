-- teleport failed handler在防掉线(AntiOfflineModule)的ServerTeleport里面已经有了, 此脚本不做处理。

local TeleportService = game:GetService("TeleportService")
local ATTEMPT_LIMIT = 5
local RETRY_DELAY = 1
local function SafeTeleport(placeId: number?, players: {Player}, options: Instance?): TeleportAsyncResult
    local attemptIndex = 0
    local success, result -- define pcall results outside of loop so results can be reported later on
    repeat
        success, result = pcall(function()
            return TeleportService:TeleportAsync(placeId, players, options) -- teleport the user in a protected call to prevent erroring
        end)
        attemptIndex += 1
        if not success then
            task.wait(RETRY_DELAY)
        end
    until success or attemptIndex == ATTEMPT_LIMIT -- stop trying to teleport if call was successful, or if retry limit has been reached
    return success, result
end
return SafeTeleport