local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local GameDataStore = DataStoreService:GetDataStore("GameDataStore")
local httpService = game:GetService("HttpService")
local rs = game:GetService("ReplicatedStorage")

local TeleportDataName = "TeleportTimesData"

local define = require(script.Parent.Define)
local helper = require(script.Parent.Helper)
local eventBus = require(rs.EventBus)
local SafeTeleport = require(script.SafeTeleport)

local ServerModule = {}

--获取赞数
local function GetMoreGameWinEveryGameClickTimes(player)
	if not helper.IsAdmin(player) then return end

	local success, data = pcall(function()
		return GameDataStore:GetAsync(TeleportDataName)
	end)
	if success then
		if data then
			eventBus.FireClient(player, define.Event.SendMoreGameWinEveryGameClickTimes, data)
		else
			print("GameDataStore暂无数据")
		end
	else
		warn("获取GameDataStore数据失败")
	end
end

local function SaveMoreGameWinEveryGameClickTimes(player: Player, GameID: number)
	local gamePlaceId_String = tostring(GameID)
	--储存数据
	local tries = 0
	local success
	repeat
		tries = tries + 1
		success = pcall(function()
			GameDataStore:UpdateAsync(TeleportDataName, function(saveData)
				if saveData then
					if not saveData[gamePlaceId_String] then
						saveData[gamePlaceId_String] = 0
					end
				else
					saveData = {}
					saveData[gamePlaceId_String] = 0
				end
				saveData[gamePlaceId_String] += 1
				--eventBus.FireClient(player, define.Event.SendMoreGameWinEveryGameClickTimes, saveData) -- update client info (but maybe send error info, because update maybe fail)
				return saveData
			end)
		end)
		if not success then task.wait(1) end
	until tries == 3 or success
	if not success then
		warn("无法保存GameDataStore数据")
	end
end

--传送游戏
local function TeleportGame(player, GameID)
	SafeTeleport(GameID, {player})
	SaveMoreGameWinEveryGameClickTimes(player, GameID)
end

-- 注册事件
eventBus.ConnectC2S(function(player, eventName, ...)
    if eventName == define.Event.RequestGoToOtherGame then
        TeleportGame(player, ...)
    elseif eventName == define.Event.GetMoreGameWinEveryGameClickTimes then
        GetMoreGameWinEveryGameClickTimes(player)
	end
end)

local function InitGameInfo()
	local gameData = helper.GetGameData()
	if gameData then
		workspace:SetAttribute("MoreGameInfoList", gameData)
	else return end
	
	local array = string.split(gameData, ";")
	if not array then return end

	local moreGamesInfo_Json = workspace:GetAttribute("MoreGamesInfo")
	local moreGamesInfo = moreGamesInfo_Json and httpService:JSONDecode(moreGamesInfo_Json)
	for _,v in array do
		task.spawn(function()
			local info = string.split(v,"@")
			if not info then
				return
			end
			local placeId = info[2]
			if not placeId then return end
			if tonumber(placeId) == game.PlaceId then return end

			local success, data = nil, nil 

			local st = os.clock()
			while not success do
				task.wait(1)
				success, data = pcall(function()
					return MarketplaceService:GetProductInfo(placeId)
				end)
			end

			if moreGamesInfo == nil then moreGamesInfo = {} end
			moreGamesInfo[placeId] = data
			workspace:SetAttribute("MoreGamesInfo", httpService:JSONEncode(moreGamesInfo))
			--print(string.format("读取游戏信息耗时:%ds [%s]", os.clock() - st, data.Name))
		end)
	end
end

InitGameInfo()

return ServerModule