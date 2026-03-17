-- by: CatchMoon
-- 游戏资产管理:
--  1. 获取游戏资产

local rs = game:GetService("ReplicatedStorage")

local AssetsFolder = rs:WaitForChild("Assets")

local AssertsUtil = {}

-- 按名称获取资源, path的根路径为game.ReplicatedStorade.Assets
function AssertsUtil.GetAssetsByName(path: string, assetsName: string): Model
	return AssetsFolder:WaitForChild(path):WaitForChild(assetsName)
end

return AssertsUtil