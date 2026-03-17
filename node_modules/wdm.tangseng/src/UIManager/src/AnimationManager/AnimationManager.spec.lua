return function()

    local manager = require(script.Parent)
	it("ok on AnimationConfig",function()
        local config = {
            {
                ModuleScript = script.Parent,
                Options = {
                    Name = "TestModule",
                    Layer = 1,
                    AutoCloseAfter = 1,
                }
            }
        }
        local result = manager.__processConfigs(config)
		expect(#result).to.equal(1)
	end)

	it("ok on string member",function()
        local config = {
            "xxx"
        }
        local result = manager.__processConfigs(config)
		expect(#result).to.equal(1)
	end)

	it("ok on module script",function()
        local config = {
            script.Parent
        }
        local result = manager.__processConfigs(config)
		expect(#result).to.equal(1)
	end)

    it("not ok on other insance",function()
        local config = {
            Instance.new("Folder")
        }
		expect(function()
            local result = manager.__processConfigs(config)
        end).to.throw("invalid config")
	end)

    
    it("success init with string",function()
        local config = {
            "ReplicatedStorage.EventBus"
        }
        manager.Init(config)
        expect(manager.HasAnimation("EventBus")).to.equal(true)
	end)

    it("success init with modulescript",function()
        local config = {
            game.ReplicatedStorage.Packages.EventBus
        }
        manager.Init(config)
        expect(manager.HasAnimation("EventBus")).to.equal(true)
	end)
end