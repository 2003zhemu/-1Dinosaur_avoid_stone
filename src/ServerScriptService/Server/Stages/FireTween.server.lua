local TweenService = game:GetService("TweenService")
local carfolder =
	game:GetService("Workspace"):WaitForChild("Obstacles"):WaitForChild("Stage19"):WaitForChild("DeathPart")
carfolder.CFrame = CFrame.new(-255.183, -511.904, -32533.445)
local tweenInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 4.5)
local tween = TweenService:Create(carfolder, tweenInfo, { CFrame = CFrame.new(-255.183, 1285.854, -32533.445) })
tween:Play()
