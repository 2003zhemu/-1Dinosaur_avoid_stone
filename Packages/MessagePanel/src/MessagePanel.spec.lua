return function()

    local screen
    -- reset
    beforeEach(function(x) 
        screen = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
        screen.Name = "UnitTestGui"
    end)

    afterEach(function(x) 
        screen:Destroy()
    end)
    
	it("gui move test2",function()
        local panel = require(script.Parent:Clone())
        local vo = panel.GetViewObject()
        vo.Gui.Parent = screen
        vo.Open("test1")
        wait(3)
        vo.Open("test1")
        vo.Open("test1")
        vo.Open("test1")
        vo.Open("test1")
        wait(6)
	end)

end