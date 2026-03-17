local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.Parent.Components)
local useEvent = require(ReplicatedStorage.Packages.Matter).useEvent

local RemoteEvent = Instance.new("RemoteEvent")
local eventBus = require(game.ReplicatedStorage.Packages.EventBus)


local eventNameReplication = require(script.Parent.Parent.Parent.EventNames).EventReplication
    
local REPLICATED_COMPONENTS = {
    "Procedure",
    "ProcedurePayload",
}

local replicatedComponents = {}

for _, name in REPLICATED_COMPONENTS do
	replicatedComponents[Components[name]] = true
end

local function replication(world)
	for _, player in useEvent(Players, "PlayerAdded") do
		local payload = {}

		for entityId, entityData in world do
			local entityPayload = {}
			payload[tostring(entityId)] = entityPayload

			for component, componentData in entityData do
				if replicatedComponents[component] then
					entityPayload[tostring(component)] = { data = componentData }
				end
			end
		end

		print("Sending initial payload to", player)
        eventBus.FireClient(player,eventNameReplication, payload)
	end

	local changes = {}

	for component in replicatedComponents do
		for entityId, record in world:queryChanged(component) do
			local key = tostring(entityId)
			local name = tostring(component)

			if changes[key] == nil then
				changes[key] = {}
			end

			if world:contains(entityId) then
				changes[key][name] = { data = record.new }
			end
		end
	end

	if next(changes) then
        eventBus.FireAllClients(eventNameReplication,changes)
	end
end

return {
	system = replication,
	priority = math.huge,
}
