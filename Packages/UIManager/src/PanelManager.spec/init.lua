
local module = {}
local defines = require(script.Parent.Defines)


local PanelManager = nil

local layerManager = nil

local PanelsValidator = nil

local defaultConfig:defines.DefaultPanelConfig = {
    FadeIn = -1,
    FadeOut= -1,
    Layer = 10
}

local tableUtil = require(game.ReplicatedStorage.Packages.Utils.TableUtil)

return function()
    

    -- reset
    beforeEach(function(x) 
        
        local folder = script.Parent:Clone()

        PanelManager = require(folder.PanelManager)

        PanelsValidator =require(folder.ConfigValidator.PanelsValidator)
        
        layerManager = require(folder.LayerManager)
    end)
    

    local PanelConfigs:defines.PanelConfigs ={
        "test1"
    }

    local layerConfigs:defines.LayerConfigs = {
        {
            Index=10,					
            Name="Layer1"					
        }
    }
    
    
	it("测试获取面板配置", function()
        PanelConfigs ={
            {
                Name="面板1",
                ModuleScript = script.Panel1
            },
        }

        PanelManager.Init(PanelConfigs,defaultConfig)
        
		local input = "面板1"
        
        local options = PanelManager.GetPanelOption(input)
        local valid,ero= PanelsValidator.ValidatePanelOption(options) 
        
		
		expect(valid).to.equal(true)

	end)
	
	it("测试获取面板配置(错误)", function()

        PanelManager.Init(PanelConfigs,defaultConfig)
		local input = 145154

		local valid,ero= PanelsValidator.ValidatePanelOption(PanelManager.GetPanelOption(input)) 

		expect(valid).to.equal(false)
	end)
	
	it("获取所有面板列表", function()
        
        local PanelConfigs:defines.PanelConfigs ={
            script.Panel1,
            script.Panel2
        }
        PanelManager.Init(PanelConfigs,defaultConfig)
		local panels=PanelManager.GetAllPanels()
		local suc =false
		local list ={
			"Panel1",
			"Panel2",
			
		}

        expect(tableUtil.IsShallowEqual(list,panels)).to.equal(true)
	end)
	
	
	it("测试已激活面板列表（未打开面板）", function()
        local PanelConfigs:defines.PanelConfigs ={
            script.Panel1
        }
        PanelManager.Init(PanelConfigs,defaultConfig)
        

        local valid= PanelManager.GetActivePanels()
		
		expect(#valid).to.equal(0)
	end)
	
	it("测试已激活面板列表（层数不存在错误）", function()

        PanelManager.Init(PanelConfigs,defaultConfig)
		local input = 1456987541 -- 层数不存在错误


        expect(function()
                PanelManager.GetActivePanels(input)
        end)
            .to.throw()
	end)
    
    
    
    it("测试已激活面板列表", function()
        
        local layerConfigs:defines.LayerConfigs = {
            {
                Index=10,					
                Name="Layer1"					
            }
        }
        
        local PanelConfigs:defines.PanelConfigs ={
            script.Panel1
        }
        
        PanelManager.Init(PanelConfigs,defaultConfig)
        
        layerManager.Init(layerConfigs)
        
		
        PanelManager.OpenPanel("Panel1")
		
        local valid= PanelManager.GetActivePanels()
		
		expect(#valid).to.equal(1)
	end)
	
	it("测试同层互斥", function()
        
        local PanelConfigs:defines.PanelConfigs ={
            script.Panel1,
            script.Panel2
        }
        
        PanelManager.Init(PanelConfigs,defaultConfig)

        layerManager.Init(layerConfigs)

		local input = 1
		
        PanelManager.OpenPanel("Panel1")
		
        PanelManager.OpenPanel("Panel2")
		
        local valid= PanelManager.GetActivePanels()
		
		
		expect(#valid).to.equal(1)
	end)

	it("测试已激活面板列表（参数为string）", function()


        local layerConfigs:defines.LayerConfigs = {
            {
                Index=10,					
                Name="Layer1"					
            }
        }

        local PanelConfigs:defines.PanelConfigs ={
            script.Panel1
        }

        PanelManager.Init(PanelConfigs,defaultConfig)

        layerManager.Init(layerConfigs)


        PanelManager.OpenPanel("Panel1")

        local valid= PanelManager.GetActivePanels("Layer1")

        expect(#valid).to.equal(1)
	end)
	
	
	it("清空指定层级（参数为string）", function()

        local layerConfigs:defines.LayerConfigs = {
            {
                Index=10,					
                Name="Layer1"					
            }
        }

        local PanelConfigs:defines.PanelConfigs ={
            script.Panel1
        }

        PanelManager.Init(PanelConfigs,defaultConfig)

        layerManager.Init(layerConfigs)
        

        PanelManager.OpenPanel("Panel1")
		
        PanelManager.ClearLayer("Layer1")
		
        local valid= table.maxn(PanelManager.GetActivePanels("Layer1")) 
		
		expect(valid).to.equal(0)
	end)
	
	it("清空指定层级（参数为num）", function()

        local layerConfigs:defines.LayerConfigs = {
            {
                Index=10,					
                Name="Layer1"					
            }
        }

        local PanelConfigs:defines.PanelConfigs ={
            script.Panel1
        }

        PanelManager.Init(PanelConfigs,defaultConfig)

        layerManager.Init(layerConfigs)


        PanelManager.OpenPanel("Panel1")

        PanelManager.ClearLayer(10)

        local valid= table.maxn(PanelManager.GetActivePanels(10)) 

        expect(valid).to.equal(0)
	end)
	
	it("打开指定面板（错误）", function()

        PanelManager.Init(PanelConfigs,defaultConfig)
		local input =56141654


        expect(function()

            PanelManager.OpenPanel(input)
        end
        ).to.throw()
	end)

    it("打开瞬时面板，并自动关闭", function()

        local layerConfigs:defines.LayerConfigs = {
            {
                Index=10,					
                Name="Layer1",
                Mode = "multiple" 
            }
        }

        local PanelConfigs:defines.PanelConfigs ={
            {
                ModuleScript = script.Panel1,
                AutoCloseAfter = 0.1
            }
        }

        PanelManager.Init(PanelConfigs,defaultConfig)

        layerManager.Init(layerConfigs)


        PanelManager.OpenPanel("Panel1")


        expect(#PanelManager.GetActivePanels()).to.equal(1)
        
        wait(0.11)
        

        expect(#PanelManager.GetActivePanels()).to.equal(0)
	end)
	

	it("打开瞬时面板，并自动关闭(2)", function()

		local layerConfigs:defines.LayerConfigs = {
			{
				Index=10,					
				Name="Layer1",
				Mode = "multiple" 
			}
		}

		local PanelConfigs:defines.PanelConfigs ={
			{
				ModuleScript = script.Panel1,
				AutoCloseAfter = 0.1
			}
		}

		PanelManager.Init(PanelConfigs,defaultConfig)

		layerManager.Init(layerConfigs)


		PanelManager.OpenPanel("Panel1")

		PanelManager.OpenPanel("Panel1")

		expect(#PanelManager.GetActivePanels()).to.equal(2)

		wait(0.11)


		expect(#PanelManager.GetActivePanels()).to.equal(0)
	end)
end
