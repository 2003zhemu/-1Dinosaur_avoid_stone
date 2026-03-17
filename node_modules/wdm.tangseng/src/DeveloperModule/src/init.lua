local module = {}


if game["Run Service"]:IsServer() then
	--module = require(script.Server)
else
	module = require(script.Client)
end

return module
