local stageConfigs = require(game.ReplicatedStorage._genConfigs.battle_tbstage)
local unitConfig = require(game.ReplicatedStorage._genConfigs.battle_tbunit)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local wukongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local Follow = require(game.ReplicatedStorage.Modules.Follow)
local Zone = require(game.ReplicatedStorage.Packages.Zone)
local getRewardCache = {}
local inDoorCache = {}

--玩家领取奖杯
for k, v in pairs(game.Workspace.GetCups:GetChildren()) do
	if v:IsA("Model") and v.PrimaryPart then
		local stage = tonumber(v.Name)
		local config = stageConfigs[stage]
		local Text = v.PrimaryPart:FindFirstChild("Text")
		if Text then
			local stat = Text:FindFirstChild("stat")
			if stat then
				if config.RewardCup == 1 then
					stat.Text = `+1 Win`
				else
					stat.Text = `+{config.RewardCup} Wins`
					local frame = Text:FindFirstChild("Frame")
					if frame then
						frame.stat.Text = `+{config.RewardCup}`
					end
				end
			end
		end

		v.PrimaryPart.Touched:Connect(function(part)
			if part and part.Parent and part.Parent:IsA("Model") then
				local character = part.Parent
				local player = game.Players:GetPlayerFromCharacter(character)
				if not player then
					return
				end
				if getRewardCache[player] then
					return
				end
				getRewardCache[player] = true
				task.delay(0.5, function()
					getRewardCache[player] = nil
				end)
				local inStage = player:GetAttribute("InStage")
				if not inStage then
					return
				end
				if not (inStage == stage or inStage == stage + 1) then
					return
				end

				local playerInviteStatus = player:GetAttribute("InviteStatus")
				if playerInviteStatus == 2 then
					return
				end
				EventBus.FireClient(player, EventDefines["玩家领取奖杯"])

				--是否购买双倍奖杯
				local isDoubleCups = player:GetAttribute(Defines.GamePass["双倍奖杯"].Key)
				local rewardCup = stageConfigs[tonumber(v.Name)].RewardCup
				if isDoubleCups then
					rewardCup = rewardCup * 2
				end

				--当前跟随玩家数
				local followCount = Follow.GetFollowerCount(player)
				--warn(`跟随人数{followCount}`, `奖励奖杯数{rewardCup * (1 + followCount * 0.2)}`)
				rewardCup = math.floor(rewardCup * (1 + followCount * 0.2))

				local allPlayers = { player } --需要处理的全部玩家
				for _, follower in pairs(Follow.GetFollowers(player)) do
					table.insert(allPlayers, follower)
				end

				--获得相同的奖杯数
				for _, plr in pairs(allPlayers) do
					if wukongServer.HasFacade(plr.UserId) then
						local facade = wukongServer.GetFacade(plr.UserId)
						if facade then
							facade:ExecuteAction("/货币/奖杯?属性增加", rewardCup)
						end
					end
				end

				--解除全部跟随
				Follow.RemoveAllFollowers(player)
				task.wait()
				for _, plr in pairs(allPlayers) do
					if plr.Character then
						-- warn("回到出生点", plr.Name, Defines.RespawnCFrames[1])
						local rootPart = plr.Character.PrimaryPart or plr.Character:FindFirstChild("HumanoidRootPart")
						if rootPart then
							rootPart.AssemblyLinearVelocity = Vector3.zero
							rootPart.AssemblyAngularVelocity = Vector3.zero
							rootPart.Anchored = true
						end
						plr.Character:PivotTo(Defines.RespawnCFrames[1])
						EventBus.FireClient(
							plr,
							EventDefines["回到出生点"],
							{ CFrame = Defines.RespawnCFrames[1] }
						)
						if #allPlayers > 1 then
							EventBus.FireClient(
								plr,
								"FollowSettle",
								{ FollowPlayer = allPlayers, LeaderPlayer = player, RewardCup = rewardCup }
							)
						end

						plr:SetAttribute("InLobby", true)
						plr:SetAttribute("InStage", nil)
						task.delay(0.2, function()
							if rootPart then
								rootPart.Anchored = false
							end
						end)
					end
				end

				player:SetAttribute("InLobby", true)
				player:SetAttribute("InStage", nil)
			end
		end)
	end
end

--玩家进入关卡
for k, v in pairs(game.Workspace.StageZones:GetChildren()) do
	if v:IsA("BasePart") then
		local Region = Zone.new(v)
		if v.Name == "Lobby" then
			Region.playerEntered:Connect(function(player)
				player:SetAttribute("InLobby", true)
				player:SetAttribute("InStage", nil)
			end)
			-- Region.playerExited:Connect(function(player)
			--     player:SetAttribute("InStage", nil)
			-- end)
		else
			Region.playerEntered:Connect(function(player)
				player:SetAttribute("InStage", tonumber(v.Name))
				player:SetAttribute("InLobby", false)
			end)
			-- Region.playerExited:Connect(function(player)
			--     player:SetAttribute("InStage", nil)
			-- end)
		end
	end
end

--恐龙UI提示需要奖杯数
for _, unit in pairs(game.Workspace.Dinosaurs:GetChildren()) do
	if unit:IsA("Model") and unit.PrimaryPart then
		local config = unitConfig[tonumber(unit.Name)]
		if not config then
			continue
		end
		local needCups = config.NeedCups
		local speed = config.ExpBonus
		local text = unit.PrimaryPart:FindFirstChild("Text")
		if text then
			local speedText = text:FindFirstChild("stat")
			if speedText then
				speedText.Text = `+{speed}Speed`
			end
			local cupsText = text:FindFirstChild("Required")
			if cupsText then
				if config.Id == 11 then --付费恐龙
					cupsText.Text = `R 399`
				else
					cupsText.Text = `{needCups} Wins Required`
					local frame = text:FindFirstChild("Frame")
					if frame then
						frame.num.Text = `{needCups}`
					end
				end
			end
		end
	end
end

--玩家进入新关卡
for k, v in pairs(game.Workspace.Doors:GetChildren()) do
	if v:IsA("Model") then
		local wall = v:FindFirstChild("Wall")
		wall.Touched:Connect(function(part)
			if part and part.Parent and part.Parent:IsA("Model") then
				local character = part.Parent
				local player = game.Players:GetPlayerFromCharacter(character)
				if not player then
					return
				end
				if inDoorCache[player] then
					return
				end
				inDoorCache[player] = true
				task.delay(2, function()
					inDoorCache[player] = nil
				end)
				EventBus.FireClient(player, EventDefines["玩家进入新关卡"], { StageId = tonumber(v.Name) })
			end
		end)
	end
end
