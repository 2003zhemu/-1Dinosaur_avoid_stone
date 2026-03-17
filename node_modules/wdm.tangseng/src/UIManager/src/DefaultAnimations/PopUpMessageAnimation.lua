-- 直线平移
local module = {}

--===========================< Roblox服务 >=============================--
local rs = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
--===========================< Roblox服务 >=============================--
local eventBus = require(rs.EventBus)

local popUp = script.Parent:WaitForChild("MainScreen"):WaitForChild("BottomPopUpFrame") -- 弹窗对象
local popUpList = {} --弹窗列表

--< 弹窗基础预设参数 >--
local popUpStayTime = 1.5 -- 弹窗停留时间
local moveUpTransformTime = 0.1 -- 被下一个弹窗挤上去的过渡时间
--local lineLimit = math.huge		-- 弹窗行数(数量)限制
local lineLimit = 3 -- 弹窗行数(数量)限制
--< 弹窗缩放特效果预设参数 >--
local zoomScale = 1.2 -- 缩放系数
local zoomTransformTime = 0.1 -- 缩放过渡时间

local isPoping = false -- 正在弹出标记

-- 处理弹窗上移
function HandlePopUpsMoveUp()
	local popUpCnt = #popUpList
	if popUpCnt > 0 then
		for _idx, popUpT: Frame in ipairs(popUpList) do
			local popUp = nil
			if #popUpT > 0 then
				popUp = popUpT[1]
			end
			if popUp == nil then
				return
			end

			local UIScale = popUp:FindFirstChild("UIScale")
			if UIScale == nil then
				return
			end

			local moveUpTransform_TweenInfo = TweenInfo.new(moveUpTransformTime, Enum.EasingStyle.Linear)
			local moveUpTransform_Goal =
				{ Position = popUp.Position - UDim2.new(0, 0, popUp.Size.Y.Scale * UIScale.Scale, 0) }
			local moveUpTransform_Tween = tweenService:Create(popUp, moveUpTransform_TweenInfo, moveUpTransform_Goal)
			moveUpTransform_Tween:Play()
		end
	end
end

-- 处理弹窗缩放动效
function HandlePopUpZoomEffect(popUp: Frame)
	if popUp == nil then
		return
	end
	local popUp_UIScale = popUp:FindFirstChild("UIScale")
	if popUp_UIScale == nil then
		return
	end

	local zoomTransformIn_TweenInfo = TweenInfo.new(zoomTransformTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local zoomTransformIn_Tween = tweenService:Create(popUp_UIScale, zoomTransformIn_TweenInfo, { Scale = zoomScale })
	zoomTransformIn_Tween:Play()
	zoomTransformIn_Tween.Completed:Wait()
	local zoomTransformOut_TweenInfo = TweenInfo.new(zoomTransformTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local zoomTransformOut_Tween = tweenService:Create(popUp_UIScale, zoomTransformOut_TweenInfo, { Scale = 1 })
	zoomTransformOut_Tween:Play()
	zoomTransformOut_Tween.Completed:Wait()
end

-- 弹出
function Pop(gui: GuiObject, text: string)
	isPoping = true
	HandlePopUpsMoveUp()
	task.wait(moveUpTransformTime)
	local label = gui:FindFirstChildOfClass("TextLabel")
	assert(label, "Gui 必须包含 TextLabel")
	label.Text = text
	task.delay(popUpStayTime, function()
		table.remove(popUpList, 1)
	end)
	table.insert(popUpList, { newPopUp })

	HandlePopUpZoomEffect(newPopUp)

	isPoping = false
end

local needPopList = {} -- 待处理弹窗信息列表

-- [Params]
-- text: 提示文本
function AddPopUpQueen(gui: GuiObject, text: string)
	if typeof(text) ~= "string" then
		warn("typeof(text) ~= string")
		return
	end

	table.insert(needPopList, { text })
end

-- 给定 guiobject, 使用 tweenservice 将其移动
function module.Play(gui: GuiObject, tipText: string)
	AddPopUpQueen(gui, tipText)
end

return module
