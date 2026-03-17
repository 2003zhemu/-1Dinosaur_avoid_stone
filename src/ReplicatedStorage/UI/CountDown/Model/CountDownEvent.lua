local wukong = require(game.ReplicatedStorage.WuKong)

local module = {}

function module:GetProductControlInfo()
	return {
		PurchaseCount = wukong:ExecuteQuery("/现金/买功能/控制台?获取已购买次数"),
		PurchaseFunc = function()
			return wukong:ExecuteQuery("/现金/买功能/控制台?弹出购买窗口")
		end,
	}
end

return module
