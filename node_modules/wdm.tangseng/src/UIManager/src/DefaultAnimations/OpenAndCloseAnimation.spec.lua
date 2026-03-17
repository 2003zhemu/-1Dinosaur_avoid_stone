return function()
	local defaultAnimationsFolder = game.ReplicatedStorage.Packages.UIManager.DefaultAnimations
	local openAnimation = require(defaultAnimationsFolder.OpenWinAnimation)
	local closeAnimation = require(defaultAnimationsFolder.CloseWinAnimation)

	local screen
	local guiFrame
	beforeAll(function()
		screen = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
		guiFrame = Instance.new("Frame", screen)
		guiFrame.AnchorPoint = Vector2.new(.5, .5)
		guiFrame.Position = UDim2.fromScale(0.5, 0.5)
		guiFrame.Size = UDim2.fromScale(0.4, 0.4)
	end)
	afterAll(function()
		task.wait(10)
		screen:Destroy()
		screen = nil
		guiFrame:Destroy()
		guiFrame = nil
	end)
	
	it("open and close win animation test",function()
		openAnimation.Play(guiFrame)
		task.wait(5)
		closeAnimation.Play(guiFrame)
	end)
end