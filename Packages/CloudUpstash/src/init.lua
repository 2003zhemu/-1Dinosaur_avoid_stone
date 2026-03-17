local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Store = require(script.Store)
local Interface = require(script.Interface)

type ICloudUpstashStore = Interface.ICloudUpstashStore
type ICloudUpstash = Interface.ICloudUpstash

--[=[
    @class CloudUpstash
    云存储服务实现类
]=]
local CloudUpstash = {}
CloudUpstash.__index = CloudUpstash

-- 存储所有已创建的store实例
local stores: { [string]: ICloudUpstashStore } = {}
-- 记录正在创建中的store
local creatingStores: { [string]: boolean } = {}

-- CloudUpstash实现
function CloudUpstash.CreateStore(storeName: string, endpoint: string, pass: string)
	if RunService:IsClient() then
		error("Store can only be created on the server")
	end
	-- 检查是否已存在同名store
	if stores[storeName] then
		error("Store already exists: " .. storeName)
	end
	-- 创建新的store实例
	stores[storeName] = Store.new(endpoint, pass)
end

function CloudUpstash.CreateStoreBySecretAsync(storeName: string, secretKeyEndpoint: string, secretKeyPass: string)
	-- 检查是否已存在同名store
	if stores[storeName] then
		error("Store already exists: " .. storeName)
	end

	-- 标记为创建中
	creatingStores[storeName] = true

	-- 异步创建store
	task.spawn(function()
		-- 从Secrets获取endpoint
		local success, endpoint = pcall(function()
			return HttpService:GetSecret(secretKeyEndpoint)
		end)

		-- 从Secrets获取pass
		local success2, pass = pcall(function()
			return HttpService:GetSecret(secretKeyPass)
		end)

		-- 如果获取成功则创建store
		if success and success2 and endpoint and pass then
			stores[storeName] = Store.new(endpoint, pass)
		else
			warn("初始化云存储失败 - 无法获取密钥")
		end

		-- 标记创建完成
		creatingStores[storeName] = false
	end)
end

-- 检查指定名称的store是否存在
function CloudUpstash.HasStore(storeName: string): boolean
	return stores[storeName] ~= nil
end

-- 检查指定名称的store是否正在创建中
function CloudUpstash.IsStoreCreating(storeName: string): boolean
	return creatingStores[storeName] == true
end

-- 获取指定名称的store实例
function CloudUpstash.GetStore(storeName: string): ICloudUpstashStore?
	return stores[storeName]
end

return CloudUpstash
