local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local obstacles = game.Workspace:FindFirstChild("Obstacles")
local StageObstacles = game.ServerStorage.Obstacles
local Cache = {}
--第17关
--海浪
local function Stage17Tween()
    task.spawn(function()
        local model = obstacles.Stage17:FindFirstChild("Model")
        if not model then return end
        local startCFrame = CFrame.new(Vector3.new(-258.655, 500.015, -26845.324)) * CFrame.Angles(0, math.rad(-180), 0)
        local endCFrame = CFrame.new(Vector3.new(-258.655, 500.015, -30155.203)) * CFrame.Angles(0, math.rad(-180), 0)

        model:PivotTo(startCFrame)
        local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(model.PrimaryPart, tweenInfo, {CFrame = endCFrame})
        tween:Play()
        task.wait(4)
        model:PivotTo(startCFrame - Vector3.new(0, 150, 0))
    end)
end

--5s
task.spawn(function()
    while true do
        task.wait(5)
        EventBus.FireAllClients(EventDefines["客户端关卡动画"])
        Stage17Tween()
    end 
end)

--4s
task.spawn(function()
    while true do
        task.wait(4)
        EventBus.FireAllClients(EventDefines["客户端关卡动画2"])
    end 
end)

--不定时执行
local checkTimes = {}
checkTimes[18] = {stepTime = 0, Interval = 1}
checkTimes[22] = {stepTime = 0, Interval = 5}

local RandomPoints = {
    ["18"] = {
        [1] = CFrame.new(Vector3.new(-328.247, 471.43, -32287.219)) * CFrame.Angles(0, math.rad(-90), 0),
        [2] = CFrame.new(Vector3.new(-260.327, 471.43, -32287.219)) * CFrame.Angles(0, math.rad(-90), 0),
        [3] = CFrame.new(Vector3.new(-192.59, 471.43, -32287.219)) * CFrame.Angles(0, math.rad(-90), 0),
        [4] = CFrame.new(Vector3.new(-328.879, 471.43, -31336.186)) * CFrame.Angles(0, math.rad(-90), 0),
        [5] = CFrame.new(Vector3.new(-260.327, 471.43, -31336.186)) * CFrame.Angles(0, math.rad(-90), 0),
        [6] = CFrame.new(Vector3.new(-192.227, 471.43, -31336.186)) * CFrame.Angles(0, math.rad(-90), 0),
    },
    ["22"] = {
        [1] = {Start = CFrame.new(-256.063, 2360.064, -37646.676), End = CFrame.new(-256.063, 2360.064, -39175.582)},
        [2] = {Start = CFrame.new(-256.063, 2188.096, -37646.676), End = CFrame.new(-256.063, 2188.096, -39175.582)},
        [3] = {Start = CFrame.new(-56.373, 2294.114, -37646.676), End = CFrame.new(-56.373, 2294.114, -39175.582)},
        [4] = {Start = CFrame.new(-254.199, 2294.114, -37646.676), End = CFrame.new(-254.199, 2294.114, -39175.582)},
        [5] = {Start = CFrame.new(-445.597, 2294.114, -37646.676), End = CFrame.new(-445.597, 2294.114, -39175.582)},
    }
}

local function CanActive(stage, dt)
    if not checkTimes[stage] then return false end
    checkTimes[stage].stepTime = checkTimes[stage].stepTime + dt
    if checkTimes[stage].stepTime >= checkTimes[stage].Interval then
        checkTimes[stage].stepTime = 0
        if stage == 18 then
            checkTimes[stage].Interval = math.random(1, 5)
        end
        return true
    end
    return false
end

local function Stage18Tween()
    local model = StageObstacles:FindFirstChild("Stage18")
    if not model then return end
    local index1 = math.random(1, 3)
    local index2 = math.random(4, 6)
    local warn1 = obstacles.Stage18:FindFirstChild(tostring(index1))
    local warn2 = obstacles.Stage18:FindFirstChild(tostring(index2))
    if warn1 then
        warn1.Transparency = 0.5
    end
    if warn2 then
        warn2.Transparency = 0.5
    end
    local function doTween(index)
        local model = model:Clone()
        model.Name = "DamagePart4"
        local randomPoint = RandomPoints["18"][index]
        model:PivotTo(randomPoint)
        model.Parent = game.Workspace
        local tweenInfo = TweenInfo.new(math.random(3, 5), Enum.EasingStyle.Linear)
        local endPos = (randomPoint + randomPoint.RightVector * 800).Position
        local tween = TweenService:Create(model, tweenInfo, {Position = endPos, Orientation = model.Orientation + Vector3.new(0 ,0, -1080)})
        tween:Play()
        tween.Completed:Once(function()
            if model then
                model:Destroy()
            end
        end)
    end
    task.delay(1, function()
        if warn1 then
            warn1.Transparency = 1
        end
        if warn2 then
            warn2.Transparency = 1
        end
        doTween(index1)
        doTween(index2)
    end)
end

local function Stage22Tween()
    local stages = StageObstacles:FindFirstChild("Stage22")
    if not stages then return end
    local randomIndex = math.random(1, 5)
    local model = stages:FindFirstChild(tostring(randomIndex))
    if not model then return end
    if not RandomPoints["22"][randomIndex] then return end
    local startCFrame = RandomPoints["22"][randomIndex].Start
    local endCFrame = RandomPoints["22"][randomIndex].End
    model = model:Clone()
    model.Parent = game.Workspace
    model:PivotTo(startCFrame)
    local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true)
    local tween = TweenService:Create(model.PrimaryPart, tweenInfo, {CFrame = endCFrame})
    tween:Play()
    tween.Completed:Once(function()
        if model then
            model:Destroy()
        end
    end)
end

RunService.Heartbeat:Connect(function(dt)
    --18关
    if CanActive(18, dt) then
        Stage18Tween()
    end

    if CanActive(22, dt) then
        Stage22Tween()
    end
end)