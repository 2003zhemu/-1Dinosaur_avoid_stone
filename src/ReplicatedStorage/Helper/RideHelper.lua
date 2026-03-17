local RideHelper = {}
local Units = game.ReplicatedStorage.Assets.Unit
local Effects = game.ReplicatedStorage.Assets.Effect
local auraConfig = require(game.ReplicatedStorage._genConfigs.battle_tbaura)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local EffectHelper = require(game.ReplicatedStorage.Helper.EffectHelper)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
RideHelper.__index = RideHelper

local PlayerRides = {}  --玩家骑乘缓存

local function Ride(player, rideId, rideShape)
    if not rideId or not player then
        return
    end
    if not rideShape then
		rideShape = 0
	end
    local tempRideId = rideId + rideShape * 1000

    task.spawn(function()
        local character = player.character or player.CharacterAdded:Wait()
        local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then
            repeat
                humanoid = character:FindFirstChild("Humanoid")
                task.wait(0.1)
            until humanoid
        end
        local baseHeight = player:GetAttribute("BaseHipHeight")
        if not baseHeight then 
            baseHeight = humanoid.HipHeight
            player:SetAttribute("BaseHipHeight", baseHeight)
        end
        if not rootPart then return end
        local dino = Units:FindFirstChild(tostring(tempRideId))
        if not dino then return end
        dino = dino:Clone()
        dino.Name = "RideDinosaur"
        local playerCFrame = character:GetPivot()
        dino.PrimaryPart.Anchored = false
        dino:PivotTo(playerCFrame - Vector3.new(0, playerCFrame.Position.Y, 0))
        dino.PrimaryPart.Anchored = true
        local rideCFrame = nil
        local Poses = dino:FindFirstChild("Poses")
        if Poses then
            local ridePart = Poses:FindFirstChild("Ride")
            if ridePart then
                rideCFrame = ridePart.CFrame
            end
        end
        if not rideCFrame then
            dino:Destroy()
            return nil
        end
        local oldModel = character:FindFirstChild("RideDinosaur")
        local weld = character:FindFirstChild("RideWeld")
        if not weld then
            weld = Instance.new("WeldConstraint")
            weld.Name = "RideWeld"
            weld.Parent = character
            weld.Part0 = rootPart
        end
        if oldModel then
            oldModel:Destroy()
        end
        weld.Part1 = nil

        character:PivotTo(rideCFrame + Vector3.new(0, baseHeight, 0))
        humanoid.HipHeight = baseHeight + rideCFrame.Position.Y - rootPart.Size.Y / 2
        weld.Part1 = dino.PrimaryPart
        dino.PrimaryPart.Anchored = false
        dino.Parent = character
        character:PivotTo(playerCFrame + Vector3.new(0, baseHeight + rideCFrame.Position.Y, 0))
        --更新玩家与骑乘恐龙高度差
        task.spawn(function()
            task.wait()
            if not character or not dino then return end
            local playerHeight = character:GetPivot().Position.Y
            local dinoHeight = dino:GetPivot().Position.Y
            local heightDiff = playerHeight - dinoHeight
            player:SetAttribute("HeightDiff", heightDiff)
        end)
        
        --通知客户端玩家更换骑乘恐龙
        EventBus.FireClient(player, EventDefines["骑乘恐龙"])
        EventBus.Fire("埋点", player.UserId, "玩家当前使用恐龙", rideId)

        --根据装备道具显示不同效果
        local effects = dino:FindFirstChild("Effects")
        if not effects then return end
        EffectHelper.SetEffectEnabled(effects, false)
        local equipedTool = player:GetAttribute("EquipedTool")
        if equipedTool then 
            local toolName = Defines.ToolByKey[equipedTool]
            if toolName then
                EffectHelper.SetEffectEnabled(effects:FindFirstChild(`Tool_{toolName}`), true)
            end
        end
    end)
end

local function WeldAura(player, auraId)
    if not auraId or not player then
        return
    end
    local config = auraConfig[auraId]
    if not config then return end
    local character = player.character or player.CharacterAdded:Wait()
    local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local aura = Effects:FindFirstChild(config.Name)
    if not aura then return end

    local oldAura = character:FindFirstChild("WeldAura")
    if oldAura then
        oldAura:Destroy()
    end

    aura = aura:Clone()
    aura.Name = "WeldAura"
    local playerCFrame = character:GetPivot()
    aura:PivotTo(playerCFrame)
    aura.Parent = character
    local weld = Instance.new("WeldConstraint")
    weld.Name = "WeldAura"
    weld.Parent = aura
    weld.Part0 = rootPart
    weld.Part1 = aura.PrimaryPart
end

function RideHelper.Init(player)
    local self = setmetatable({}, RideHelper)
    self.Player = player
    self.Conns = {}
    
    self.RideId = player:GetAttribute("RideId")
	self.RideShape = player:GetAttribute("RideShape") or 0
	Ride(player, self.RideId, self.RideShape)

    self.Conns["RideId"] = player:GetAttributeChangedSignal("RideId"):Connect(function()
        self.RideId = player:GetAttribute("RideId")
	    self.RideShape = player:GetAttribute("RideShape") or 0
	    Ride(player, self.RideId, self.RideShape)  
    end)

    self.Conns["RideShape"] = player:GetAttributeChangedSignal("RideShape"):Connect(function()
		self.RideId = player:GetAttribute("RideId")
		self.RideShape = player:GetAttribute("RideShape") or 0
		Ride(player, self.RideId, self.RideShape)
	end)

    self.Conns["EquipedTool"] = player:GetAttributeChangedSignal("EquipedTool"):Connect(function()
        local Character = player.Character
        if not Character then return end
        local dino = Character:FindFirstChild("RideDinosaur")
        if not dino then return end
        local effects = dino:FindFirstChild("Effects")
        if not effects then return end
        EffectHelper.SetEffectEnabled(effects, false)
        local equipedTool = player:GetAttribute("EquipedTool")
        if equipedTool then
            local toolName = Defines.ToolByKey[equipedTool]
            if toolName then
                EffectHelper.SetEffectEnabled(effects:FindFirstChild(`Tool_{toolName}`), true)
            end
        end
    end)
    
    self.AurasId = player:GetAttribute("AurasId")
    local config = auraConfig[self.AurasId]
    if config then
       player:SetAttribute("AuraBonus", config.ExpBonus)
    end
     WeldAura(player, self.AurasId)

    self.Conns["AurasId"] = player:GetAttributeChangedSignal("AurasId"):Connect(function()
        self.AurasId = player:GetAttribute("AurasId")
        local config = auraConfig[self.AurasId]
        if config then
        player:SetAttribute("AuraBonus", config.ExpBonus)
        end
        WeldAura(player, self.AurasId)
    end)

    PlayerRides[player] = self
    return self
end

function RideHelper.Destroy(player)
    local self = PlayerRides[player]
    if self then
        for _, conn in pairs(self.Conns) do
            conn:Disconnect()
        end
    end
    PlayerRides[player] = nil
end
return RideHelper