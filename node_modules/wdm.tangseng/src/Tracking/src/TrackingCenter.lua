local RunService = game:GetService("RunService")
local EventProcessor = require(script.Parent.EventProcessor)

local TrackingCenter = {}
TrackingCenter.__index = TrackingCenter

local remoteEvent: RemoteEvent = nil

if game["Run Service"]:IsServer() then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "TrackingCenterEvent"
	remoteEvent.Parent = script.Parent
else
	remoteEvent = script.Parent:WaitForChild("TrackingCenterEvent")
end

-- 获取统计服务
local function getService(serviceName: string?): EventProcessor.EventConfig
	return require(script.Parent.Services.GameAnalytics)
end

-- 验证域
local function validateRegion(eventConfigs: { EventProcessor.EventConfig }, isClient: boolean, eventId: string)
	for k, config in pairs(eventConfigs) do
		if config.Id == eventId then
			if config.IsClient ~= isClient then
				error("EventId: " .. eventId .. " is not " .. (isClient and "client" or "server") .. " event")
			end
			return config
		end
	end
	error("EventId: " .. eventId .. " is not found")
end

-- new TrackingCenter
function TrackingCenter.new(eventConfigs: { EventProcessor.EventConfig }, serviceName: string?)
	local self = setmetatable({}, TrackingCenter)
	self.EventConfigs = eventConfigs
	self.Service = getService(serviceName)
	if RunService:IsServer() then
		remoteEvent.OnServerEvent:Connect(function(player: Player, eventId: string, ...)
			local config = validateRegion(eventConfigs, true, eventId)
			EventProcessor.ProcessEvent(player.UserId, self.Service, config, ...)
		end)
	end
	return self
end

--- 客户端通过EventBus触发事件
function TrackingCenter:OnReceiveEventBusMessage(userId: number, eventId: string, ...)
	local config = validateRegion(self.EventConfigs, true, eventId)
	EventProcessor.ProcessEvent(userId, self.Service, config, ...)
end

--- 服务端触发事件
function TrackingCenter:Fire(userId: number, eventId: string, ...)
	local config = validateRegion(self.EventConfigs, false, eventId)
	EventProcessor.ProcessEvent(userId, self.Service, config, ...)
end

--- 客户端触发事件
function TrackingCenter:FireServer(eventId: string, ...)
	validateRegion(self.EventConfigs, true, eventId)
	remoteEvent:FireServer(eventId, ...)
end

export type Type = typeof(TrackingCenter.new())

return TrackingCenter
