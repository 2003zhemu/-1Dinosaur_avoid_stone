local MemoryStoreService = game:GetService("MemoryStoreService")
local SeasonProvider = require(script.Parent.Parent.SeasonProvider)
local RANK_EXPIRE_TIME = 60

local module = {}
local _globalRankCache = {}

local function getGlobalStore()
	local name = SeasonProvider.GetCurrentSeasonName() .. "_GlobalRank"
	return MemoryStoreService:GetSortedMap(name), name
end

local function getLastGlobalStore()
	local name = SeasonProvider.GetLastSeasonName() .. "_GlobalRank"
	return MemoryStoreService:GetSortedMap(name), name
end

local function getGlobalStoreBySeasonName(seasonName)
	local name = seasonName .. "_GlobalRank"
	return MemoryStoreService:GetSortedMap(name), name
end

local function updateListCache(name, player, data)
	if _globalRankCache[name] then
		local list = _globalRankCache[name].Value
		local found = false
		for i, v in ipairs(list) do
			if v.UserId == player.UserId then
				found = true
				list[i].Value = {
					Name = v.UserId,
					Value = data
				}
				break
			end
		end
		if not found then
			table.insert(_globalRankCache[name].Value, {
				UserId = player.UserId,
				Value = {
					Name = player.UserId,
					Value = data
				}
			})
			table.sort(_globalRankCache[name].Value, function(a, b)
				return a.Value.Value > b.Value.Value
			end)
			if #_globalRankCache[name].Value > 3 then
				table.remove(_globalRankCache[name].Value, 4)
			end
		end
	elseif not workspace:GetAttribute("GameMode") then
		module.GetGlobalRankList()
	end
end

function module.Update(player, value)
	if value == 0 then
		return
	end
	local seasonName = SeasonProvider.GetCurrentSeasonName()
	local globalStore, name = getGlobalStore()

	local data = value

	globalStore:SetAsync(player.UserId, data, SeasonProvider.GetPlayerDataExpireTime(), value)
	updateListCache(name, player, data)
	print("[Rank System] Global Store Update: ", seasonName, player.UserId, value)
end

function module.GetValue(player, seasonName)
	if not seasonName then
		seasonName = SeasonProvider.GetCurrentSeasonName()
	end
	local globalStore, name = getGlobalStoreBySeasonName(seasonName)
	return globalStore:GetAsync(player.UserId)
end

function module.GetGlobalRankList(useCache)
	local globalStore, name = getGlobalStore()
	if _globalRankCache[name] and not _globalRankCache[name].Outdate then
		return _globalRankCache[name].Value
	end
	if useCache then
		return _globalRankCache[name] or {}
	end
	local items = globalStore:GetRangeAsync(Enum.SortDirection.Descending, SeasonProvider.GetGlobalMaxRankCount())
	local result = {}
	for i, item in ipairs(items) do
		result[i] = {
			UserId = tonumber(item.key),
			Value = {
				Name = item.key,
				Value = item.value
			}
		}
	end
	_globalRankCache[name] = {
		Value = result,
		Time = os.time(),
		Outdate = false
	}
	return result
end

function module.GetLastGlobalRankList(useCache)
	local globalStore, name = getLastGlobalStore()
	if _globalRankCache[name] and not _globalRankCache[name].Outdate then
		return _globalRankCache[name].Value
	end
	if useCache then
		return _globalRankCache[name] or {}
	end
	local items = globalStore:GetRangeAsync(Enum.SortDirection.Descending, SeasonProvider.GetGlobalMaxRankCount())
	
	local result = {}
	for i, item in ipairs(items) do
		result[i] = {
			UserId = tonumber(item.key),
			Value = {
				Name = item.key,
				Value = item.value
			}
		}
	end
	_globalRankCache[name] = {
		Value = result,
		Time = os.time(),
		Outdate = false
	}
	return result
end

function module.GetGlobalRank(player, useCache)
	local list = module.GetGlobalRankList(useCache)
	if list == nil and useCache then
		return nil
	end
	local idx = nil
	for i, v in pairs(list) do
		if v.UserId == player.UserId then
			idx = i
		end
	end
	return idx or 0
end

function module.GetPlayerLastRank(player, useCache)
	local list = module.GetLastGlobalRankList(useCache)
	if list == nil and useCache then
		return nil
	end
	local idx = nil
	for i, v in pairs(list) do
		if v.UserId == player.UserId then
			idx = i
		end
	end
	return idx or 0
end

function checkRankExpire()
	while wait(1) do
		for i, v in pairs(_globalRankCache) do
			if os.time() - v.Time > RANK_EXPIRE_TIME * 2 then
				_globalRankCache[i] = nil
			elseif os.time() - v.Time > RANK_EXPIRE_TIME then
				_globalRankCache[i].Outdate = true
			end
		end
	end
end
spawn(checkRankExpire)

return module