local module = {}
local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)

-- 根据悟空路径，获取Element数据
module.GetElementCountOfOnlinePlayers = function(path: string): {
	{
		key: Name,
		value: number,
	}
}
	local result = {}
	for k, player: Player in game.Players:GetPlayers() do
		if wukongServer.HasFacade(player.UserId) then
			local facade = wukongServer.GetFacade(player.UserId)
			local count = facade:ExecuteQuery(path)
			if count == 0 then
				continue
			end
			table.insert(result, {
				key = player.Name,
				value = count,
			})
		end
	end

	return result
end

return module
