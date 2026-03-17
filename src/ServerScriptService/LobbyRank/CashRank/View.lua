local replicatestorage = game:GetService("ReplicatedStorage")
local module = {}

local config = nil
local function Num2Str(num: number, precision: number?, hideZero: boolean?): string
	if typeof(num) ~= "number" then
		warn("typeof(num) ~= number")
		return
	end
	if precision == nil then
		precision = 2
	end
	if hideZero == nil then
		hideZero = false
	end

	if hideZero and num == 0 then
		return "0"
	end

	local str = ("%." .. precision .. "f"):format(num)

	if hideZero and str:find(".") then
		local cnt = 0
		for i = #str, 1, -1 do
			if str:sub(i, i) == "0" then
				cnt = cnt + 1
			elseif str:sub(i, i) == "." then
				cnt = cnt + 1
				break
			else
				break
			end
		end

		str = str:sub(1, #str - cnt)
	end

	return str
end
-- 给要显示在UI上的number加单位
local function AppendUnit(n: number, precision: number?, hideZero: boolean?)
	if precision == nil then
		precision = 2
	end
	if hideZero == nil then
		hideZero = true
	end

	local Units = {
		"",
		"K",
		"M",
		"B",
		"T",
		"Qa",
		"Qi",
		"Sx",
		"Sp",
		"Oc",
		"N",
		"D",
		"Ud",
		"Dd",
		"Td",
		"Qt",
		"Qd",
		"Sd",
		"St",
		"Od",
		"Nod",
		"V",
		"Cv",
	}

	for i = 22, 1, -1 do
		if n >= math.pow(10, 3 * i) then
			local res = Num2Str((n / math.pow(10, 3 * i)), precision, hideZero)
			if i ~= 22 and res == "1000" then
				return "1" .. Units[i + 2]
			else
				return res .. Units[i + 1]
			end
		end
	end
	local res = Num2Str(n, precision, hideZero)
	if res == "1000" then
		return "1" .. Units[2]
	else
		return res .. Units[1]
	end
end
-- 更新view配置，参数为路径对应排行榜实例
module.Init = function(cfg)
	config = cfg
end
local helper = require(script.Parent.RankHelper)
local function updateRankListinfo(ranklist, num, newlist)
	--如果已经有了该值的排行榜，修改值即可
	local success, userId = pcall(function()
		return game.Players:GetUserIdFromNameAsync(newlist[num]["key"])
	end)
	if ranklist:FindFirstChild(tostring(num)) then
		local newLbFrame = ranklist:FindFirstChild(tostring(num))
		newLbFrame.name.Text = newlist[num]["key"]
		newLbFrame.power.Text = helper.GetText(newlist[num]["value"])
		newLbFrame.rank.Text = "#" .. num
		newLbFrame.LayoutOrder = num
		newLbFrame:SetAttribute("truepower", newlist[num]["value"])
		newLbFrame.Visible = true

		if success then
			newLbFrame.ImageLabel.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=48&h=48"
		end
		--如果没有该值的排行榜，新增一个
	else
		local newLbFrame = ranklist["4"]:Clone()
		newLbFrame.Name = num
		newLbFrame.name.Text = newlist[num]["key"]
		newLbFrame.power.Text = helper.GetText(newlist[num]["value"])
		newLbFrame.rank.Text = "#" .. num
		newLbFrame.Parent = ranklist
		newLbFrame.LayoutOrder = num
		newLbFrame:SetAttribute("truepower", newlist[num]["value"])
		if success then
			newLbFrame.ImageLabel.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=48&h=48"
		end
	end
end

local function sortRank(rank)
	local tmpRank = table.clone(rank)

	--根据Key值排序，key为玩家名称，类型为string，使用string.lower()比较ascll码进行排序
	table.sort(tmpRank, function(a, b)
		if a["value"] ~= b["value"] then
			return a["value"] > b["value"]
		else
			return string.lower(a["key"]) < string.lower(b["key"])
		end
	end)
	return tmpRank
end

-- local list = {
-- 	{ key = "b", value = 2 },
-- 	{ key = "c", value = 3 },
-- 	{ key = "a", value = 1 },
-- 	{ key = "aa", value = 4 },
-- }
-- warn(sortRank(list))
-- 更新指定排行榜
module.UpdateBoard = function(path: string, rank)
	sortRank(rank)
	local board = config[path]

	if board == nil then
		return
	end
	for i, v in rank do
		if rank[i]["key"] == "PLAYERNAME" then
			continue
		else
			updateRankListinfo(board, i, rank)
		end
	end
	---可优化
end

return module
