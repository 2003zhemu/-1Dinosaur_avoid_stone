local WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local MemoryStoreService = game:GetService("MemoryStoreService")
local SeasonProvider = require(script.Parent.Parent.SeasonProvider)
local RANK_EXPIRE_TIME = 60

local module = {}

local _seasonPlayerGroups = {}
local _groupRankListCache = {}

local _userGroupStore
local _userLastGroupStore

local function getUserGroupStore()

	if not _userGroupStore then
		_userGroupStore = {
			GetAsync = function(self, userId)
				local currentSeasonIdx = SeasonProvider.GetCurrentSeasonIndex()
				local facade = WuKongServer.WaitFacade(userId)
				if facade then
					local playerCurSeasonIdx = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季编号?属性数量")
					local levelrank = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季分组等级?属性数量")
					local groupIdx = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季分组编号?属性数量")
					local playerScore = facade:ExecuteQuery("/赛季系统/赛季数据/本赛季成绩?属性数量")

					if playerCurSeasonIdx ~= currentSeasonIdx then

						facade:ExecuteAction("/赛季系统/赛季数据/本赛季编号?属性设为指定值", 0)
						facade:ExecuteAction("/赛季系统/赛季数据/本赛季分组等级?属性设为指定值", 0)
						facade:ExecuteAction("/赛季系统/赛季数据/本赛季分组编号?属性设为指定值", 0)
						facade:ExecuteAction("/赛季系统/赛季数据/本赛季成绩?属性设为指定值", 0)

						local lastSeasonIdx = SeasonProvider.GetLastSeasonIndex()
						if playerCurSeasonIdx == lastSeasonIdx then
							facade:ExecuteAction("/赛季系统/赛季数据/上赛季编号?属性设为指定值", playerCurSeasonIdx)
							facade:ExecuteAction("/赛季系统/赛季数据/上赛季分组等级?属性设为指定值", levelrank)
							facade:ExecuteAction("/赛季系统/赛季数据/上赛季分组编号?属性设为指定值", groupIdx)
							facade:ExecuteAction("/赛季系统/赛季数据/上赛季分组奖励是否领取?属性设为指定值", 0)
							facade:ExecuteAction("/赛季系统/赛季数据/上赛季全局奖励是否领取?属性设为指定值", 0)
							facade:ExecuteAction("/赛季系统/赛季数据/上赛季成绩?属性设为指定值", playerScore)
						end

						return nil
					else
						local info = {
							Group = levelrank .. "_" .. groupIdx
						}
						return info
					end
				end
			end,

			SetAsync = function(self, userId, value)
				local currentSeasonIdx = SeasonProvider.GetCurrentSeasonIndex()
				local facade = WuKongServer.WaitFacade(userId)
				if facade then

					local groupName = value.Group
					local info = string.split(groupName, "_")
					local levelrank = tonumber(info[1])
					local groupIdx = tonumber(info[2])

					facade:ExecuteAction("/赛季系统/赛季数据/本赛季编号?属性设为指定值", currentSeasonIdx)
					facade:ExecuteAction("/赛季系统/赛季数据/本赛季分组等级?属性设为指定值", levelrank)
					facade:ExecuteAction("/赛季系统/赛季数据/本赛季分组编号?属性设为指定值", groupIdx)
				end
			end
		}
	end

	return _userGroupStore
end

local function getLastUserGroupStore()
	if not _userLastGroupStore then
		_userLastGroupStore = {
			GetAsync = function(self, userId)
				local lastSeasonIdx = SeasonProvider.GetLastSeasonIndex()
				local facade = WuKongServer.HasFacade(userId) and WuKongServer.GetFacade(userId)
				if facade then
					local playerLastSeasonIdx = facade:ExecuteQuery("/赛季系统/赛季数据/上赛季编号?属性数量")
					if playerLastSeasonIdx ~= lastSeasonIdx then
						return nil
					else
						local levelrank = facade:ExecuteQuery("/赛季系统/赛季数据/上赛季分组等级?属性数量")
						local groupIdx = facade:ExecuteQuery("/赛季系统/赛季数据/上赛季分组编号?属性数量")

						local info = {
							Group = levelrank .. "_" .. groupIdx
						}
						return info
					end
				end
			end
		}
	end
	return _userLastGroupStore
