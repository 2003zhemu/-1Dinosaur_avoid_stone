local module = {}

local ProfileService = require(script.Parent.ProfileService)

local template = require(script.Parent.TemplateProvider).GetTemplate()

local config = require(script.Parent.UserDataStoreConfig)

module.GetStore = function()
	local name = ""

	name = config.ProductStore.Name

	return ProfileService.GetProfileStore(name, template)
end

return module
