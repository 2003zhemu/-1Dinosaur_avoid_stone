local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Matter = require(ReplicatedStorage.Packages.Matter)

local config = require(script.Parent.ProcedureManagerConfig)


local components = {}

components.Procedure = Matter.component("Procedure")

components.ProcedurePayload = Matter.component("ProcedurePayload")

return components
