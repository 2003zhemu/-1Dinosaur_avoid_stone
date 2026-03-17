local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local CustomPriority = require(game.ReplicatedStorage.Battle.Core.CustomPriority)
local ToolHelper = require(game.ReplicatedStorage.Helper.ToolHelper)
local Players = game:GetService("Players")

local function ServerEvent(world: Matter.World, state: typeof(State), context: typeof(Context))
	--客服端发到服务端，服务端处理
	for id, player, eventName, params in Matter.useEvent(EventBus.RemoteEvent, "OnServerEvent") do
		if eventName == "PlayerPickupTool" then
			local entityId = params.EntityType
			if world:contains(entityId) then
				local toolComp = world:get(entityId, context.Components.Tool)
                local stageComp = world:get(entityId, context.Components.Stage)
                local modelComp = world:get(entityId, context.Components.ServerModel)
                if not toolComp or not stageComp or not modelComp then
                    return
                end

                --玩家装备道具
                ToolHelper.UseTool(player, toolComp.Key)
				if modelComp.Model then
					modelComp.Model:Destroy()
				end
				world:despawn(entityId)
			end
		end
	end

	--服务端发到服务端
	for id, eventName, params in Matter.useEvent(EventBus.BindableEvent, "Event") do
		if eventName == "ControlSpawnTool" then
			local stage = params.Stage
			local toolIndex = params.ToolIndex
			context.Helper.ToolHelper.SpawnCustomTool(world, state, context, stage, toolIndex)
		end
	end
end

return {
	system = ServerEvent,
	event = "default",
    priority = CustomPriority.CommonHigheshPriority,
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