end

local function getGroupDispatcherStoreByLevel(levelRank)
	return MemoryStoreService:GetSortedMap(SeasonProvider.GetGroupNamePrefix() .. "_" ..levelRank .. "_GroupDispatcher")
end

local function initPlayerGroup(player)
	-- local playerData = PLAYER_DATAS:WaitForChild(player.Name, 30)
	-- if playerData then
	-- 	local playerLevel = playerData:WaitForChild("MaxRoleLevel").Value
	-- 	local levelRank = SeasonProvider.GetLevelRankByPlayerLevel(playerLevel)
	-- 	local groupDispatcherStore = getGroupDispatcherStoreByLevel(levelRank)
	-- 	local userGroupStore = getUserGroupStore()
	-- 	local keys = groupDispatcherStore:GetRangeAsync(Enum.SortDirection.Descending, 1)
	-- 	if not keys or #keys == 0 then
	-- 		keys = {
	-- 			{key = "1"}
	-- 		}
	-- 	end
	-- 	local playerGroupName = nil
	-- 	local groupIdx = keys[1].key
	-- 	while not playerGroupName do
	-- 		pcall(function()
	-- 			-- 更新键
	-- 			groupDispatcherStore:UpdateAsync(groupIdx, function(value)
	-- 				if not value then
	-- 					playerGroupName = levelRank .. "_" .. groupIdx
	-- 					return 1
	-- 				end
	-- 				if value < SeasonProvider.GetGroupMaxPlayerCount() then
	-- 					playerGroupName = levelRank .. "_" .. groupIdx
	-- 					return value + 1
	-- 				end
	-- 				playerGroupName = nil
	-- 				return nil
	-- 			end, SeasonProvider.GetPlayerDataExpireTime())
	-- 		end)
	-- 		if not playerGroupName then
	-- 			groupIdx = tostring(tonumber(groupIdx) + 1)
	-- 		end
	-- 	end

	-- 	local seasonName = SeasonProvider.GetCurrentSeasonName()
	-- 	local info = {
	-- 		Group = playerGroupName
	-- 	}
	-- 	userGroupStore:SetAsync(player.UserId, info, SeasonProvider.GetPlayerDataExpireTime())

	-- 	warn(`[Rank System] ${seasonName} initPlayerGroup ${player.UserId} ${playerGroupName}`)

	-- 	return info
	-- end
end

local function getPlayerGroupStore(player, notInit)
	local seasonName = SeasonProvider.GetCurrentSeasonName()
	local prefix = SeasonProvider.GetGroupNamePrefix()
	if not _seasonPlayerGroups[seasonName] then
		_seasonPlayerGroups[seasonName] = {}
	end
	if not _seasonPlayerGroups[seasonName][player.UserId] then
		local groupInfo = getUserGroupStore():GetAsync(player.UserId)
		if not groupInfo and not notInit then
			groupInfo = initPlayerGroup(player)
		end
		if not groupInfo then
			return warn(`[Rank System] ${seasonName} group ${player.UserId} not found`)
		end
		_seasonPlayerGroups[seasonName][player.UserId] = groupInfo
	end
	local groupName = prefix .. "_" .. _seasonPlayerGroups[seasonName][player.UserId].Group
	return MemoryStoreService:GetSortedMap(groupName), groupName
end

local function getLastPlayerGroupStore(player)
	local lastSeasonName = SeasonProvider.GetLastSeasonName()
	local prefix = SeasonProvider.GetLastGroupNamePrefix()
	if not _seasonPlayerGroups[lastSeasonName] then
		_seasonPlayerGroups[lastSeasonName] = {}
	end
	if not _seasonPlayerGroups[lastSeasonName][player.UserId] then
		local groupInfo = getLastUserGroupStore():GetAsync(player.UserId)
		groupInfo = groupInfo or {}
		_seasonPlayerGroups[lastSeasonName][player.UserId] = groupInfo
	end
	if not _seasonPlayerGroups[lastSeasonName][player.UserId].Group then
		return nil
	end
	local groupName = prefix .. "_" .. _seasonPlayerGroups[lastSeasonName][player.UserId].Group
	return MemoryStoreService:GetSortedMap(groupName), groupName
end

