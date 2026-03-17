local RunService = game:GetService("RunService")
local module = {}
local debug = false
local pool = {}
if RunService:IsServer() then
	warn("Server call view assets,TODO: fixed")
	return
end
--TODO: 自动根据文件夹名字生成
local Assets: Folder = game.ReplicatedStorage.Assets
local AssetSpawnFolder = Instance.new("Folder", game.Workspace)
AssetSpawnFolder.Name = "Assets"
local UnitSpawnFolder = Instance.new("Folder", AssetSpawnFolder)
UnitSpawnFolder.Name = "Units"
local UISpawnFolder = Instance.new("Folder", AssetSpawnFolder)
UISpawnFolder.Name = "UI"
local EffectSpawnFolder = Instance.new("Folder", AssetSpawnFolder)
EffectSpawnFolder.Name = "Effect"
local RoomSpawnFolder = Instance.new("Folder", AssetSpawnFolder)
RoomSpawnFolder.Name = "Room"
local objectFolder = Instance.new("Folder", AssetSpawnFolder)
objectFolder.Name = "Object"

local AssetConfig = {
	Unit = {
		AssetFolder = Assets.Unit,
		SpawnFolder = UnitSpawnFolder,
	},
	UI = {
		AssetFolder = Assets.UI,
		SpawnFolder = UISpawnFolder,
	},
	Effect = {
		AssetFolder = Assets.Effect,
		SpawnFolder = EffectSpawnFolder,
	}
}

local AssetCache = {}
for assetType, assetTypeConfig in AssetConfig do
	AssetCache[assetType] = {}
	for _, assetTemplate in pairs(assetTypeConfig.AssetFolder:GetChildren()) do
		AssetCache[assetType][assetTemplate.Name] = assetTemplate
	end
end

local markPoolItem = function(asset, poolName, subName)
	asset:SetAttribute("PoolName", poolName)
	asset:SetAttribute("AssetName", subName)
end

local getPoolItem = function(poolName, assetName)
	if pool[poolName] == nil then
		pool[poolName] = {}
	end
	if pool[poolName][assetName] == nil then
		pool[poolName][assetName] = {}
	end
	local item = nil
	if #pool[poolName][assetName] > 0 then
		if debug then
			print("getPoolItem", poolName, assetName, #pool[poolName][assetName])
		end
		item = table.remove(pool[poolName][assetName])
	else
		local asset = AssetCache[poolName][assetName]
		if asset == nil then
			warn(`not exit pool[{poolName}] asset[{assetName}] `)
			return nil
		end
		item = asset:Clone()
		markPoolItem(item, poolName, assetName)
		if debug then
			print("getPoolItem", poolName, assetName, "new")
		end
	end
	item.Parent = AssetConfig[poolName].SpawnFolder
	return item
end
-- TODO:

module.GetAsset = function(poolName: "Effect"|"Room"|"Unit" | "DamageIndicator" | "UI", assetName: string)
	return getPoolItem(poolName, assetName)
end

module.Return = function(asset)
	if asset.Parent == nil then
		warn("may be return asset to pool twice", asset.Name)
	end
	local poolName = asset:GetAttribute("PoolName")
	local assetName = asset:GetAttribute("AssetName")
	if poolName == nil or assetName == nil then
		warn(`try return not pool item {asset.Name}`)
		return
	end

	table.insert(pool[poolName][assetName], asset)
	if debug then
		print("returnPoolItem", poolName, assetName, #pool[poolName][assetName])
	end
	asset.Parent = nil
end

return module
