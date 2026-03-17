local module = {}
local versionCompare = require(script.Parent.VersionCompare)
local LoggerManager = require(game.ReplicatedStorage.Packages.LoggerManager)
local logger = LoggerManager.GetLogger("Migration")

export type MigrateModule = {
	ModuleName: string,
	Module: { Migrate: (userId: number) -> () },
}

local function getMigrationModules(lastMigrateVersion, allModules: { MigrateModule })
	local migrationModules = {}

	-- 比较版本号
	local function _needMigrate(targetVersion)
		if versionCompare(lastMigrateVersion, targetVersion) == -1 then
			return true
		end
		return false
	end

	-- 获取迁移
	local function _getMigrations()
		for i = #allModules, 1, -1 do
			local migrationModule = allModules[i]
			if _needMigrate(migrationModule.ModuleName) then
				table.insert(migrationModules, migrationModule)
			end
		end
	end
	_getMigrations()

	return migrationModules
end

module.StartMigrate = function(
	userId,
	setVerHandler,
	lastMigrateVersion,
	migrateModules: MigrateModule,
	facade,
	playerData
)
	local modules = getMigrationModules(lastMigrateVersion, migrateModules)
	for _, migrationModule in ipairs(modules) do
		local migration = migrationModule.Module
		local suc = pcall(function()
			logger.verbose(function()
				print("start migration " .. migrationModule.ModuleName)
			end)
			migration.Migrate(userId, facade, playerData)
		end)
		if suc then
			setVerHandler(migrationModule.ModuleName)
		else
			logger.Warn(function(name)
				print(name, "迁移失败", userId, migrationModule.ModuleName)
			end)
			-- todo ,kick
			break
		end
	end
end

return module
