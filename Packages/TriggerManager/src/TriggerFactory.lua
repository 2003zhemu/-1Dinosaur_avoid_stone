local module = {}
local Defines =require(script.Parent.Defines)

module.BuildTrigger= function(triggerConfig:Defines.TriggerConfig)
	
	local eventSource:Defines.EventSource =triggerConfig.EventSourceProvider()
	
	
	local trigger:Defines.Trigger ={
		Name=triggerConfig.Name,
		
		Active= function()
			eventSource._Connect(triggerConfig.Next)
		end,
		
		DisActive =function()
			eventSource._Disconnect()
		end,
		
		
	}
	
	return trigger
end




return module
