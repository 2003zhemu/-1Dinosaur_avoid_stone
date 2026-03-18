local TweenService = game:GetService("TweenService")
local carfolder = game:GetService("Workspace"):WaitForChild("Obstacles"):WaitForChild("Stage5")

local cfg = {
	Items = {
		item = "Part1",
		startPos = CFrame.new(-52.036, 18.694, -2720.939), --初始位置
		endPos = CFrame.new(-52.036, 70.681, -2720.939), --结束位置
		startspeed = 2, --初始速度
		endSpeed = 2, --返回速度
		starttime = 4, --出发等待时间
		endtime = 0, --返回停留时间
		waitTime = 0, --动画开始前的等待时间
	},
	{
		item = "Part2",
		startPos = CFrame.new(-137.468, 18.694, -2720.939), --初始位置
		endPos = CFrame.new(-137.468, 70.681, -2720.939), --结束位置
		startspeed = 2,
		endSpeed = 2,
		starttime = 4,
		endtime = 0,
		waitTime = 0,
	},
	{
		item = "Part3",
		startPos = CFrame.new(-181.078, 18.694, -2720.939), --初始位置
		endPos = CFrame.new(-181.078, 72.333, -2720.939), --结束位置
		startspeed = 2,
		endSpeed = 2,
		starttime = 4,
		endtime = 0,
		waitTime = 4,
	},
	{
		item = "Part4",
		startPos = CFrame.new(-93.165, 18.694, -2720.939), --初始位置
		endPos = CFrame.new(-93.165, 72.333, -2720.939), --结束位置
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
