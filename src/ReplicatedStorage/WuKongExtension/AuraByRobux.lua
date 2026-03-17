local RagdollHelper = require(game.ReplicatedStorage.Helper.RagdollHelper)
local auraConfig = require(game.ReplicatedStorage._genConfigs.battle_tbaura)
local HttpService = game:GetService("HttpService")
local IS_SERVER = game:GetService("RunService"):IsServer()

--玩家R币购买特性
return function(userId, auraId)
    if not IS_SERVER then return end
	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
    if not auraId then return end
    local config = auraConfig[auraId]
    if not config then return end

     local ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
     if not ContainerHelper then return end

    local buyed = ContainerHelper.GetContainerValue(player.UserId, `属性`, `购买特性`)
    if not buyed then
        buyed = {}
    else
        buyed = HttpService:JSONDecode(buyed)
    end
    buyed[config.Name] = true
    ContainerHelper.SetContainerValue(player.UserId, `属性`, `购买特性`, HttpService:JSONEncode(buyed))
    --装备当前购买的特性
    facade:ExecuteAction("/属性/装备特性?属性设为指定值", id)
end
