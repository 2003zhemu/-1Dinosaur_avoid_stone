local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Follow = require(game.ReplicatedStorage.Modules.Follow)
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
if not PhysicsService:IsCollisionGroupRegistered("Player") then
    PhysicsService:RegisterCollisionGroup("Player")
end
if not PhysicsService:IsCollisionGroupRegistered("Follower") then
    PhysicsService:RegisterCollisionGroup("Follower")
end
PhysicsService:CollisionGroupSetCollidable("Player", "Player", false)
PhysicsService:CollisionGroupSetCollidable("Player", "Follower", false)
PhysicsService:CollisionGroupSetCollidable("Follower", "Follower", false)
--PhysicsService:CollisionGroupSetCollidable("Follower", "Default", true)
-- 0未邀请 1邀请中 2已接受 3邀请别人 4被人跟随 5解除跟随中  6一键邀请
EventBus.ConnectC2S(function(player, eventName, params)
	if eventName == "InvitePlayer" then
		local inviteId = params.InviteId
		if not inviteId then
			return
		end
		local invitePlayer = Players:GetPlayerByUserId(inviteId)
		if not invitePlayer then
			return
		end
		--是否在大厅
		local inLobby = invitePlayer:GetAttribute("InLobby")
		if not inLobby then
			EventBus.FireClient(
				player,
				EventDefines["服务端消息提示"],
				{ Type = "Warn", Text = "The invited player is not in the lobby" }
			)
			return
		end
		--是否在跟随
		local inviteStatus = invitePlayer:GetAttribute("InviteStatus")
		if inviteStatus and inviteStatus ~= 0 then
			EventBus.FireClient(
				player,
				EventDefines["服务端消息提示"],
				{ Type = "Warn", Text = "The invited player is already following" }
			)
			return
		end
		--是否禁用邀请
		local canInvite = invitePlayer:GetAttribute("AcceptInvite")
		if not canInvite then
			EventBus.FireClient(
				player,
				EventDefines["服务端消息提示"],
				{ Type = "Warn", Text = "The invited player disable invitation" }
			)
			return
		end

		--邀请目标设置为邀请中
		invitePlayer:SetAttribute("InviteStatus", 3)
		--通知被邀请目标 正在被邀请
		EventBus.FireClient(invitePlayer, EventDefines["被邀请"], { PlayerId = player.UserId })
		warn(1)
	end

	if eventName == "InviteAll" then
		--玩家发起一键邀请
		player:SetAttribute("InviteStatus", 6)
		task.delay(10, function()
			if player:GetAttribute("InviteStatus") == 6 then
				player:SetAttribute("InviteStatus", 0)
			end
		end)

		for k, plr in pairs(Players:GetPlayers()) do
			if plr == player then
				continue
			end
			--是否在大厅
			local inLobby = plr:GetAttribute("InLobby")
			if not inLobby then
				continue
			end
			--是否在跟随
			local inviteStatus = plr:GetAttribute("InviteStatus")
			if inviteStatus and inviteStatus ~= 0 then
				continue
			end

			--是否禁用邀请
			local canInvite = plr:GetAttribute("AcceptInvite")
			if not canInvite then
				continue
			end

			--邀请目标设置为邀请中
			plr:SetAttribute("InviteStatus", 1)
			--通知被邀请目标 正在被邀请
			EventBus.FireClient(plr, EventDefines["被邀请"], { PlayerId = player.UserId })
		end
	end
end)

-- --显示邀请按钮
-- game.Players.PlayerAdded:Connect(function(player)
--     player.CharacterAdded:Connect(function(character)
--         local rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
--         if not rootPart then
--             repeat
--                 task.wait(0.1)
--                 rootPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
--             until rootPart
--         end
--         Follow.Init(player)
--         local ProximityPrompt = Instance.new("ProximityPrompt")
--         ProximityPrompt.Parent = rootPart
--         ProximityPrompt.Name = "PlayerInvitePrompt"
--         ProximityPrompt.ActionText = "Invite Follow"
--         ProximityPrompt.ObjectText = "+20% rewards per follower"
--         ProximityPrompt.HoldDuration = 0.5
--         ProximityPrompt.RequiresLineOfSight = false
--         ProximityPrompt.MaxActivationDistance = 10

--         ProximityPrompt.Triggered:Connect(function(triggerPlayer)
--             if triggerPlayer == player then return end
--             --玩家 triggerPlayer 邀请玩家 player
            
--             --只有大厅里能邀请
--             local triggerPlayerInLobby = triggerPlayer:GetAttribute("InLobby")
--             local playerInLobby = player:GetAttribute("InLobby")
--             if not triggerPlayerInLobby or not playerInLobby then 
--                 EventBus.FireClient(triggerPlayer, EventDefines["服务端消息提示"], {Type = "Warn", Text = "Only in lobby can invite"})
--                 return 
--             end

--             --邀请目标被其他玩家邀请 0未邀请 1邀请中 2已接受 3邀请别人 4被人跟随
--             local playerInviteStatus = player:GetAttribute("InviteStatus")
--             if playerInviteStatus == 1 or playerInviteStatus == 2 or playerInviteStatus == 3 or playerInviteStatus == 4 then
--                 EventBus.FireClient(triggerPlayer, EventDefines["服务端消息提示"], {Type = "Warn", Text = `Player {player.Name} is already invited`})
--                 return
--             end

--             --邀请目标设置为邀请中
--             player:SetAttribute("InviteStatus", 1)
--             triggerPlayer:SetAttribute("InviteStatus", 3)

--             --通知被邀请目标 正在被邀请
--             EventBus.FireClient(player, EventDefines["被邀请"], {PlayerId = triggerPlayer.UserId})
--         end)

--         for k, part in pairs(character:GetDescendants()) do
--             if part:IsA("BasePart") then
--                 part.CollisionGroup = "Player"
--             end
--         end
--         character.DescendantAdded:Connect(function(child)
--             if child:IsA("BasePart") then
--                 child.CollisionGroup = "Player"
--             end
--         end)
--     end)
-- end)

--玩家离线
game.Players.PlayerRemoving:Connect(function(player)
	Follow.Destroy(player)

    local FollowPlayerId = player:GetAttribute("FollowPlayerId")
    if FollowPlayerId then
        local invitePlayer = game.Players:GetPlayerByUserId(FollowPlayerId)
        if invitePlayer then
            Follow.RemoveFollower(invitePlayer, player)
        end
    end
end)