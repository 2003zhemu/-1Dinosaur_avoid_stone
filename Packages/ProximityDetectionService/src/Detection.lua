--[=[
    @class Detection
]=]
local Prompt = require(script.Parent.Prompt)
local Defines = require(script.Parent.Defines)

local Detection = {}
Detection.__index = Detection

-- detection构造方法
-- @param name string
-- @param instance Instance
-- @param options Defines.Options
-- @return any
function Detection.new(name: string, instance: Instance, options: Defines.Options)
	local self = {}
	setmetatable(self, Detection)
	
	self.prompt = Prompt.new(instance, name)					--创建自定义prompt，带抛出事件
	self.prompt.MaxActivationDistance = options.Distance or 0	--设置触发距离
	self.prompt.Enabled = false									--初始化不可用，需手动激活（activate）

	self.name = name				--名
	self._activated = false			--是否激活
	self.group = nil				--分组group
	self.close = options.Close		--靠近触发
	self.away = options.Away		--离开触发

	return self
end

--[=[
    设置靠近触发
    @param callback (detection: Detection) -> ()
    @return void
]=]
function Detection:setClose(callback: (detection: any?) -> ())
	self.close = callback
end
--[=[
    设置离开触发
    @param callback (detection: Detection) -> ()
    @return void
]=]
function Detection:SetAway(callback: (detection: any?) -> ())
	self.away = callback
end
--触发靠近方法
function Detection:getClose()
	local callback: (this: any) -> () = self.close
	if callback then
		callback(self)
	end
end
--触发离开方法
function Detection:moveAway()
	local callback: (this: any) -> () = self.away
	if callback then
		callback(self)
	end
end
--[=[
    设置detection可用性
    @param activated boolean
    @return void
]=]
function Detection:activate(activated: boolean)
	assert(typeof(activated) == "boolean" or not activated, "activated value must be a boolean or nil")
	if activated == nil then
		activated = true
	end
	if self._activated == activated then
		return
	end
	self._activated = activated
	self.prompt.Enabled = activated
end
--[=[
    设置detection不可用
    @return void
]=]
function Detection:deactivate()
	self:activate(false)
end
--[=[
    销毁
    @return void
]=]
function Detection:destroy()
	self:deactivate()
	self.prompt:Destroy()
	self.group:removeDetection(self)
end

return Detection