local function updateListCache(name, player, data)
	if _groupRankListCache[name] then
		local list = _groupRankListCache[name].Value
		for i, v in ipairs(list) do
			if v.UserId == player.UserId then
				list[i].Value = {
					Name = player.UserId,
					Value = data
				}
				break
			end
		end
		table.sort(list, function(a, b)
			return a.Value.Value > b.Value.Value
		end)
	end
end

function module.Update(player, value)
	if value == 0 then
		return
	end
	local suc = pcall(function()
		local playerGroupStore, name = getPlayerGroupStore(player)

		local data = value

		playerGroupStore:SetAsync(player.UserId, data, SeasonProvider.GetPlayerDataExpireTime(), value)

		local seasonName = SeasonProvider.GetCurrentSeasonName()

		updateListCache(name, player, data)

		print("[Rank System] Group Store Update:", seasonName, player.UserId, value)
	end)
	return suc
end

function module.GetCurrentSeasonValue(player)
	local playerGroupStore, name = getPlayerGroupStore(player, true)
	if playerGroupStore then
		return playerGroupStore:GetAsync(player.UserId)
	end
end

function module.GetGroupRankList(player)

	local seasonName = SeasonProvider.GetCurrentSeasonName()
	if not _seasonPlayerGroups[seasonName] or not _seasonPlayerGroups[seasonName][player.UserId] then
		-- 未分组
		return nil
	end

	local playerGroupStore, name = getPlayerGroupStore(player)

	if _groupRankListCache[name] then
		return _groupRankListCache[name].Value
	end

	local keys = playerGroupStore:GetRangeAsync(Enum.SortDirection.Descending, SeasonProvider.GetGroupMaxPlayerCount())
	local result = {}
	for i, key in ipairs(keys) do
		result[i] = {
			UserId = tonumber(key.key),
			Value = {
				Value = key.value,
				Name = key.key
			}
		}
	end

	_groupRankListCache[name] = {
		Value = result,
		Time = os.time()
	}

	return result
end

function module.GetLastGroupRankList(player)

	local lastPlayerGroupStore, name = getLastPlayerGroupStore(player)
	if not lastPlayerGroupStore then
		return nil
	end

	if _groupRankListCache[name] then
		return _groupRankListCache[name].Value
	end

	local items = lastPlayerGroupStore:GetRangeAsync(Enum.SortDirection.Descending, SeasonProvider.GetGroupMaxPlayerCount())
	local result = {}
	for i, key in ipairs(items) do
		result[i] = {
			UserId = tonumber(key.key),
			Value = {
				Value = key.value,
				Name = key.key
			}
		}
	end

	_groupRankListCache[name] = {
		Value = result,
		Time = os.time()
	}

	return result
end

function playerAdded(player)
	local seasonName = SeasonProvider.GetCurrentSeasonName()
	if not _seasonPlayerGroups[seasonName] then
		_seasonPlayerGroups[seasonName] = {}
	end
	if not _seasonPlayerGroups[seasonName][player.UserId] then
		local suc, res
		repeat
			suc = pcall(function()
				local groupName = getUserGroupStore():GetAsync(player.UserId)
				_seasonPlayerGroups[seasonName][player.UserId] = groupName
			end)
			if not suc then
				wait(1)
			end
		until suc
	end

	--print("[Rank System] Player Added: ", player.UserId, _seasonPlayerGroups[seasonName][player.UserId])
end

for _, player in ipairs(game.Players:GetPlayers()) do
	spawn(function()
		playerAdded(player)
	end)
end

-- WuKongServer.ConnectUserRegisterEvent(function(userId, facadeProvider)
-- 	local player = game.Players:GetPlayerByUserId(userId)
-- 	if player then
-- 		playerAdded(player)
-- 	end
-- end)

game.Players.PlayerAdded:Connect(playerAdded)

game.Players.PlayerRemoving:Connect(function(player)
	for i, v in pairs(_seasonPlayerGroups) do
		if v[player.UserId] then
			_seasonPlayerGroups[i][player.UserId] = nil
		end
	end
end)

function checkRankExpire()
	while wait(1) do
		for i, v in pairs(_groupRankListCache) do
			if os.time() - v.Time > RANK_EXPIRE_TIME then
				_groupRankListCache[i] = nil
			end
		end
	end
end

spawn(checkRankExpire)

return module