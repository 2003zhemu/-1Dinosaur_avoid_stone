return function()

    local screen
    local guiFrame
    -- reset
    beforeEach(function(x) 
        screen = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
        guiFrame = Instance.new("Frame", screen)
        guiFrame.Position = UDim2.fromScale(0.5, 0.8)
        guiFrame.Size = UDim2.fromScale(0.1, 0.1)
    end)

    afterEach(function(x) 
        screen:Destroy()
        guiFrame:Destroy()
    end)
    

	it("xxx",function()
        local panel = require(game.ReplicatedStorage.Packages.UIManager.MessagePanel)
        
	end)
end