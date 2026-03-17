local effectHelper = require(game.ReplicatedStorage.Helper.EffectHelper)
local effects = game.ReplicatedStorage.Assets.Effect
local AudioManager = require(game.ReplicatedStorage.Packages.AudioManager)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local localPlayer = game.Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local function PlayEffect(effectName)
	local effect = effects:FindFirstChild(effectName)
	if not effect then
		return
	end
	effect = effect:Clone()
	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	local cframe = Character:GetPivot() - Vector3.new(0, 2, 0)
	local dino = Character:FindFirstChild("RideDinosaur")
	if dino then
		cframe = dino:GetPivot()
	end
	effect:PivotTo(cframe)
	effect.Parent = game.Workspace.Effects
	if rootPart then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = rootPart
		weld.Part1 = effect.PrimaryPart
		weld.Parent = effect
	end
	local times = effectHelper.EmitAll(effect)
	task.delay(times, function()
		effect:Destroy()
	end)
end

local function PlayToolEffect(effectName)
	if not effectName then
		return
	end
	local effect = effects:FindFirstChild(effectName)
	if not effect then
		return
	end
	effect = effect:Clone()
	local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
	local cframe = Character:GetPivot()
	effect:PivotTo(cframe)
	effect.Parent = game.Workspace.Effects
	if rootPart then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = rootPart
		weld.Part1 = effect.PrimaryPart
		weld.Parent = effect
	end
	local times = effectHelper.EmitAll(effect)
	task.delay(times, function()
		effect:Destroy()
	end)
end
-- EventBus.ConnectS2C(function(eventName, params)
--     if eventName == EventDefines["玩家初始化"] then

--     end
-- end)

localPlayer:GetAttributeChangedSignal("UserLevel"):Connect(function()
	if not localPlayer:GetAttribute("PlayerReady") then
		return
	end
	--玩家升级
	if localPlayer:GetAttribute("UserLevel") and localPlayer:GetAttribute("UserLevel") > 0 then
		PlayEffect("升级特效")
		AudioManager:PlaySoundEffect("升级")
	end
end)

localPlayer:GetAttributeChangedSignal("RebornTimes"):Connect(function()
	if not localPlayer:GetAttribute("PlayerReady") then
		return
	end
	--玩家重生
	if localPlayer:GetAttribute("RebornTimes") and localPlayer:GetAttribute("RebornTimes") > 0 then
		PlayEffect("重生特效")
		AudioManager:PlaySoundEffect("重生")
		EventBus.FireServer("埋点", "玩家重生进度", localPlayer:GetAttribute("RebornTimes"))
	end
end)

EventBus.ConnectS2C(function(eventName, params)
	if eventName == "UnequipTool" then
		local ToolName = params.ToolName
		PlayToolEffect(ToolName .. "EndEffect")
	end
end)

EventBus.Connect(function(eventName, params)
	if eventName == "PlayToolEffect" then
		local EffectName = params.EffectName
		PlayToolEffect(EffectName)
	end
end)
