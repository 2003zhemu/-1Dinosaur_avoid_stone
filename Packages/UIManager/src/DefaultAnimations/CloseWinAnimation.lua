local module = {}
-- 关闭窗口动画

local TweenService = game:GetService("TweenService")
local closetweenInfo = TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

local blureffect = workspace.Camera:FindFirstChildOfClass("BlurEffect")

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

local function playCloseWinAnimation(frame)
	blureffect.Enabled =false
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

	frame.Visible=true
	if frameTween then
		frameTween:Pause()
		frameTween = nil
	end
	if frameCon then
		frameCon:Disconnect()
		frameCon = nil
	end

	frameTween = TweenService:Create(frame,closetweenInfo,{
		Position = UDim2.new(0.5, 0 , 1.4, 0),
	})
	frameCon = frameTween.Completed:Connect(function(pb)
		frame.Visible = false
		if frameCon then
			frameCon:Disconnect()
			frameCon = nil
		end
	end)
	frameTween:Play()
end

-- 给定 guiobject, 使用 tweenservice 将其移动
function module.Play(gui:GuiObject)
	playCloseWinAnimation(gui)
end


return module