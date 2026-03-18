-- local TweenService = game:GetService("TweenService")
-- local carfolder = game:GetService("Workspace"):WaitForChild("Obstacles"):WaitForChild("Stage20")

-- -- 存储所有车的状态
-- local cars = {}

-- -- 初始化所有车的状态
-- local function initCars()
-- 	table.insert(cars, {
-- 		car = carfolder["Part1"],
-- 		startPos = CFrame.new(59.09, 81.896, -333.076) * CFrame.Angles(0, math.rad(-90), 0),
-- 		endPos = CFrame.new(-95.986, 81.896, -333.076) * CFrame.Angles(0, math.rad(-90), 0),
-- 		isMoving = false,
-- 		nextActionTime = tick() + math.random(0, 2), -- 每辆车不同的初始等待时间
-- 		probabilities = 1, --概率
-- 		startspeed = { max = 1, min = 0.5 },
-- 		endspeed = { max = 1, min = 0.2 },
-- 	})
-- end

-- initCars()

-- -- 单个主循环管理所有车的移动
-- task.spawn(function()
-- 	-- while true do
-- 	-- 	local currentTime = tick()
-- 	-- 	-- 遍历所有车
-- 	-- 	for _, carData in ipairs(cars) do
-- 	-- 		-- 检查是否到达行动时间
-- 	-- 		if currentTime >= carData.nextActionTime then
-- 	-- 			if not carData.isMoving then
-- 	-- 				-- 检查概率
-- 	-- 				local random = math.random()
-- 	-- 				if random <= carData.probabilities then
-- 	-- 					-- 开始新移动
-- 	-- 					local speed = math.random(carData.minspeed, carData.maxspeed)

-- 	-- 					-- 重置到起点
-- 	-- 					carData.car.CFrame = carData.startPos

-- 	-- 					-- 创建并播放tween
-- 	-- 					local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Linear)
-- 	-- 					local tween = TweenService:Create(carData.car, tweenInfo, { CFrame = carData.endPos })
-- 	-- 					tween:Play()

-- 	-- 					-- 记录移动状态
-- 	-- 					carData.isMoving = true
-- 	-- 					-- 移动完成后才能进行下一次行动
-- 	-- 					carData.nextActionTime = currentTime + speed + math.random(carData.timestart, carData.timeend)
-- 	-- 				else
-- 	-- 					-- 概率没通过，设置下次检查时间
-- 	-- 					carData.nextActionTime = currentTime + math.random(carData.timestart, carData.timeend)
-- 	-- 				end
-- 	-- 			else
-- 	-- 				-- 如果正在移动，检查是否完成
-- 	-- 				if currentTime >= carData.nextActionTime - math.random(carData.timestart, carData.timeend) then
-- 	-- 					carData.isMoving = false
-- 	-- 				end
-- 	-- 			end
-- 	-- 		end
-- 	-- 	end

-- 	-- 	-- 短暂等待，避免过度占用CPU，同时保持响应性
-- 	-- 	task.wait(0.1)
-- 	-- end
-- end)
