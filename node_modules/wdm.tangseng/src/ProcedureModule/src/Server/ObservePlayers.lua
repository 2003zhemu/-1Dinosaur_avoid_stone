
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Components = require(script.Parent.Parent.Components)
local cfg = require(script.Parent.Parent.ProcedureManagerConfig)

local module = {}


module.SetPlayerProcedureId = function(player,id)
	return player:SetAttribute("ProcedureID",id)
end

module.GetPlayerProcedureId = function(player)
	return player:GetAttribute("ProcedureID")
end

local function _onStart(world,player)
	local id = world:spawn(

		Components.Procedure({
			Player = player,
			Current = "NotStart",
			IsEnter = true
		}),
		Components.ProcedurePayload()
	)
	module.SetPlayerProcedureId(player,id)
end

module.Start = function (world)

	game.Players.PlayerAdded:Connect(function(player)
		_onStart(world,player)
	end)

	game.Players.PlayerRemoving:Connect(function(player)
		local id = module.GetPlayerProcedureId(player)
		world:remove(id)
	end)
	
	for k,v in game.Players:GetPlayers() do
		_onStart(world,v)
	end
end


return module
