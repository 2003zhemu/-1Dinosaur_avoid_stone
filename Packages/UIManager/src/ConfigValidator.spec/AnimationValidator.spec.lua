
local defines = require(script.Parent.Parent.Defines)


return function()
	-- local animationValidator = require(script.Parent.Parent.ConfigValidator.AnimationValidator)
	
	-- 一个配置通过测试
	--it("No.1 一个配置通过测试",function()
	--	-- 准备数据
	--	local str = "test1"
	--	local ModuleScriptName = ""
	--	local layers_Options:defines.AnimationOptions = {
	--		--Name = "Name_Animation1",Context = 1,
	--	}
		
	--	local layers_Config:defines.AnimationConfig = {ModuleScript="ModuleScript_1"} and layers_Options
	--	local layers_Configs:defines.AnimationConfigs = {
	--		{str},
	--		{layers_Config}
	--	}

	--	-- 测试业务
	--	local success,errorMessage =  animationValidator.Validate_Configs(layers_Configs)

	--	-- 断言
	--	expect(success).to.equal(true)
	--	warn("一个配置通过 --> ", errorMessage)
	--end)
	
	-- AnimationOptions 的 ModuleScript 对应的类型不对 既不是 ModuleScript 也不是 string
		
	-- AnimationOptions 的 Name 既不是 string 类型 也不为 空, 比如传入一个 数字 布尔值等
	
	

end