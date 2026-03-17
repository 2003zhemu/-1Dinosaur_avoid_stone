local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)

local PathfindingService = game:GetService("PathfindingService")

-- 异步结果缓冲：Path 计算在 task.spawn 里跑，结果先放到这里，下一帧再应用到 ECS
local pendingResults: {
	[number]: {
		Points: { { Position: Vector3 } }?,
		Nav: any,
		Target: Vector3?,
		RequestId: number,
	},
} = {}

----------------------------------------------------------------------
-- 1. 调用PathfindingService，拿到原始 Waypoints
----------------------------------------------------------------------
local function buildRawPoints(agentParams, startPos: Vector3, goalPos: Vector3)
	local path = PathfindingService:CreatePath({
		Costs = agentParams.Costs,
	})

	path:ComputeAsync(startPos, goalPos)
	if path.Status ~= Enum.PathStatus.Success then
		return nil
	end

	local points = {}
	for _, wp in ipairs(path:GetWaypoints()) do
		table.insert(points, {
			Position = wp.Position,
		})
	end
	return points
end

local function PathSystem(world: Matter.World, state: typeof(State), context: typeof(Context))
	-- local Components = context.Components

	-- for id, comp in world:queryChanged(Components.Request_FindPath) do
	-- 	if not comp.new then
	-- 		continue
	-- 	end
	-- 	comp = comp.new
	-- 	world:despawn(id)
	-- 	local ownerid = comp.OwnerId
	-- 	local startPos = comp.StartPos
	-- 	local goalPos = comp.GoalPos
	-- 	local nav = comp.NavAgent

	-- 	if not ownerid then
	-- 		continue
	-- 	end
	-- 	if not world:contains(ownerid) then
	-- 		pendingResults[ownerid] = nil
	-- 		continue
	-- 	end
	-- 	local oldPath = world:get(ownerid, Components.Path)
	-- 	local newReqId = (oldPath and oldPath.RequestId or 0) + 1
	-- 	-- 异步寻路
	-- 	task.spawn(function()
	-- 		local ok, rawPoints = pcall(buildRawPoints, nav, startPos, goalPos)

	-- 		pendingResults[ownerid] = {
	-- 			Points = rawPoints,
	-- 			Nav = nav,
	-- 			Target = goalPos,
	-- 			RequestId = newReqId,
	-- 		}
	-- 	end)
	-- end

	-- --  应用异步寻路结果
	-- ------------------------------------------------------------------
	-- for entityId, result in pairs(pendingResults) do
	-- 	if world:contains(entityId) then
	-- 		local currentPath = world:get(entityId, Components.Path)
	-- 		if currentPath and currentPath.RequestId == result.RequestId then
	-- 			-- 只有最新的 RequestId 才会被应用，避免“旧结果覆盖新结果”
	-- 			if result.Points and #result.Points > 0 then
	-- 				world:insert(
	-- 					entityId,
	-- 					Components.Path({
	-- 						Points = result.Points,
	-- 						Index = 1,
	-- 						Target = result.Target,
	-- 						RequestId = result.RequestId,
	-- 					})
	-- 				)
	-- 			else
	-- 				-- 寻路失败 / 没有点：清空 Points，但保留 RequestId
	-- 				world:insert(
	-- 					entityId,
	-- 					Components.Path({
	-- 						Points = {},
	-- 						Index = 1,
	-- 						Target = result.Target,
	-- 						RequestId = result.RequestId,
	-- 					})
	-- 				)
	-- 			end
	-- 		else
	-- 			world:insert(
	-- 				entityId,
	-- 				Components.Path({
	-- 					Points = result.Points,
	-- 					Index = 1,
	-- 					Target = result.Target,
	-- 					RequestId = result.RequestId,
	-- 				})
	-- 			)
	-- 		end
	-- 	end

	-- 	pendingResults[entityId] = nil
	-- end
end

return {
	system = PathSystem,
	event = "FixedUpdate",
	env = {
		production = { disableClient = true },
		devClient = { disableClient = true },
		dev = { disableClient = true },
	},
}
