local Players = game:GetService("Players")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 10)
local Cache = {}
local conn = nil
local Damage = {
    ["DeathPart"] = 100,
    ["DamagePart1"] = 10,
    ["DamagePart2"] = 20,
    ["DamagePart3"] = 30,
    ["DamagePart4"] = 40,
    ["DamagePart5"] = 50
}

--玩家碰到的块
local function DoDamage(hit)
    --跟随时不受伤害
    if localPlayer:GetAttribute("InviteStatus") == 2 or localPlayer:GetAttribute("InviteStatus") == 5 then return end
    --死亡时不受伤害
    if localPlayer:GetAttribute("IsDead") then return end
    if not hit then return end
    if Cache[hit] then return end
    Cache[hit] = true
    task.delay(1, function()
        Cache[hit] = nil
    end)
    local key = hit.Name
    --免疫工具不受伤害
    if Damage[key] and localPlayer:GetAttribute("InImmuneTool") then
        --免伤特效
        EventBus.Fire("PlayToolEffect", {EffectName = "ImmuneDamageEffect"})
        EventBus.FireServer(EventDefines["免疫时受到伤害"], {Damage = Damage[key]})
        return
    end
    if Damage[key] and Humanoid then
        Humanoid:TakeDamage(Damage[key])
    end
end

local function CheckDamage()
    local Dinosaur = Character:FindFirstChild("RideDinosaur")
    if not Dinosaur then 
        repeat
            Dinosaur = Character:FindFirstChild("RideDinosaur")
            task.wait(0.1)
        until Dinosaur
    end

    local DamagePart = Dinosaur:FindFirstChild("DamagePart")
    if not DamagePart then
        repeat
            DamagePart = Dinosaur:FindFirstChild("DamagePart")
            task.wait(0.1)
        until DamagePart
    end
    if conn then
        conn:Disconnect()
    end
    conn = DamagePart.Touched:Connect(function(hit)
        DoDamage(hit)
    end)
end

EventBus.ConnectS2C(function(eventName, params)
    if eventName == EventDefines["骑乘恐龙"] then
        CheckDamage()
    end
end)

CheckDamage()


