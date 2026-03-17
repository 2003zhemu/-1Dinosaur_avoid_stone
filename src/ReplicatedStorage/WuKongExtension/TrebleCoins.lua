local Players = game:GetService("Players")
local IS_SERVER = game:GetService("RunService"):IsServer()
local WuKong, WuKongServer
local function getFacade(userId: number)
	local facade
	if IS_SERVER then
		if not WuKongServer then
			WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
		end
		facade = WuKongServer.HasFacade(userId) and WuKongServer.GetFacade(userId)
	else
		if not WuKong then
			WuKong = require(game.ReplicatedStorage.WuKong)
		end
		facade = WuKong
	end
	return facade
end
return function(userId, container, arg)
	local player = Players:GetPlayerByUserId(userId)
	if not player then
		return 0
	end
	local coins = player:GetAttribute("PendingCoins") or 0
	local facade = getFacade(userId)
	pcall(function(...)
		facade:ExecuteAction("/货币/金币?属性增加", coins * 2)
		player:SetAttribute("PendingCoins", 0)
	end)
end
