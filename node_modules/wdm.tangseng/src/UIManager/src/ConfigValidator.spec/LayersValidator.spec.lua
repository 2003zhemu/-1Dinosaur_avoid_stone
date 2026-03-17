
local defines = require(script.Parent.Parent.Defines)

return function()
	local layersValidator = require(script.Parent.Parent.ConfigValidator.LayersValidator)

	-- 一个配置通过
	it("一个配置通过",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=10,Name="test", Mode="multiple"}
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(true)
		warn("一个配置通过 --> ", errorMessage)
	end)

	-- Index 不得重复
	it("Index 不得重复",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=10,Name="test1"},
			{Index=10,Name="test2"}
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)

	-- Index 不能是浮点型数字 
	it("Index 不能是浮点型数字",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=1.11,Name="test1.11"},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)


	-- Index 不能为空
	it("Index 不能为空test1 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Name="test-10086"},
		}
		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)
		-- 断言
		expect(success).to.equal(false)
	end)
	it("Index 不能为nil test2 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=nil,Name="test-10086"},
		}
		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)
		-- 断言
		expect(success).to.equal(false)
	end)

	-- Name 不得重复
	it("Name 不得重复 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=1,Name="test0"},
			{Index=2,Name="test0"},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)

	-- Name 不能为空
	it("Name 不能为空 test1 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=1},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)
	it("Name 不能为空 test2 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=1, Name=""},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)

	-- Mode 指定类型错误 既不是 "single" 也不是 "multiple"
	it("Mode 指定类型错误 test1 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=1,Name="test1", Mode="testMode"},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)
	it("Mode 指定类型错误 test2 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=1,Name="test1", Mode=123},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)

	-- Index 不能为 string 
	it("Index 不能为string ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index="1",Name="test0"},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)

	-- Index 不能为bool值
	it("Index 不能为bool值 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=false,Name="test0"},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)

	-- Name 不能为 number	
	it("Name 不能为 number ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=1,Name=10086.1},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)

	-- Name 不能为 bool值
	it("Name 不能为 bool 值 ",function()
		-- 准备数据
		local layers:defines.LayerConfigs = {
			{Index=1,Name=false},
		}

		-- 测试业务
		local success,errorMessage =  layersValidator.Validate(layers)

		-- 断言
		expect(success).to.equal(false)
	end)

end
