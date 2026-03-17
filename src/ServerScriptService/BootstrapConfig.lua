local RunService = game:GetService("RunService")
-- 样例，不同步

local module = {}
-- 模块配置源，数组成员为容纳配置的目录
module.ModuleConfigSources = {
	game.ReplicatedStorage.Configs,
}

-- 是否加载悟空
module.IsRequireWuKong = false

-- 模块启动后回调
module.OnBootstraped = function()
	task.spawn(function()
		local MarketplaceService = game:WaitForChild("MarketplaceService")
		local PurchaseHandler = require(game.ReplicatedStorage.WuKong.WuKongServer.PurchaseHandler)
		local GA = require(game.ReplicatedStorage.Packages.GameAnalytics)
		MarketplaceService.ProcessReceipt = function(receiptInfo)
			local result = PurchaseHandler.onProcessReceipt(receiptInfo)	
			if result == Enum.ProductPurchaseDecision.PurchaseGranted then
				task.spawn(GA.ProcessReceiptCallback, GA, receiptInfo)
			end
			return result
		end
	end)

	require(game.ReplicatedStorage.WuKong.WuKongDebugger):SetAdminCheckingHandler(function(userId)
		if RunService:IsStudio() then
			return true
		end
	end)

	local UserDataManager = require(game.ReplicatedStorage.Packages.UserDataManager)
	require(game.ReplicatedStorage.Packages.AwardInviteService).SetDataProvider(function(userId)
		return UserDataManager.GetData(userId)
	end)
end

-- 模块列表
module.ModuleScripts = {

	-- 核心
	--"ReplicatedStorage.Packages.AntiOfflineModule", -- 防掉线模块
	"ReplicatedStorage.Packages.UserDataManager", -- 用户数据模块
	-- "ReplicatedStorage.Packages.ProcedureModule", -- 流程模块
	--"ReplicatedStorage.Packages.Migration",

	-- 管理系统
	--"ReplicatedStorage.Packages.AdminModule",
	-- 邀请系统
	--"ReplicatedStorage.Packages.AwardInviteService",
}

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module, script.Name)

return module
