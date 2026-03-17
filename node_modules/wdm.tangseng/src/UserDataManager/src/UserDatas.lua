local module = {}

local datas = {}

-- set data event
module.setDataEvent = Instance.new("BindableEvent")
module.setDataEvent.Name = "setDataEvent"
module.setDataEvent.Parent = script

-- delete data event
module.deleteDataEvent = Instance.new("BindableEvent")
module.deleteDataEvent.Name = "deleteDataEvent"
module.deleteDataEvent.Parent = script

module.GetDatas = function()
	return datas
end

module.GetData = function(userId: number)
	return datas[userId]
end

module.SetData = function(userId: number, profile: {})
	assert(profile)
	datas[userId] = profile
	module.setDataEvent:Fire(userId)
end

module.DeleteData = function(userId: number)
	datas[userId] = nil
	module.deleteDataEvent:Fire(userId)
end

return module
