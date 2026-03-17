local Defines = require(game.ReplicatedStorage.Modules.Defines)
local SpeedHelper = {}
SpeedHelper.__index = SpeedHelper

local PlayerSpeeds = {}  --玩家速度缓存
local ratios = {0.5, 0.3, 0.1}
local function ChangeSpeed(speed)
    if not speed then return 0 end
    if speed <= 316 then  --150级速度为316
        return speed
    end
    local tempSpeed = 316
    local extraSpeed = speed - 316
    for index, ratio in ipairs(ratios) do
        if extraSpeed <= 0 then break end
        tempSpeed = tempSpeed + math.min(100, extraSpeed) * ratio
        extraSpeed = extraSpeed - 100
    end
    if extraSpeed > 0 then
        tempSpeed = tempSpeed + extraSpeed * ratios[#ratios]
    end
    return math.clamp(tempSpeed, 0, speed)
end

local function SetSpeed(player)
    local maxSpeed = player:GetAttribute("UserMaxSpeed") or 0
    local controlSpeed = player:GetAttribute("ControlSpeed")
    local customSpeed = player:GetAttribute("UserCustomSpeed") or maxSpeed
    local toolDashUpSpeed = player:GetAttribute("ToolDashUpSpeed") or 0

    local resultSpeed = 0
    if controlSpeed and controlSpeed > 0 then
        resultSpeed = controlSpeed
    else
        resultSpeed = math.min(maxSpeed, customSpeed)
    end
    resultSpeed = ChangeSpeed(resultSpeed)
    resultSpeed = resultSpeed * (1 + toolDashUpSpeed)
    local Character = player.character
    if not Character then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    Humanoid.WalkSpeed = resultSpeed
end

function SpeedHelper.Init(player)
    local self = setmetatable({}, SpeedHelper)
    self.Player = player

    self.Conn = game:GetService("RunService").Heartbeat:Connect(function()
        SetSpeed(player)
    end)


    
    PlayerSpeeds[player] = self
    return self
end

function SpeedHelper.GetSpeed(player)
    if not player then
        return 0
    end
    --（坐骑加成+1+光环加成）*（1+0.5*重生次数）*速度倍率
    local rate = 1
    if player:GetAttribute(Defines.GamePass["双倍速度"].Key) then --双倍速度通行证
        rate = 2
    end
    if player:GetAttribute("RuningRate") then  --跑步机加成
        rate = rate + player:GetAttribute("RuningRate")
    end

    local currentSpeed = 1
    if player:GetAttribute("RideBonus") then
        currentSpeed = currentSpeed + player:GetAttribute("RideBonus")
    end
    if player:GetAttribute("AuraBonus") then
        currentSpeed = currentSpeed + player:GetAttribute("AuraBonus")
    end
    if player:GetAttribute("RebornTimes") then
        currentSpeed = currentSpeed * (1 + 0.5 * player:GetAttribute("RebornTimes"))
    end
    currentSpeed = currentSpeed * rate
    return currentSpeed
end

function SpeedHelper.Destroy(player)
    local self = PlayerSpeeds[player]
    if self then
        self.Conn:Disconnect()
    end
    PlayerSpeeds[player] = nil
end

return SpeedHelper