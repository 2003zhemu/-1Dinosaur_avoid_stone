local RunService = game:GetService("RunService")
local WuKongHelper = require(game.ReplicatedStorage.WuKong.WuKongHelper)
local module = {}
local wukong = nil

module.Getfacade = function(userid)
	local facade
	if RunService:IsClient() then
		if not wukong then
			wukong = require(game.ReplicatedStorage.WuKong)
		end
		facade = wukong
	elseif RunService:IsServer() then
		if not wukong then
			wukong = require(game.ReplicatedStorage.WuKong.WuKongServer)
		end
		if not wukong.HasFacade(userid) then
			return
		end
		facade = wukong.GetFacade(userid)
		if not facade then
			return
		end
	end
	return facade
end

module.SetContainerValue = function(userid, containerName, key, value)
	local facade = module.Getfacade(userid)
	if not facade then
		return
	end
	local Container = facade:GetContainer()
	if not Container._containers[containerName] then
		error("Container not found: " .. containerName)
		return
	end
	WuKongHelper.SetPluginValue(Container._containers[containerName], key, value)
end

module.GetContainerValue = function(userid, containerName, key)
	local facade = module.Getfacade(userid)
	if not facade then
		return
	end
	local Container = facade:GetContainer()
	if not Container or not Container._containers[containerName] then
		error("Container not found: " .. containerName)
		return
	end
	return WuKongHelper.TryGetPluginValue(Container._containers[containerName], key)
end

return module
