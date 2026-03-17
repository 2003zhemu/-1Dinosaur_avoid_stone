local RunService = game:GetService("RunService")
local Rewire = require(game.ReplicatedStorage.Battle.Packages.rewire)
local hotReloader = Rewire.HotReloader.new()

local module = {}

for k, v in pairs(script:GetChildren()) do
	if v:IsA("ModuleScript") then
		hotReloader:listen(v, function(newModule)
			local ok, m = pcall(require, newModule)
			if not ok then
				warn("Error when hot-reloading helper", newModule.Name)
				return
			end
			module[newModule.Name] = m
		end, function(_, context)
			if context.isReloading then
				return
			end
			local originalModule = context.originalModule
			module[originalModule.Name] = nil
		end)
	end
end

return module
