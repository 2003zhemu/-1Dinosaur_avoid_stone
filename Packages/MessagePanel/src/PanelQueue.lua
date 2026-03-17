local module = {}

local rs = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local needPopList = {} -- 待处理弹窗信息列表
local popUpList = {} --弹窗列表

local guiFrame = Instance.new("Frame")
guiFrame.Size = UDim2.fromScale(1, 1)
guiFrame.BackgroundTransparency = 1
local popUp = require(script.Parent.MessagePanelConfig).MessagePanelFrame

--< 弹窗基础预设参数 >--
local popUpStayTime = 1.5 -- 弹窗停留时间
local moveUpTransformTime = 0.1 -- 被下一个弹窗挤上去的过渡时间
--local lineLimit = math.huge		-- 弹窗行数(数量)限制
local lineLimit = 3 -- 弹窗行数(数量)限制
local enableZoomEffect = true -- 是否开启缩放动效
--< 弹窗缩放特效果预设参数 >--
local zoomScale = 1.2 -- 缩放系数
local zoomTransformTime = 0.1 -- 缩放过渡时间

local isPoping = false -- 正在弹出标记

-- 处理弹窗上移
function HandlePopUpsMoveUp()
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
function module.Pop(text: string)
	print(22222222, text)
	isPoping = true

	local popUpCnt = #popUpList
	if popUpCnt > 0 then
		-- Destroy Top PopUp
		if popUpCnt == lineLimit then
			popUpList[1][1].Visible = false
			popUpList[1][1]:Destroy()
			popUpList[1] = nil
		end
		HandlePopUpsMoveUp()
	end
	task.wait(moveUpTransformTime)
	local newPopUp: Frame = popUp:Clone()
	newPopUp.Parent = guiFrame
	newPopUp.Name = "NewPopUp"
	newPopUp.Visible = true
	newPopUp:FindFirstChildOfClass("TextLabel").Text = text
	task.delay(popUpStayTime, function()
		newPopUp.Visible = false
		newPopUp:Destroy()
		newPopUp = nil
		table.remove(popUpList, 1)
	end)
	table.insert(popUpList, { newPopUp })

	if enableZoomEffect then
		HandlePopUpZoomEffect(newPopUp)
	end

	isPoping = false
end

function module.GetNeedPopList()
	return needPopList
end

function module.GetIsPoping()
	return isPoping
end

function module.GetGui()
	return guiFrame
end

return module
