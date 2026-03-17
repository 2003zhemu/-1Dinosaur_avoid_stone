local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local module = {}

function module:Load() end

function module:Start()
	
end

function module:ClaimOnlineReward(i)
	local list = self.OnlineState:GetList()
	local v = list[i]
	if v.MoreInfo.IsGet then
		Alert.Info("The reward has been claimed!")
	else
		if v.MoreInfo.CanGet then
			self.OnlineState.RewardShow += 1
		else
			Alert.Info("Cannot be obtained before the bonus time!")
		end
	end
end

function module:SubmitCode()
	self.Panel.Submited = true
end
return module
