local AudioManager = require(game.ReplicatedStorage.Packages.AudioManager)
local module = {}

function module:SubmitCode()
	self.Panel.Submited = true
end
return module
