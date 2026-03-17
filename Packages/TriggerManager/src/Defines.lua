--!strict

local module = {}


--[=[
	@interface TriggerConfig
	.Name string -- 触发器名称（不可重复）
	.EventSourceProvider ()->(EventSource) -- 触发方法
	.Next (...any)->() -- 触发执行的方法
	.Group number? -- 触发器的分组
	@within TriggerManager
	触发器配置
]=]

--触发器配置
export type TriggerConfig={
	Name:string, 		 -- 触发器名称（不可重复）
	EventSourceProvider:()->(EventSource),          --触发方法	
	Next:(...any)->(),		--触发执行的方法
	Group:number?,            --触发器的分组
}

--[=[
	@interface ActiveTrigger
	.Name string -- 触发器名称（不可重复）
	.Method EventSource -- 触发方法
	@within TriggerManager
	已触发的触发器
]=]

--已触发的触发器
export type ActiveTrigger ={
	Name:string,
	Method:EventSource,   
}

--[=[
	@interface EventSource
	._Connect (...any)->() -- 激活触发器
	._Disconnect ()->() -- 取消激活触发器
	@within TriggerManager
	触发器
]=]
--触发方法
export type EventSource ={
	
	_Connect:(...any)->(), --激活触发器
	
	_Disconnect:()->(), -- 取消激活触发器
	
}

--[=[
	@interface Trigger
	.Name string -- 触发器名称（不可重复）
	.Active ()->() -- 激活触发器
	.DisActive ()->() -- 取消激活触发器
	@within TriggerManager
	触发器
]=]
export type Trigger ={
	Name:string,					-- 触发器名称（不可重复）
	Active:()->(),
	DisActive:()->()
}


--[=[
	@interface TriggerManager
	.AddTrigger (triggerConfig:TriggerConfig)->() -- 添加触发器
	.RemoveTrigger (triggerName:string)->()  -- 移除触发器
	.ActiveTriggers (triggerName:{Name:string?, Group:string? })->()   --激活触发器
	.DisActiveTriggers (triggerName:{Name:string?,Group:string? })->() --取消激活触发器
	.GetActiveTriggerList ()->(string) --获得当前激活的触发器列表
	.GetAllTriggerList ()->(string) --获得当前添加的所有触发器
	@within TriggerManager
	TriggerManager接口配置
]=]
export type TriggerManager ={

	---添加触发器
	AddTrigger:(triggerConfig:TriggerConfig)->(),

	---移除触发器
	RemoveTrigger:(triggerName:string)->(),

	--激活触发器
	ActiveTriggers:(triggerName:{
		Name:string?,		--激活某个触发器  
		Group:string?,		--激活某组触发器			ex 激活第一个场景的触发器
	})->(),

	--取消激活触发器
	DisActiveTriggers:(triggerName:{
		Name:string?,		--取消激活某个触发器
		Group:string?,		--取消激活某组触发器  

	})->(),

	--获得当前激活的触发器列表
	GetActiveTriggerList:()->(string),

	--获得当前添加的所有触发器
	GetAllTriggerList:()->(string),
}

return module
