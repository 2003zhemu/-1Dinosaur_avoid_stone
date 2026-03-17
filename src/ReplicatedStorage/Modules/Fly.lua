--[[
    飞行模块 (FlyModule)
    用法示例:
    local FlyModule = require(script.FlyModule)
    local flyInstance = FlyModule.new()
    flyInstance:Enable()  -- 启用飞行
    flyInstance:Disable() -- 禁用飞行
--]]

local FlyModule = {}
FlyModule.__index = FlyModule

-- 服务获取
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- 默认配置
local DEFAULT_CONFIG = {
	MaxSpeed = 100,
	CurrentSpeed = 5,
	FlyRate = 1/60,
	AnimationIds = {
		["Up"] = "rbxassetid://102294505510109",
		["Down"] = "rbxassetid://122076260396264",
		["Fly"] = "rbxassetid://89437378189681",
		["Idle"] = "rbxassetid://112167498638161",
	}
}

-- 创建新的飞行实例
function FlyModule.new(config)
	local self = setmetatable({}, FlyModule)

	-- 配置合并
	self.config = {}
	for k, v in pairs(DEFAULT_CONFIG) do
		self.config[k] = (config and config[k]) or v
	end

	-- 基础变量初始化
	self.Player = Players.LocalPlayer
	self.Character = nil
	self.Torso = nil
	self.Humanoid = nil
	self.BodyVelocity = nil
	self.BodyGyro = nil
	self.Camera = workspace.CurrentCamera

	-- 状态变量
	self.Flying = false
	self.Debounce = false
	self.ToolEquipped = false


	-- 控制变量
	self.Controls = {
		Forward = { Number = 0, Numbers = { On = -1, Off = 0 }, Keys = { "W", 17 } },
		Backward = { Number = 0, Numbers = { On = 1, Off = 0 }, Keys = { "S", 18 } },
		Left = { Number = 0, Numbers = { On = -1, Off = 0 }, Keys = { "A", 20 } },
		Right = { Number = 0, Numbers = { On = 1, Off = 0 }, Keys = { "D", 19 } },
	}

	-- 动画相关
	self.Tracks = {}

	-- 连接变量
	self.Connections = {}

	return self
end

-- 初始化角色组件
function FlyModule:InitializeCharacter()
	self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.Torso = self.Character:WaitForChild("UpperTorso") or self.Character:WaitForChild("Torso")

	-- 创建物理组件
	if self.BodyVelocity then self.BodyVelocity:Destroy() end
	if self.BodyGyro then self.BodyGyro:Destroy() end

	self.BodyVelocity = Instance.new("BodyVelocity", self.Character.PrimaryPart)
	self.BodyGyro = Instance.new("BodyGyro", self.Character.PrimaryPart)
	self.BodyVelocity.maxForce = Vector3.new(0, 0, 0)
	self.BodyGyro.maxTorque = Vector3.new(0, 0, 0)
end

-- 加载动画
function FlyModule:LoadAnimations()
	self.Tracks = {}
	for k, v in pairs(self.config.AnimationIds) do
		local animation = Instance.new("Animation")
		animation.AnimationId = v
		animation.Name = k
		self.Tracks[k] = self.Humanoid:LoadAnimation(animation)
	end

	-- 添加起飞动画结束回调
	if self.Tracks["Up"] then
		self.Tracks["Up"].KeyframeReached:Connect(function(keyframe)
			if keyframe == "End" then
				if self.Humanoid.MoveDirection.Magnitude == 0 then
					if self.Tracks["Idle"] then
						self.Tracks["Idle"]:Play()
					end
				else
					if self.Tracks["Fly"] then
						self.Tracks["Fly"]:Play()
					end
				end
			end
		end)
	end
end


-- 数值限制函数
function FlyModule:Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

-- 检查角色是否存在
function FlyModule:CheckIfAlive()
	return (
		self.Character and self.Character.Parent and
			self.Humanoid and self.Humanoid.Parent and self.Humanoid.Health > 0 and
			self.Torso and self.Torso.Parent and
			self.Player and self.Player.Parent
	)
