local wukong = require(game.ReplicatedStorage.WuKong)
local rebirthConfig = require(game.ReplicatedStorage._genConfigs.battle_tbreborn)
local localPlayer = game.Players.LocalPlayer
local module = {
	Level = 0,
	MaxLevel = 0,
    RebirthTimes = 0,
    AurasId = 0,
    Exp = 0,
}

module.Level = localPlayer:GetAttribute("UserLevel") or 0
module.RebirthTimes = localPlayer:GetAttribute("RebornTimes") or 0
module.MaxLevel = rebirthConfig["重生" .. module.RebirthTimes].MaxLevel

module.AurasId = wukong:ExecuteQuery("/属性/装备特性?属性数量") or 0
module.Exp = wukong:ExecuteQuery("/属性/经验?属性数量") or 0

localPlayer:GetAttributeChangedSignal("RebornTimes"):Connect(function()
    module.RebirthTimes = localPlayer:GetAttribute("RebornTimes") or 0
    module.MaxLevel = rebirthConfig["重生" .. module.RebirthTimes].MaxLevel
end)

localPlayer:GetAttributeChangedSignal("UserLevel"):Connect(function()
    module.Level = localPlayer:GetAttribute("UserLevel") or 0
end)

wukong:RegisterSlotObserver("/属性/装备特性", function(slot, value)
    module.AurasId = wukong:ExecuteQuery("/属性/装备特性?属性数量") or 0
end)

wukong:RegisterSlotObserver("/属性/经验", function(slot, value)
    module.Exp = wukong:ExecuteQuery("/属性/经验?属性数量") or 0
end)


return module
