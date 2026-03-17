local defines =require(script.Defines)
local triggerfactory =require(script.TriggerFactory)
local triggersource =require(script.TriggerSource)

local module= {
	
}
--[=[
    @class TriggerManager
    @client

    触发器管理员
]=]

module.AddTrigger=function(triggerConfig:defines.TriggerConfig)
	local trigger = triggerfactory.BuildTrigger(triggerConfig)
	
	if triggerConfig.Group then
		
		triggersource.AddTriggerIntoTriggerList(trigger,triggerConfig.Group)
		
	else
		triggersource.AddTriggerIntoTriggerList(trigger)

	end
	
end

module.RemoveTrigger=function(triggerName:string)
	triggersource.RemoveTriggerFromTriggerList(triggerName)
end

module.ActiveTriggers=function(triggerName)
	triggersource.ActiveTrigger(triggerName)
end

module.DisActiveTriggers=function(triggerName)
	triggersource.DisactiveTrigger(triggerName)
end

module.GetActiveTriggerList =function()
	return triggersource.GetActiveTriggerList()
end
module.GetAllTriggerList =function()
	return triggersource.GetAllTriggerList()
		
end
module.EventSourceFactory = require(script.EventSourceFactory)

return module
