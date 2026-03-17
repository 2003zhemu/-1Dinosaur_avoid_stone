local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid")
local lastFireTime = 0  -- 上次发送请求的时间
local tweenInfo1 = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local flyOutGui = nil
local startFrame = nil
local template = nil

RunService.Heartbeat:Connect(function()
    if not Character then
        Character = localPlayer.Character
    end

    if not Humanoid then
        Humanoid = Character:FindFirstChild("Humanoid")
    end

    --掉落死亡处理
    if Character then
        local curPos = Character:GetPivot().Position
        if curPos.Y <= -300 then
            EventBus.FireServer(EventDefines["玩家掉落死亡"])
        end
    end

    --滑行处理
	if Humanoid and Humanoid.MoveDirection.Magnitude == 0 then
		local state = Humanoid:GetState()
		if state == Enum.HumanoidStateType.Running then
			local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
			if rootPart then
				local currentVel = rootPart.AssemblyLinearVelocity
				rootPart.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y, 0)
			end
		end
	end

    if localPlayer:GetAttribute("InMaxLevel") then
        return
    end

    if localPlayer:GetAttribute("InRuning") or (Humanoid and Humanoid.MoveDirection.Magnitude > 0) then
        local currentTime = os.clock()
        local stepTime = 0.4
        if Humanoid and Humanoid.WalkSpeed > 0 then
            stepTime = 0.4 / (Humanoid.WalkSpeed / 16) --默认速度16 速度越快间隔越短
        end
        if math.clamp(stepTime, 0.35, 0.4) < currentTime - lastFireTime then
            lastFireTime = currentTime
            EventBus.FireServer(EventDefines["玩家步数增加"])
            --UI飘飞展示步数
            task.spawn(function()
                local runingSpeed = localPlayer:GetAttribute("RuningSpeed")
                if not runingSpeed then
                    return
                end
                if not template then
                    local playerGui = localPlayer:FindFirstChild("PlayerGui")
                    if playerGui then
                        flyOutGui = playerGui:FindFirstChild("Flyout")
                        if flyOutGui then   
                            startFrame = flyOutGui:FindFirstChild("Start")
                            if startFrame then
                                template = startFrame:FindFirstChild("Template")
                            end
                        end
                    end
                end
                if not template then
                    return
                end

                local textUI = template:Clone()
                textUI.Parent = flyOutGui
                textUI.Visible = true
                textUI.AnchorPoint = Vector2.new(0.5, 0.5)
                textUI.Text = "+" .. runingSpeed .. " Spd"
                textUI.Rotation = math.random(-10, 10)
                textUI.TextTransparency = 0
                textUI.TextStrokeTransparency = 0

                local UIStroke = textUI:FindFirstChild("UIStroke")
                if UIStroke then
                    UIStroke.Transparency = 0
                end

                local icon = textUI:FindFirstChild("ImageLabel")
                if icon then
                    icon.ImageTransparency = 0
                end

                local PosX = startFrame.AbsolutePosition.X + startFrame.AbsoluteSize.X / 2
                local PosY = startFrame.AbsolutePosition.Y + startFrame.AbsoluteSize.Y / 2
                local mathRad = math.rad(math.random(0, 360))  --随机角度
                local offsetX = math.cos(mathRad) * 150
                local offsetY = math.sin(mathRad) * 150

                local startPos = UDim2.new(0, PosX, 0, PosY)
                local endPos = UDim2.new(0, PosX + offsetX, 0, PosY + offsetY)
                local startSize = UDim2.new(0, 0, 0, 0)
                local endSize = template.Size
                local tween1 = TweenService:Create(textUI, tweenInfo1, {Size = endSize})
                local tween2 = TweenService:Create(textUI, tweenInfo2, {Position = endPos})
                local tween3 = TweenService:Create(textUI, tweenInfo3, {
                    TextTransparency = 1,
                    TextStrokeTransparency = 1,
                    Rotation = math.random(-15, 15),
                })

                local tween4 = nil
                local tween5 = nil
                if UIStroke then
                    tween4 = TweenService:Create(UIStroke, tweenInfo3, {Transparency = 1})
                end
                if icon then
                    tween5 = TweenService:Create(icon, tweenInfo3, {ImageTransparency = 1})
                end
        
                tween1:Play()
                tween2:Play()
                task.delay(0.2, function()
                    if textUI and textUI.Parent then
                        tween3:Play()
                        if tween4 then
                            tween4:Play()
                        end
                        if tween5 then
                            tween5:Play()
                        end
                    end
                end)
                game:GetService("Debris"):AddItem(textUI, 0.5)
            end)
        end
    end
end)
