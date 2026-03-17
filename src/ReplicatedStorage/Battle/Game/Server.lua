local start = require(script.Parent.start)
local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)

local state = require(script.Parent.Ecs.ServerState)
local context = require(script.Parent.Context)

-- 重要, 对组件进行混合, 不能删除这两行
local merger = require(script.Parent.Parent.Packages.MatterExtension.ComponentsMerger)
local components, componentConfigs = merger.Merge(context.Components, {
	game.ReplicatedStorage.Battle,
})
context.Components = components
-- 添加同步组件
local replicatedComponents = {}
for k, v in pairs(componentConfigs) do
	if v.Sync then
		replicatedComponents[components[k]] = {}
	end
end

local commonReplicatedComponents = table.clone(replicatedComponents)
commonReplicatedComponents[components.Transform] = nil --Transform特殊同步

context.Components.Replication = Matter.component("Replication", {
	Common = commonReplicatedComponents, --通用的queryChanged同步组件
	All = replicatedComponents, --所有同步组件用于全量同步
	__debugToString = function(t)
		warn(t)
		local str = ""
		for k, v in pairs(t.Value) do
			str = str .. tostring(k) .. "\n"
		end
		return str
	end,
})

local GameServer = {}
GameServer.Start = function(gameState, system)
	local world = start({
		game.ReplicatedStorage.Battle.Core.Ecs,
		game.ReplicatedStorage.Battle.Game.Ecs,
		system,
	}, { Core = state(), Game = gameState }, context)
	return world, state, context
end

return GameServer
