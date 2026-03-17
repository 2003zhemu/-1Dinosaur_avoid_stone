local wukong = require(game.ReplicatedStorage.WuKong)

local module = {
	GiftCoin = 0,
}

local giftCoinProducts = {
	100,
	200,
	300,
	400,
	500,
	600,
	700,
	800,
	900,
	1000,
	2000,
	3000,
	4000,
	5000,
	7000,
}

function module:GetSpriteByVendorId(vendorId)
	local path = self:GetPathByVendorId(vendorId)
	if string.find(path, "药水") and string.find(path, "买") then
		return "Icons", potionList[vendorId]
	elseif vendorId == "超级捆绑包" then
		return "Icons", "攻速药水1"
	elseif string.find(path, "金币") and string.find(path, "买") then
		return "Icons", "金币" .. tonumber(string.match(vendorId, "%d+")) + 1
	elseif string.find(path, "VIP") then
		return "Icons", "VIP"
	elseif string.find(path, "双倍金币") then
		return "Icons", "coinx2"
	elseif string.find(path, "自动收集") then
		return "商店", "自动图标"
	elseif string.find(path, "二倍攻速") then
		return "Icons", "shoot_speedx2"
	elseif string.find(path, "买活动货币2") then
		return "万圣节25年", "糖果"
	else
		return 1
	end
end

function module:GetCountByVendorId(vendorId)
	local path = self:GetPathByVendorId(vendorId)
	local products = self:GetProductsByVendorId(vendorId)
	if string.find(path, "现金/买金币/") then
		return products[1].Count
	elseif string.find(path, "现金/买钻石/") then
		return products[1].Count
	elseif string.find(path, "现金/买活动货币1/") then
		return products[1].Count
	elseif string.find(path, "现金/买活动货币2/") then
		return products[1].Count
	else
		return 1
	end
end

function module:GetPriceByVendorId(vendorId)
	local path = self:GetPathByVendorId(vendorId)
	if path then
		local suc, res = pcall(function()
			return wukong:ExecuteQuery(path .. "?获取R币价格")
		end)
		if suc then
			return res
		end
	end
	return 999999
end

function module:GetNameByVendorId(vendorId)
	local path = self:GetPathByVendorId(vendorId)
	local products = self:GetProductsByVendorId(vendorId)
	--print(path)
	if string.find(path, "药水") and string.find(path, "买") then
		return "Potion"
	elseif vendorId == "超级捆绑包" then
		return "Super Bundle"
	elseif string.find(path, "金币") and string.find(path, "买") then
		return "金币"
	elseif string.find(path, "双倍金币") then
		return "DoubleMoney"
	elseif string.find(path, "自动收集") then
		return "AutoSell"
	elseif string.find(path, "二倍攻速") then
		return "DoubleAS"
	elseif string.find(path, "VIP") then
		return "VIP"
	elseif string.find(path, "活动货币2") then
		return "活动货币2"
	end
end

function module:GetProductsByVendorId(vendorId)
	local path = self:GetPathByVendorId(vendorId)
	local suc, res = pcall(function()
		return wukong:ExecuteQuery(path .. "?获取产品信息")
	end)
	if suc then
		return res
	end
end

function module:GetGiftCoinProduct(vendorId)
	local price = self:GetPriceByVendorId(vendorId)
	local has = self.GiftCoin
	local need = price - has
	if need <= 0 then
		return nil
	end
	-- 最近的一档
	for i = 1, #giftCoinProducts do
		if giftCoinProducts[i] >= need then
			return `/现金/买礼物币/{giftCoinProducts[i]}礼物币`
		end
	end
end

local nameCache = {}
function module:GetPlayerName(userId)
	if not nameCache[userId] then
		local suc, res = pcall(function()
			return game.Players:GetNameFromUserIdAsync(userId)
		end)
		nameCache[userId] = suc and res
	end
	return nameCache[userId] or userId
end
function module:GetPlayerHeadIcon(userId)
	return "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
end

return module
