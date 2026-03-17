local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local EventTimeHelper = require(game.ReplicatedStorage.Helper.EventTimeHelper)
local players = game:GetService("Players")
local init = false
local isEventActive = false

local function ToolSpawn(world: Matter.World, state: typeof(State), context: typeof(Context))
	if not init then
		init = context.Helper.ToolHelper.Init()
	end

	isEventActive = EventTimeHelper.IsEventActive()

	--isEventActive = true

	--显示活动地图
	if isEventActive then
		local eventMap = game.Workspace.Map:FindFirstChild("活动地图")
		local originMap = game.Workspace.Map:FindFirstChild("原色地图")
		if not eventMap and originMap then
			local eventMapBak = game.ServerStorage:FindFirstChild("活动地图")
			if eventMapBak then
				eventMapBak:Clone().Parent = game.Workspace.Map
				originMap:Destroy()
			end
		end
	else
		local eventMap = game.Workspace.Map:FindFirstChild("活动地图")
		local originMap = game.Workspace.Map:FindFirstChild("原色地图")
		if eventMap and not originMap then
			local originMapBak = game.ServerStorage:FindFirstChild("原色地图")
			if originMapBak then
				originMapBak:Clone().Parent = game.Workspace.Map
				eventMap:Destroy()
			end
		end
	end

	local Components = context.Components
	if isEventActive and Matter.useThrottle(10) then
		local stageCounts = {}
		for entityId, tool, stage in world:query(Components.Tool, Components.Stage) do
			local curStage = stage.Value
			if stageCounts[curStage] == nil then
				stageCounts[curStage] = 0
			end
			stageCounts[curStage] += 1
		end

		for k, config in pairs(context.GenConfigs["battle_tbstage"]) do
			local curCount = stageCounts[k] or 0
			if curCount < config.ToolCount then
				-- 生成道具
				for i = 1, config.ToolCount - curCount do
					context.Helper.ToolHelper.SpawnTool(world, state, context, k)
				end
			end
		end
	end

	if not isEventActive then
		local Components = context.Components
		for entityId, tool, model in world:query(Components.Tool, Components.ServerModel) do
			if model and model.Model then
				model.Model:Destroy()
			end
			world.despawn(entityId)
		end
	end
end

return {
	system = ToolSpawn,
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
