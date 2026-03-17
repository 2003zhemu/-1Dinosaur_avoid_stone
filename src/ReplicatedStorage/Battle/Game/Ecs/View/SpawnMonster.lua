local Players = game:GetService("Players")
local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local CustomPriority = require(game.ReplicatedStorage.Battle.Core.CustomPriority)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)

local function SpawnMonster(world, state: typeof(State), context: typeof(Context))
    -- local Components = context.Components
    -- for entityId, monsterComp in world:queryChanged(Components.Monster) do
    --     local monster = monsterComp.new    
    --     local oldMonster = monsterComp.old
    --     if not world:contains(entityId) then
    --         continue
    --     end
    --     --生成新怪物
    --     if monster and not oldMonster then
    --         local stage = monster.Stage
    --         local key = monster.Key
    --         local parentFolder = game.Workspace.Obstacles:FindFirstChild("Stage" .. tostring(stage))
    --         if not parentFolder then continue end
    --         local monsterModel = parentFolder:FindFirstChild(key)
    --         if not monsterModel then continue end
    --         world:insert(entityId, context.Components.Model({Model = compModel}))
    --     end
    -- end
end

return {
	system = SpawnMonster,
	event = "default",
    priority = CustomPriority.CommonLowestPriority,
	env = {
		production = {
			disableServer = true,
		},
		devClient = {
			disableServer = true,
		},
		dev = {
			disableServer = true,
		},
	},
}