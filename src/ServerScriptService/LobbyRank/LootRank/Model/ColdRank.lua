local DataStoreService = game:GetService("DataStoreService")
local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local rankLength = 100
local module = {}

module.GetColdRank = function(path, RankDataName)
	local boardData = DataStoreService:GetOrderedDataStore(RankDataName)

	local Data = boardData:GetSortedAsync(false, rankLength)
	local BestPage = Data:GetCurrentPage()
	return BestPage
end

module.SetColdRank = function(path, data)
	for _, player in pairs(game.Players:GetPlayers()) do
		if wukongServer.HasFacade(player.UserId) then
			local facade = wukongServer.GetFacade(player.UserId)
			local num = facade:ExecuteQuery(path)

			if num == 0 then
				continue
			end

			local success = pcall(function()
				data:SetAsync(player.Name, num)
			end)
		end
	end
end

return module
