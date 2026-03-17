local Players = game:GetService("Players")

local LoggerManager = require(game.ReplicatedStorage.Packages.LoggerManager)
local logger = LoggerManager.GetLogger("Migration")
local WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)

local UserDatas = require(script.Parent.UserDatas)
local MigrationConfig = require(script.Parent.MigrationConfig)

-- 加载模块
local loader = require(game.ReplicatedStorage.Packages.ModuleLoader)
local allMigrationModules = loader.LoadModules(MigrationConfig.Migrations)

local module = {}

local function PlayerAdded(player)
	local userId = player.UserId
	local facade = WuKongServer.WaitFacade(userId)

	-- 获取 wukong facade
	if not facade then
		return
	end

	---- 获取legacy 的用户数据
	--local playerData
	--repeat
	--	playerData = game.ReplicatedStorage.PlayerData:FindFirstChild(player.Name)
	--	if not playerData then
	--		wait()
	--	end
	--until playerData or not player:IsDescendantOf(game.Players)
	--if not playerData then
	--	return
	--end

	local userData = UserDatas.GetData(userId)
	if not userData then
		return logger.Info(function(name)
			print(name, "没有找到用户数据", userId)
		end)
	end

	local Migrate = require(script.Parent.Migrate)

	-- 迁移逻辑
	local setVerHandler = function(ver)
		userData.Data.MigrationVersion = ver
	end
	local lastMigrateVersion = userData.Data.MigrationVersion
	Migrate.StartMigrate(userId, setVerHandler, lastMigrateVersion, allMigrationModules, facade, playerData)
end

for _, player in pairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

type PlayerConfig = {
	UserId: number,
}

module.RunPlayerConfigTest = function(config: PlayerConfig)
	PlayerAdded(config)
end

return module