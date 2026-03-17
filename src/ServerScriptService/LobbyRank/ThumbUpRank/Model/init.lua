local module = {}
local hotScore = require(script.HotScore)
local coldRank = require(script.ColdRank)
local rankLength = 100
export type RankItem = {
	key: Name,
	value: number,
}

local coldRankRep = {}

-- 从数据库更新冷排名
module.UpdateColdRank = function(path: string, RankDataName)
	coldRankRep[path] = coldRank.GetColdRank(path, RankDataName)
	return coldRankRep[path]
end

-- 向数据库写入冷排名
module.SetColdRank = function(path: string, data)
	coldRank.SetColdRank(path, data)
end

-- 获取热排名
module.GetHotRank = function(path: string): { RankItem }
	local hotScore = hotScore.GetElementCountOfOnlinePlayers(path)

	if coldRankRep[path] == nil then
		-- 排序
		table.sort(hotScore, function(a, b)
			return a.value > b.value
		end)

		-- return
		return hotScore
	end

	local coldrank = table.clone(coldRankRep[path])

	--删除冷表中与热表相同的元素
	for k, v in pairs(hotScore) do
		for k2, v2 in pairs(coldrank) do
			if v.key == v2.key then
				table.remove(coldrank, k2)
			end
		end
	end

	--将剩余冷表加入热表
	for i, v in coldrank do
		table.insert(hotScore, v)
	end

	--排序
	table.sort(hotScore, function(a, b)
		return a.value > b.value
	end)

	--删除热表多余的部分，只留前100
	if #hotScore > rankLength then
		for i = #hotScore, rankLength + 1, -1 do
			table.remove(hotScore, i)
		end
	end

	coldRankRep[path] = hotScore

	return hotScore
end

return module
