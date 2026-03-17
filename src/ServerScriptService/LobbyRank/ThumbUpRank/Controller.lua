local module = {}
local view = require(script.Parent.View)
local model = require(script.Parent.Model)
local DataStoreService = game:GetService("DataStoreService")

local RankDataConfig = {
	["/数据/获赞数?属性数量"] = "ThumbUpRankDataStore1", -- 此处填写地址对应Board 数据库名称
}

module.InitView = function(viewConfig)
	view.Init(viewConfig)
end

module.UpdateColdRank = function(path: string, RankDataName)
	--排行榜数据

	local RankDataName = RankDataConfig[path]

	local boardData = DataStoreService:GetOrderedDataStore(RankDataName)

	model.SetColdRank(path, boardData)

	local rank = model.UpdateColdRank(path, RankDataName)

	if rank == nil then
		return
	end

	view.UpdateBoard(path, rank)
end

module.UpdateBoard = function(path: string)
	local rank = model.GetHotRank(path)

	view.UpdateBoard(path, rank)
end

return module
