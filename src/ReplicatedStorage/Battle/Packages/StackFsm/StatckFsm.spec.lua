return function()
	local StackFsm = require(script.Parent)

	beforeEach(function() end)

	afterEach(function() end)
	it("should create a new StackFsm with correct initial properties", function()
		local fsm = StackFsm.new()

		-- 检查返回的对象是否为正确的类型
		expect(typeof(fsm)).to.equal("table")

		-- 检查状态表是否正确初始化
		expect(typeof(fsm.m_States)).to.equal("table")
		expect(next(fsm.m_States)).to.equal(nil) -- 检查m_States是否为空

		-- 检查状态链表是否正确初始化
		expect(fsm.m_FsmStateBases:IsEmpty()).to.equal(true)
	end)

	-- 测试用例1
	it("should return nil when no states are present", function()
		local fsm = StackFsm.new()
		expect(fsm:GetCurrentState()).to.equal(nil)
	end)

	-- 测试用例4
	it("should return nil when a state is added and then removed", function()
		local fsm = StackFsm.new()
		local state = { StateName = "TestState1", OnRemoved = function() end, StateTypes = 1 }
		fsm.m_FsmStateBases:Append(state)
		fsm.m_FsmStateBases:Delete(state)
		expect(fsm:GetCurrentState()).to.equal(nil)
	end)

	-- 测试2: 当状态机有一个状态时，应返回该状态
	it("should return the only state when FSM has one state", function()
		local fsm = StackFsm.new()
		local sampleState = {
			StateName = "SampleState",
			StateTypes = 1,
			Priority = 1,
		}
		fsm:ChangeState(sampleState)
		local currentState = fsm:GetCurrentState()
		expect(currentState).to.equal(sampleState)
	end)

	-- 测试3: 当状态机有多个状态时，应当返回优先级最高的那个
	it("should return the last added state when FSM has multiple states", function()
		local fsm = StackFsm.new()
		local firstState = {
			StateName = "FirstState",
			StateTypes = 1,
			Priority = 1,
		}
		local secondState = {
			StateName = "SecondState",
			StateTypes = 1,
			Priority = 2,
		}
		fsm:ChangeState(firstState)
		fsm:ChangeState(secondState)
		local currentState = fsm:GetCurrentState()
		expect(currentState).to.equal(secondState)
	end)

	-- 测试4: 当状态机添加了状态然后删除了，应返回nil
	it("should return nil when FSM had a state but was removed", function()
		local fsm = StackFsm.new()
		local sampleState = {
			StateName = "SampleState",
			StateTypes = 1,
			Priority = 1,
		}
		fsm:ChangeState(sampleState)
		fsm:RemoveState("SampleState")
		local currentState = fsm:GetCurrentState()
		expect(currentState).to.equal(nil)
	end)

	-- 测试5: 当状态机有多个状态，删除了非栈顶状态，仍应返回原始的栈顶状态
	it("should return the original top state when FSM has multiple states and a non-top state was removed", function()
		local fsm = StackFsm.new()
		local firstState = {
			StateName = "FirstState",
			StateTypes = 1,
			Priority = 1,
		}
		local secondState = {
			StateName = "SecondState",
			StateTypes = 2,
			Priority = 2,
		}
		fsm:ChangeState(firstState)
		fsm:ChangeState(secondState)
		fsm:RemoveState("FirstState")
		local currentState = fsm:GetCurrentState()
		expect(currentState).to.equal(secondState)
	end)

	-- 测试1: 当状态机没有状态时，任何状态都不是第一个状态
	it("should return false when FSM has no states", function()
		local fsm = StackFsm.new()
		local result = fsm:CheckIsFirstState({ StateName = "SampleState", StateTypes = 1 })
		expect(result).to.equal(false)
	end)

	-- 测试2: 当状态机有一个状态，并且检查这个状态时，应返回true
	it("should return true when checking the only state in FSM", function()
		local fsm = StackFsm.new()
		local sampleState = { StateName = "SampleState", StateTypes = 1 }
		fsm:__insertState(sampleState)
		local result = fsm:CheckIsFirstState(sampleState)
		expect(result).to.equal(true)
	end)

	-- 测试3: 当状态机有多个状态， 检查最后一个状态时，应返回 true
	it("should return true when checking the first added state in FSM with multiple states", function()
		local fsm = StackFsm.new()
		local firstState = { StateName = "FirstState", StateTypes = 1 }
		local secondState = { StateName = "SecondState", StateTypes = 2 }
		local state3 = { StateName = "state3", StateTypes = 3 }
		local state4 = { StateName = "state4", StateTypes = 4 }
		fsm:__insertState(firstState)
		fsm:__insertState(secondState)
		fsm:__insertState(state3)
		fsm:__insertState(state4)
		local result = fsm:CheckIsFirstState(state4)
		expect(result).to.equal(true)
	end)

	-- 测试4: 当状态机有多个状态，检查非第一个状态时，应返回false
	it("should return false when checking any state other than the first in FSM with multiple states", function()
		local fsm = StackFsm.new()
		local firstState = { StateName = "FirstState", StateTypes = 1 }
		local secondState = { StateName = "SecondState", StateTypes = 0, Priority = -1 }
		fsm:__insertState(firstState)
		fsm:__insertState(secondState)
		local result = fsm:CheckIsFirstState(secondState)
		expect(result).to.equal(false)
	end)

	-- 测试5: 当检查的状态在状态机中不存在时，应返回false
	it("should return false when checking a state that doesn't exist in FSM", function()
		local fsm = StackFsm.new()
		local existingState = { StateName = "ExistingState", StateTypes = 1 }
		local nonExistingState = { StateName = "NonExistingState", StateTypes = 1 }
		fsm:__insertState(existingState)
		local result = fsm:CheckIsFirstState(nonExistingState)
		expect(result).to.equal(false)
	end)
	-- 测试1: 当状态机没有状态时，尝试删除状态应该不产生效果
	it("should do nothing when FSM has no states", function()
		local fsm = StackFsm.new()
		local stateName = "SampleState"
		expect(fsm:RemoveState(stateName)).to.equal(false)
	end)

	-- 测试2: 当状态机有一个匹配的状态，该状态应被成功删除
	it("should remove the state when FSM has a matching state", function()
		local fsm = StackFsm.new()
		local stateName = "SampleState"
		fsm:__insertState({ StateName = stateName, StateTypes = 1 })

		expect(fsm:RemoveState(stateName)).to.equal(true)
	end)

	-- 测试3: 当状态机有多个状态，删除其中一个后，其余状态仍应保持不变
	it("should only remove the specified state when FSM has multiple states", function()
		local fsm = StackFsm.new()
		local firstState = 2
		local secondState = 4
		fsm:__insertState({ StateName = firstState, StateTypes = firstState })
		fsm:__insertState({ StateName = secondState, StateTypes = secondState })

		expect(fsm:RemoveStateByStateTypes(firstState)).to.equal(true)
		-- 再次确认未被删除的状态仍然存在
		-- 这里假设有一个ContainsState方法，如果没有，请替换为适当的方法
		expect(fsm:ContainsState(secondState)).to.equal(true)
	end)

	-- 测试4: 当尝试删除不存在的状态时，状态机不应发生变化
	it("should not modify FSM when trying to remove a non-existing state", function()
		local fsm = StackFsm.new()
		local existingState = 1
		local nonExistingState = 2
		fsm:__insertState({ StateName = existingState, StateTypes = existingState })
		fsm:RemoveState(nonExistingState)
		expect(fsm:GetStateCount()).to.equal(1)
		expect(fsm:ContainsState(existingState)).to.equal(true)
	end)

	-- 测试5: 连续删除同一状态应只有第一次有效
	it("should only remove a state once", function()
		local fsm = StackFsm.new()
		local stateName = "SampleState"
		fsm:__insertState({ StateName = stateName, StateTypes = 1 })

		expect(fsm:RemoveState(stateName)).to.equal(true)
		expect(fsm:RemoveState(stateName)).to.equal(false)
	end)

	it("应当正确地切换到新状态并成为链表的头部", function()
		local fsm = StackFsm.new()
		local template = { Key = "Value" }
		local isSuccess = fsm:ChangeStateByStateTypes(template, 1, "TestState", 5)
		expect(isSuccess).to.equal(true)
		expect(fsm:GetCurrentState().StateName).to.equal("TestState")
	end)

	it("应当保持当前链表的头部状态不变，当试图切换到一个优先级较低的状态", function()
		local fsm = StackFsm.new()
		local template1 = { Key = "Value1" }
		local template2 = { Key = "Value2" }
		fsm:ChangeStateByStateTypes(template1, 1, "State1", 10)
		fsm:ChangeStateByStateTypes(template2, 2, "State2", 5)
		expect(fsm:GetCurrentState().StateName).to.equal("State1")
	end)

	it("当试图切换到一个已存在的状态，该状态位置不发生改变 ", function()
		local fsm = StackFsm.new()
		local template1 = { Key = "Value1" }
		local template2 = { Key = "Value2" }
		fsm:ChangeStateByStateTypes(template1, 1, "State1", 5)
		fsm:ChangeStateByStateTypes(template2, 2, "State2", 10)
		fsm:ChangeStateByStateTypes(template1, 1, "State1", 5)
		expect(fsm:GetCurrentState().StateName).to.equal("State2")
	end)

	it("当切换到新状态时，新状态应当包含正确的属性值 ", function()
		local fsm = StackFsm.new()
		local template = { Key = "Value" }
		fsm:ChangeStateByStateTypes(template, 1, "TestState", 5)
		local currentState = fsm:GetCurrentState()
		expect(currentState.StateName).to.equal("TestState")
		expect(currentState.StateTypes).to.equal(1)
		expect(currentState.Priority).to.equal(5)
		expect(currentState.Key).to.equal("Value")
	end)

	it("当多次切换到新状态时，链表头部应当始终为优先级最高的状态", function()
		local fsm = StackFsm.new()
		local template1 = { Key = "Value1" }
		local template2 = { Key = "Value2" }
		local template3 = { Key = "Value3" }
		fsm:ChangeStateByStateTypes(template2, 2, "State2", 2)
		fsm:ChangeStateByStateTypes(template1, 1, "State1", 1)
		fsm:ChangeStateByStateTypes(template3, 3, "State3", 3)
		expect(fsm:GetCurrentState().StateName).to.equal("State3")
	end)

	-- 1. 测试移除存在的状态
	it("should remove an existing state by name", function()
		local fsm = StackFsm.new()
		local state = { StateName = "TestState1", Priority = 1, StateTypes = 1 }
		fsm:__insertState(state)
		local result = fsm:RemoveState("TestState1")
		expect(result).to.equal(true)
		expect(fsm:GetState("TestState1")).to.equal(nil)
	end)

	-- 2. 测试移除不存在的状态
	it("should return false when trying to remove a non-existing state", function()
		local fsm = StackFsm.new()
		local result = fsm:RemoveState("TestState2")
		expect(result).to.equal(false)
	end)

	-- 3. 测试移除状态后是否调用OnRemoved方法
	it("should call OnRemoved when a state is removed", function()
		local fsm = StackFsm.new()
		local isOnRemovedCalled = false
		local state = {
			StateName = "TestState3",
			Priority = 1,
			StateTypes = 1,
			OnRemoved = function()
				isOnRemovedCalled = true
			end,
		}
		fsm:__insertState(state)
		fsm:RemoveState("TestState3")
		expect(isOnRemovedCalled).to.equal(true)
	end)

	-- 4. 测试移除首状态后，下一个状态是否变为首状态并调用OnEnter
	it("should set the next state as current and call its OnEnter when the first state is removed", function()
		local fsm = StackFsm.new()
		local isOnEnterCalled = false
		local state1 = { StateName = "TestState4", Priority = 2, StateTypes = 1 }
		local state2 = {
			StateName = "TestState5",
			Priority = 1,
			StateTypes = 1,
			OnEnter = function()
				isOnEnterCalled = true
			end,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		fsm:RemoveState("TestState4")
		expect(fsm:GetCurrentState().StateName).to.equal("TestState5")
		expect(isOnEnterCalled).to.equal(true)
	end)

	-- 5. 测试移除非首状态时，首状态不受影响
	it("should keep the current state unchanged when removing a non-first state", function()
		local fsm = StackFsm.new()
		local state1 = { StateName = "TestState6", Priority = 1, StateTypes = 1 }
		local state2 = { StateName = "TestState7", Priority = 2, StateTypes = 1 }
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		fsm:RemoveState("TestState7")
		expect(fsm:GetCurrentState().StateName).to.equal("TestState6")
	end)

	-- 1. 测试移除存在的状态类型
	it("should remove states with the specified stateTypes", function()
		local fsm = StackFsm.new()
		local state1 = { StateName = "TestState1", Priority = 1, StateTypes = 2 }
		local state2 = { StateName = "TestState2", Priority = 2, StateTypes = 2 }
		local state3 = { StateName = "TestState3", Priority = 3, StateTypes = 3 }
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		fsm:__insertState(state3)
		local result = fsm:RemoveStateByStateTypes(2)
		expect(fsm:GetState("TestState1")).to.equal(nil)
		expect(fsm:GetState("TestState2")).to.equal(nil)
	end)

	-- 2. 测试移除不存在的状态类型
	it("should return false when trying to remove states with a non-existing stateTypes", function()
		local fsm = StackFsm.new()
		local result = fsm:RemoveStateByStateTypes(4)
		expect(result).to.equal(false)
	end)

	-- 3. 测试移除状态后是否调用OnRemoved方法
	it("should call OnRemoved for states with the specified stateTypes when they are removed", function()
		local fsm = StackFsm.new()
		local isOnRemovedCalled1 = false
		local isOnRemovedCalled2 = false
		local state1 = {
			StateName = "TestState4",
			Priority = 1,
			StateTypes = 2,
			OnRemoved = function()
				isOnRemovedCalled1 = true
			end,
		}
		local state2 = {
			StateName = "TestState5",
			Priority = 2,
			StateTypes = 2,
			OnRemoved = function()
				isOnRemovedCalled2 = true
			end,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		fsm:RemoveStateByStateTypes(2)
		expect(isOnRemovedCalled1).to.equal(true)
		expect(isOnRemovedCalled2).to.equal(true)
	end)

	-- 4. 测试移除首状态类型后，下一个状态是否变为首状态并调用OnEnter
	it("should set the next state as current and call its OnEnter when the first state types are removed", function()
		local fsm = StackFsm.new()
		local isOnEnterCalled = false
		local state1 = { StateName = "TestState6", Priority = 2, StateTypes = 3 }
		local state2 = {
			StateName = "TestState7",
			Priority = 1,
			StateTypes = 2,
			OnEnter = function()
				isOnEnterCalled = true
			end,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		fsm:RemoveStateByStateTypes(3)
		expect(fsm:GetCurrentState().StateName).to.equal("TestState7")
		expect(isOnEnterCalled).to.equal(true)
	end)

	-- 5. 测试移除非首状态类型时，首状态不受影响
	it("should keep the current state unchanged when removing non-first state types", function()
		local fsm = StackFsm.new()
		local state1 = { StateName = "TestState8", Priority = 1, StateTypes = 2 }
		local state2 = { StateName = "TestState9", Priority = 2, StateTypes = 3 }
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		fsm:RemoveStateByStateTypes(3)
		expect(fsm:GetCurrentState().StateName).to.equal("TestState8")
	end)

	it("should return true when state with given targetStateTypes exists", function()
		local fsm = StackFsm.new()
		local stateType = 2
		local dummyState = { StateTypes = stateType, StateName = "DummyState", Priority = 1 }
		fsm:__insertState(dummyState)
		local result = fsm:ContainsState(stateType)
		expect(result).to.equal(true)
	end)

	it("should return false when state with given targetStateTypes does not exist", function()
		local fsm = StackFsm.new()
		local stateType = 2
		local result = fsm:ContainsState(stateType)
		expect(result).to.equal(false)
	end)

	it("should return true even if only a subset of the targetStateTypes exists", function()
		local fsm = StackFsm.new()
		local stateType = 3
		local dummyState = { StateTypes = stateType, StateName = "DummyState", Priority = 1 }
		fsm:__insertState(dummyState)
		local result = fsm:ContainsState(1)
		expect(result).to.equal(true)
	end)

	it("should return false if none of the subset of the targetStateTypes exists", function()
		local fsm = StackFsm.new()
		local stateType = 2
		local dummyState = { StateTypes = stateType, StateName = "DummyState", Priority = 1 }
		fsm:__insertState(dummyState)
		local subsetType = 8
		local result = fsm:ContainsState(subsetType)
		expect(result).to.equal(false)
	end)

	it("should return false when state list for given targetStateTypes is empty", function()
		local fsm = StackFsm.new()
		local stateType = 2
		fsm.m_States[stateType] = {} -- Even though we shouldn't modify private members, this case is an edge case test.
		local result = fsm:ContainsState(stateType)
		expect(result).to.equal(false)
	end)
	it("should return true when state with given targetStateTypes exactly exists", function()
		local fsm = StackFsm.new()
		local stateType = 2
		local dummyState = { StateTypes = stateType, StateName = "DummyState", Priority = 1 }
		fsm:__insertState(dummyState)
		local result = fsm:HasAbsoluteEqualsState(stateType)
		expect(result).to.equal(true)
	end)

	it("should return false when state with given targetStateTypes does not exist", function()
		local fsm = StackFsm.new()
		local stateType = 2
		local result = fsm:HasAbsoluteEqualsState(stateType)
		expect(result).to.equal(false)
	end)

	it("should return false if there's an additional state in the fsm not present in targetStateTypes", function()
		local fsm = StackFsm.new()
		local stateType = 2
		local anotherStateType = 4
		local dummyState1 = { StateTypes = stateType, StateName = "DummyState1", Priority = 1 }
		local dummyState2 = { StateTypes = anotherStateType, StateName = "DummyState2", Priority = 2 }
		fsm:__insertState(dummyState1)
		fsm:__insertState(dummyState2)
		local combinedType = bit32.bor(stateType, anotherStateType)
		local result = fsm:HasAbsoluteEqualsState(combinedType)
		expect(result).to.equal(false)
	end)

	it("should return false if targetStateTypes has an additional state not present in the fsm", function()
		local fsm = StackFsm.new()
		local stateType = 2
		local dummyState = { StateTypes = stateType, StateName = "DummyState", Priority = 1 }
		fsm:__insertState(dummyState)
		local combinedType = bit32.bor(stateType, 4)
		local result = fsm:HasAbsoluteEqualsState(combinedType)
		expect(result).to.equal(false)
	end)

	it("should return false when state list for given targetStateTypes is empty", function()
		local fsm = StackFsm.new()
		local stateType = 2
		fsm.m_States[stateType] = {} -- Even though we shouldn't modify private members, this case is an edge case test.
		local result = fsm:HasAbsoluteEqualsState(stateType)
		expect(result).to.equal(false)
	end)
	-- 测试1: 当状态机中没有任何状态时，期望返回false
	it("should return false when no states exist in the state machine", function()
		local fsm = StackFsm.new()
		local result = fsm:CheckConflictState(1)
		expect(result).to.equal(false)
	end)

	-- 测试2: 当状态机中存在与给定冲突状态相匹配的状态时，期望返回true
	it("should return true when a conflicting state exists in the state machine", function()
		local fsm = StackFsm.new()
		fsm.m_States[2] = { { Key = 2 } } -- 模拟一个状态
		local result = fsm:CheckConflictState(2)
		expect(result).to.equal(true)
	end)

	-- 测试3: 当状态机中存在的状态与给定的冲突状态不完全匹配时，期望返回false
	it("should return false when existing states do not perfectly match the given conflict state", function()
		local fsm = StackFsm.new()
		fsm.m_States[1] = { { Key = 1 } } -- 模拟一个状态
		local result = fsm:CheckConflictState(2)
		expect(result).to.equal(false)
	end)

	-- 测试4: 当状态机中的状态与给定的冲突状态有重叠但状态的key为0时，期望返回false
	it("should return false when there's an overlap with the conflicting state but the state's key is 0", function()
		local fsm = StackFsm.new()
		fsm.m_States[2] = { { Key = 0 } } -- 模拟一个状态
		local result = fsm:CheckConflictState(2)
		expect(result).to.equal(false)
	end)

	-- 测试5: 当状态机中的状态与给定的冲突状态有重叠，且状态数量为0时，期望返回false
	it(
		"should return false when there's an overlap with the conflicting state but the number of states is 0",
		function()
			local fsm = StackFsm.new()
			fsm.m_States[2] = {} -- 模拟一个状态列表但不包含任何状态
			local result = fsm:CheckConflictState(2)
			expect(result).to.equal(false)
		end
	)
	-- 测试1: 当状态机中没有任何状态时，期望返回nil
	it("should return nil when no states exist in the state machine", function()
		local fsm = StackFsm.new()
		local result = fsm:GetState("TestState")
		expect(result).to.equal(nil)
	end)

	-- 测试2: 当状态机中存在与给定名称相匹配的状态时，期望返回该状态
	it("should return the state when a state with the given name exists in the state machine", function()
		local fsm = StackFsm.new()
		local mockState = { name = "TestState", data = "TestData" }
		fsm.m_States["TestState"] = mockState
		local result = fsm:GetState("TestState")
		expect(result).to.equal(mockState)
	end)

	-- 测试3: 当状态机中不存在与给定名称相匹配的状态时，期望返回nil
	it("should return nil when no state with the given name exists in the state machine", function()
		local fsm = StackFsm.new()
		local mockState = { name = "AnotherState", data = "AnotherData" }
		fsm.m_States["AnotherState"] = mockState
		local result = fsm:GetState("TestState")
		expect(result).to.equal(nil)
	end)

	-- 测试4: 当输入的状态名为nil或空字符串时，期望返回nil
	it("should return nil when the state name provided is nil or an empty string", function()
		local fsm = StackFsm.new()
		local resultForNil = fsm:GetState(nil)
		local resultForEmptyString = fsm:GetState("")
		expect(resultForNil).to.equal(nil)
		expect(resultForEmptyString).to.equal(nil)
	end)

	-- 测试5: 当状态机的状态存储结构不是预期的表格格式时，期望返回nil
	it("should return nil when the state storage structure of the FSM is not in the expected table format", function()
		local fsm = StackFsm.new()
		fsm.m_States = nil -- 模拟状态存储结构被破坏
		local result = fsm:GetState("TestState")
		expect(result).to.equal(nil)
	end)
end
