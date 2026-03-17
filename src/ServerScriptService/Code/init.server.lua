local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserDataManager = require(ReplicatedStorage.Packages.UserDataManager)
if ReplicatedStorage.Packages:FindFirstChild("CodeService") then
    require(ReplicatedStorage.Packages.CodeService).SetDataProvider(function(player)
        return UserDataManager.GetData(player.UserId)
    end)
end