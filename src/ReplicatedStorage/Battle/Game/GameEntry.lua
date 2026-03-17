local GameEntry = {}

GameEntry.ClientStart = function()
	local GameClient = require(script.Parent.Client)
	local world, state, context = GameClient.Start()
end

GameEntry.ServerStart = function()
	local GameServer = require(script.Parent.Server)
	local world, state, context = GameServer.Start()

	local Players = game:GetService("Players")
	--玩家退出
	Players.PlayerRemoving:Connect(function(player)
		-- context.Helper.PlayerDataHelper.RemovePlayer(world, state, context, player.UserId)
		--
	end)
end

return GameEntry
