local module = {}

-- 打开窗口动画

local TweenService = game:GetService("TweenService")
local openInfo = TweenInfo.new(0.5,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out,0,false,0)

-- 镜头模糊
if not blureffect then
	blureffect= Instance.new("BlurEffect")
	blureffect.Parent=workspace.Camera
end

blureffect.Enabled =false

local frameTween = nil
local frameCon = nil

local oldframe=nil
local newframe=nil

local function playOpenWinAnimation(frame)
	blureffect.Enabled = true
	if oldframe==nil then
		oldframe=frame
	else
		newframe=frame
	end
	if oldframe == newframe then
		if frameTween then
			frameTween:Pause()
			frameTween = nil
		end

		if frameCon then
			frameCon:Disconnect()
			frameCon = nil
		end
	else
		oldframe=newframe
	end

	frame.Position =UDim2.new(0.5, 0 , 0.5, 0)
	local UIScale = frame:FindFirstChildOfClass("UIScale")
	if not UIScale then
		UIScale = Instance.new("UIScale",frame)
	end

	UIScale.Scale = 0
	frame.Visible = true
	frameTween = TweenService:Create(UIScale,openInfo,{Scale = 1})

	frameCon = frameTween.Completed:Connect(function()
		UIScale.Scale = 1
		if frameCon then
			frameCon:Disconnect()
			frameCon = nil
		end
	end)
	frameTween:Play()
end

-- 给定 guiobject, 使用 tweenservice 将其移动
function module.Play(gui:GuiObject)
	playOpenWinAnimation(gui)
end


return module