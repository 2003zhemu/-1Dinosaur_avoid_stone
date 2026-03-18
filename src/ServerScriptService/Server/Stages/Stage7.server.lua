local TweenService = game:GetService("TweenService")
local carfolder = game:GetService("Workspace"):WaitForChild("Obstacles"):WaitForChild("Stage7")

task.spawn(function()
	while true do
		task.wait(4)
		local part = carfolder:WaitForChild("Part")
		part.CFrame = CFrame.new(-115.292, 86.485, -3666.055)
		local info = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local tween = TweenService:Create(part, info, { CFrame = CFrame.new(-115.292, 86.485, -4019.607) })
		tween:Play()
		tween.Completed:Connect(function()
			part.CFrame = CFrame.new(-115.292, 17.367, -4019.607)
		end)
	end
end)
