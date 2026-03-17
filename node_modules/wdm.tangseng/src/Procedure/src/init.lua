--[=[
	@class Procedure
	@server
	@client

	流程

	提供两个事件：
	* OnEnterProcedure 进入流程事件
	* OnLeaveProcedure 离开流程事件

	```lua
	require(game.ReplicatedStorage.Packages.Procedure)

	local p1 = procedure.new({"Login","Born","Fight"}) -- 流程将在指定数组中循环
	p1.OnEnterProcedure:Connect(function(name)
		print("EnterProcedure:"..name)
	end)
	p1.OnLeaveProcedure:Connect(function(name)
		print("LeaveProcedure:"..name)
	end)

	```
]=]

local Procedure = {}
Procedure.__index = Procedure

--[=[
	Procedure 构造函数
	@param flow {string} - 进度流数组,将在完成当前进度后,自动进入下一个进度（或者第一个进度）,

	```lua
	local p1 = procedure.new({"Login","Born","Fight"}) -- 流程将在指定数组中循环
	```
]=]
function Procedure.new(flow: { string }?)
	local self = setmetatable({}, Procedure)
	self.__current = nil
	self.__flow = flow
	self.__procedureStartTime = 0
	self.__enterProcedureEvent = Instance.new("BindableEvent", script)
	self.__leaveProcedureEvent = Instance.new("BindableEvent", script)
	self.__context = {}
	self.OnEnterProcedure = self.__enterProcedureEvent.Event
	self.OnLeaveProcedure = self.__leaveProcedureEvent.Event
	return self
end

--- * 结束当前进度, 并自动跳转到下一个进度
--- * 如果没有设置下个进度,则会从flow中找寻
--- * 如果当前进度不在flow内,则报错,因为这意味着进度流不正确.
function Procedure:FinishCurrentProcedure()
	assert(self.__current, "Procedure not started")
	assert(self.__flow, "Procedure don't have any flow")
	assert(type(self.__flow) == "table", "Procedure flow must be a table")
	if not self.__next then
		for index, value in self.__flow do
			if value == self.__current then
				-- 判断是否在末尾,则需要重置为第一个进度
				if index == #self.__flow then
					self.__next = self.__flow[1]
				else
					self.__next = self.__flow[index + 1]
				end
			end
		end
	end

	if not self.__next then
		error("Procedure flow error:" .. self.__current .. " not in flow")
	end

	self:SetProcedure(self.__next)
end

--[=[
	* 设置当前进度
	* 如果参数为数组,则第一个为当前进度,第二个为下一进度

	```lua
	procedure:SetProcedure("Login")  -- 设置当前进度为Login
	procedure:SetProcedure({"Login","Born"})  -- 设置当前进度为Login,且在完成Login后,自动进入Born

	```
]=]
function Procedure:SetProcedure(procedure: string | { string })
	self.__next = nil
	if type(procedure) == "table" then
		assert(#procedure == 2, "Procedure flow error:procedure must be a table with 2 element")
		assert(type(procedure[1]) == "string", "Procedure flow error:procedure[1] must be a string")
		assert(type(procedure[2]) == "string", "Procedure flow error:procedure[2] must be a string")
		self.__next = procedure[2]
	end

	assert(procedure)
	if self.__current == procedure then
		return
	end

	if self.__current then
		self.__leaveProcedureEvent:Fire(self.__current)
	end

	self.__current = procedure
	self.__context = {}
	self.__procedureStartTime = os.clock()
	self.__enterProcedureEvent:Fire(self.__current)
end

--- 获取当前流程名称
function Procedure:GetProcedure(): string
	return self.__current
end

--- 设置当前流程上下文
function Procedure:SetProcedureContext(key: any, value: any)
	self.__context[key] = value
end

--- 获取当前流程上下文
function Procedure:GetProcedureContext(key: any)
	return self.__context[key]
end

--- 获取当前流程开始时间
function Procedure:GetProcedureStartTime(): number
	return self.__procedureStartTime
end

--- 获取当前流程持续时间
function Procedure:GetProcedureDuration(): number
	return os.clock() - self.__procedureStartTime
end

--- 是否处在指定流程名称
function Procedure:IsInProcedure(name: string)
	return self.__current == name
end

export type Type = typeof(Procedure.new())

return Procedure
