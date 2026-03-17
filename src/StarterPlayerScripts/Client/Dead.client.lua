local Players = game:GetService("Players")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local AudioManager = require(game.ReplicatedStorage.Packages.AudioManager)
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

local humanoid = Character:FindFirstChild("Humanoid")
if not humanoid then
    repeat
        humanoid = Character:FindFirstChild("Humanoid")
        task.wait(0.1)
    until humanoid
end

local playerModule = nil
task.spawn(function()
	local module = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")
	if not module then
		repeat
			task.wait(0.1)
			module = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")
		until module
	end
	local ControlModule = module:FindFirstChild("ControlModule")
	if not ControlModule then
		repeat
			task.wait(0.1)
			ControlModule = module:FindFirstChild("ControlModule")
		until ControlModule
	end
	playerModule = require(ControlModule)
end)

local StarterGui = game:GetService("StarterGui")
task.spawn(function()
    local success = false
    while not success do
        success = pcall(function()
            StarterGui:SetCore("ResetButtonCallback", false)
        end)
        task.wait(0.1)
    end
end)

humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

humanoid.HealthChanged:Connect(function(newHealth)
    --玩家死亡时
    if newHealth <= 0 then
        humanoid.Health = humanoid.MaxHealth
        localPlayer:SetAttribute("IsDead", true)
        EventBus.FireServer(EventDefines["玩家死亡"])

        local rootPart = Character.PrimaryPart or Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.Anchored = true
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.AssemblyAngularVelocity = Vector3.zero
            task.delay(0.1, function()
                if rootPart and rootPart.Parent then
                    rootPart.Anchored = false
                end
            end)
        end

        -- 强制让 Humanoid 退出死亡动作状态
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end)

local lastDeadTime = 0

localPlayer:GetAttributeChangedSignal("IsDead"):Connect(function()
    --warn(localPlayer:GetAttribute("IsDead"))
    if localPlayer:GetAttribute("IsDead") then
        if os.time() - lastDeadTime < 1 then return end
        lastDeadTime = os.time()
        --死亡
        if playerModule then
            playerModule:Enable(false)
        end
        AudioManager:PlaySoundEffect("死亡")
        --通知客户端显示复活页面
        EventBus.Fire(EventDefines["客户端显示复活页面"])
    else
        --复活
        if playerModule then
            playerModule:Enable(true)
        end
        --通知客户端隐藏复活页面
        EventBus.Fire(EventDefines["客户端隐藏复活页面"])
    end
end)

