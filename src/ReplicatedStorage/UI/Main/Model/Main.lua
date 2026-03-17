local wukong = require(game.ReplicatedStorage.WuKong)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local localPlayer = game.Players.LocalPlayer
local module = {
    IsBuyDoubleSpeed = false,
    IsBuyStartPack = false,
}

function module:GetProductControlInfo()
    return {
        PurchaseCount = wukong:ExecuteQuery("/现金/买功能/控制台?获取已购买次数"),
        PurchaseFunc = function() 
            return wukong:ExecuteQuery("/现金/买功能/控制台?弹出购买窗口")
        end,
    }
end


function module.Init()
    if localPlayer:GetAttribute(Defines.GamePass["双倍速度"].Key) then
        module.IsBuyDoubleSpeed = localPlayer:GetAttribute(Defines.GamePass["双倍速度"].Key)
    end
    if localPlayer:GetAttribute(Defines.GamePass["新手礼包"].Key) then
        module.IsBuyStartPack = localPlayer:GetAttribute(Defines.GamePass["新手礼包"].Key)
    end

    if not module.IsBuyDoubleSpeed then
        localPlayer:GetAttributeChangedSignal(Defines.GamePass["双倍速度"].Key):Connect(function()
            module.IsBuyDoubleSpeed = localPlayer:GetAttribute(Defines.GamePass["双倍速度"].Key)
        end)
    end
    if not module.IsBuyStartPack then
        localPlayer:GetAttributeChangedSignal(Defines.GamePass["新手礼包"].Key):Connect(function()
            module.IsBuyStartPack = localPlayer:GetAttribute(Defines.GamePass["新手礼包"].Key)
        end)
    end
end

function module.BuyExp(Id)
    wukong:ExecuteQuery(`/现金/买速度/{Id}?弹出购买窗口`)
end

function module.BuyDoubleSpeed()
    if module.IsBuyDoubleSpeed then return end
    wukong:ExecuteQuery(`/现金/通行证/双倍速度?弹出购买窗口`)
end

function module.BuyStartPack()
    if module.IsBuyStartPack then return end
    wukong:ExecuteQuery(`/现金/通行证/新手礼包?弹出购买窗口`)
end

return module
