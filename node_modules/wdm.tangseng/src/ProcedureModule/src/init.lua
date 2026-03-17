
local matter = require(game.ReplicatedStorage.Packages.Matter)


if game["Run Service"]:IsClient() then
    return require(script.Client)
	
else
    return require(script.Server)
end

