local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Env = require(game.ReplicatedStorage.Packages.Environment)
local start = require(script.Parent.start)
local ClientState = require(script.Parent.Ecs.ClientState)
local context = require(script.Parent.Context)

-- 重要, 对组件进行混合, 不能删除这两行
local merger = require(script.Parent.Parent.Packages.MatterExtension.ComponentsMerger)
context.Components = merger.Merge(context.Components, {
	game.ReplicatedStorage.Battle,
})
local GameClient = {}

--启动客户端
GameClient.Start = function(GameState, system)
	-- start world
	if context.IsEcsServer then
		-- 单机模式等待workspace资源加载完毕
		task.wait(3)
	end
	-- wait for ui load
	local world, state, _ = start({
		ReplicatedStorage.Battle.Core.Ecs,
		ReplicatedStorage.Battle.Game.Ecs,
		system,
	}, { Core = ClientState(), Game = GameState }, context)

	-- setupTags(world,state,context)
	local replcation = require(game.ReplicatedStorage.Battle.Game.clientReplication)

	local entityMap = replcation.BeginReplication(world, state, context)
	return world, state, context
end

--开启单机模式
GameClient.StartStandAloneMode = function() end

return GameClient
