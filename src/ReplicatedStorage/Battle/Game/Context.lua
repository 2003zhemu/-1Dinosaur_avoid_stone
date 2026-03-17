local RunService = game:GetService("RunService")
local Context = {}
local merger = require(script.Parent.Parent.Packages.MatterExtension.ComponentsMerger)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
-- Context.Components=require(game.ReplicatedStorage.Battle.Game.Ecs.Components)
Context.Components = merger.MergeComponents(
	require(game.ReplicatedStorage.Battle.Game.Ecs.Components),
	require(game.ReplicatedStorage.Battle.Core.CoreComponents)
)
local Env = require(game.ReplicatedStorage.Packages.Environment)
Context.Env = Env
Context.IsEcsServer = Env.IsDevClient() or RunService:IsServer()
Context.IsClient = RunService:IsClient()
Context.TweenService = game:GetService("TweenService")
Context.BattleDefine = require(game.ReplicatedStorage.Battle.Core.BattleDefine)

Context.SendCommand = function(commandName: string, payload: {})
	-- if command event is BindableEvent
	if RunService:IsClient() then
		EventBus.FireServer("ECS_COMMAND", commandName, payload)
	else
		EventBus.Fire("ECS_COMMAND", commandName, payload)
	end
end

--Context.UI_State = require(game.ReplicatedStorage.UI._global.State)

local config = require(game.ReplicatedStorage.Battle.Config)
Context.Config = config

if Context.IsClient then
	Context.PopupText = require(game.ReplicatedStorage.Packages.Neza.Alert)
end
Context.BattleUtilities = require(game.ReplicatedStorage.Battle.Core.BattleUtilities)

Context.GameTime = require(game.ReplicatedStorage.Battle.Packages.GameTime)

-- Context.AudioManager = require(game.ReplicatedStorage.Packages.AudioManager)

Context.Random = Random.new(os.clock())

Context.Helper = require(game.ReplicatedStorage.Battle.Game.Helper)
--src\ReplicatedStorage\Battle\Game\View\UnitAnimation.lua
Context.View = require(game.ReplicatedStorage.Battle.Game.View)
if RunService:IsClient() then
	Context.View = require(game.ReplicatedStorage.Battle.Game.View)
	Context.Debris = game:GetService("Debris")
	-- Context.LocalPropertyHelper = require(game.ReplicatedStorage.Helper.PropertyHelper)
end

-- Context.UnitAnime = require(game.ReplicatedStorage.Battle.Game.View.UnitAnimation)
Context.FireSignal = function(world, state, context, signalId, ...)
	local queryResult = world:query(context.Components.Signals)
	local _, signalComp = queryResult:next()
	if signalComp then
		table.insert(signalComp.Value, { signalId, ... })
	end
end

Context.GenConfigs = {}
for k,v in pairs(game.ReplicatedStorage._genConfigs:GetChildren()) do
    Context.GenConfigs[v.Name] = require(v)
end


return Context
