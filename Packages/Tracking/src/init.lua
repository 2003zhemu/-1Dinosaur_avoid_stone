local module = {}
local TrackingCenter = require(script.TrackingCenter)
local EventProcessor = require(script.EventProcessor)
local trackingCenter = nil
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local MESSAGE_NAME = "埋点"

--- 初始化
function module.Init(eventConfigs: { EventProcessor.EventConfig }, serviceName: string?)
	if trackingCenter then
		error("TrackingCenter is initialized")
	end
	trackingCenter = TrackingCenter.new(eventConfigs, serviceName)

	if game["Run Service"]:IsServer() then
		-- 服务端监听客户端发送来的RemoteEvent
		EventBus.ConnectC2S(function(player: Player, messageName: string, eventId: string, ...)
			if messageName ~= "埋点" then
				return
			end
			trackingCenter:OnReceiveEventBusMessage(player.UserId, eventId, ...)
		end)

		-- 服务端监听服务端发送来的Event
		EventBus.Connect(function(messageName: string, userId: number, eventId: string, ...)
			if messageName ~= "埋点" then
				return
			end
			trackingCenter:Fire(userId, eventId, ...)
		end)
	end
end

--- 服务端触发事件
function module.Fire(userId: number, eventId: string, ...)
	if not trackingCenter then
		error("TrackingCenter not initialized")
	end
	trackingCenter:Fire(userId, eventId, ...)
end

--- 客户端触发事件
function module.FireServer(eventId: string, ...)
	if not trackingCenter then
		error("TrackingCenter not initialized")
	end
	trackingCenter:FireServer(eventId, ...)
end

return module
