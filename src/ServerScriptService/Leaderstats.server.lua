local Players = game:GetService("Players")

local WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)

local boundUsers: { [number]: boolean } = {}

local function getOrCreateNumberStat(player: Player, name: string): NumberValue
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local stat = leaderstats:FindFirstChild(name)
	if stat and stat:IsA("NumberValue") then
		return stat
	end

	if stat then
		stat:Destroy()
	end

	local newStat = Instance.new("NumberValue")
	newStat.Name = name
	newStat.Value = 0
	newStat.Parent = leaderstats
	return newStat
end

local function safeQueryNumber(facade, queryPath: string): number
	local ok, result = pcall(function()
		return facade:ExecuteQuery(queryPath)
	end)
	if not ok then
		return 0
	end
	if type(result) ~= "number" then
		return 0
	end
	return result
end

local function bindCurrency(player: Player, facade)
	local thumbup = getOrCreateNumberStat(player, "ThumbUpNum")
	local cupNum = getOrCreateNumberStat(player, "CupNum")

	local function refreshThumbUp()
		thumbup.Value = safeQueryNumber(facade, "/数据/获赞数?属性数量")
	end

	local function refreshCup()
		cupNum.Value = safeQueryNumber(facade, "/货币/奖杯?属性数量")
	end

	refreshThumbUp()
	refreshCup()

	facade:RegisterSlotObserver("/数据/获赞数", function()
		if player:IsDescendantOf(Players) then
			refreshThumbUp()
		end
	end)

	facade:RegisterSlotObserver("/货币/奖杯", function()
		if player:IsDescendantOf(Players) then
			refreshCup()
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	getOrCreateNumberStat(player, "ThumbUpNum")
	getOrCreateNumberStat(player, "CupNum")
end)

Players.PlayerRemoving:Connect(function(player)
	boundUsers[player.UserId] = nil
end)

WuKongServer.ConnectUserRegisterEvent(function(userId: number)
	if boundUsers[userId] then
		return
	end

	if not WuKongServer.HasFacade(userId) then
		return
	end

	local player = Players:GetPlayerByUserId(userId)
	if not player then
		return
	end

	local facade = WuKongServer.GetFacade(userId)
	if not facade then
		return
	end

	boundUsers[userId] = true
	bindCurrency(player, facade)
end)
