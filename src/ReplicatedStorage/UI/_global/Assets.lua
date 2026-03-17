
local module = {}

local StoreBackImg = {
	[1] = { "商品品质底图", "白" },
	[2] = { "商品品质底图", "绿" },
	[3] = { "商品品质底图", "蓝" },
	[4] = { "商品品质底图", "紫" },
	[5] = { "商品品质底图", "金" },
	[6] = { "商品品质底图", "红" },
	[7] = { "商品品质底图", "彩" },
}

local QualityImg = {
	[1] = { "主界面", "零件框" },
	[2] = { "物品背包", "绿色" },
	[3] = { "物品背包", "蓝色" },
	[4] = { "物品背包", "紫色" },
	[5] = { "物品背包", "黄色" },
	[6] = { "物品背包", "红色" },
	[7] = { "物品背包", "彩色" },
	[8] = { "物品背包", "超彩" },
}

function module:GetIconBgById(id)
	if not id then
		return table.unpack(QualityImg[1])
	end
	return table.unpack(QualityImg[self:GetQuality(id)])
end

function module:StoreQuality(id)
	if not id then
		return
	end
	if id == "金币" then
		return table.unpack(QualityImg[3])
	end
	if id == "PlayerLevelUp" then
		return table.unpack(QualityImg[5])
	end
end


function module:GetBgByQuality(id)
	if not id then
		return table.unpack(StoreBackImg[1])
	end
	return table.unpack(StoreBackImg[self:GetQuality(id)])
end

return module
