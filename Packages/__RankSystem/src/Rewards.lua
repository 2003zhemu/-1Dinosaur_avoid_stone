local WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local module = {}

local function getRewards(facade)
    
end

local function getRewardByRank(facade, rank)
    local slots = facade:ExecuteQuery("/活动/活动奖励1/活动奖励1_排名奖励?获取所有格子编号")
    for i, v in pairs(slots) do
        local path = `/活动/活动奖励1/活动奖励1_排名奖励/{v}`
        local config = facade:ExecuteQuery(path .. "?获取元素配置")
        local tags = config.Tags
        local levelMin = math.min(tonumber(tags[1]), tonumber(tags[2]))
        local levelMax = math.max(tonumber(tags[1]), tonumber(tags[2]))
        if rank >= levelMin and rank <= levelMax then
            return v
        end
    end
end

function module.GetGlobalPresetRewards()
    -- return infinitebattle_tbglobalawardconfig
end

function module.GetGroupPresetRewards()
    -- return infinitebattle_tbgroupawardconfig
end

function module.Give(player, rank)
    local facade = WuKongServer.WaitFacade(player.UserId)
    if not facade then
        return
    end
    local reward = getRewardByRank(facade, rank)
    if reward then
        local suc, res = pcall(function()
            return facade:ExecuteValidate(`/活动/活动奖励1/活动奖励1_排名奖励/{reward}?购买验证`)
        end)
        if suc and not res:getHasError() then
            return facade:ExecuteAction(`/活动/活动奖励1/活动奖励1_排名奖励/{reward}?购买`).Receive
        end
    end
end

return module