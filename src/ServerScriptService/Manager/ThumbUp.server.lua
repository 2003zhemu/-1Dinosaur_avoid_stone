local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local Players = game:GetService("Players")

local Connects = {}
-- thumbedRecord[fromUserId][toUserId] = true 防止重复点赞
local thumbedRecord = {}
local boundUsers: { [number]: boolean } = {}

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

local function bindThumbUpNumAttribute(player: Player, facade)
	local function refresh()
		if not player:IsDescendantOf(Players) then
			return
		end
		local value = safeQueryNumber(facade, "/数据/获赞数?属性数量")
		player:SetAttribute("ThumbUpNum", value)
	end

	refresh()
	facade:RegisterSlotObserver("/数据/获赞数", refresh)
end

EventBus.ConnectC2S(function(player: Player, eventName: string, param)
	if eventName == "ThumbUp" then
		if not wukongServer.HasFacade(player.UserId) then
			return
		end
		local targetUserId = param.TargetUserId
		if not targetUserId then
			return
		end
		local targetPlayer = Players:GetPlayerByUserId(targetUserId)
		if not targetPlayer then
			return
		end
		-- 防重复点赞校验
		if not thumbedRecord[player.UserId] then
			thumbedRecord[player.UserId] = {}
		end
		if thumbedRecord[player.UserId][targetUserId] then
			return
		end
		thumbedRecord[player.UserId][targetUserId] = true

		local facade = wukongServer.GetFacade(targetUserId)
		if facade then
			facade:ExecuteAction("/数据/获赞数?属性增加", 1)
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	local current = player:GetAttribute("ThumbUpNum")
	if type(current) ~= "number" then
		current = 0
	end
	player:SetAttribute("ThumbUpNum", current)
	Connects[player.UserId] = player:GetAttributeChangedSignal("InviteStatus"):Connect(function()
		local inviteStatus = player:GetAttribute("InviteStatus")
		if inviteStatus == 0 then
			-- 跟随会话结束，重置该玩家的点赞记录，允许下一次会话重新点赞
			thumbedRecord[player.UserId] = nil
			for _, record in pairs(thumbedRecord) do
				record[player.UserId] = nil
			end
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local conn = Connects[player.UserId]
	if conn then
		conn:Disconnect()
		Connects[player.UserId] = nil
	end
	boundUsers[player.UserId] = nil

	thumbedRecord[player.UserId] = nil
	-- 清理其他人对该玩家的点赞记录（目标玩家已离开）
	for _, record in pairs(thumbedRecord) do
		record[player.UserId] = nil
	end
end)

wukongServer.ConnectUserRegisterEvent(function(userId: number)
	if boundUsers[userId] then
		return
	end
	if not wukongServer.HasFacade(userId) then
		return
	end

	local player = Players:GetPlayerByUserId(userId)
	if not player then
		return
	end

	local facade = wukongServer.GetFacade(userId)
	if not facade then
		return
	end

	boundUsers[userId] = true
	bindThumbUpNumAttribute(player, facade)
end)
