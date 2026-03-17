local wukong = require(game.ReplicatedStorage.WuKong)

local module = {
	ItemSelect = nil, --当前选择的物品
	StageSelect = nil, --当前选择的关卡
	ItemSelect_Owen = nil, --欧文的当前选择的物品
}

function module:GetProductControlInfo()
	return {
		PurchaseCount = wukong:ExecuteQuery("/现金/买功能/控制台?获取已购买次数"),
		PurchaseFunc = function()
			return wukong:ExecuteQuery("/现金/买功能/控制台?弹出购买窗口")
		end,
	}
end

return module
