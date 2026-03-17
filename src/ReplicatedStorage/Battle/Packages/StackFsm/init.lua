local LinkedList = require(game.ReplicatedStorage.Battle.Packages.Generic.LinkedList)
local HttpService = game.HttpService
local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)

-- 状态机类定义
-- 下推状态机,参考:https://www.lfzxb.top/nkgmoba-statesystem/
local StackFsm = {}
StackFsm.__index = StackFsm

-- 创建新的状态机实例
function StackFsm.new(...)
	local payload = { ... }
	local fsm = {}
	fsm.payload = payload
	fsm.m_States = {}
	fsm.m_FsmStateBases = LinkedList.new()
	setmetatable(fsm, StackFsm)
	return fsm
end

export type Type = typeof(StackFsm.new({}))

type FsmCallback = (fsm: Type, world: Matter.World, state: {}, context: {}) -> ()

export type State = {
	StateTypes: number,
	StateName: string,
	ConflictStateTypes: number,
	OnEnter: FsmCallback?,
	OnRemoved: FsmCallback?,
	OnExit: FsmCallback?,
}

function StackFsm:GetStateCount(): number
	return #self.m_States
end

-- 获取栈顶状态
function StackFsm:GetCurrentState(): State
	if self.m_FsmStateBases:IsEmpty() then
		return nil
	end
	return self.m_FsmStateBases:First()
end

-- 检查是否为栈顶状 态
function StackFsm:CheckIsFirstState(aFsmStateBase: State)
	return aFsmStateBase == self:GetCurrentState()
end

-- 移除状态（通过名称）
-- 返回是否移除成功
function StackFsm:RemoveState(stateName): boolean
	local temp = self:GetState(stateName)
	if not temp then
		return false
	end

	local isRemoved = false

	local theRemovedItemIsFirstState = self:CheckIsFirstState(temp)
	local stateTypeList = self.m_States[temp.StateTypes]
	for i, state in ipairs(stateTypeList) do
		if state == temp then
			isRemoved = true
			table.remove(stateTypeList, i)
			break
		end
	end

	self.m_FsmStateBases:Delete(temp)

	if temp.OnRemoved then
		temp:OnRemoved(self, unpack(self.payload))
	end
	-- 在Lua中没有ReferencePool，所以暂时忽略

	local firstS = self:GetCurrentState()
	if theRemovedItemIsFirstState and firstS and firstS.OnEnter then
		firstS.OnEnter(self, unpack(self.payload))
	end

	return isRemoved
end

-- 移除状态
-- 返回是否移除成功
function StackFsm:RemoveStateByStateTypes(stateTypes): boolean
	-- 如果没有完全相等的状态类型，则直接返回
	if not self:HasAbsoluteEqualsState(stateTypes) then
		return false
	end

	local statesToBeRemoved = {}

	-- 遍历指定状态类型的所有状态
	for _, state in ipairs(self.m_States[stateTypes]) do
		table.insert(statesToBeRemoved, state)
	end

	local isRemoved = false

	self.m_States[stateTypes] = {}

	local removedFirstState = false

	-- 对所有待移除的状态进行处理
	for _, state in ipairs(statesToBeRemoved) do
		if not removedFirstState then
			removedFirstState = self:CheckIsFirstState(state)
		end

		if self.m_FsmStateBases:Delete(state) then
			isRemoved = true
		end

		if state.OnExit then
			state.OnExit(self, unpack(self.payload))
		end
		if state.OnRemoved then
			state:OnRemoved(self, unpack(self.payload))
		end

		-- ReferencePool:Release(state) -- 假设ReferencePool在Lua中以单例的形式存在
	end

	-- 如果移除的状态中包含了首状态
	if removedFirstState then
		local currentFsmState = self:GetCurrentState()
		if currentFsmState and currentFsmState.OnEnter then
			currentFsmState.OnEnter(self, unpack(self.payload))
		end
	end
	return isRemoved
end

