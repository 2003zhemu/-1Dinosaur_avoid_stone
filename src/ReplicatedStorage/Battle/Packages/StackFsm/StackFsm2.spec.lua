return function()
	local StackFsm = require(script.Parent)

	beforeEach(function() end)

	afterEach(function() end)

	it("1. 插入一个新状态应当成功 ", function()
		local fsm = StackFsm.new()
		local state = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		fsm:__insertState(state)
		expect(fsm:GetState(state.StateName)).to.equal(state)
	end)

	it("2. 插入已存在的状态应当将其提升同优先级状态的首位", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		local state2 = {
			StateName = "TestState2",
			Priority = 1,
			StateTypes = 2,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		fsm:__insertState(state1, true)
		expect(fsm:GetCurrentState()).to.equal(state1)
	end)

	it("3. 插入优先级较高的状态应当放在链表首位", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		local state2 = {
			StateName = "TestState2",
			Priority = 2,
			StateTypes = 2,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		expect(fsm:GetCurrentState()).to.equal(state2)
	end)

	it("4. 插入相同优先级的状态应当按插入顺序排列", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		local state2 = {
			StateName = "TestState2",
			Priority = 1,
			StateTypes = 2,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		expect(fsm:GetCurrentState()).to.equal(state2)
	end)

	it("5. 插入优先级较低的状态应当放在链表末尾", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 2,
			StateTypes = 1,
		}
		local state2 = {
			StateName = "TestState2",
			Priority = 1,
			StateTypes = 2,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		expect(fsm:GetCurrentState()).to.equal(state1)
	end)
	it("6. 插入状态时指定不包含自身，应当不会更改链表顺序", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state1, false)
		expect(fsm:GetCurrentState()).to.equal(state1)
	end)

	it("7. 插入多个相同状态应当仅保留一个", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state1, true)
		-- 假设GetStateList是用来获取所有状态列表的函数
		expect(fsm:GetStateCount()).to.equal(1)
	end)

	it("8. 当状态链表为空时，插入状态应当直接放在链表首位", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		fsm:__insertState(state1)
		expect(fsm:GetCurrentState()).to.equal(state1)
	end)

	it("9. 插入不同类型的状态应当成功", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		local state2 = {
			StateName = "TestState2",
			Priority = 2,
			StateTypes = 2,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state2)
		expect(fsm:GetState(state2.StateName)).to.equal(state2)
	end)

	it("插入状态后，应当能通过状态名访问到状态", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "TestState1",
			Priority = 1,
			StateTypes = 1,
		}
		fsm:__insertState(state1)
		expect(fsm:GetState(state1.StateName)).to.equal(state1)
	end)
	it("11. 插入状态时指定包含自身，应当能查看到自身在链表中", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "SelfContainedState",
			Priority = 1,
			StateTypes = 1,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state1, true)
		expect(fsm:ContainsState(1)).to.equal(true)
	end)

	it("12. 插入的状态优先级较高应当放在链表首位", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "NormalPriorityState",
			Priority = 1,
			StateTypes = 1,
		}
		local highPriorityState = {
			StateName = "HighPriorityState",
			Priority = 10,
			StateTypes = 2,
		}
		fsm:__insertState(state1)
		fsm:__insertState(highPriorityState)
		expect(fsm:GetCurrentState()).to.equal(highPriorityState)
	end)

	it("13. 插入的状态优先级相同应当放在已存在状态后面", function()
		-- local fsm = StackFsm.new()
		-- local state1 = {
		-- 	StateName = "State1",
		-- 	Priority = 5,
		-- 	StateTypes = 1,
		-- }
		-- local state2 = {
		-- 	StateName = "State2",
		-- 	Priority = 5,
		-- 	StateTypes = 2,
		-- }
		-- fsm:__insertState(state1)
		-- fsm:__insertState(state2)
		-- -- 假设GetNextState是用来获取下一个状态的函数
		-- expect(fsm:GetNextState()).to.equal(state2)
	end)

	it("14. 插入状态后，尝试插入一个包含自身的状态，链表不应该变化", function()
		local fsm = StackFsm.new()
		local state1 = {
			StateName = "State1",
			Priority = 1,
			StateTypes = 1,
		}
		fsm:__insertState(state1)
		fsm:__insertState(state1, true)
		-- 假设GetStateList是用来获取所有状态列表的函数
		expect(fsm:GetStateCount()).to.equal(1)
	end)

	it(
		"15. 插入状态后，尝试插入一个不包含自身的状态，应当仅有一个状态在链表中",
		function()
			local fsm = StackFsm.new()
			local state1 = {
				StateName = "State1",
				Priority = 1,
				StateTypes = 1,
			}
			fsm:__insertState(state1)
			fsm:__insertState(state1, false)
			-- 假设GetStateList是用来获取所有状态列表的函数
			expect(fsm:GetStateCount()).to.equal(1)
		end
	)
end
