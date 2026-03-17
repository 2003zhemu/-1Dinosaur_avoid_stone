local Gun = {}
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local effectHelper = require(game.ReplicatedStorage.Helper.EffectHelper)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local toolHelper = require(game.ReplicatedStorage.Helper.ToolHelper)
local Status = require(game.ReplicatedStorage.ToolModules.Status)
local ToolConfigs = require(script.Parent.Config)
local toolModels = nil
local Player = nil
local Character = nil
local Humanoid = nil
local Mouse = nil
if RunService:IsServer() then
	toolModels = game.ServerStorage.ToolModels
end
if RunService:IsClient() then
	Player = Players.LocalPlayer
	Character = Player.Character or Player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid", 10)
	Mouse = Player:GetMouse()
end

Gun.__index = Gun

function Gun.New(Tool)
	local self = setmetatable({}, Gun)
	local configs = ToolConfigs[Tool.Name] or {}
	self.Configs = configs
	self.Tool = Tool
	self.ToolName = Tool.Name
	self.Conns = {}
	self.Tracks = {}
	self.Sounds = {}
	self.AttackAble = true
	self.Touchs = Tool:FindFirstChild("Touchs")
	self.ColdTime = configs.ColdTime or 1
	self.Damage = configs.Damage or 0
	self.Distance = configs.MaxDistance or 200
	self.Speed = configs.Speed or 150
	self.Models = {}
	self.HitPlayers = {}
	self.CurHitPlr = nil
	self.FirePos = {}

	if RunService:IsClient() then
		self.Player = Player
		self.Character = Character
		self.Humanoid = Humanoid
		self.Mouse = Mouse
	end

	self.ServerControl = Tool:WaitForChild("ServerControl", 10)
	
	return self
end

function Gun:Disconnect(name)
	if name and self.Conns[name] then
		self.Conns[name]:Disconnect()
		self.Conns[name] = nil
	else
		for k,v in pairs(self.Conns) do
			v:Disconnect()
			self.Conns[k] = nil
		end
	end
end

function Gun:Equipped(options)
	if RunService:IsClient() then
		if self.Configs.CloseIdle then
			self.Conns["Animate"] = RunService.RenderStepped:Connect(function()
				if not self.Humanoid then return end
				if self.Humanoid:FindFirstChild("Animator") then
					for k,v in pairs(self.Humanoid.Animator:GetPlayingAnimationTracks()) do
						if v.Name == "ToolNoneAnim" then
							v:Stop()
							self:Disconnect("Animate")
						end
					end
				end
			end)
		end

		if not self.Tracks["Idle"] then
			local anim = self.Tool:FindFirstChild("Idle")
			if anim then
				self.Tracks["Idle"] = self.Humanoid:LoadAnimation(anim)
			end
		end
		if not self.Tracks["Attack"] then
			local anim = self.Tool:FindFirstChild("Attack")
			if anim then
				self.Tracks["Attack"] = self.Humanoid:LoadAnimation(anim)
				self.Tracks["Attack"].Looped = false
			end
		end

		if self.Tracks["Idle"] then
			self.Tracks["Idle"]:Play()
		end

		self.Sounds["Attack"] = self.Tool:FindFirstChild("AttackSound")
	else
		if self.Touchs then
			self.Touchs:ClearAllChildren()
		end
		if self.Tool and self.Tool.Parent:FindFirstChildWhichIsA("Humanoid") then
            self.Character = self.Tool.Parent
            self.Humanoid = self.Tool.Parent:FindFirstChildWhichIsA("Humanoid")
            self.Player = Players:GetPlayerFromCharacter(self.Character)
			if self.Configs.HasAccessory then
				local accessorys = toolModels:FindFirstChild(self.ToolName)
				if accessorys and self.Humanoid then
					for i, v: Accessory in accessorys:GetChildren() do
						local equip = v:Clone()
						equip.Name = "Tool" .. v.Name .. tostring(i)
						table.insert(self.Models, equip)
						self.Humanoid:AddAccessory(equip)
						if self.Touchs then
							local nameValue = Instance.new("StringValue", self.Touchs)
							nameValue.Value = equip.Name
						end
					end
				end
			end  
		end
	end
	return self
end

function Gun:Unequipped()
	if self.Touchs then
		self.Touchs:ClearAllChildren()
	end
	for k, v in pairs(self.Models) do
		v:Destroy()
	end
	self.Models = {}
	if self.Tracks["Idle"] then
		self.Tracks["Idle"]:Stop()
	end
	if self.Tracks["Attack"] and self.Tracks["Attack"].IsPlaying then
		self.Tracks["Attack"]:Stop()
	end
	self:Disconnect()
end

