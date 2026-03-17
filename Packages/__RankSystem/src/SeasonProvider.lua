local ConstProvider = require(game.ReplicatedStorage.Packages.ConstProvider)
-- 赛季开始时间
-- local SEASON_START_TIME = os.time({year = 2024, month = 6, day = 14, hour = 0, min = 0, sec = 0})
local SEASON_START_TIME = ConstProvider.GetConstValue("第一个赛季开启时间")
-- 赛季周期、一天
local SEASON_PERIOD = ConstProvider.GetConstValue("每个赛季持续时间秒")

local SEASON_GROUP_MAXPLAYERCOUNT = 20
local SEASON_GLOBAL_RANKCOUNT = ConstProvider.GetConstValue("排行榜分组人数")

local SEASON_PREFIX = ConstProvider.GetConstStringValue("赛季命名前缀")

local PLAYER_DATA_EXPIRE_TIME = SEASON_PERIOD * 2 + 3600 * 24

local module = {}

function module.GetSeasonStartTime()
    return SEASON_START_TIME
end

function module.GetSeasonPeriod()
    return SEASON_PERIOD
end

function module.GetCurrentSeasonIndex()
    local now = os.time()
    local diff = now - SEASON_START_TIME
    return math.floor(diff / SEASON_PERIOD) + 1
end

function module.GetCurrentSeasonName()
    return SEASON_PREFIX .. "_" .. module.GetCurrentSeasonIndex()
end

function module.GetLastSeasonName()
    return SEASON_PREFIX .. "_" .. module.GetCurrentSeasonIndex() - 1
end

function module.GetLastSeasonIndex()
    return module.GetCurrentSeasonIndex() - 1
end

function module.GetCurrentSeasonStartTime()
    local index = module.GetCurrentSeasonIndex()
    return SEASON_START_TIME + (index - 1) * SEASON_PERIOD
end

function module.GetLastSeasonStartTime()
    local index = module.GetCurrentSeasonIndex() - 1
    return SEASON_START_TIME + (index - 1) * SEASON_PERIOD
end

function module.GetCurrentSeasonEndTime()
    local index = module.GetCurrentSeasonIndex()
    return SEASON_START_TIME + index * SEASON_PERIOD
end

function module.GetLastSeasonEndTime()
    local index = module.GetCurrentSeasonIndex() - 1
    return SEASON_START_TIME + index * SEASON_PERIOD
end

function module.GetGroupNamePrefix()
    return module.GetCurrentSeasonName() .. "_Group"
end

function module.GetLastGroupNamePrefix()
    return SEASON_PREFIX .. "_" .. module.GetCurrentSeasonIndex() - 1 .. "_Group"
end

function module.GetGroupNamePrefixBySeasonName(seasonName)
    return seasonName .. "_Group"
end

function module.GetPlayerSeasonName(player)
    
end

function module.GetGroupMaxPlayerCount()
    return SEASON_GROUP_MAXPLAYERCOUNT
end

function module.GetGlobalMaxRankCount()
    return SEASON_GLOBAL_RANKCOUNT
end

function module.GetPlayerDataExpireTime()
    return PLAYER_DATA_EXPIRE_TIME
end

function module.GetSeasonTimeToString()
    local t = module.GetCurrentSeasonStartTime()
    -- utc时间 例如 5.01 - 5.31
    local start = os.date("!*t", t)
    local endt = os.date("!*t", t + SEASON_PERIOD)
    return start.month .. "." .. start.day .. " - " .. endt.month .. "." .. endt.day .. " UTC"
end

function module.GetLastSeasonTimeToString()
    local t = module.GetLastSeasonStartTime()
    -- utc时间 例如 5.01 - 5.31
    local start = os.date("!*t", t)
    local endt = os.date("!*t", t + SEASON_PERIOD)
    return start.month .. "." .. start.day .. " - " .. endt.month .. "." .. endt.day .. " UTC"
end

function module.GetLeftDayToString()
    local t = module.GetCurrentSeasonEndTime()
    local now = os.time()
    local diff = t - now
    local day = math.floor(diff / (3600 * 24))
    local hour = math.floor((diff % (3600 * 24)) / 3600)
    local min = math.floor((diff % 3600) / 60)
    return `Reset after {day} days {hour} hours {min} minutes`
end

return module