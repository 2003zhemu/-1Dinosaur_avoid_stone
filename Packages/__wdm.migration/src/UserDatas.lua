local module = {}

module.UserDataProvider = require(script.Parent.MigrationConfig).UserDataProvider

module.GetData = function(userId: number)
	return module.UserDataProvider and module.UserDataProvider(userId) or nil
end

return module
