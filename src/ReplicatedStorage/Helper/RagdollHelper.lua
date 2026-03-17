local RagdollHelper = {}
RagdollHelper.__index = RagdollHelper


function RagdollHelper.EnableRagdoll(player)
    if not player then return end
    local character = player.Character
    if not character then return end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid == nil then return end

	humanoid.RequiresNeck = false
	humanoid.BreakJointsOnDeath = false
	humanoid.PlatformStand = true
	for _, child in pairs(character:GetDescendants()) do
		if child:IsA("Motor6D") then
			local a0 = Instance.new("Attachment")
			local a1 = Instance.new("Attachment")
			a0.Parent = child.Part0
			a1.Parent = child.Part1
			a0.CFrame = child.C0
			a1.CFrame = child.C1
			a0.Name = "RagdollAttachment"
			a1.Name = "RagdollAttachment"

			local BallSocketConstraint = Instance.new("BallSocketConstraint")
			BallSocketConstraint.Name = "RagdollBallSocketConstraint"
			BallSocketConstraint.Parent = child.Parent
			BallSocketConstraint.Attachment0 = a0
			BallSocketConstraint.Attachment1 = a1
			BallSocketConstraint.LimitsEnabled = true

			if child.Name == "Root" then
				BallSocketConstraint:Destroy()
				local hinge1 = Instance.new("HingeConstraint")
				hinge1.Name = "RagdollHingeConstraint"
				hinge1.Parent = child.Parent
				hinge1.Attachment0 = a0
				hinge1.Attachment1 = a1
				hinge1.LimitsEnabled = true
			end
			if child.Name == "Neck" then
				BallSocketConstraint:Destroy()
				local hinge2 = Instance.new("HingeConstraint")
				hinge2.Name = "RagdollHingeConstraint"
				hinge2.Parent = child.Parent
				hinge2.Attachment0 = a0
				hinge2.Attachment1 = a1
				hinge2.LimitsEnabled = true
				hinge2.LowerAngle = 0
				hinge2.UpperAngle = 0
			end
			BallSocketConstraint.TwistLimitsEnabled = true
			child.Enabled = false
		end
	end
	local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		rootPart.Anchored = true
	end
end

function RagdollHelper.DisableRagdoll(player)
	if not player then return end
    local character = player.Character
    if not character then return end

    for _, child in pairs(character:GetDescendants()) do
        if child:IsA("Motor6D") then
            child.Enabled = true
        end
    end

    for _, child in pairs(character:GetDescendants()) do
        if child.Name == "RagdollAttachment" or 
           child.Name == "RagdollBallSocketConstraint" or 
           child.Name == "RagdollHingeConstraint" then
            child:Destroy()
        end
    end

	local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
	local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		rootPart.Anchored = false
	end
end

return RagdollHelper