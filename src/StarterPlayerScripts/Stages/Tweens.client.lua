local TweenService = game:GetService("TweenService")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local effectHelper = require(game.ReplicatedStorage.Helper.EffectHelper)
local obstacles = game.Workspace:FindFirstChild("Obstacles")

--尖锥下砸
local function Stage2Tween()
	task.spawn(function()
		local model = obstacles.Stage2.FallArea
		if not model.PrimaryPart then
			return
		end
		local startCFrame = CFrame.new(Vector3.new(-115.5, 120, -1041.555))
		local endCFrame = CFrame.new(Vector3.new(-115.5, 70, -1041.555))
		model:PivotTo(startCFrame)
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Bounce)
		local tween = TweenService:Create(model.PrimaryPart, tweenInfo, { CFrame = endCFrame })
		tween:Play()
		task.wait(2)
		if model.PrimaryPart then
			local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Linear)
			tween = TweenService:Create(model.PrimaryPart, tweenInfo2, { CFrame = startCFrame })
			tween:Play()
		end
	end)
end

--圆球滚落
local function Stage5Tween()
	task.spawn(function()
		local ball = obstacles.Stage5:FindFirstChild("DamagePart4")
		if not ball then
			return
		end
		local startPos = Vector3.new(-113.583, 240.161, -2979.392)
		local endPos = Vector3.new(-113.583, 94, -2428.392)
		--先下落
		ball.CFrame = CFrame.new(startPos + Vector3.new(0, 60, 0))
		local tweenInfo1 = TweenInfo.new(1, Enum.EasingStyle.Bounce)
		local tween = TweenService:Create(ball, tweenInfo1, { Position = startPos })
		tween:Play()
		task.wait(1) --下落时长
		--再滚动
		--warn("第五关 客户端执行滚动")
		if ball then
			local tweenInfo2 = TweenInfo.new(4, Enum.EasingStyle.Linear)
			tween = TweenService:Create(
				ball,
				tweenInfo2,
				{ Position = endPos, Orientation = ball.Orientation + Vector3.new(360, 0, 0) }
			)
			tween:Play()
		end

		task.wait(4) --等待滚动完成
		if ball then
			ball.CFrame = CFrame.new(startPos + Vector3.new(0, 60, 0))
			ball.Orientation = Vector3.new(0, 0, 0)
		end
	end)
end

--岩浆喷发
local function Stage7Tween()
	task.spawn(function()
		local model = obstacles.Stage7.Model
		if not model.PrimaryPart then
			return
		end
		local startCFrame = CFrame.new(Vector3.new(-294.166, 219.832, -4830.457))
		local endCFrame = CFrame.new(Vector3.new(-294.166, 219.832, -5816.34))
		local hideCFrame = CFrame.new(Vector3.new(-294.166, 180.036, -4949.978))

		model:PivotTo(startCFrame)
		local tweenInfo = TweenInfo.new(3.2, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(model.PrimaryPart, tweenInfo, { CFrame = endCFrame })
		tween:Play()
		task.spawn(function()
			for k = 1, 4 do
				effectHelper.EmitAll(model)
				task.wait(math.random(70, 100) / 100)
			end
		end)
		task.wait(3.2)
		model:PivotTo(hideCFrame)
	end)
end

--大摆锤
local function Stage9Tween()
	task.spawn(function()
		local model = obstacles.Stage9.Model
		if not model.PrimaryPart then
			return
		end
		local startCFrame = CFrame.new(Vector3.new(-290.944, 332.212, -7740.607)) * CFrame.Angles(0, 0, math.rad(-40))
		local endCFrame = CFrame.new(Vector3.new(-290.944, 332.212, -7740.607)) * CFrame.Angles(0, 0, math.rad(40))

		model:PivotTo(startCFrame)
		local tweenInfo1 = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)
		local tween = TweenService:Create(model.PrimaryPart, tweenInfo1, { CFrame = endCFrame })
		tween:Play()
	end)
end

