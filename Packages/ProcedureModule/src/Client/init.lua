local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local start = require(script.Parent.Bootstrap)
local receiveReplication = require(script:WaitForChild("ReceiveReplication"))
local components = require(script.Parent.Components)

local world, state = start({
	script.Parent.SharedSystems
	--ReplicatedStorage.Client.systems,
})



receiveReplication(world, state)

local eventBus = require(game.ReplicatedStorage.Packages.EventBus)
local eventNames = require(script.Parent.EventNames)

-- 获取当前流程名称
module.GetCurrentProcedure = function()
    local id = game.Players.LocalPlayer:GetAttribute("ProcedureID")
    local procedure = world:get(id,components.Procedure)
    return procedure.Current
end


-- 更改流程
module.ChangeProcedure = function(procedureName:string,payload:any?)
    eventBus.FireServer(eventNames.EventChangeProcedure,procedureName,payload)
end

-- 退出当前流程，回复到默认流程
module.QuitProcedure = function(payload:any?)
   
    eventBus.FireServer(eventNames.EventQuitProcedure,payload)
end



return module
