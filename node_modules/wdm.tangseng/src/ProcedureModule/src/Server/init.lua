local module = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local start = require(script.Parent.Bootstrap)
local ob = require(script.ObservePlayers)
local cfg = require(script.Parent.ProcedureManagerConfig)
local components = require(script.Parent.Components)
local world = start({
	script.Systems,
	script.Parent.SharedSystems
})


local Matter = require(game.ReplicatedStorage.Packages.Matter)

ob.Start(world)

local module = {}


-- 获取当前流程名称
module.GetCurrentProcedure = function(player:Player)
	local id = ob.GetPlayerProcedureId(player)
	local component = world:get(id,components.Procedure)
	return component.Current
end


-- 更改流程
module.ChangeProcedure = function(player:Player,procedureName:string)
    assert(procedureName)
    assert(procedureName~="NotStart","不能设置状态为 'NotStart'")
	assert(table.find(cfg.ProcedureNames,procedureName)>0)
	
	local id = ob.GetPlayerProcedureId(player)
	local procedure = world:get(id,components.Procedure)

	if procedure.Current == procedureName then
		warn("目标流程与当前流程相等，无需切换:"..procedureName)
		return
	end
	
	local previous = procedure.Current
	world:insert(id,procedure:patch({
		Current = procedureName,
		Previous = previous,
		IsEnter = false
	}))
	
end

-- 退出当前流程，回复到默认流程
module.QuitProcedure = function(player:Player)
    local default = cfg.DefaultProcedure
    module.ChangeProcedure(player,default)
end


-- event from client
local eventBus = require(game.ReplicatedStorage.Packages.EventBus)
local eventNames = require(script.Parent.EventNames)

eventBus.ConnectC2S(function(player,eventName,...)
    
    if eventName == eventNames.EventChangeProcedure then
        module.ChangeProcedure(player,...)
    end
    
    if eventName == eventNames.EventQuitProcedure then
        module.QuitProcedure(player,...)
    end
    
end)


return module
