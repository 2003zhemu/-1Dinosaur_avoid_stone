local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local TweenService = game:GetService("TweenService")

local players = game:GetService("Players")

local function Monster(world: Matter.World, state: typeof(State), context: typeof(Context))
	local Components = context.Components
	for entityId, monster in world:query(context.Components.Monster) do
		local target = world:get(entityId, Components.Target)
		local monsterData = world:get(entityId, Components.MonsterData)
		local monsterTrack = world:get(entityId, Components.MonsterTrack)
		local transformComp = world:get(entityId, context.Components.Transform)

		if not transformComp or not monsterData then continue end
		local selfCFrame = transformComp.CFrame
		local tracks = {}
		if monsterTrack and monsterTrack.Tracks then
			tracks = monsterTrack.Tracks
		end
		--正在追击目标
		if target and target.TargetId then
			local player = game.Players:GetPlayerByUserId(target.TargetId)
			if not player then
				world:remove(entityId, Components.Target)
				continue
			end
			if player:GetAttribute("InStage") ~= monster.Stage then  --玩家已经离开关卡
				world:remove(entityId, Components.Target)
				continue
			end
			if not player.Character then
				world:remove(entityId, Components.Target)
				continue
			end
			local playerCFrame = player.Character:GetPivot()
			local playerPos = playerCFrame.Position
			--判断玩家是否在怪物的攻击范围内
			if playerPos.X < monsterData.MinX or playerPos.X > monsterData.MaxX or playerPos.Z < monsterData.MinZ or playerPos.Z > monsterData.MaxZ then
				world:remove(entityId, Components.Target)
				continue
			end
			--防止怪物重叠
			if monster.Vector then
				local tempCFrame = playerCFrame + monster.Vector * playerCFrame.RightVector * 3
				playerPos = tempCFrame.Position
			end 
			--往目标方向移动
			local vector = (playerPos - selfCFrame.Position).Unit
			--追击速度
			local speed = monsterData.Speed
			local deltaTime = Matter:useDeltaTime()
			local newPos = selfCFrame.Position + vector * speed * deltaTime
			local newCFrame = CFrame.lookAt(newPos, newPos + vector)
			local lerpCFrame = selfCFrame:lerp(newCFrame, 0.1)
			local vector = lerpCFrame - lerpCFrame.Position
			local lastCFrame = CFrame.new(newCFrame.Position) * vector
			world:insert(entityId, context.Components.Transform({ CFrame = lastCFrame }))
			
			if monster.Model and monster.Model.PrimaryPart then
				if tracks["Idle"] and tracks["Idle"].IsPlaying then
					tracks["Idle"]:Stop()
				end
				if tracks["Move"] and not tracks["Move"].IsPlaying then
					tracks["Move"]:Play()
				end
				TweenService:Create(monster.Model.PrimaryPart, TweenInfo.new(deltaTime), { CFrame = lastCFrame }):Play()
			end
			continue
		end

		--寻找关卡里的新目标
		for _, player in ipairs(players:GetPlayers()) do
			if not player:GetAttribute("InStage") then continue end
			if player:GetAttribute("InStage") ~= monster.Stage then continue end
			if player.Character then
				local playerPos = player.Character:GetPivot().Position
				if playerPos.X > monsterData.MinX and playerPos.X < monsterData.MaxX and playerPos.Z > monsterData.MinZ and playerPos.Z < monsterData.MaxZ then
					world:insert(entityId, Components.Target({
						TargetId = player.UserId,
					}))
					break
				end
			end
		end
		--如果没有找到新目标，回到原位置
		if not target then
			if tracks["Move"] and tracks["Move"].IsPlaying then
				tracks["Move"]:Stop()
			end
			if tracks["Idle"] and not tracks["Idle"].IsPlaying then
				tracks["Idle"]:Play()
			end
			world:insert(entityId, context.Components.Transform({ CFrame = monsterData.StartCFrame }))
			if monster.Model then
				monster.Model:PivotTo(monsterData.StartCFrame)
			end
		end
	end
end
return {
	system = Monster,
	event = "default",
	env = {
		production = {
			-- disableServer = true,
			disableClient = true,
			--onlyServer = true,
		},
		devClient = {
			-- disableServer = true,
			disableClient = true,
			--onlyServer = true,
		},
		dev = {
			-- disableServer = true,
			disableClient = true,
			--onlyServer = true,
		},
	},
}
