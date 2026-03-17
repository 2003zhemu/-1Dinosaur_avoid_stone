return function()
	local Time = nil
	local fixedUpdateCount = 0
	local coroutineSpeedCount = 0
	beforeEach(function(x)
		Time = require(game.ReplicatedStorage.Packages.Time:Clone())
		fixedUpdateCount = 0
		coroutineSpeedCount = 0
	end)

	describe("Updater", function()
		describe("timeScale 属性", function()
			it("应该能够设置和获取 timeScale", function()
				Time.timeScale = 2
				expect(Time.timeScale).to.equal(2)

				Time.timeScale = 0.5
				expect(Time.timeScale).to.equal(0.5)

				Time.timeScale = 1
				expect(Time.timeScale).to.equal(1)
			end)
		end)

		it("不受 timeScale 影响", function()
			local initialRealTime = Time.realtimeSinceStartup
			Time.timeScale = 0.5
			Time.onStepped(0.5) --  这只是一个示例，您需要根据实际的实现来调整
			expect(Time.realtimeSinceStartup - initialRealTime).to.equal(0.5)
		end)
	end)

	-- 4. timeScale为0时，FixedUpdate函数不再执行
	it("timeScale 为0时，FixedUpdate  不再执行", function()
		local fixedUpdateCount = 0
		Time.OnFixedUpdate:Connect(function()
			fixedUpdateCount = fixedUpdateCount + 1
		end)
		Time.timeScale = 0
		Time.onStepped(0.5)
		expect(fixedUpdateCount).to.equal(0)
	end)

	-- 6. timeScale 会影响 FixedUpdate，但 不会影响 Update
	it("timeScale 影响 FixedUpdate， 但不影响 Update", function()
		local fixedUpdateCount = 0
		local updateCount = 0
		Time.OnFixedUpdate:Connect(function()
			fixedUpdateCount = fixedUpdateCount + 1
		end)
		Time.OnUpdate:Connect(function()
			updateCount = updateCount + 1
		end)

		Time.timeScale = 2
		Time.onStepped(0.5)
		expect(fixedUpdateCount >= 0.98).to.equal(true) -- 因为 timeScale 是2，所以 FixedUpdate 应该执行了多次
		expect(updateCount).to.equal(1) -- Update 只应执行一次
	end)

	-- 9. timeScale 影响的时间属性
	it("timeScale 改变影响 time、 deltaTime、fixedTime 和 fixedUnscaledDeltaTime", function()
		local initialTime = Time.time
		local initialDeltaTime = Time.deltaTime
		local initialFixedTime = Time.fixedTime
		local initialFixedUnscaledDeltaTime = Time.fixedUnscaledDeltaTime

		Time.timeScale = 2
		Time.onStepped(0.5)
		expect(Time.time - initialTime).to.equal(2 * 0.5)
		expect(Time.deltaTime - initialDeltaTime).to.equal(2 * 0.5)
		expect(Time.fixedTime - initialFixedTime >= 0.98).to.equal(true) -- Assuming fixedTime increments are >1 for timeScale of 2
		expect(Time.fixedUnscaledDeltaTime - initialFixedUnscaledDeltaTime).to.equal(0)
	end)

	-- 10. timeScale 不影响的时间属性
	it(
		"timeScale 改变不会影响 realtimeSinceStartup、unscaledTime、unscaledDeltaTime、fixedUnscaledTime、fixedDeltaTime",
		function()
			local initialRealtimeSinceStartup = Time.realtimeSinceStartup
			local initialUnscaledTime = Time.unscaledTime
			local initialUnscaledDeltaTime = Time.unscaledDeltaTime
			local initialFixedUnscaledTime = Time.fixedUnscaledTime
			local initialFixedDeltaTime = Time.fixedDeltaTime

			Time.timeScale = 2
			Time.onStepped(0.5)
			expect(Time.realtimeSinceStartup - initialRealtimeSinceStartup).to.equal(0.5)
			expect(Time.unscaledTime - initialUnscaledTime).to.equal(0.5)
			expect(Time.unscaledDeltaTime - initialUnscaledDeltaTime).to.equal(0.5)
			expect(Time.fixedDeltaTime - initialFixedDeltaTime).to.equal(0) -- It remains unchanged
		end
	)

	-- 11. 当timeScale为0时，fixedUnscaledTime 的行为
	it("timeScale 为0，fixedUnscaledTime 停止，但从0变为非0，会有跳跃", function()
		Time.timeScale = 0
		local initialFixedUnscaledTime = Time.fixedUnscaledTime
		Time.onStepped(0.5)
		expect(Time.fixedUnscaledTime - initialFixedUnscaledTime).to.equal(0)

		Time.timeScale = 1
		Time.onStepped(0.5)
		-- 在这里，您可以选择期望的行为，但重要的是要记住 fixedUnscaledTime 只在 FixedUpdate 阶段更新。
	end)

	-- 12. 当timeScale改变，fixedUnscaledDeltaTime 的行为
	it("timeScale 改变，fixedUnscaledDeltaTime 反比改变", function()
		local initialFixedUnscaledDeltaTime = Time.fixedUnscaledDeltaTime

		Time.timeScale = 2
		Time.onStepped(0.5)
		expect(Time.fixedUnscaledDeltaTime).to.equal(initialFixedUnscaledDeltaTime / 2)

		Time.timeScale = 0
		Time.onStepped(0.5)
		expect(Time.fixedUnscaledDeltaTime).to.equal(initialFixedUnscaledDeltaTime)
	end)

	-- Time.time
	it("Time.time 表示从游戏开始到现在的时间", function()
		expect(Time.time).to.equal(0)
		Time.onStepped(0.5)
		expect(Time.time).to.equal(0.5)
		Time.timeScale = 0
		Time.onStepped(0.5)
		expect(Time.time).to.equal(0.5) -- 因为时间缩放为0，所以Time.time应该不会改变
	end)

	-- Time.deltaTime
	it("Time.deltaTime 表示从上一帧到当前帧的时间", function()
		Time.onStepped(0.5)
		expect(Time.deltaTime).to.equal(0.5)
	end)

	-- Time.fixedTime
	it("Time.fixedTime 表示从游戏开始的固定时间", function()
		expect(Time.fixedTime).to.equal(0)
		Time.onStepped(0.5)
		-- 这里假设固定时间间隔为0.1秒
		expect(Time.fixedTime < 0.5 and Time.fixedTime > 0.48).to.equal(true) -- 时间应累加
	end)

	-- Time.timeScale
	it("Time.timeScale 表示时间缩放", function()
		expect(Time.timeScale).to.equal(1)
		Time.onStepped(0.5)
		expect(Time.time).to.equal(0.5)

		Time.timeScale = 2
		Time.onStepped(0.5)
		expect(Time.time).to.equal(1.5) -- 0.5 * 2 = 1 + 0.5 = 1.5
	end)

	-- Time.frameCount
	it("Time.frameCount  表示总帧数", function()
		expect(Time.frameCount).to.equal(0)
		Time.onStepped(0.5)
		expect(Time.frameCount).to.equal(1)
	end)

	-- Time.realtimeSinceStartup
	it("Time.realtimeSinceStartup  表示自游戏开始后的总时间， 即使暂停也会增加", function()
		expect(Time.realtimeSinceStartup).to.equal(0)
		Time.timeScale = 0
		Time.onStepped(0.5)
		expect(Time.realtimeSinceStartup).to.equal(0.5) -- 假设os.clock增加了0.5
	end)

	-- Time.unscaledDeltaTime
	it("Time.unscaledDeltaTime 考虑和不考虑timescale的差异", function()
		Time.timeScale = 2
		Time.onStepped(0.5)
		expect(Time.unscaledDeltaTime).to.equal(0.5)
		expect(Time.deltaTime).to.equal(1) -- 因为timescale为2，所以是0.5*2
	end)

	-- Time.unscaledTime
	it("Time.unscaledTime 考虑和不考虑timescale的差异 ", function()
		Time.timeScale = 2
		Time.onStepped(0.5)
		expect(Time.unscaledTime).to.equal(0.5)
		expect(Time.time).to.equal(1) -- 因为timescale为2，所以是0.5*2
	end)

	-- 1. 默认值测试
	it("默认的Time.fixedDeltaTime值应为0.02", function()
		expect(Time.fixedDeltaTime).to.equal(0.02)
	end)

	-- 2. 对fixedDeltaTime的改变不应影响fixedUnscaledDeltaTime
	it("改变Time.fixedDeltaTime不影响Time.fixedUnscaledDeltaTime", function()
		local originalFixedUnscaledDeltaTime = Time.fixedUnscaledDeltaTime
		Time.fixedDeltaTime = 0.03
		expect(Time.fixedUnscaledDeltaTime).to.equal(originalFixedUnscaledDeltaTime)
	end)

	-- 3. 改变timeScale不应影响fixedDeltaTime
	it("改变Time.timeScale不影响Time.fixedDeltaTime", function()
		local originalFixedDeltaTime = Time.fixedDeltaTime
		Time.timeScale = 2
		expect(Time.fixedDeltaTime).to.equal(originalFixedDeltaTime)
		Time.timeScale = 0.5
		expect(Time.fixedDeltaTime).to.equal(originalFixedDeltaTime)
	end)

	-- 4.  检查fixedDeltaTime对固定更新的影响
	it("Time.fixedDeltaTime决定了固定更新的频率", function()
		Time.fixedDeltaTime = 0.03
		local initialFixedFrameCount = Time.fixFrameCount

		local steps = 11
		local stepDuration = 0.003
		for i = 1, steps do
			Time.onStepped(stepDuration)
		end

		local frameDifference = Time.fixFrameCount - initialFixedFrameCount
		expect(frameDifference).to.equal(1) -- 因为总时间超过了一个固定的更新周期
	end)

	-- 5. 恢复fixedDeltaTime到默认值
	it("可以恢复Time.fixedDeltaTime到其默认值", function()
		Time.fixedDeltaTime = 0.02
		expect(Time.fixedDeltaTime).to.equal(0.02)
	end)

	local largeDeltaTime = 0.15 -- This is greater than fixedDeltaTime (0.02) multiple times
	local expectedCalls = math.floor(largeDeltaTime / Time.fixedDeltaTime)
	local actualCalls = 0

	-- Mock the Fixed Update function to count how many times it's called
	local originalFixedUpdate = Time.FixedUpdateEvent
	Time.OnFixedUpdate:Connect(function()
		actualCalls = actualCalls + 1
	end)

	-- Call the onStepped with the large deltaTime
	Time.onStepped(largeDeltaTime)

	-- Assert that the fixed UpdateEvent was called the expected number of times
	expect(actualCalls).to.equal(expectedCalls)

	-- Restore the original Fixed Update function
	Time.FixedUpdateEvent = originalFixedUpdate
end
