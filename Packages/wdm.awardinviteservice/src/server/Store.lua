local MemoryStoreService = game:GetService("MemoryStoreService")
local AwardInviteMap = MemoryStoreService:GetHashMap("AwardInviteMap")

local EXPIRETIME = 3888000
local EXPIRETIME_TICK = 10
local module = {}
local _playerTicks = {}

function module.AddToPlayerInvites(userId, beInvitedUserId)
    local suc, res = pcall(function()
        AwardInviteMap:UpdateAsync(userId, function(value)
            if value == nil then
                return {
                    beInvitedUserId
                }
            else
                if not table.find(value, beInvitedUserId) then
                    table.insert(value, beInvitedUserId)
                    return value
                end
            end
        end, EXPIRETIME)
    end)
    if not suc then
        warn(res)
    end
end

function module.GetInvitesAndClean(userId)
    if _playerTicks[userId] and tick() - _playerTicks[userId] < EXPIRETIME_TICK then
        return {}
    end
    _playerTicks[userId] = tick()
    local invites = {}
    local suc, res = pcall(function()
        AwardInviteMap:UpdateAsync(userId, function(value)
            if value then
                for i, v in ipairs(value) do
                    table.insert(invites, v)
                end
                table.clear(value)
                return value
            end
            return nil
        end, EXPIRETIME)
    end)
    if not suc then
        warn(res)
    end
    return invites
end

game.Players.PlayerRemoving:Connect(function(player)
    _playerTicks[player.UserId] = nil
end)

return module