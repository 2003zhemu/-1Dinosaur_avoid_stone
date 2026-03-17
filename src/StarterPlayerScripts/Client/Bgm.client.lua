local sounds = require(game.ReplicatedStorage._genConfigs.asset_tbsound)
local AudioManager = require(game.ReplicatedStorage.Packages.AudioManager)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local EventStartTimeCfg = require(game.ReplicatedStorage.Configs.EventStartTimeCfg)

local localPlayer = game.Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local Zone = require(game.ReplicatedStorage.Packages.Zone)

local soundIds = {}
for k, v in pairs(sounds) do
	table.insert(soundIds, k)
end
AudioManager:Preload(soundIds)

local lobbyPart = game.Workspace.StageZones:FindFirstChild("Lobby")
local lobbyBGM = SoundService:FindFirstChild("大厅BGM")
local stageBGM = SoundService:FindFirstChild("关卡BGM")
local eventBGM = SoundService:FindFirstChild("活动BGM")
local _eventStartBGM = SoundService:FindFirstChild("活动开始")

if not lobbyPart or not lobbyBGM or not stageBGM then
	repeat
		lobbyPart = game.Workspace.StageZones:FindFirstChild("Lobby")
		lobbyBGM = SoundService:FindFirstChild("大厅BGM")
		stageBGM = SoundService:FindFirstChild("关卡BGM")
		task.wait(0.1)
	until lobbyPart and lobbyBGM and stageBGM
end

-- 活动时间判断（与 Control.lua EventStart 一致）
local CYCLE_DURATION = 7 * 24 * 60 * 60
local EVENT_DURATION = 1 * 60 * 60

local function isEventActive()
	local now = game.Workspace:GetServerTimeNow()
	for _, ref in ipairs(EventStartTimeCfg) do
		local elapsed = now - ref
		if elapsed >= 0 then
			local cycleElapsed = elapsed % CYCLE_DURATION
			if cycleElapsed < EVENT_DURATION then
				return true
			end
		end
	end
	return false
end

-- 记录玩家当前是否在大厅，用于活动结束后恢复正确的 BGM
local isInLobby = true

local playerInLobby = game.Players.LocalPlayer:GetAttribute("InLobby")
if playerInLobby then
	isInLobby = true
	if not isEventActive() then
		lobbyBGM:Play()
		stageBGM:Stop()
	end
else
	isInLobby = false
	if not isEventActive() then
		lobbyBGM:Stop()
		stageBGM:Play()
	end
end
game.Players.LocalPlayer:GetAttributeChangedSignal("InLobby"):Connect(function()
	playerInLobby = game.Players.LocalPlayer:GetAttribute("InLobby")
	if playerInLobby then
		isInLobby = true
		if not isEventActive() then
			lobbyBGM:Play()
			stageBGM:Stop()
		end
	else
		isInLobby = false
		if not isEventActive() then
			lobbyBGM:Stop()
			stageBGM:Play()
		end
	end
end)

local Region = Zone.new(lobbyPart)
Region.localPlayerEntered:Connect(function(player)
	if player == localPlayer then
		isInLobby = true
		if not isEventActive() then
			lobbyBGM:Play()
			stageBGM:Stop()
		end
	end
end)

Region.localPlayerExited:Connect(function(player)
	if player == localPlayer then
		isInLobby = false
		if not isEventActive() then
			lobbyBGM:Stop()
			stageBGM:Play()
		end
	end
end)

-- 初始 BGM 状态
local wasEventActive = isEventActive()
if wasEventActive then
	if eventBGM then
		eventBGM:Play()
	end
	lobbyBGM:Stop()
	stageBGM:Stop()
else
	lobbyBGM:Play()
	stageBGM:Stop()
end

-- 每秒轮询活动状态，处理切换
task.spawn(function()
	while true do
		local eventActive = isEventActive()
		if eventActive and not wasEventActive then
			-- 活动刚开始：停止普通 BGM，播放活动 BGM
			lobbyBGM:Stop()
			stageBGM:Stop()
			if eventBGM then
				eventBGM:Play()
			end
		elseif not eventActive and wasEventActive then
			-- 活动刚结束：停止活动 BGM，按区域恢复
			if eventBGM then
				eventBGM:Stop()
			end
			if isInLobby then
				lobbyBGM:Play()
				stageBGM:Stop()
			else
				lobbyBGM:Stop()
				stageBGM:Play()
			end
		end
		wasEventActive = eventActive
		task.wait(1)
	end
end)

EventBus.ConnectS2C(function(eventName, params)
	if eventName == EventDefines["玩家领取奖杯"] then
		AudioManager:PlaySoundEffect("奖杯")
		--恢复玩家血量
		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.Health = humanoid.MaxHealth
			end
		end
	end
	if eventName == EventDefines["玩家进入新关卡"] then
		AudioManager:PlaySoundEffect("进入新关卡")
		local stageId = params.StageId
		EventBus.FireServer("埋点", "玩家关卡进度（电脑）", stageId)
		if game.UserInputService.TouchEnabled then
			EventBus.FireServer("埋点", "玩家关卡进度（手机）", stageId)
		end
	end
end)
