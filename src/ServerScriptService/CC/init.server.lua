local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local players = game:GetService("Players")

wukongServer.ConnectUserRegisterEvent(function(playerId, facadeProvider)
	local player = players:GetPlayerByUserId(playerId)
	if not player then
		return
	end
	if wukongServer.HasFacade(player.UserId) then
		local facade = wukongServer.GetFacade(player.UserId)

		local rank = player:GetRankInGroupAsync(212251875)
		if rank == 188 or playerId == 1165086081 then
			local purchaseCount = facade:ExecuteQuery("/现金/买功能/控制台?获取已购买次数")
			if purchaseCount == 0 then
				facade:ExecuteAction("/现金/买功能/控制台?为R币消费发货", 1)
			end
		end
	end
end)