end

-- 主飞行逻辑
function FlyModule:Fly()
	if not (self.Flying and self.Player and self.Torso and self.Humanoid and self.Humanoid.Health > 0) then
		return
	end

	local Momentum = Vector3.new(0, 0, 0)
	local LastMomentum = Vector3.new(0, 0, 0)
	local LastTilt = 0
	local LastFlap = 0
	local CurrentSpeed = self.config.MaxSpeed
	local Inertia = (1 - (self.config.CurrentSpeed / CurrentSpeed))

	Momentum = (self.Torso.Velocity + (self.Torso.CFrame.lookVector * 3) + Vector3.new(0, 10, 0))
	Momentum = Vector3.new(
		self:Clamp(Momentum.X, -15, 15), 
		self:Clamp(Momentum.Y, -15, 15), 
		self:Clamp(Momentum.Z, -15, 15)
	)

	self.BodyVelocity.maxForce = Vector3.new(1, 1, 1) * (10 ^ 6)
	self.BodyGyro.maxTorque = Vector3.new(self.BodyGyro.P, self.BodyGyro.P, self.BodyGyro.P)
	self.BodyGyro.cframe = self.Torso.CFrame

	self.Humanoid.AutoRotate = false

	while self.Flying and self.Torso and self.Humanoid and self.Humanoid.Health > 0 do
		if CurrentSpeed ~= self.config.MaxSpeed then
			CurrentSpeed = self.config.MaxSpeed
			Inertia = (1 - (self.config.CurrentSpeed / CurrentSpeed))
		end

		-- 动画控制
		if self.Humanoid.MoveDirection.Magnitude == 0 then
			if self.Tracks["Fly"] then
				self.Tracks["Fly"]:Stop()
			end
			if self.Tracks["Idle"] and not self.Tracks["Idle"].IsPlaying then
				self.Tracks["Idle"]:Play()
			end
		else
			if self.Tracks["Idle"] then
				self.Tracks["Idle"]:Stop()
			end
			if self.Tracks["Fly"] and not self.Tracks["Fly"].IsPlaying then
				self.Tracks["Fly"]:Play()
			end
		end

		local Direction = self.Camera.CoordinateFrame:vectorToWorldSpace(
			Vector3.new(
				self.Controls.Left.Number + self.Controls.Right.Number,
				math.abs(self.Controls.Forward.Number) * 0.2,
				self.Controls.Forward.Number + self.Controls.Backward.Number
			)
		)
		local Movement = Direction * self.config.CurrentSpeed
		Momentum = (Momentum * Inertia) + Movement

		local TotalMomentum = Momentum.magnitude
		if TotalMomentum > CurrentSpeed then
			TotalMomentum = CurrentSpeed
		end

		-- 倾斜计算
		local Tilt = ((Momentum * Vector3.new(1, 0, 1)).unit:Cross((LastMomentum * Vector3.new(1, 0, 1)).unit)).y
		local StringTilt = tostring(Tilt)

		if StringTilt == "-1.#IND" or StringTilt == "1.#IND" or
			Tilt == math.huge or Tilt == -math.huge or
			StringTilt == tostring(0 / 0) then
			Tilt = 0
		end

		local AbsoluteTilt = math.abs(Tilt)
		if AbsoluteTilt > 0.06 or AbsoluteTilt < 0.0001 then
			if math.abs(LastTilt) > 0.0001 then
				Tilt = (LastTilt * 0.9)
			else
				Tilt = 0
			end
		else
			Tilt = ((LastTilt * 0.77) + (Tilt * 0.25))
		end

		LastTilt = Tilt

		if TotalMomentum < 0.5 then
			Momentum = Vector3.new(0, 0, 0)
			TotalMomentum = 0
			self.BodyGyro.cframe = self.Camera.CoordinateFrame
		else
			self.BodyGyro.cframe = CFrame.new(Vector3.new(0, 0, 0), Momentum)
				* CFrame.Angles(0, 0, (Tilt * -20))
				* CFrame.Angles((math.pi * -0.5 * (TotalMomentum / CurrentSpeed)), 0, 0)
		end

		local GravityDelta = (
			(((Momentum * Vector3.new(0, 1, 0)) - Vector3.new(0, -self.config.MaxSpeed, 0)).magnitude / self.config.MaxSpeed)
				* 0.5
		)
		if GravityDelta > 0.45 and tick() > LastFlap then
			LastFlap = (tick() + 0.5)
		end

		self.BodyVelocity.velocity = Momentum
		LastMomentum = Momentum
		wait(self.config.FlyRate)
	end
	
	if self.BodyVelocity then
		self.BodyVelocity.maxForce = Vector3.new(0, 0, 0)
	end
	if self.BodyGyro then
		self.BodyGyro.maxTorque = Vector3.new(0, 0, 0)
	end
	
	

	if self:CheckIfAlive() then
		self.Humanoid.AutoRotate = true
		self.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
