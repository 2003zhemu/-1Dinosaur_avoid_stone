local RagdollHelper = require(game.ReplicatedStorage.Helper.RagdollHelper)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local Follow = require(game.ReplicatedStorage.Modules.Follow)
--玩家购买复活
return function(userId)
	local player = game.Players:GetPlayerByUserId(userId)
	if not player then
		return
	end
	RagdollHelper.DisableRagdoll(player)
	Follow.UpdateFollowPlayers(player)
	task.wait()
	--回到关卡起点
	local curStage = player:GetAttribute("InStage")
	local goCFrame = Defines.RespawnCFrames[curStage]
	if goCFrame and player.Character then
		local rootPart = player.Character.PrimaryPart or player.Character:FindFirstChild("HumanoidRootPart")
		if rootPart then
			rootPart.AssemblyLinearVelocity = Vector3.zero
			rootPart.AssemblyAngularVelocity = Vector3.zero
			rootPart.Anchored = true
		end
		player.Character:PivotTo(goCFrame)
		task.wait(0.2)
		if rootPart then
			rootPart.Anchored = false
		end
	end
	if curStage == 1 then
		player:SetAttribute("InLobby", true)
		player:SetAttribute("InStage", nil)
	else
		player:SetAttribute("InLobby", false)
		player:SetAttribute("InStage", curStage - 1)
	end
	player:SetAttribute("IsDead", false)
end
