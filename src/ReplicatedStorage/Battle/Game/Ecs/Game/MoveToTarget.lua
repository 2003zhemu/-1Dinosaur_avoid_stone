local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)

-- 路点过滤阈值：太近 / 在身后就跳过，避免回拉
local WAYPOINT_TOO_CLOSE = 0.3

local function isWaypointBehindOrTooClose(currentPos: Vector3, waypointPos: Vector3, targetPos: Vector3)
	local toWP = waypointPos - currentPos
	local dist = toWP.Magnitude
	if dist < WAYPOINT_TOO_CLOSE then
		return true
	end

	local toTarget = targetPos - currentPos
	if toTarget.Magnitude < 1e-4 then
		return false
	end

	local dot = toWP:Dot(toTarget)
	if dot <= 0 then
		-- 路点在身后
		return true
	end

	return false
end

-- 安全取得路点位置（兼容 Vector3 / { Position = ... } / { Pos = ... }）
local function getWaypointPos(node)
	local t = typeof(node)
	if t == "Vector3" then
		return node
	elseif t == "table" then
		return node.Position or node.Pos or node[1]
	end
	return nil
end

local function MoveToTarget(world, state: typeof(State), context: typeof(Context))
	-- local Components = context.Components

	-- if state.Core.SimulateBattle == false then
	-- 	return
	-- end

	-- for id in world:query(Components.Movable) do
	-- 	local moveSpeedComp = world:get(id, Components.MoveSpeed)
	-- 	if not moveSpeedComp then
	-- 		continue
	-- 	end

	-- 	local transformComp = world:get(id, Components.Transform)
	-- 	if not transformComp then
	-- 		continue
	-- 	end

	-- 	local moveTarget = world:get(id, Components.MoveTarget)
	-- 	if not moveTarget then
	-- 		-- 理论上有 Movable 必须有 MoveTarget，这里防御一下
	-- 		world:remove(id, Components.M)
	-- 		continue
	-- 	end

	-- 	if not context.BattleUtilities.Buff.BuffState.CanMove(world, state, context, id) then
	-- 		continue
	-- 	end

	-- 	local selfPose = transformComp.CFrame
	-- 	local currentPos = selfPose.Position
	-- 	local moveSpeed = moveSpeedComp[1]
	-- 	local dt = context.GameTime.fixedDeltaTime
	-- 	local maxStep = moveSpeed * dt

	-- 	local path = world:get(id, Components.Path)
	-- 	local targetPos = moveTarget.Position
	-- 	local v3: Vector3 = Vector3.zero

	-- 	local hasPath = path ~= nil and path.Points ~= nil and #path.Points > 0

	-- 	--------------------------------------------------------
	-- 	-- 1. 只能按 Path 走：有 Path 才动；没 Path 就停
	-- 	--------------------------------------------------------
	-- 	if hasPath then
	-- 		local points = path.Points
	-- 		local n = #points
	-- 		local idx = math.clamp(path.Index or 1, 1, n)

	-- 		-- 过滤掉“在身后/太近”的路点
	-- 		local validIdx = nil
	-- 		for i = idx, n do
	-- 			local node = points[i]
	-- 			local wpPos = getWaypointPos(node)
	-- 			if wpPos then
	-- 				if not isWaypointBehindOrTooClose(currentPos, wpPos, targetPos) then
	-- 					validIdx = i
	-- 					break
	-- 				end
	-- 			end
	-- 		end

	-- 		if not validIdx then
	-- 			-- 前方没有有用路点 → 认为路径走完，停止移动
	-- 			v3 = Vector3.zero

	-- 			-- 清掉移动标记，保留 MoveTarget，让 PathSystem 以后还能重算
	-- 			world:remove(id, Components.M)
	-- 		else
	-- 			idx = validIdx
	-- 			local node = points[idx]
	-- 			local wpPos = getWaypointPos(node)

	-- 			if not wpPos then
	-- 				-- 非法路点，直接跳下一个
	-- 				world:insert(
	-- 					id,
	-- 					Components.Path({
	-- 						Points = points,
	-- 						Index = math.min(idx + 1, n),
	-- 						Target = path.Target,
	-- 						RequestId = path.RequestId,
	-- 					})
	-- 				)
	-- 				v3 = Vector3.zero
	-- 			else
	-- 				local toWP = wpPos - currentPos
	-- 				local dist = toWP.Magnitude

	-- 				if dist <= maxStep then
	-- 					-- 本帧可以直接踩到这个路点
	-- 					if dist > 0 then
	-- 						v3 = toWP / dt
	-- 					else
	-- 						v3 = Vector3.zero
	-- 					end

	-- 					if idx >= n then
	-- 						-- ✅ 走到最后一个路点：结束移动
	-- 						world:remove(id, Components.MoveTarget)
	-- 						world:insert(
	-- 							id,
	-- 							Components.Path({
	-- 								Points = {},
	-- 								Index = 1,
	-- 								Target = nil,
	-- 								RequestId = path.RequestId,
	-- 							})
	-- 						)
	-- 						world:remove(id, Components.M)
	-- 					else
	-- 						-- 还有后续路点：推进索引
	-- 						world:insert(
	-- 							id,
	-- 							Components.Path({
	-- 								Points = points,
	-- 								Index = idx + 1,
	-- 								Target = path.Target,
	-- 								RequestId = path.RequestId,
	-- 							})
	-- 						)
	-- 						world:insert(id, Components.M())
	-- 					end
	-- 				else
	-- 					-- 还没到路点：按类型算 3D 速度（这里已简化，仅 Jump/Drop 加速）
	-- 					local dir = Vector3.zero
	-- 					if toWP.Magnitude > 1e-4 then
	-- 						dir = toWP.Unit
	-- 					end

	-- 					local speed = moveSpeed

	-- 					v3 = dir * speed
	-- 					world:insert(id, Components.M())
	-- 				end
	-- 			end
	-- 		end
	-- 	else
	-- 		----------------------------------------------------
	-- 		-- 2. 没有 Path：不再直线追 MoveTarget，直接停下
	-- 		--    只清掉 M，让单位不再移动，但保留 MoveTarget，
	-- 		--    方便 PathSystem 后续重算出新路径再继续。
	-- 		----------------------------------------------------
	-- 		v3 = Vector3.zero
	-- 		world:remove(id, Components.M)
	-- 	end

	-- 	--------------------------------------------------------
	-- 	-- 3. 写 Velocity（XZ + Y），实际位移由 Move.lua 完成
	-- 	--------------------------------------------------------
	-- 	local velComp = world:get(id, Components.Velocity)
	-- 	if velComp then
	-- 		if v3.Magnitude > 1e-4 then
	-- 			velComp.Value.Adjust = Vector2.new(v3.X, v3.Z)
	-- 			velComp.Value.Y = v3.Y
	-- 		else
	-- 			velComp.Value.Adjust = Vector2.zero
	-- 			velComp.Value.Y = 0
	-- 		end
	-- 	end
	-- end
end

return {
	system = MoveToTarget,
	event = "FixedUpdate",
	env = {
		production = { disableClient = true },
		devClient = { disableClient = true },
		dev = { disableClient = true },
	},
}
