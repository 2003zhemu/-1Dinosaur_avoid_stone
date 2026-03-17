--[=[
	@class AdminModule
	@server
	@client

	管理员模块

]=]

local AdminModule = {}

local module = {}

if game["Run Service"]:IsServer() then
	module = require(script.Server)
else
	module = require(script.Client)
end

--- 是否为管理员
function AdminModule.IsAdmin (player: Player)
	if game["Run Service"]:IsStudio() then
		return true
	end

	return module.IsAdmin(player)
end


return AdminModule
