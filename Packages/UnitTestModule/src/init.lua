--[=[
	@class UnitTestModule
	@server
	@client

	单元测试模块, 可以在服务端或者客户端进行单元测试.

	可以监听被测目录文件变更事件, 重新进行单元错误
]=]
local DebugOptions = require(game.ReplicatedStorage.Packages.DebugOptions)

local Rewire = require(game.ReplicatedStorage.Packages.rewire)
local reloader = Rewire.HotReloader.new()
local TestEZ = require(game.ReplicatedStorage.Packages.TestEZ)

local UnitTestModule = {}

--- 尝试启动单元测试
--- @return boolean --- 是否启动了单元测试
--- todo: 缓冲
function UnitTestModule.TryUnitTest(testFolders: {})
	-- 是否单元测试
	if DebugOptions.IsEnable("启用Studio单元测试") then
		if not testFolders or #testFolders == 0 then
			return
		end

		local function cloneSources(folders)
			local result = {}
			for k, v in pairs(folders) do
				result[k] = v:Clone()
				result[k].Parent = nil
			end
			return result
		end

		for k, v in pairs(testFolders) do
			reloader:scan(v, function(module)
				TestEZ.TestBootstrap:run(cloneSources(testFolders), TestEZ.Reporters.TextReporter)
			end, function() end)
		end
		return true
	end
end

return UnitTestModule
