-- 临时使用, 回头改为单元测试
local sdk = require(game.ReplicatedStorage.Packages.GameAnalytics)

sdk:setEnabledReportErrors(false)

local debugOptions = require(game.ReplicatedStorage.Packages.DebugOptions)
local isEnable = debugOptions.IsEnable("GA日志开关")
sdk:setEnabledInfoLog(isEnable)
sdk:setEnabledVerboseLog(isEnable)

local KeyConfig = require(game.ServerStorage.Configs.GameAnalyticsKey)

sdk:initServer(KeyConfig.Key, KeyConfig.Secret)

-- track
local Tracking = require(game.ReplicatedStorage.Packages.Tracking)
Tracking.Init(require(game.ReplicatedStorage._genConfigs.tracking_tbevent))

local function onPlayerAdded(player)
	local st = tick()
	player:SetAttribute("Login", st)

	local joinData = player:GetJoinData()
	if joinData and joinData.TeleportData then
		for i, v in pairs(joinData.TeleportData) do
			if i == "FromBattle" then
				player:SetAttribute("FromBattle", v)
			end
		end
	end
end
for i, player in pairs(game.Players:GetPlayers()) do
	onPlayerAdded(player)
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
game.Players.PlayerRemoving:Connect(function(player)
	if not player:GetAttribute("Teleporting") then
		local t = player:GetAttribute("Login") or tick() - 1
		local diff = math.floor(tick() - t)
		local t = tick() - player:GetAttribute("Login")
		-- Tracking.Fire(player.UserId, "大厅直接退出", diff)
	else
		local fromBattle = player:GetAttribute("FromBattle")
		if fromBattle then
			-- Tracking.Fire(player.UserId, "开启下局对战")
		end
	end
end)
