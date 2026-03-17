local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local CustomPriority = require(game.ReplicatedStorage.Battle.Core.CustomPriority)
--定时器系统
local function TimerSystem(world, state, context: typeof(Context))
	--处理delay事件
	for id, TimerDelayComp in world:query(context.Components.TimerDelay) do
		if TimerDelayComp.TriggerTime <= context.GameTime.time then
			world:despawn(id)
			TimerDelayComp.Func(world, state, context, TimerDelayComp.Params)
		end
	end
	for id, TimerLoopComp in world:query(context.Components.TimerLoop) do
		local TriggerTime = TimerLoopComp.TriggerTime
		local stopLoop = false
		while stopLoop == false and TriggerTime <= context.GameTime.time do
			TriggerTime = TriggerTime + TimerLoopComp.Interval
			stopLoop = TimerLoopComp.Func(world, state, context, TimerLoopComp.Params)
		end
		if stopLoop then
			world:despawn(id)
		else
			world:insert(id, TimerLoopComp:patch({ TriggerTime = TriggerTime }))
		end
	end
end

return {
	system = TimerSystem,
	event = "FixedUpdate",
	priority = CustomPriority.ServerReplication - 1,
	env = {
		production = {
			-- disableClient = true,
		},
		devClient = {
			-- disableClient = true,
		},
		dev = {
			-- disableClient = true,
		},
	},
}
