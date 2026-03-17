local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local players = game:GetService("Players")

local function ToolClear(world: Matter.World, state: typeof(State), context: typeof(Context))
	if Matter.useThrottle(1) then
        local Components = context.Components
		for entityId, tool, model, expire in world:query(Components.Tool, Components.ServerModel, Components.ExpireTime) do
			if expire.Value <= os.clock() then
				local serverModel = model.Model
				if serverModel then
					serverModel:Destroy()
				end
				world:despawn(entityId)
			end
		end
	end
end

return {
	system = ToolClear,
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
