local module = {}

-- 设置传送数据
module.SetTeleportData = function(player: Player, data)
	if data then
		local json = game.HttpService:JSONEncode(data)
		player:SetAttribute("TeleportData", json)
	else
		player:SetAttribute("TeleportData", nil)
	end
end

-- 获取传送数据
module.GetTeleportData = function(player)
	local json = player:GetAttribute("TeleportData")
	if json then
		return game.HttpService:JSONDecode(json)
	else
		return nil
	end
end

-- 给传送数据打补丁，返回完整数据
module.PatchTeleportData = function(player, patch)
	assert(type(patch) == "table", "patch must be a table")

	local data = module.GetTeleportData(player)
	if not data then
		data = {}
	end

	for k, v in patch do
		data[k] = v
	end
	module.SetTeleportData(player, data)
	local json = game.HttpService:JSONEncode(data)

	player:SetAttribute("TeleportData", json)
end

return module
