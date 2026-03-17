local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local AudioManager = require(game.ReplicatedStorage.Packages.AudioManager)
local HttpService = game:GetService("HttpService")
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local lastPickupTime = 0

local function ToolPickup(world: Matter.World, state: typeof(State), context: typeof(Context))
	if Matter.useThrottle(0.3) then
		if localPlayer:GetAttribute("InviteStatus") == 2 or localPlayer:GetAttribute("InviteStatus") == 5 then return end
        local ActiveTools = game.Workspace:FindFirstChild("ActiveTools")
        if not ActiveTools then return end
        local character = localPlayer.Character
        if not character then return end
		if os.clock() - lastPickupTime < 3 then return end
		local startCFrame = character:GetPivot()

        local Overlap = OverlapParams.new() 
        Overlap.FilterType = Enum.RaycastFilterType.Include
        Overlap.FilterDescendantsInstances = { ActiveTools }

        local results = game.Workspace:GetPartBoundsInBox(startCFrame, Vector3.new(8, 20, 8), Overlap)
        for _, part in pairs(results) do
            local model = part:FindFirstAncestorOfClass("Model")
            local entityType = model:GetAttribute("entityType")
            if entityType then
				AudioManager:PlaySoundEffect("拾取道具")
                EventBus.FireServer("PlayerPickupTool", {EntityType = entityType})
                lastPickupTime = os.clock()
                return
            end
        end
	end
end
return {
	system = ToolPickup,
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