function Gun:Activated(options)
    if self.Player and not toolHelper.CanActive(self.Player.UserId) then
		return
	end
	if RunService:IsClient() then
		if self.AttackAble then
			self.AttackAble = false
            task.delay(self.ColdTime, function()  
				self.AttackAble = true
			end)
			if self.ColdTime > 1 then
				EventBus.Fire("ToolInCold", {ColdTime = self.ColdTime, ToolName = self.ToolName})
			end
			self.HitPlayers = {}
			self:PlaySound({SoundName = self.Configs.AttackSoundName})

			self:PlayAnimate({AnimateName = self.Configs.AttackAnimateName})
			self:GetVector()
			if self.ServerControl then
				self.ServerControl:InvokeServer()
			end
		end
	end
    
	if RunService:IsServer() then
		if not self.AttackAble then return end
		self.AttackAble = false
		task.delay(self.ColdTime, function()  
			self.AttackAble = true
		end)
		self.HitPlayers = {}
		self.CurHitPlr = nil
		for k,v in pairs(self.Models) do  --武器模型
			local firePos = v:FindFirstChild("FirePos")
			if firePos and firePos:IsA("ObjectValue") then
				firePos = firePos.Value
			end
			if not firePos then continue end
			if #self.FirePos == 0 then
				table.insert(self.FirePos, firePos)
			end
			
			local bullet = toolModels:FindFirstChild(self.Configs.BulletName)
			if not bullet then continue end
			bullet = bullet:Clone()
			self.Bullet = bullet
			local HitPart = nil
			if bullet:IsA("BasePart") then
				HitPart = bullet
			elseif bullet:IsA("Model") then
				HitPart = bullet.PrimaryPart
			end
			local startPos = nil
			if firePos:IsA("Attachment") then
				startPos = firePos.WorldCFrame.Position
			else
				startPos = firePos.Position		
			end
			local selfCFrame = self.Character:GetPivot()
			local vector = selfCFrame.LookVector
			local endPos = (selfCFrame + selfCFrame.LookVector * self.Distance).Position
			local distance = self.Distance
			local moveConn = nil
			local function DoHit(gun, Hit, options)
				if not Hit and not Hit.Parent then return end
				--打中炮台
				if Hit.Parent and Hit.Parent.Name:find("Turret") then
					EventBus.Fire("DamageTurret", {
						TurretName = Hit.Parent.Name,
						Damage = gun.Damage, --自定义伤害值
						AttackerId = gun.Player.UserId
					})
				end
				
				local hitCharacter = Hit:FindFirstAncestorOfClass("Model")
				if not hitCharacter then return end
				local hitPlr = Players:GetPlayerFromCharacter(hitCharacter)
				if not hitPlr then return end
				if hitPlr == self.Player then return end
				if self.HitPlayers[hitPlr] then return end
                self.HitPlayers[hitPlr] = true
				self.CurHitPlr = hitPlr
				if moveConn then
					moveConn:Disconnect()
					moveConn = nil
				end
				if bullet then
					Debris:AddItem(bullet, 0.1)
				end
				if options and options.Callback then
					options.Callback(hitPlr, gun.Configs)
				end
			end
			
			--通过碰撞检测寻找目标
			if self.Configs.HitType == "Touched" then
				HitPart.Touched:Connect(function(Hit)
					DoHit(self, Hit, options)
				end)

			--通过射线检测寻找目标
			elseif self.Configs.HitType == "Ray" then
				local raycastParams = options.RaycastParams
				if not raycastParams then
					raycastParams = RaycastParams.new()
					raycastParams.IgnoreWater = true
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude
					raycastParams.FilterDescendantsInstances = {self.Character, game.Workspace.Map, game.Workspace.Unit}
				end
				local raycastResult = game.Workspace:Raycast(startPos, vector.Unit * self.Distance, raycastParams)
				 
				--处理击中的玩家
				if raycastResult and raycastResult.Instance then
					local Hit = raycastResult.Instance
					DoHit(self, Hit, options)
				end
				if raycastResult and raycastResult.Position then
					endPos = raycastResult.Position
					vector = CFrame.lookAt(startPos, endPos).LookVector
					distance = (endPos - startPos).Magnitude
				end
			else
				bullet:Destroy()
			end
			
			if bullet then
				effectHelper.EmitAll(firePos)
				local startTime = tick()
				local totalTime = distance / self.Speed
				bullet:PivotTo(CFrame.lookAt(startPos, startPos + vector))
				bullet.Parent = game.Workspace
				moveConn = RunService.Heartbeat:Connect(function()
					local elapsed = tick() - startTime
					local progress = math.min(elapsed / totalTime, 1)
					-- 线性插值
					local currentPos = startPos:Lerp(endPos, progress)
					bullet:PivotTo(CFrame.lookAt(currentPos, currentPos + vector))
					if progress >= 1 then
						if moveConn then
							moveConn:Disconnect()
							moveConn = nil
						end
						bullet:PivotTo(CFrame.lookAt(endPos, endPos + vector))
						if bullet then
							Debris:AddItem(bullet, 0.1)
						end
						-- 测试
						-- if self.Configs.NoHitCheck then
						-- 	if options and options.CallBack then
						-- 		options.CallBack(nil, self.Configs)
						-- 	end
						-- end
					end
				end)
			end
		end
	end
	return true
end

function Gun:PlaySound(options)
	if not options then return end
	if options.SoundName and self.Sounds[options.SoundName] then
		self.Sounds[options.SoundName]:Play()
	end
end

function Gun:PlayAnimate(options)
	if not options then return end
	if options.AnimateName and self.Tracks[options.AnimateName] then
		self.Tracks[options.AnimateName]:Play()
	end
end

function Gun:GetVector()
	if self.Character and self.Mouse then
		local startPos = self.Character:GetPivot().Position
		local hitPos = self.Mouse.Hit.Position
		local vector = (Vector3.new(hitPos.X,startPos.Y,hitPos.Z) - startPos).Unit
		self.Character:PivotTo(CFrame.lookAt(startPos, startPos + vector))
		return vector
	end
end

return Gun