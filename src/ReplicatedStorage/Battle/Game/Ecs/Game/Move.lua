local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)

-- 朝向插值速度
local TURN_SPEED = 10

local function Move(world: Matter.World, state: typeof(State), context: typeof(Context))
	-- local Components = context.Components

	-- if state.Core.SimulateBattle == false then
	-- 	return
	-- end

	-- for entityId, transformComp, velocityComp in world:query(Components.Transform, Components.Velocity) do
	-- 	-- 不能移动就清速度
	-- 	if not context.BattleUtilities.Buff.BuffState.CanMove(world, state, context, entityId) then
	-- 		velocityComp.Value.Adjust = Vector2.zero
	-- 		velocityComp.Value.Y = 0
	-- 		continue
	-- 	end

	-- 	local dt = context.GameTime.fixedDeltaTime
	-- 	local cf = transformComp.CFrame
	-- 	local pos = cf.Position

	-- 	----------------------------------------------------------------
	-- 	-- 1. 计算速度：水平（XZ）+ 竖直（Y）
	-- 	----------------------------------------------------------------
	-- 	local v2 = velocityComp.Value.Adjust

	-- 	local vy = velocityComp.Value.Y or 0

	-- 	-- 如果既没有水平速度，也没有竖直速度，就不用移动和转身
	-- 	if v2 == Vector2.zero and vy == 0 then
	-- 		velocityComp.Value.Adjust = Vector2.zero
	-- 		velocityComp.Value.Y = 0
	-- 		continue
	-- 	end

	-- 	-- 位移（XZ + Y）
	-- 	local move2D = v2 * dt
	-- 	local move3D = Vector3.new(move2D.X, vy * dt, move2D.Y)
	-- 	local newPos = pos + move3D

	-- 	----------------------------------------------------------------
	-- 	-- 2. 朝向：优先看 Threat 目标，其次看移动方向
	-- 	----------------------------------------------------------------
	-- 	local currentLook = cf.LookVector
	-- 	local curHoriz = Vector3.new(currentLook.X, 0, currentLook.Z)
	-- 	if curHoriz.Magnitude < 1e-4 then
	-- 		curHoriz = Vector3.new(0, 0, -1)
	-- 	end

	-- 	local desiredHoriz: Vector3? = nil

	-- 	-- 1）优先看仇恨目标
	-- 	local threat = world:get(entityId, Components.Threat)
	-- 	if threat and threat.TargetId and world:contains(threat.TargetId) then
	-- 		local targetTrans = world:get(threat.TargetId, Components.Transform)
	-- 		if targetTrans then
	-- 			local toTarget = targetTrans.CFrame.Position - newPos
	-- 			local toTargetHoriz = Vector3.new(toTarget.X, 0, toTarget.Z)
	-- 			if toTargetHoriz.Magnitude > 1e-3 then
	-- 				desiredHoriz = toTargetHoriz.Unit
	-- 			end
	-- 		end
	-- 	end

	-- 	-- 2）没有有效目标，就按移动方向看（只看 XZ）
	-- 	if not desiredHoriz then
	-- 		local horizMove = Vector3.new(move3D.X, 0, move3D.Z)
	-- 		if horizMove.Magnitude > 1e-3 then
	-- 			desiredHoriz = horizMove.Unit
	-- 		end
	-- 	end

	-- 	-- 3）啥都没有，就保持原朝向
	-- 	if not desiredHoriz then
	-- 		desiredHoriz = curHoriz
	-- 	end

	-- 	-- 平滑插值转身
	-- 	local alpha = math.clamp(TURN_SPEED * dt, 0, 1)
	-- 	local blended = curHoriz:Lerp(desiredHoriz, alpha)
	-- 	if blended.Magnitude < 1e-4 then
	-- 		blended = curHoriz
	-- 	end
	-- 	blended = blended.Unit

	-- 	local newPose = CFrame.new(newPos, newPos + blended)
	-- 	world:insert(entityId, Components.Transform({ CFrame = newPose }))

	-- 	velocityComp.Value.Adjust = Vector2.zero
	-- 	velocityComp.Value.Y = 0
	-- end
end

return {
	system = Move,
	event = "FixedUpdate",
	--after = {}, -- 以后做 Rvo 再加 { Rvo }
	env = {
		production = {
			disableClient = true,
		},
		devClient = {
			disableClient = true,
		},
		dev = {
			disableClient = true,
		},
	},
}
