local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Battle.Packages.Matter)

local State = require(ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(ReplicatedStorage.Battle.Game.Context)
local clientReplication = {}
local function setupReplication(world: Matter.World, state: typeof(State), context: typeof(Context), ui)
	if game["Run Service"]:IsStudio() then
		local DebugOptions = require(game.ReplicatedStorage.Packages.DebugOptions)

		-- 客户端调试时，不需要和服务器同步
		if DebugOptions.IsEnable("客户端调试开关") then
			warn("客户端调试已启动，不再接收服务端 component 数据.")
			return
		end
	end

	local RemoteEventMatterDiff = ReplicatedStorage:WaitForChild("MatterDiff")
	local MatterStartSync: RemoteEvent = ReplicatedStorage:WaitForChild("MatterStartSync")
	local function debugPrint(...)
		if state.debugEnabled then
			-- print("Replication>", ...)
		end
	end

	RemoteEventMatterDiff.OnClientEvent:Connect(function(entities)
		local signals = nil
		for serverEntityId, componentMap in entities do
			-- 传过来的是str
			serverEntityId = tonumber(serverEntityId)
			local isInClientWorld = world:contains(serverEntityId)
			if isInClientWorld and next(componentMap) == nil then
				world:despawn(serverEntityId)
				debugPrint(string.format("Despawn %d", serverEntityId))
				continue
			end

			local componentsToInsert = {}
			local componentsToRemove = {}

			local insertNames = {}
			local removeNames = {}
			if componentMap["Signals"] then
				signals = componentMap["Signals"]
				componentMap["Signals"] = nil
			end

			for name, container in componentMap do
				--处理信号量
				if container.data then
					table.insert(componentsToInsert, context.Components[name](container.data))
					table.insert(insertNames, name)
				else
					table.insert(componentsToRemove, context.Components[name])
					table.insert(removeNames, name)
				end
			end

			if not isInClientWorld then
				world:spawnAt(serverEntityId, unpack(componentsToInsert))

				debugPrint(string.format("Spawn %d with %s", serverEntityId, table.concat(insertNames, ",")))
			else
				if #componentsToInsert > 0 then
					world:insert(serverEntityId, unpack(componentsToInsert))
				end

				if #componentsToRemove > 0 then
					world:remove(serverEntityId, unpack(componentsToRemove))
				end

				debugPrint(
					string.format(
						"Modify %s, removing %s",
						serverEntityId,
						if #insertNames > 0 then table.concat(insertNames, ", ") else "nothing",
						if #removeNames > 0 then table.concat(removeNames, ", ") else "nothing"
					)
				)
			end
		end

		if signals then
			if signals.data then
				for id, signal in pairs(signals.data.Value) do
					if #signal < 1 then
						print("error signal", signal)
						continue
					end
					local signalId = signal[1]
					context.BattleUtilities.Signal.Handles[signalId](
						world,
						state,
						context,
						select(2, table.unpack(signal))
					)
				end
			end
		end
	end)
	MatterStartSync:FireServer()
end
clientReplication.BeginReplication = setupReplication

return clientReplication