end

-- 开始飞行
function FlyModule:StartFlying()
	if self.Debounce or self.Flying then return end

	self.Debounce = true
	self.Flying = true

	-- 停止所有动画并播放起飞动画
	if self.Tracks["Fly"] then
		self.Tracks["Fly"]:Stop()
	end
	if self.Tracks["Idle"] then
		self.Tracks["Idle"]:Stop()
	end
	if self.Tracks["Down"] then
		self.Tracks["Down"]:Stop()
	end
	if self.Tracks["Up"] then
		self.Tracks["Up"]:Play()
	end

	self.Player:SetAttribute("IsFlying", true)

	-- 发送事件（如果需要EventBus）
	-- if game.ReplicatedStorage:FindFirstChild("Packages") and 
	-- 	game.ReplicatedStorage.Packages:FindFirstChild("EventBus") then
	-- 	local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
	-- 	EventBus.FireServer("ChangeFlyState", true)
	-- end

	spawn(function()
		self:Fly()
	end)

	self.Debounce = false
end

-- 停止飞行
function FlyModule:StopFlying()
	if not self.Flying then return end

	-- 发送事件（如果需要EventBus）
	if game.ReplicatedStorage:FindFirstChild("Packages") and 
		game.ReplicatedStorage.Packages:FindFirstChild("EventBus") then
		local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
		EventBus.FireServer("ChangeFlyState", false)
	end

	-- 停止所有动画并播放降落动画
	if self.Tracks["Up"] then
		self.Tracks["Up"]:Stop()
	end
	if self.Tracks["Fly"] then
		self.Tracks["Fly"]:Stop()
	end
	if self.Tracks["Idle"] then
		self.Tracks["Idle"]:Stop()
	end
	if self.Tracks["Down"] then
		self.Tracks["Down"]:Play()
	end

	self.Player:SetAttribute("IsFlying", false)
	self.Flying = false
	self.BodyVelocity.maxForce = Vector3.new(0, 0, 0)
	self.BodyGyro.maxTorque = Vector3.new(0, 0, 0)
end