-- 是否包含某个状态_通过状态类型判断，需要包含targetStateTypes的超集才会返回true
function StackFsm:ContainsState(targetStateTypes: number): boolean
	-- 遍历所有的状态
	for key, value in pairs(self.m_States) do
		-- 如果目标状态类型是当前状态类型的子集，并且状态列表不为空，则返回true
		if (bit32.band(targetStateTypes, key) == targetStateTypes) and (#value > 0) then
			return true
		end
	end
	return false
end

-- 是否完全包含某个状态，需要包含targetStateTypes一致的时候才会返回true
function StackFsm:HasAbsoluteEqualsState(targetStateTypes): boolean
	-- 遍历所有的状态
	for key, value in pairs(self.m_States) do
		-- 如果当前状态类型与目标状态类型完全一致，并且状态列表不为空，则返回true
		if (targetStateTypes == key) and (#value > 0) then
			return true
		end
	end

	return false
end

-- 是否会发生状态互斥，只要包含了conflictStateTypes的子集， 就返回true
function StackFsm:CheckConflictState(conflictStateTypes): boolean
	-- 遍历当前状态机中的状态
	for key, states in pairs(self.m_States) do
		-- 判断状态是否互斥，即：当前状态和冲突状态有重叠并且当前状态类型不为0且状态数量大于0
		if key ~= 0 and bit32.band(conflictStateTypes, key) == key and #states > 0 then
			return true
		end
	end
	return false
end

-- 根据状态名称获取状态
function StackFsm:GetState(stateName): State
	local current = self.m_FsmStateBases.head
	while current do
		if current.Data.StateName == stateName then
			return current.Data
		end
		current = current.Next
	end
	return nil
end

-- 向状态机添加一个状态，如果当前已存在，说明需要把它提到同优先级状态的前面去， 让他先执行
-- 私有函数
function StackFsm:__insertState(fsmStateToInsert: State, containsItSelf: boolean)
	containsItSelf = containsItSelf or false -- 默认值

	if fsmStateToInsert.TryEnter and not fsmStateToInsert.TryEnter(self, unpack(self.payload)) then
		-- 如果没有目标状态，说明是新增的状态，但是没有成功 添加，需要归还给引用池
		if not containsItSelf then
			-- ReferencePool.Release(fsmStateToInsert)
		end
		return
	end

	local current = self.m_FsmStateBases.head

	local insertPriority = fsmStateToInsert.Priority or 0

	while current do
		local curPriority = current.Data.Priority or 0

		if insertPriority >= curPriority then
			break
		end
		current = current.Next
	end

	local tempFirstState = self:GetCurrentState()

	-- 如果包含自身，就看current是不是自己， 如果是，就不对链表做改变，如果不是就提到current前面
	if containsItSelf then
		if fsmStateToInsert.StateName == current.Data.StateName then
			return
		else
			self.m_FsmStateBases:Delete(fsmStateToInsert)
			self.m_FsmStateBases:AddBefore(current.Data, fsmStateToInsert)
		end
	else
		-- 如果不包含自身，且current不为空，即代表非尾节点有自己的位置，就插入到最前面，
		-- 否则代表所有结点优先级都大于自身，就直接插入链表最后面
		if current then
			self.m_FsmStateBases:AddBefore(current.Data, fsmStateToInsert)
		else
			self.m_FsmStateBases:Append(fsmStateToInsert)
		end

		local stateList = self.m_States[fsmStateToInsert.StateTypes]
		if stateList then
			table.insert(stateList, fsmStateToInsert)
		else
			self.m_States[fsmStateToInsert.StateTypes] = { fsmStateToInsert }
		end
	end

	-- 如果这个被插入的状态成为了链表首状态，说明发生了状态变化
	if self:CheckIsFirstState(fsmStateToInsert) and tempFirstState then
		if tempFirstState.OnExit then
			tempFirstState.OnExit(self, unpack(self.payload))
		end
		if fsmStateToInsert.OnEnter then
			fsmStateToInsert.OnEnter(self, unpack(self.payload))
		end
	end
end

-- 切换状态，如果当前已存在，说明需要把它提到同优先级状态的前面去，让他先执行
-- 这里的切换成功是指目标状态来到链表头部，插入到链表中或者插入失败都属于切换失败
function StackFsm:ChangeState(aFsmStateBase): boolean
	local tempFsmStateBase = self:GetState(aFsmStateBase.StateName)

	if tempFsmStateBase ~= nil then
		-- 因为已有此状态，所以进行回收
		-- ReferencePool.Release(aFsmStateBase)
		self:__insertState(tempFsmStateBase, true)
		return self:CheckIsFirstState(tempFsmStateBase)
	end

	self:__insertState(aFsmStateBase)
	return self:CheckIsFirstState(aFsmStateBase)
end

-- 切换状态，如果当前已存在，说明需要把它提到同优先级状态的前面去，让他先执行
-- 这里的切换成功是指目标状态来到链表头部，插入到链表中或者插入失败都属于切换失败
-- template , 状态的原型模板
function StackFsm:ChangeStateByStateTypes(template, stateTypes, stateName, priority): boolean
	local aFsmStateBase = self:GetState(stateName)

	if aFsmStateBase then
		self:__insertState(aFsmStateBase, true)
		return self:CheckIsFirstState(aFsmStateBase)
	end

	local tmp = HttpService:JSONEncode(template)
	local newState = HttpService:JSONDecode(tmp)
	newState.StateTypes = stateTypes
	newState.StateName = stateName
	newState.Priority = priority

	-- 使用提供的createAFsmStateBase函数创建新的AFsmStateBase实例
	aFsmStateBase = newState
	self:__insertState(aFsmStateBase)
	return self:CheckIsFirstState(aFsmStateBase)
end

return StackFsm
