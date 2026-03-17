local module = {}

local adminWindow = require(game.ReplicatedStorage.Packages.AdminModule.Client.AdminWindow)

local isStudio = game:GetService("RunService"):IsStudio()

local devUserId = game.Players.LocalPlayer.UserId

wait(1)

local devRoot = game.ReplicatedStorage:WaitForChild("__developer", 3)

if not devRoot then
	warn("虽然启用了 DeveloperModule,但是未在 ReplicatedStorage 中发现 '__developer' 目录 ")
	return {}
end

local function _getDevFolder()
	for k, v: Instance in devRoot:GetChildren() do
		if v.Name == tostring(devUserId) then
			return v
		end
	end
end

local devFolder = _getDevFolder()

local function _requireModule(ins: Instance)
	if ins.ClassName ~= "ModuleScript" then
		return
	end

	local success, resp = pcall(function()
		return require(ins)
	end)

	if not success then
		local parent = ins.Parent
		warn("加载客户端开发模块失败:" .. parent.Name .. "\\" .. ins.Name)
		return
	end

	-- 添加模块的方法到管理员窗口
	for k, v in pairs(resp) do
		adminWindow.AddTestFunc(k, v)
	end
end

-- dev folder for cur developer
if devFolder then
	for k, v in pairs(devFolder:GetChildren()) do
		_requireModule(v)
	end
end

-- shard dev folder
local shareFolder = devRoot:FindFirstChild("__shared")
if shareFolder then
	for k, v in pairs(shareFolder:GetChildren()) do
		_requireModule(v)
	end
end

return module