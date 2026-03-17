local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local useEvent = require(ReplicatedStorage.Battle.Packages.Matter).useEvent
local CustomPriority = require(ReplicatedStorage.Battle.Core.CustomPriority)
local BattleDefine = require(ReplicatedStorage.Battle.Core.BattleDefine)
local RemoteEventDiffSync = nil
local RemoteEventClientStartSync = nil
if RunService:IsServer() then
	RemoteEventDiffSync = Instance.new("RemoteEvent")
	RemoteEventDiffSync.Name = "MatterDiff"
	RemoteEventDiffSync.Parent = ReplicatedStorage
	RemoteEventClientStartSync = Instance.new("RemoteEvent")
	RemoteEventClientStartSync.Name = "MatterStartSync"
	RemoteEventClientStartSync.Parent = ReplicatedStorage
end
local tranformDirtyCache = {} --{id:Tranform}
local nextUpdateTime = 0
local TransformUpdateInternal = 0.1
local EntityOrientationBand = 0b1111_1111_1111_1111
local function replication(world, state, context)
	if not context.Components.Replication then
		error("未添加同步组件: Replication")
		return
	end
	local id, rep = world:single(context.Components.Replication)
	if not rep then
		world:spawn(context.Components.Replication())
		id, rep = world:single(context.Components.Replication)
	end
	-- local signalId, signals = world:single(context.Components.Signals)
	-- if not signals then
	-- 	world:spawn(context.Components.Signals())
	-- 	id, signals = world:single(context.Components.Signals)
	-- end

	-- todo single
	local queryResult = world:query(context.Components.Signals)
	local signalId, signalComp = queryResult:next()
	if not signalComp then
		world:spawn(context.Components.Signals())
		queryResult = world:query(context.Components.Signals)
		signalId, signalComp = queryResult:next()
	end
	-- local queryResult = world:query(context.Components.Signals)
	-- local signalId, signals = queryResult._next()
	-- if not signals then
	-- 	world:spawn(context.Components.Signals())
	-- 	queryResult = world:query(context.Components.Signals)
	-- 	signalId, signals = queryResult._next()
	-- end

	for _, player in useEvent(RemoteEventClientStartSync, "OnServerEvent") do
		state.Core.SyncPlayers[player] = player
		local payload = {}
		local replicatedComponentsAll = rep.All
		if not replicatedComponentsAll then
			return
		end
		for entityId, entityData in world do
			local entityPayload = {}
			payload[tostring(entityId)] = entityPayload

			for component, componentData in entityData do
				if replicatedComponentsAll[component] then
					entityPayload[tostring(component)] = { data = componentData }
				end
			end
		end

		-- print("Sending initial payload to", player)
		RemoteEventDiffSync:FireClient(player, payload)
	end
	for _, player in useEvent(Players, "PlayerRemoving") do
		state.Core.SyncPlayers[player] = nil
	end
	local replicatedComponentsCommon = rep.Common
	if not replicatedComponentsCommon then
		return
	end
	local changes = {}

	for component in replicatedComponentsCommon do
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
	local forceUpdateTransform = false
	--Sync Transform
	for entityId, TransformComp in world:queryChanged(context.Components.Transform) do
		if not world:contains(entityId) then
			tranformDirtyCache[entityId] = {}
		else
			if TransformComp.new then
				tranformDirtyCache[entityId] = { TransformComp.new.CFrame }
				if TransformComp.old == nil then
					forceUpdateTransform = true
					-- print("forceupdate transform")
				end
			end
		end
	end
	if nextUpdateTime < context.GameTime.time or forceUpdateTransform then
		nextUpdateTime = context.GameTime.time + TransformUpdateInternal
		--sync dirty transform info
		local transformDatas = {}
		if next(tranformDirtyCache) then
			for entityId, data in tranformDirtyCache do
				local compressCFrame: Vector3int16
				local cframe: CFrame = data[1]
				if data[1] then
					local _, yRaidus = cframe:ToOrientation()
					local yAngle = math.floor((yRaidus / math.pi + 1) / 2 * EntityOrientationBand)
					compressCFrame = Vector3int16.new(yAngle, data[1].X * 10, data[1].Z * 10)
				end
				table.insert(transformDatas, { entityId, compressCFrame })
			end
			table.clear(tranformDirtyCache)
			-- print("fire dirty transform")
			context.FireSignal(world, state, context, BattleDefine.BattleSignal.SyncTransform, transformDatas)
		end
	end

	if #signalComp.Value > 0 then
		changes[signalId] = {}
		changes[signalId][tostring(context.Components.Signals)] = { data = signalComp }
	end

	if next(changes) then
		for player, _ in state.Core.SyncPlayers do
			RemoteEventDiffSync:FireClient(player, changes)
		end
	end
	if #signalComp.Value > 0 then
		table.clear(signalComp.Value)
	end
end

return {
	system = replication,
	priority = CustomPriority.ServerReplication,
	event = "FixedUpdate",
	env = {
		production = {
			onlyServer = true,
		},
		devClient = {
			onlyServer = true,
		},
		dev = {
			onlyServer = true,
		},
	},
}
