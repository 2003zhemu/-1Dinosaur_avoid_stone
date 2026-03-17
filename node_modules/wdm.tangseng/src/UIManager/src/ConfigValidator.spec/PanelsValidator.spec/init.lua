


local defines = require(script.Parent.Parent.Defines)

return function()
	local panelsValidator = require(script.Parent.Parent.ConfigValidator.PanelsValidator)

	it("验证Name的类型为字符串", function()

		-- 定义测试数据 
		local input = {
			Name = 123  
		}
		
		-- 调用校验函数
		local valid, msg = panelsValidator.ValidatePanelOption(input)

		-- 断言校验结果  
		expect(valid).to.equal(false)
	end)
	
	-- add
	it("验证Layer的类型为string", function()

		local input = {
			Layer = "1"
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end)
	-- update
	it("验证Layer的类型为数值", function()

		local input = {
			Layer = false
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)
		
	it("验证Layer的值在有效范围内", function()

		local input = {
			Layer = -1 -- Layer为负数
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(false)
	end)

	it("验证FadeIn = 10 时,只能为-1 test1", function()

		local input = {
			FadeIn = 10 -- FadeIn为10
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)

	it("验证FadeIn = -1 时,只能为-1", function()

		local input = {
			FadeIn = -1 -- FadeIn为-1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end)
	
	it("验证FadeIn的类型为字符串", function()

		local input = {
			FadeIn = "fadeIn" 
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end)

	it("验证FadeIn的类型为表", function()

		local input = {
			FadeIn = {}
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end) 

	it("验证FadeIn的类型为nil", function()

		local input = {
			FadeIn = nil
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end)

	it("验证FadeIn数值范围", function()

		local input = {
			FadeIn = -10
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)
	
	it("验证FadeIn 类型只能为 number?|string?|AnimationOptions? ", function()

		local input = {
			FadeIn = true
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)
	

	it("验证FadeOut为数值(10)时,只能为-1", function()

		local input = {
			FadeOut = 10
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)

	it("验证FadeOut为数值(-1)时,只能为-1", function()

		local input = {
			FadeOut = -1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end)

	it("验证FadeOut数值范围", function()

		local input = {
			FadeOut = -10
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)
	
	it("验证FadeOut 类型只能为 number?|string?|AnimationOptions? ", function()

		local input = {
			FadeOut = false
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)

	it("验证IsModal的类型为布尔", function()

		local input = {
			IsModal = "1" 
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
		
	end)

	it("验证IsModal 值范围必须是 true 或者 false", function()

		local input = {
			IsModal = true
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end)
	
	it("验证FadeOut的类型为字符串", function()

		local input = {
			FadeOut = "fadeOut"
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true) 

	end)

	it("验证FadeOut的类型为表", function()

		local input = {
			FadeOut = {}
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证FadeOut的类型为nil", function()

		local input = {
			FadeOut = nil
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)
	
	it("验证PrevFadeOut为数值(1)时,只能为-1", function()

		local input = {
			PrevFadeOut = 1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
		
	end)

	it("验证PrevFadeOut为数值(-1)时,只能为-1", function()

		local input = {
			PrevFadeOut = -1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证PrevFadeOut的类型为字符串", function()

		local input = {
			PrevFadeOut = "fadeOut"
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证PrevFadeOut的类型为表", function()

		local input = {
			PrevFadeOut = {}
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证PrevFadeOut的类型为nil", function()

		local input = {
			PrevFadeOut = nil
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证PrevFadeOut数值范围,只能为-1", function()

		local input = {
			PrevFadeOut = -10 
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	
	end)
	
	it("验证 PrevFadeOut 类型只能为 number?|string?|AnimationOptions? ", function()
		local input = {
			PrevFadeOut = false
		}
		local valid, msg = panelsValidator.ValidatePanelOption(input)
		expect(valid).to.equal(false)
	end)
	
	it("验证NextFadeIn为数值(1)时,只能为-1", function()

		local input = {
			NextFadeIn = 1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)

	it("验证NextFadeIn为数值(-1)时,只能为-1", function()

		local input = {
			NextFadeIn = -1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证NextFadeIn的类型为字符串", function()

		local input = {
			NextFadeIn = "fadeOut"
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证NextFadeIn的类型为表", function()

		local input = {
			NextFadeIn = {}
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证NextFadeIn的类型为nil", function()

		local input = {
			PrevFadeOut = nil
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)

	end)

	it("验证NextFadeIn数值(-10)范围,只能为-1", function()

		local input = {
			NextFadeIn = -10 
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)

	end)

	it("验证 NextFadeIn 类型只能为 number?|string?|AnimationOptions? ", function()
		local input = {
			FadeIn = false
		}
		local valid, msg = panelsValidator.ValidatePanelOption(input)
		expect(valid).to.equal(false)
		--.to.contain("type NextFadeIn must be number or string or AnimationOptions")
	end)
	
	it("验证 AutoCloseAfter 的类型为数值", function()

		local input = {
			AutoCloseAfter = "1"
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)

	end)
	it("验证 AutoCloseAfter 的值(-1)在有效范围内", function()

		local input = {
			AutoCloseAfter = -1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(false)

	end)
	it("验证 AutoCloseAfter 的值(0)在有效范围内", function()

		local input = {
			AutoCloseAfter = 0
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	it("验证 AutoCloseAfter  的值(1.32)在有效范围内", function()

		local input = {
			AutoCloseAfter = 1.32
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	
	it("验证 Context  的值nil", function()

		local input = {
			Context = nil
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	it("验证 Context  的值 any:string ", function()

		local input = {
			Context = "12"
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	it("验证 Context  的值 any:number ", function()

		local input = {
			Context = 12
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	it("验证 Context  的值 any:bool ", function()

		local input = {
			Context = false
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	
	it("验证 Next  的值 nil ", function()

		local input = {
			Next = nil
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	it("验证 Next  的值 PanelOptions(错误值) ", function()
		local Next1:defines.PanelOptions = {
			Name=123,
			Layer=1,
			FadeIn=1,
			FadeOut=-1,	
		}
		
		local input = {
			Next=Next1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	
	it("验证 Next  的值 PanelOptions ", function()
		local Next1:defines.PanelOptions = {
			Name=123,
			Layer=1,
			FadeIn=-1,
			FadeOut =-1,	
		}

		local input = {
			Next=Next1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)  

		expect(valid).to.equal(true)
	end)
	
	
	-- add: 验证 Layer == 1 在 defines.LayerConfigs中
	it("验证 Layer == 1 在 defines.LayerConfigs中", function()

		local input = {
			Layer = 1
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end)

	-- add: 验证 Layer == '1' 在 defines.LayerConfigs中
	it("验证 Layer == '1' 在 defines.LayerConfigs中", function()

		local input = {
			Layer = '1'
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(true)
	end)
	
	-- add: 验证 Layer == "inexistent" 不在 defines.LayerConfigs中 
	it("验证 Layer == 'inexistent' 不在 defines.LayerConfigs中", function()

		local input = {
			Layer = "inexistent"
		}

		local valid, msg = panelsValidator.ValidatePanelOption(input)

		expect(valid).to.equal(false)
	end)
	
	-- add: 验证 FadeIn = 1 在 defines.AnimationConfigs 中 expect(valid).to.equal(true)
	-- add: 验证 FadeIn = "1" 在 defines.AnimationConfigs 中 expect(valid).to.equal(true)
	-- add: 验证 FadeIn = AnimationOptions 在 defines.AnimationConfigs 中 expect(valid).to.equal(true)
	-- add: 验证 FadeIn = 10086 不在 defines.AnimationConfigs 中  expect(valid).to.equal(false)
	-- add: 验证 FadeIn = "10086" 不在 defines.AnimationConfigs 中  expect(valid).to.equal(false)
	-- add: 验证 FadeIn = AnimationOptions 不在 defines.AnimationConfigs 中  expect(valid).to.equal(false)
	
	-- add: 验证 FadeOut = 2 在 defines.AnimationConfigs 中 expect(valid).to.equal(true)
	-- add: 验证 FadeOut = "2" 在 defines.AnimationConfigs 中 expect(valid).to.equal(true)
	-- add: 验证 FadeOut = AnimationOptions 在 defines.AnimationConfigs 中 expect(valid).to.equal(true)
	-- add: 验证 FadeOut = 100862 不在 defines.AnimationConfigs 中  expect(valid).to.equal(false)
	-- add: 验证 FadeOut = "100862" 不在 defines.AnimationConfigs 中  expect(valid).to.equal(false)
	-- add: 验证 FadeOut = AnimationOptions 不在 defines.AnimationConfigs 中  expect(valid).to.equal(false)
	
	-- ----ValidatePanelConfig-----------------------------------------
	it("验证 ModuleScript 所指脚本: 存在", function()

		local input:defines.PanelConfig = {
			ModuleScript = script.Test_ModuleScript
		}

		local valid, msg = panelsValidator.ValidatePanelConfig(input)

		expect(valid).to.equal(true)
	end)
	
	it("验证 ModuleScript 所指脚本: 不存在", function()

		local input:defines.PanelConfig = {
			ModuleScript = script.Test_ModuleScript2
		}

		local valid, msg = panelsValidator.ValidatePanelConfig(input)

		expect(valid).to.equal(false)
	end)
	
	it("验证 Name 值->是<-中文的", function()

		local input:defines.PanelConfig = {
			Name = "是中文名"
		}

		local valid, msg = panelsValidator.ValidatePanelConfig(input)

		expect(valid).to.equal(false)
	end)
	
	it("验证 Name 值->不是<-中文的", function()

		local input:defines.PanelConfig = {
			Name = "Not Chinese characters"
		}

		local valid, msg = panelsValidator.ValidatePanelConfig(input)

		expect(valid).to.equal(false)
	end)
	
	it("验证 PanelOptions 中 Layer 的 值既不是数字也不是字符串", function()

		local input:defines.PanelConfig = {
			Layer = false
		}

		local valid, msg = panelsValidator.ValidatePanelConfig(input)

		expect(valid).to.equal(false)
	end)
	

	it("验证 PanelOptions 中 Layer 的值类型是数字", function()

		local input:defines.PanelConfig = {
			Layer = 10
		}

		local valid, msg = panelsValidator.ValidatePanelConfig(input)

		expect(valid).to.equal(true)
	end)
	
	it("验证 PanelOptions 中 Layer 的值类型是string", function()

		local input:defines.PanelConfig = {
			Layer = "test_str"
		}

		local valid, msg = panelsValidator.ValidatePanelConfig(input)

		expect(valid).to.equal(true)
	end)
end

