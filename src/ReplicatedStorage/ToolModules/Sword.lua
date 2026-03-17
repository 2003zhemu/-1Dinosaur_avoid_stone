local Sword = {}
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

Sword.__index = Sword

function Sword.New(Tool)
	local self = setmetatable({}, Sword)
	local configs = ToolConfigs[Tool.Name] or {}
	self.Configs = configs
	self.Tool = Tool
	self.ToolName = Tool.Name
	self.Conns = {}
	self.Tracks = {}
	self.Sounds = {}
	self.AttackAble = true
    self.HitAble = false
	self.Touchs = Tool:FindFirstChild("Touchs")
    self.Hit = Tool:FindFirstChild("Hit")
	self.ColdTime = configs.ColdTime or 1
	self.Damage = configs.Damage or 0
	self.Distance = configs.Distance or 30  --击飞距离
    self.Hight = configs.Hight or 10  --击飞高度
    self.Duration = configs.Duration or 3  --击飞控制时间
	self.Models = {}
	self.HitPlayers = {}
	--self.FirePos = {}

	if RunService:IsClient() then
		self.Player = Player
		self.Character = Character
		self.Humanoid = Humanoid
		self.Mouse = Mouse
	end

	return self
end

function Sword:Disconnect(name)
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

function Sword:Equipped(options)
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
    end

 	if RunService:IsServer() then
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

function Sword:Unequipped()
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

function Sword:Activated(options)
    if self.Player and not toolHelper.CanActive(self.Player.UserId) then
		return
	end
	if RunService:IsClient() then
        if not self.AttackAble then return end
		self.AttackAble = false
        self.HitAble = true
        task.delay(self.ColdTime, function()
            self.AttackAble = true
            self.HitAble = false
        end)
		if self.ColdTime > 1 then
			EventBus.Fire("ToolInCold", {ColdTime = self.ColdTime, ToolName = self.ToolName})
		end
		
        self.HitPlayers = {}
        self:PlaySound({SoundName = self.Configs.AttackSoundName})
        self:PlayAnimate({AnimateName = self.Configs.AttackAnimateName})

        if self.Configs.SetEffect then
            local sendOptions = self.Configs.SetEffect
            sendOptions.UserId = self.Player.UserId
            if not sendOptions.EffectName then
                sendOptions.EffectName = self.Tool.Name
            end
            EventBus.FireServer("SetToolEffect",sendOptions)
        end

        local function DoHit(sword, part, options)
            if not self.HitAble then return end --未攻击时返回
            if not part or not part.Parent then return end
            if part:IsDescendantOf(self.Tool.Parent) then return end --击中自己返回

            --打中炮台
            if part.Parent and part.Parent.Name:find("Turret") then
                EventBus.FireServer("DamageTurret", {
                    TurretName = part.Parent.Name,
                    Damage = sword.Damage, --自定义伤害值
                    AttackerId = sword.Player.UserId
                })
            end
            
            if not self.Character then return end
            local hitPlr = game.Players:GetPlayerFromCharacter(part.Parent)
            if not hitPlr then return end
            if not toolHelper.CanAttacked(hitPlr.UserId) then return end
            if self.HitPlayers[hitPlr] then return end
            self.HitPlayers[hitPlr] = true
            --HitAble = true --有击中的直接结束（每次最多只打中一个）
            if self.Configs.FlyAway then
                local params = {}
                params.UserId = hitPlr.UserId
                params.CFrame = self.Character:GetPivot()
                params.Distance = self.Distance
                params.Height = self.Height
                params.Duration = self.Duration
                EventBus.FireServer("PlayerBeHit", hitPlr)
                EventBus.FireServer("RagdollFayAway", params)
            end
            if options and options.Callback then
                options.Callback(hitPlr, sword.Configs)
            end
        end

        if self.Hit and not self.Conns["HitTouched"] then
            if self.Hit:IsA("ObjectValue") then
                self.Hit = self.Hit.Value
            end
            self.Conns["HitTouched"] = self.Hit.Touched:Connect(function(part)
                DoHit(self, part, options)
            end)
        end
        if self.Touchs then
            if not self.Character then return end
            for k,v in pairs(self.Touchs:GetChildren()) do
                if v:IsA("StringValue") and v.Value then
                    local accessoryName = v.Value
                    if not accessoryName then continue end
                    if self.Conns[accessoryName] then continue end
                    local accessory = self.Character:FindFirstChild(accessoryName)
                    if not accessory then continue end
                    local Core = accessory:FindFirstChild("Core")
                    if not Core then continue end
                    if Core:IsA("ObjectValue") then
                        Core = Core.Value
                    end
					if not self.Conns[accessoryName] then
						self.Conns[accessoryName] = Core.Touched:Connect(function(part)
							DoHit(self, part, options)
						end)
					end
                end
            end
        end
	end
	if RunService:IsServer() then
        if not self.AttackAble then return end
		self.AttackAble = false
        self.HitAble = true
        task.delay(self.ColdTime, function()
            self.AttackAble = true
            self.HitAble = false
        end)
	end
	return true
end

function Sword:PlaySound(options)
	if not options then return end
	if options.SoundName and self.Sounds[options.SoundName] then
		self.Sounds[options.SoundName]:Play()
	end
end

function Sword:PlayAnimate(options)
	if not options then return end
	if options.AnimateName and self.Tracks[options.AnimateName] then
		self.Tracks[options.AnimateName]:Play()
	end
end

return Sword