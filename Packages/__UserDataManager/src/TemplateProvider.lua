-- 从 Configs/UserDateTemplate ModuleScript中，读取模板配置，如果不存在，则返回空表
local module = {}

local deepClone = require(game.ReplicatedStorage.Packages.Utils.TableUtil).DeepClone

module.GetTemplate = function()
	local source = require(script.Parent.UserDataTemplateConfig).UserDateTemplate
	local template = deepClone(source)

	assert(not template.Container, "用户数据模板中，不得包含'Container'成员")

	template.Container = false

	template.CreateTime = os.time()

	return {}
end

return module
