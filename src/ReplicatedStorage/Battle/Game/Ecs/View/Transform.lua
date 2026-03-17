local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)

local function Transform(world: Matter.World, state: typeof(State), context: typeof(Context))
	local Components = context.Components
	for id, TransformComp in world:queryChanged(Components.Transform) do
		if TransformComp.new == nil then
			return
		end
		local model = world:get(id, Components.Model)
		if model and model.Model then
            model.Model:PivotTo(TransformComp.new.CFrame)
		end
	end
end
return {
	system = Transform,
	event = "default",
	env = {
		production = {
			disableServer = true,
			--disableClient = true,
			--onlyServer = true,
		},
		devClient = {
			disableServer = true,
			--disableClient = true,
			--onlyServer = true,
		},
		dev = {
			disableServer = true,
			--disableClient = true,
			--onlyServer = true,
		},
	},
}
