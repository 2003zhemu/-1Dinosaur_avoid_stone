local module = {}
local defines =require(script.Parent.Defines)


local TriggerList ={

}


local GroupTriggerList={

}

local ActiveTriggerList= {
	
}

module.AddTriggerIntoTriggerList = function (...)

	local arr ={...}
	if #arr == 2 then

		if not GroupTriggerList[arr[2]] then
			GroupTriggerList[arr[2]]={}
		end

		table.insert(GroupTriggerList[arr[2]],arr[1])

	end

	table.insert(TriggerList,arr[1])

end

module.RemoveTriggerFromTriggerList =function(triggerName:string)
	for i,v:defines.Trigger in pairs(TriggerList) do
		if v.Name == triggerName then
			table.remove(TriggerList,i)
		end
	end

	for i,v in pairs(GroupTriggerList) do
		for j,k:defines.Trigger in v do
			if k.Name == triggerName then
				table.remove(GroupTriggerList[i],j)
			
			end
		end
	end
end

module.ActiveTrigger =function(triggerName:string)
	
	for i,v:defines.Trigger in pairs(TriggerList) do
		if v.Name == triggerName then
			table.insert(ActiveTriggerList,v)
			v.Active()
			return
		end
	end
	
	print("找不到该名称的触发器")
end

module.DisactiveTrigger =function(triggerName:string)
	for i,v:defines.Trigger in pairs(ActiveTriggerList) do
		if v.Name == triggerName then
			table.remove(ActiveTriggerList,i)
			v.DisActive()
			return
		end
	end

	print("找不到该名称的已激活触发器")
end

module.GetActiveTriggerList =function ()
	return ActiveTriggerList
end
module.GetAllTriggerList =function()
	return TriggerList
end

return module