--大摆锤2
local function Stage21Tween()
	task.spawn(function()
		local model = obstacles.Stage21.Model1
		if not model.PrimaryPart then
			return
		end
		local startCFrame = CFrame.new(Vector3.new(-343.95, 2438.553, -36438.598)) * CFrame.Angles(0, 0, math.rad(-40))
		local endCFrame = CFrame.new(Vector3.new(-343.95, 2438.553, -36438.598)) * CFrame.Angles(0, 0, math.rad(40))

		model:PivotTo(startCFrame)
		local tweenInfo1 = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)
		local tween = TweenService:Create(model.PrimaryPart, tweenInfo1, { CFrame = endCFrame })
		tween:Play()

		local model = obstacles.Stage21.Model2
		if not model.PrimaryPart then
			return
		end
		local endCFrame = CFrame.new(Vector3.new(-117.369, 2438.553, -36438.598)) * CFrame.Angles(0, 0, math.rad(-40))
		local startCFrame = CFrame.new(Vector3.new(-117.369, 2438.553, -36438.598)) * CFrame.Angles(0, 0, math.rad(40))

		model:PivotTo(startCFrame)
		local tweenInfo1 = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)
		local tween = TweenService:Create(model.PrimaryPart, tweenInfo1, { CFrame = endCFrame })
		tween:Play()
	end)
end

--激光
local function Stage11Tween()
	task.spawn(function()
		local Laser1 = obstacles.Stage11.Laser
		local Laser2 = obstacles.Stage11.Laser2
		if not Laser1.PrimaryPart or not Laser2.PrimaryPart then
			return
		end
		local startCFrame1 = CFrame.new(Vector3.new(-161.594, 445.65, -10827.842)) * CFrame.Angles(0, math.rad(90), 0)
		local endCFrame1 = CFrame.new(Vector3.new(-373.332, 445.65, -10827.842)) * CFrame.Angles(0, math.rad(90), 0)
		local startCFrame2 = CFrame.new(Vector3.new(-264.423, 445.65, -10385.482)) * CFrame.Angles(0, math.rad(180), 0)
		local endCFrame2 = CFrame.new(Vector3.new(-264.423, 445.65, -10049.723)) * CFrame.Angles(0, math.rad(180), 0)
		local tweenInfo1 = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
		local tween1 = TweenService:Create(Laser1.PrimaryPart, tweenInfo1, { CFrame = endCFrame1 })
		tween1:Play()

		local tweenInfo2 = TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
		local tween2 = TweenService:Create(Laser2.PrimaryPart, tweenInfo2, { CFrame = endCFrame2 })
		tween2:Play()
	end)
end

--圆锯
local function Stage13Tween()
	task.spawn(function()
		local model = obstacles.Stage13.Model
		if not model.PrimaryPart then
			return
		end
		-- local AngularVelocity = model.PrimaryPart:FindFirstChild("AngularVelocity")
		-- if not AngularVelocity then
		--     AngularVelocity = Instance.new("AngularVelocity")
		--     AngularVelocity.Parent = model.PrimaryPart
		--     AngularVelocity.MaxTorque = 1000000
		-- end
		-- AngularVelocity.AngularVelocity = Vector3.new(30, 0, 0)

		local startCFrame = CFrame.new(Vector3.new(-261.555, 455.127, -14640.636))
		local endCFrame = startCFrame + Vector3.new(0, 0, 1445)
		model:PivotTo(startCFrame)
		local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(
			model.PrimaryPart,
			tweenInfo,
			{ CFrame = endCFrame * CFrame.Angles(math.rad(-5000), 0, 0) }
		)
		tween:Play()
		task.wait(5) --等待滚动完成
		model:PivotTo(startCFrame)
	end)
end

--海浪
local function Stage17Tween()
	task.spawn(function()
		local model = obstacles.Stage17:FindFirstChild("DamagePart4")
		if not model then
			return
		end
		local startCFrame = CFrame.new(Vector3.new(-258.655, 500.015, -26845.324)) * CFrame.Angles(0, math.rad(-180), 0)
		local endCFrame = CFrame.new(Vector3.new(-258.655, 500.015, -30155.203)) * CFrame.Angles(0, math.rad(-180), 0)

		model:PivotTo(startCFrame)
		local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Linear)
		local tween = TweenService:Create(model, tweenInfo, { CFrame = endCFrame })
		tween:Play()
		task.wait(4)
		model:PivotTo(startCFrame - Vector3.new(0, 150, 0))
	end)
end

EventBus.ConnectS2C(function(eventName, params)
	if eventName == EventDefines["客户端关卡动画"] then
		pcall(Stage2Tween)
		pcall(Stage5Tween)
		pcall(Stage7Tween)
		pcall(Stage11Tween)
		pcall(Stage13Tween)
		--Stage17Tween()
	end
	if eventName == EventDefines["客户端关卡动画2"] then
		pcall(Stage9Tween)
		pcall(Stage21Tween)
	end
end)
