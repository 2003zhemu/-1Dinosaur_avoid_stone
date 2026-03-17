local module = {}

local LoggerManager = require(game.ReplicatedStorage.Packages.LoggerManager)
local logger = LoggerManager.GetLogger("ModuleLoader")

local function _loadModule(instance)
	logger.Verbose(function(name)
		print(name, "开始加载模块:" .. instance.Name)
	end)

	local start = os.clock()

	-- 超时检查
	local isFinish = false
	task.spawn(function()
		while not isFinish do
			wait(2)

			local cur = os.clock()
			if cur - start > 5 and not isFinish then
				warn("加载模块超时:" .. instance.Name)
			end
		end
	end)

	-- 加载模块
	local success, result = pcall(function()
		return require(instance)
	end)

	isFinish = true
	local endd = os.clock()

	if success then
		-- print("加载模块成功:"..instance.Name..",耗时:"..(endd-start))
		logger.Verbose(function(name)
			print(name, "加载模块成功:" .. instance.Name .. ",耗时:" .. (endd - start))
		end)
		return result
	else
		logger.warn(function(name)
			warn(name, "加载模块失败:" .. instance.Name .. ",耗时:" .. (endd - start))
		end)
		error(instance.Name .. " :" .. result)
	end
end

module.LoadAllModules = function(root: Instance, result)
	for k, ins in pairs(root:GetChildren()) do
		if ins.ClassName == "Folder" then
			module.LoadAllModules(ins, result)
			return
		end

		if ins.ClassName ~= "ModuleScript" then
			continue
		end

		if result[ins.Name] then
			error("模块已经被加载了:" .. ins.Name)
		end

		task.spawn(function()
			local tmp = _loadModule(ins)

			result[ins.Name] = tmp
		end)
	end
end

module.LoadModules = function(
	modules: { string | ModuleScript },
	result
): {
	{
		ModuleName: string,
		Module: any,
	}
}
	local loadedCount = 0
	for index, v in pairs(modules) do
		local ins = nil

		if type(v) == "string" then
			local segments = string.split(v, ".")
			for k2, v2 in pairs(segments) do
				if k2 == 1 then
					ins = game[v2]
				else
					ins = ins:WaitForChild(v2)
				end

				if k2 ~= #segments then
					continue
				end
			end
		else
			ins = v
		end

		task.spawn(function()
			local tmp = _loadModule(ins)
			assert(tmp)
			result[index] = {
				ModuleName = ins.Name,
				Module = tmp,
			}
			loadedCount = loadedCount + 1
		end)
	end

	while true do
		task.wait()
		if #modules == loadedCount then
			return
		end
	end
end

return module
