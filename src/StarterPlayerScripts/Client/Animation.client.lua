local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local RideAnimation = Instance.new("Animation")
RideAnimation.AnimationId = "rbxassetid://101764189645640"
local playerTrack = nil
local dinoAnimator = nil
local Tracks = {}

local function PlayTrack(name)
    if dinoAnimator then
        for k, v in pairs(dinoAnimator:getPlayingAnimationTracks()) do
            if v ~= Tracks[name] then
                v:Stop()
            end
        end
    end
    
    for k, v in pairs(Tracks) do
        if k ~= name then
            v:Stop()
        else
            if not v.IsPlaying then
                v:Play()
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    if not playerTrack then
        for k,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
            v:Stop()
        end
        playerTrack = Humanoid:LoadAnimation(RideAnimation)
        playerTrack:Play()
    end
    local Dinosaur = Character:FindFirstChild("RideDinosaur")
    if not Dinosaur then return end
    if not Tracks["Move"] then
        local AnimationController = Dinosaur:FindFirstChild("AnimationController")
        if not AnimationController then return end
        dinoAnimator = AnimationController:FindFirstChild("Animator")
        if not dinoAnimator then return end
        for k, v in pairs(dinoAnimator:GetChildren()) do
            if v:IsA("Animation") then
                if not Tracks[v.Name] then
                    Tracks[v.Name] = dinoAnimator:LoadAnimation(v)
                end
            end
        end
        for k, v in pairs(dinoAnimator:GetPlayingAnimationTracks()) do
            v:Stop()
        end
    end

    --跟随时播放移动
    if localPlayer:GetAttribute("InviteStatus") and localPlayer:GetAttribute("InviteStatus") == 2 then
        PlayTrack("Move")
        Tracks["Move"]:AdjustSpeed(1)
        return
    end

    --跑步机上
    if localPlayer:GetAttribute("InRuning") then
        PlayTrack("Move")
        --TODO 根据跑步机调整动画速度？
        Tracks["Move"]:AdjustSpeed(math.clamp(Humanoid.WalkSpeed / 16, 0.5, 2))
        return
    end

    if Humanoid.MoveDirection.Magnitude == 0 then
        PlayTrack("Idle")
        return
    end
    PlayTrack("Move")
    --TODO 根据玩家速度调整动画速度
    Tracks["Move"]:AdjustSpeed(math.clamp(Humanoid.WalkSpeed / 16, 0.5, 2))
end)

EventBus.ConnectS2C(function(eventName, params)
    if eventName == EventDefines["骑乘恐龙"] then
        for k, track in pairs(Tracks) do
           track:Stop()
           Tracks[k] = nil
        end
        Tracks = {}
        local Dinosaur = Character:WaitForChild("RideDinosaur", 10) 
        if not Dinosaur then return end
        local AnimationController = Dinosaur:FindFirstChild("AnimationController")
        if not AnimationController then return end
        dinoAnimator = AnimationController:FindFirstChild("Animator")
        if not dinoAnimator then return end
        for k, v in pairs(dinoAnimator:GetChildren()) do
            if v:IsA("Animation") then
                if not Tracks[v.Name] then
                    Tracks[v.Name] = dinoAnimator:LoadAnimation(v)
                end
            end
        end

        for k, v in pairs(dinoAnimator:GetPlayingAnimationTracks()) do
            v:Stop()
        end
    end
end)
