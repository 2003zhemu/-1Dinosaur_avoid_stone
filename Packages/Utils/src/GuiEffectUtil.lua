-- by: CatchMoon
-- [unfinished] [拆分模块, 放到packages里面去]
-- [该模块暂时不再维护]

--==============================< Roblox >==================================--
local TweenService = game:GetService("TweenService")
--==============================< Roblox >==================================--

local UDim2F = require(script.Parent.UDim2F)

local this = {}

-- 判断窗口是否打开

local opening = false
local closing = false
function this.IsOpen(win: Frame)
	return win.Visible
end

-- 注意:win的Size属性不能受其它控件影响
function this.Open(
	win: GuiObject,
	defaultSize: UDim2,
	scale: number?,
	transformTime: number?,
	waitTime: number?)
	if opening then return end
	opening = true
	
	if transformTime == nil then transformTime = 0.05 end
	if scale == nil then scale = 0.95 end
	if waitTime == nil then waitTime = 0 end
	
	task.wait(waitTime)
	win.Visible = true
	
	local expandTweenInfo = TweenInfo.new(transformTime, Enum.EasingStyle.Quint)
	local expandGoal = { Size = defaultSize }
	local expandTween = TweenService:Create(win, expandTweenInfo, expandGoal)
	expandTween:Play()
	expandTween.Completed:Wait()
	expandTween = nil
	
	opening = false
end

-- 注意:win的Size属性不能受其它控件影响
function this.Close(
	win: GuiObject,
	defaultSize: UDim2,
	scale: number?,
	transformTime: number?,
	waitTime: number?)
	if closing then return end
	closing = true
	
	if transformTime == nil then transformTime = 0.05 end
	if scale == nil then scale = 0.95 end
	if waitTime == nil then waitTime = 0 end
	
	task.wait(waitTime)
	
	local lessenTweenInfo = TweenInfo.new(transformTime, Enum.EasingStyle.Quint)
	local lessenGoal = { Size = UDim2F.Lerp(defaultSize, scale) }
	local lessenTween = TweenService:Create(win, lessenTweenInfo, lessenGoal)
	lessenTween:Play()
	lessenTween.Completed:Wait()
	win.Visible = false
	lessenTween = nil
	
	closing = false
end

-- 注意:win的Size属性不能受其它控件影响
function this.Switch(
	win: GuiObject,
	defaultSize: UDim2,
	scale: number?,
	transformTime: number?,
	waitTime: number?)
	
	if this.IsOpen(win) then
		this.Close(win, defaultSize, scale, transformTime, waitTime)
	else
		this.Open(win, defaultSize, scale, transformTime, waitTime)
	end
end

-- 设置鼠标悬停至UI上时UI自动放大, 鼠标离开时UI自动还原
--[[
	checkUI: 检测鼠标悬停的UI, 该UI的大小决定检测区域大小
	expandUI: 要扩展的UI(需要有Size属性[Size为UDim2类型], 之后可能会适配其它UI控件)
	scale: 缩放系数
	transformTime: 放大或还原的过渡时间
	
	注意:win的Size属性不能受其它控件影响
]]
function this.SetUIExpand(
	checkUI: GuiObject,
	expandUI: GuiObject?,
	scale: number?,
	transformTime: number?)
	
	if expandUI == nil then expandUI = checkUI end
	if scale == nil then scale = 1.1 end
	if transformTime == nil then transformTime = 0.1 end
	local uiDefaultSize = expandUI.Size
	local expandTween = nil
	local restoreTween = nil
	
	checkUI.MouseEnter:Connect(function()
		if restoreTween ~= nil then restoreTween = nil end
		
		-- 仅在此项目中使用
		require(game.StarterPlayer.StarterPlayerScripts.Managers.SoundManager).PlaySound("MoveInButton")
		
		local uiCurScale = expandUI.Size.X.Scale / uiDefaultSize.X.Scale
		local expandTransformTime = (1 - (uiCurScale - 1) / (scale - 1)) * transformTime
		local expandTweenInfo = TweenInfo.new(expandTransformTime)
		local expandTweenGoal = { Size = UDim2F.Lerp(uiDefaultSize, scale) }
		expandTween = TweenService:Create(expandUI, expandTweenInfo, expandTweenGoal)
		expandTween:Play()
	end)
	checkUI.MouseLeave:Connect(function()
		if expandTween ~= nil then expandTween = nil end
		
		local uiCurScale = expandUI.Size.X.Scale / uiDefaultSize.X.Scale
		local restoreTransformTime = ((uiCurScale - 1) / (scale - 1)) * transformTime
		local restoreTweenInfo = TweenInfo.new(restoreTransformTime)
		local restoreTweenGoal = { Size = uiDefaultSize }
		restoreTween = TweenService:Create(expandUI, restoreTweenInfo, restoreTweenGoal)
		restoreTween:Play()
	end)
end

-- 设置Viewport中模型的效果：
-- 鼠标进入模型顺时针旋转一定角度(rotateAngle), 鼠标离开逆时针旋转至归位, (viewport必须设置CurrentCamera)
--[[
params:
	viewportFrame: 需要该特效的UI控件
	tranformTime: 旋转变化的事件
	rotateAngle: 要旋转的角度
]]
function this.SetViewportModelRotateEffect(
	viewportFrame: ViewportFrame,
	transformTime: number?,
	rotateAngle: number?)
	if transformTime == nil then transformTime = 0.5 end
	if rotateAngle == nil then rotateAngle = 40 end
	
	local model = viewportFrame:FindFirstChildOfClass("Model")
	
	local targetCFrame = Instance.new("CFrameValue")
	targetCFrame.Changed:Connect(function()
		model:PivotTo(targetCFrame.Value)
	end)
	
	if model ~= nil then
		targetCFrame.Value = CFrame.Angles(0, math.rad(179), 0)
		model:PivotTo(CFrame.Angles(0, math.rad(179), 0))
		local defaultCFrame = targetCFrame.Value
		local rotateTween = nil
		local restoreTween = nil
		
		viewportFrame.MouseEnter:Connect(function()
			if restoreTween ~= nil then restoreTween = nil end
			
			local rotateGoal = { Value = CFrame.Angles(0, math.rad(179 - 45), 0) }
			local rotateTween = TweenService:Create(targetCFrame, TweenInfo.new(transformTime), rotateGoal)
			rotateTween:Play()
		end)
		viewportFrame.MouseLeave:Connect(function()
			if rotateTween ~= nil then rotateTween = nil end
			
			local restoreGoal = { Value = CFrame.Angles(0, math.rad(179), 0) }
			local restoreTween = TweenService:Create(targetCFrame, TweenInfo.new(transformTime), restoreGoal)
			restoreTween:Play()
		end)
	end
end

return this