local Players = game:GetService("Players")
local WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local ContainerHelper = require(game.ServerScriptService.PlayerAttributeManager.ContainerHelper)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local HttpService = game:GetService("HttpService")

local CONTAINER_NAME = "属性"
local KEY = "已经收藏提示过"

local AttributeName = {
	[`已经收藏提示过`] = `FavoriteFlag`,
}

EventBus.ConnectC2S(function(player, eventName, args)
	if eventName == `SetContainerValue` then
		local userid = args.userid
		local containerName = args.containerName
		local key = args.key
		local value = args.value
		if not (containerName == CONTAINER_NAME and key == KEY) then
			return
		end
		local suc = ContainerHelper.GetContainerValue(userid, containerName, key)
		if not suc then
			return
		end
		ContainerHelper.SetContainerValue(userid, containerName, key, value)
		player:SetAttribute(AttributeName[key], value)
	end
end)

WuKongServer.ConnectUserRegisterEvent(function(playerId)
	local player = Players:GetPlayerByUserId(playerId)
	if not player then
		return
	end
	if WuKongServer.HasFacade(player.UserId) then
		task.spawn(function()
			local suc, data = ContainerHelper.GetContainerValue(player.UserId, CONTAINER_NAME, KEY)
			if not suc then
				ContainerHelper.SetContainerValue(player.UserId, CONTAINER_NAME, KEY, false)
				player:SetAttribute(AttributeName[KEY], false)
			else
				player:SetAttribute(AttributeName[KEY], data)
			end
		end)
	end
end)
