--[=[
	@class Time
	时间库 TODO: 只保留Game用到的fixed相关的设计
]=]

local Time = {}

-- The time at the beginning of this frame (Read Only).
Time.time = 0

-- The time since the last FixedUpdate started (Read Only). This is the time in seconds since the start of the game.
Time.fixedTime = 0

-- 	The timeScale-independent time at the beginning of the last MonoBehaviour.FixedUpdate phase (Read Only). This is the time in seconds since the start of the game.
Time.fixedUnscaledTime = 0

-- 	The timeScale-independent time for this frame (Read Only). This is the time in seconds since the start of the game.
Time.unscaledTime = 0

-- The interval in seconds from the last frame to the current one
Time.deltaTime = 0

-- 这里假定逻辑帧是20次每秒
--The interval in seconds at which physics and other fixed frame rate updates (like MonoBehaviour's FixedUpdate) are performed.
Time.fixedDeltaTime = 0.05

-- 	The timeScale-independent interval in seconds from the last frame to the current one (Read Only).
Time.unscaledDeltaTime = 0

-- 	The timeScale-independent time at the beginning of the last MonoBehaviour.FixedUpdate phase (Read Only). This is the time in seconds since the start of the game.
Time.fixedUnscaledDeltaTime = 0

-- 	The scale at which time passes.
Time.timeScale = 1

-- Returns true if called inside a fixed time step callback (like MonoBehaviour's FixedUpdate), otherwise returns false.
Time.inFixedTimeStep = false

-- 运行时间
Time.realtimeSinceStartup = 0

-- 运行帧数
Time.frameCount = 0

-- FixUpdate
local FixedUpdateEvent = Instance.new("BindableEvent")

Time.OnFixedUpdate = FixedUpdateEvent.Event

-- Update
local UpdateEvent = Instance.new("BindableEvent")

Time.OnUpdate = UpdateEvent.Event

-- 固定帧数
Time.fixFrameCount = 0

-- 记录timeScale为0时的开始时间
local timeScaleZeroStartTime = nil
-- 记录当timescale为0时，fixedUnscaledTime的值
local lastFixedUnscaledTime = nil

local fixedUnupdatedTime = 0

-- 固定帧更新
local function onFixUpdate(handler)
	Time.inFixedTimeStep = true

	-- 如果timescale == 0,  则说明时间静止了, 不再更新
	if Time.timeScale == 0 then
		return
	end

	if Time.fixedTime == nil then
		Time.fixedTime = Time.time
		fixedUnupdatedTime = Time.time
		handler()
	end

	fixedUnupdatedTime = fixedUnupdatedTime + Time.deltaTime
	while fixedUnupdatedTime > Time.fixedDeltaTime do
		fixedUnupdatedTime = fixedUnupdatedTime - Time.fixedDeltaTime
		Time.fixedTime = Time.fixedTime + Time.fixedDeltaTime
		handler()
	end

	Time.inFixedTimeStep = false
end

function Time.onStepped(deltaTime)
	-- 未缩放的时间差
	Time.unscaledDeltaTime = deltaTime

	-- 从游戏开始到现在的实际时间
	Time.realtimeSinceStartup = Time.realtimeSinceStartup + deltaTime

	-- 计算与 timeScale 无关的时间值
	Time.unscaledTime = Time.unscaledTime + deltaTime

	-- time
	Time.time = Time.time + deltaTime * Time.timeScale

	-- delta time
	Time.deltaTime = deltaTime * Time.timeScale

	Time.frameCount = Time.frameCount + 1

	-- 如果timeScale为0
	if Time.timeScale == 0 then
		-- 如果timeScaleZeroStartTime为nil，说明这是第一次设置为0
		if not timeScaleZeroStartTime then
			timeScaleZeroStartTime = Time.unscaledTime
			lastFixedUnscaledTime = Time.fixedUnscaledTime or Time.fixTime
		end
	elseif timeScaleZeroStartTime then
		-- timeScale从0变为非0
		local durationPaused = Time.unscaledTime - timeScaleZeroStartTime
		Time.fixedUnscaledTime = lastFixedUnscaledTime + durationPaused
		timeScaleZeroStartTime = nil
		lastFixedUnscaledTime = nil
	end

	if Time.inFixedTimeStep then
		Time.fixedUnscaledTime = Time.fixedUnscaledTime + Time.fixedDeltaTime
		Time.fixedUnscaledDeltaTime = Time.fixedDeltaTime
	end

	onFixUpdate(function()
		Time.fixFrameCount = Time.fixFrameCount + 1
		FixedUpdateEvent:fire(Time.fixedDeltaTime)
	end)

	UpdateEvent:fire(deltaTime)
end

local isListen = false

--[=[
	监听 RunService.Stepped 事件
]=]
function Time.ListenStepped()
	assert(not isListen)
	isListen = true
	-- stepped
	local RunService = game:GetService("RunService")
	RunService.Stepped:Connect(function(time, deltaTime)
		Time.onStepped(deltaTime)
	end)
end

return Time
