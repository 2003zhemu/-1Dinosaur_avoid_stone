local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.Bootstarp

-- UI启动项
module.Starts = {
	"ReplicatedStorage.UI",
}

module.StartModules = {}

-- 组件包
-- default has：NezaUI.components2
module.Components = {
	--"ReplicatedStorage.MyComponents",
}

-- 预制体包
-- default has：ReplicatedStorage.UIPrefabs
module.Prefabs = {
	-- "ReplicatedStorage.Assets.uiprefabs",
}

-- 图集包
-- default has：ReplicatedStorage.SpriteSheets
module.SpriteSheets = {
	--"ReplicatedStorage.UI2.Pet.Model.mysprites",
	"ReplicatedStorage.Assets.sprites",
}
module.InputAdaptable = true

-- 启动时回调
module.OnBootstraped = function()
	print("Neza has been bootstrapped")
end

return module
