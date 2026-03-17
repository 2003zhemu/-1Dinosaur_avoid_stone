local localPlayer = game.Players.LocalPlayer
local UserId = localPlayer.UserId
local wukong = require(game.ReplicatedStorage.WuKong)
local auraConfig = require(game.ReplicatedStorage._genConfigs.battle_tbaura)

local module = {
	Submited = false,
}

function module:CanBuyAura(id)
	local config = auraConfig[`特性{id}`]
	if not config then
		return false
	end
	if self.DataContext.Currency.Cups >= config.Cost then
		return true
	end
	return false
end

function module:IsBuyedAura(id)
	local suc, data = self.DataContext.ContainerHelper.GetContainerValue(UserId, `属性`, `购买特性`)
	if suc and data and data[`特性{id}`] then
		return true
	end
	return false
end

function module.BuyAura(id)
	if id then
		wukong:ExecuteQuery(`/现金/通行证/特性{id}?弹出购买窗口`)
	end
end

function module.BuyRevive()
	wukong:ExecuteQuery(`/现金/买功能/复活?弹出购买窗口`)
end

return module
