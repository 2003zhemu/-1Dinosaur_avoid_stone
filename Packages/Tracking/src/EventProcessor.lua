local module = {}

export type EventConfig = {
	Id: string,
	IsClient: (any) -> nil,
	EventType: {
		_type_: string,
	},
}

local function processEventDesign(userId: number, service, eventType: { Name: string }, ...)
	if not eventType.Name then
		error("event type name is nil")
	end

	service:ReportEventDesign(userId, eventType.Name, ...)
end

local function processEventProgressionStart(userId: number, service, eventType: {}, ...)
	service:ReportEventProgressionStart(userId, ...)
end

local function processEventProgressionComplete(userId: number, service, eventType: {}, ...)
	service:ReportEventProgressionComplete(userId, ...)
end

local function processEventProgressionFail(userId: number, service, eventType: {}, ...)
	service:ReportEventProgressionFail(userId, ...)
end

local function processEventError(userId: number, service, eventType: {}, ...)
	error("not implemented")
end

local function processEventResourceAdd(userId: number, service, eventType: {}, ...)
	error("not implemented")
end

local function processEventResourceSink(userId: number, service, eventType: {}, ...)
	error("not implemented")
end

local function processEventBusiness(userId: number, service, eventType: {}, ...)
	error("not implemented")
end

module.ProcessEvent = function(userId: number, service, eventConfig: EventConfig, ...)
	if eventConfig.EventType._type_ == "EventDesign" then
		processEventDesign(userId, service, eventConfig.EventType, ...)
	elseif eventConfig.EventType._type_ == "EventProgressionStart" then
		processEventProgressionStart(userId, service, eventConfig.EventType, ...)
	elseif eventConfig.EventType._type_ == "EventProgressionComplete" then
		processEventProgressionComplete(userId, service, eventConfig.EventType, ...)
	elseif eventConfig.EventType._type_ == "EventProgressionFail" then
		processEventProgressionFail(userId, service, eventConfig.EventType, ...)
	elseif eventConfig.EventType._type_ == "EventError" then
		processEventError(userId, service, eventConfig.EventType, ...)
	elseif eventConfig.EventType._type_ == "EventResourceAdd" then
		processEventResourceAdd(userId, service, eventConfig.EventType, ...)
	elseif eventConfig.EventType._type_ == "EventResourceSink" then
		processEventResourceSink(userId, service, eventConfig.EventType, ...)
	elseif eventConfig.EventType._type_ == "EventBusiness" then
		processEventBusiness(userId, service, eventConfig.EventType, ...)
	else
		error("invalid event type")
	end
end

return module
