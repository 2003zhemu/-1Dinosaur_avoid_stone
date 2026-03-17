local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local effects = game.ReplicatedStorage.Assets.Effect
local effectHelper = require(game.ReplicatedStorage.Helper.EffectHelper)
local UserInputService = game:GetService("UserInputService")
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local localPlayer = game.Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid")
local flyModule = require(game.ReplicatedStorage.Modules.Fly)
local initFly = flyModule.new()

local jumpConn = nil
local jumpToolEffectConn = nil
local lastChangeTime = 0

EventBus.ConnectS2C(function(eventName, params)
    if eventName == "FlyStatus" then
        local InFlyTool = params.InFlyTool
        Character = localPlayer.Character
        if Character then
            Humanoid = Character:FindFirstChild("Humanoid")
        end

        if InFlyTool then
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
            initFly:Enable()
            if Humanoid then
                jumpConn = UserInputService.JumpRequest:Connect(function()
                    if os.clock() - lastChangeTime < 1 then
                        return
                    end
                    lastChangeTime = os.clock()
                    local curState = localPlayer:GetAttribute("IsFlying")
                    if not curState then
                        initFly:StartFlying()
                    else
                        initFly:StopFlying()
                    end
                end)
            end
        else
            initFly:StopFlying()
            initFly:Disable()
            if jumpConn then
                jumpConn:Disconnect()
                jumpConn = nil
            end
        end
    end

    if eventName == "ShowJumpEffect" then
        if jumpToolEffectConn then
            jumpToolEffectConn:Disconnect()
            jumpToolEffectConn = nil
        end
        Character = localPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChild("Humanoid")
            if Humanoid then
                jumpToolEffectConn = Humanoid.StateChanged:Connect(function(oldState, newState)
                    if newState == Enum.HumanoidStateType.Jumping then
                        local startCFrame = Character:GetPivot()
                        if Humanoid then
                            startCFrame = startCFrame - Vector3.new(0, Humanoid.HipHeight, 0)
                        end
                        local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            startCFrame = startCFrame - Vector3.new(0, rootPart.Size.Y / 2, 0)
                        end
                        local effect = effects:FindFirstChild("JumpEffect")
                        if effect then
                            effect = effect:Clone()
                            effect:PivotTo(startCFrame)
                            effect.Parent = game.Workspace.Effects
                            local times = effectHelper.EmitAll(effect)
                            task.delay(times, function()
                                effect:Destroy()
                            end)
                        end
                    end
                end)
            end
        end
        
    end

    if eventName == "UnequipTool" then
        local toolName = params.ToolName
        if toolName and toolName == "Jump" then
            if jumpToolEffectConn then
                jumpToolEffectConn:Disconnect()
                jumpToolEffectConn = nil
            end
        end
    end
end)