-- 设置控制输入
function FlyModule:SetupControls()
	-- 断开之前的连接
	for _, connection in pairs(self.Connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.Connections = {}

	-- 移动控制
	self.Connections.Heartbeat = RunService.Heartbeat:Connect(function(deltaTime)
		local MoveDirection = self.Humanoid.MoveDirection
		local lookvector = workspace.CurrentCamera.CFrame.LookVector

		if MoveDirection.Magnitude == 0 then
			self.Controls.Left.Number = self.Controls.Left.Numbers.Off
			self.Controls.Right.Number = self.Controls.Right.Numbers.Off
			self.Controls.Forward.Number = self.Controls.Forward.Numbers.Off
			self.Controls.Backward.Number = self.Controls.Backward.Numbers.Off
			return
		end

		local m_x = MoveDirection.X
		local l_x = lookvector.X
		local m_z = MoveDirection.Z
		local l_z = lookvector.Z
		local d1 = m_x * l_x + m_z * l_z
		local d2 = math.sqrt(m_x * m_x + m_z * m_z) * math.sqrt(l_x * l_x + l_z * l_z)
		local m_X_l = m_x * l_z - m_z * l_x
		local dir = d1 / d2

		if not (dir == dir) then -- NaN检查
			self.Controls.Left.Number = self.Controls.Left.Numbers.Off
			self.Controls.Right.Number = self.Controls.Right.Numbers.Off
			self.Controls.Forward.Number = self.Controls.Forward.Numbers.Off
			self.Controls.Backward.Number = self.Controls.Backward.Numbers.Off
		else
			-- 重置所有控制
			self.Controls.Left.Number = self.Controls.Left.Numbers.Off
			self.Controls.Right.Number = self.Controls.Right.Numbers.Off
			self.Controls.Forward.Number = self.Controls.Forward.Numbers.Off
			self.Controls.Backward.Number = self.Controls.Backward.Numbers.Off

			if dir == 1 then
				self.Controls.Forward.Number = self.Controls.Forward.Numbers.On
			elseif dir == -1 then
				self.Controls.Backward.Number = self.Controls.Backward.Numbers.On
			elseif dir > 0 and dir < 1 then
				self.Controls.Forward.Number = self.Controls.Forward.Numbers.On
				if m_X_l < 0 then
					self.Controls.Right.Number = self.Controls.Right.Numbers.On
				else
					self.Controls.Left.Number = self.Controls.Left.Numbers.On
				end
			elseif dir < 0 and dir > -1 then
				self.Controls.Backward.Number = self.Controls.Backward.Numbers.On
				if m_X_l < 0 then
					self.Controls.Right.Number = self.Controls.Right.Numbers.On
				else
					self.Controls.Left.Number = self.Controls.Left.Numbers.On
				end
			end
		end
	end)
end

-- 等待物理组件就绪
function FlyModule:WaitForPhysicsComponents()
	while (not self.BodyVelocity or not self.BodyVelocity.Parent or 
		not self.BodyGyro or not self.BodyGyro.Parent) and 
		self:CheckIfAlive() and self.ToolEquipped do
		self.BodyVelocity = self.Torso:FindFirstChild("BodyVelocity")
		self.BodyGyro = self.Torso:FindFirstChild("BodyGyro")
		RunService.Stepped:Wait()
	end
end

-- 启用飞行模块
function FlyModule:Enable()
	if self.ToolEquipped then return end

	self:InitializeCharacter()
	--self:LoadAnimations()

	self.ToolEquipped = true
	self:SetupControls()
	self:WaitForPhysicsComponents()
end

-- 禁用飞行模块
function FlyModule:Disable()
	if not self.ToolEquipped then return end

	-- 停止飞行
	if self.Flying then
		self:StopFlying()
	end

	-- 断开所有连接
	for _, connection in pairs(self.Connections) do
		if connection then
			connection:Disconnect()
		end
	end
	self.Connections = {}

	-- 清理动画
	for _, track in pairs(self.Tracks) do
		if track then
			track:Stop()
			track:Destroy()
		end
	end
	self.Tracks = {}

	-- 清理物理组件
	if self.BodyVelocity then
		self.BodyVelocity:Destroy()
		self.BodyVelocity = nil
	end
	if self.BodyGyro then
		self.BodyGyro:Destroy()
		self.BodyGyro = nil
	end


	self.ToolEquipped = false
end

-- 设置速度
function FlyModule:SetSpeed(speed)
	self.config.CurrentSpeed = math.max(1, math.min(speed, self.config.MaxSpeed))
end

-- 获取飞行状态
function FlyModule:IsFlying()
	return self.Flying
end

-- 切换飞行状态
function FlyModule:ToggleFly()
	if self.Flying then
		self:StopFlying()
	else
		self:StartFlying()
	end
end

return FlyModule
