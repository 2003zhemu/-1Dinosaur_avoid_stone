local TweenService = game:GetService("TweenService")
local carfolder = game:GetService("Workspace"):WaitForChild("Obstacles"):WaitForChild("Stage3")

local cfg = {
	Items = {
		item = "Part1",
		startPos = CFrame.new(51.411, 86.776, -1468.257), --初始位置
		endPos = CFrame.new(-110.009, 86.776, -1468.257), --结束位置
		startspeed = 2, --初始速度
		endSpeed = 2, --返回速度
		starttime = 4, --出发等待时间
		endtime = 0, --返回停留时间
		waitTime = 0, --动画开始前的等待时间
	},
	{
		item = "Part2",
		startPos = CFrame.new(46.383, 86.776, -1644.748), --初始位置
		endPos = CFrame.new(-110.009, 86.776, -1644.748), --结束位置
		startspeed = 2,
		endSpeed = 2,
		starttime = 4,
		endtime = 0,
		waitTime = 0,
	},
	{
		item = "Part3",
		startPos = CFrame.new(-281.655, 86.776, -1736.17), --初始位置
		endPos = CFrame.new(-125.061, 86.776, -1736.17), --结束位置
		startspeed = 2,
		endSpeed = 2,
		starttime = 4,
		endtime = 0,
		waitTime = 4,
	},
	{
		item = "Part4",
		startPos = CFrame.new(-284.424, 86.776, -1557.567), --初始位置
		endPos = CFrame.new(-122.604, 86.776, -1557.567), --结束位置
		startspeed = 2,
		endSpeed = 2,
		starttime = 4,
		endtime = 0,
		waitTime = 4,
	},
}

local function createLoopingTween(part, startPos, endPos, startspeed, endSpeed, starttime, endtime)
	-- 创建两个方向的补间
	part.CFrame = startPos

	local tweenInfoStart =
		TweenInfo.new(startspeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, starttime)

	local tweenInfoEnd = TweenInfo.new(endSpeed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, endtime)
	local tweenToEnd = TweenService:Create(part, tweenInfoStart, { CFrame = endPos })
	local tweenToStart = TweenService:Create(part, tweenInfoEnd, { CFrame = startPos })

	tweenToEnd.Completed:Connect(function()
		tweenToStart:Play()
	end)

	tweenToStart.Completed:Connect(function()
		tweenToEnd:Play()
	end)

	tweenToEnd:Play()
end

for index, value in pairs(cfg) do
	local part = carfolder:FindFirstChild(value.item)
	if part then
		task.spawn(function()
			task.wait(value.waitTime or 0)
			createLoopingTween(
				part,
				value.startPos,
				value.endPos,
				value.startspeed,
				value.endSpeed,
				value.starttime,
				value.endtime
			)
		end)
	else
		warn("找不到部件: " .. value.item)
	end
end
