local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local players = game:GetService("Players")

local function PlayerInit(world: Matter.World, state: typeof(State), context: typeof(Context))
	if Matter.useThrottle(0.3) then
        local Components = context.Components
		for _, player in ipairs(players:GetPlayers()) do
			if not player:GetAttribute("Init") and player:GetAttribute("PlayerWukongReady") then
				player:SetAttribute("Init", true)
                world:Spawn(
                    Components.Player({
                        UserId = player.UserId
                    })
                )
			end
		end
	end
end
return {
	system = PlayerInit,
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
