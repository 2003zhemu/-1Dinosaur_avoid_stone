local module = {}
-- 关闭窗口动画

local TweenService = game:GetService("TweenService")
local closetweenInfo = TweenInfo.new(0.25,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)

local eventBus = require(game.ReplicatedStorage.Packages.EventBus)
local uiManagerDefines = require(game.ReplicatedStorage.Packages.UIManager.Defines)

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
eventBus.Connect(function(eventName,...)
    if eventName == uiManagerDefines.EventAfterClose then
        -- 获取gui并验证参数
        local arr = {...}
        local panelName = arr[1]
        local gui: GuiObject = arr[2]

		if panelName ~= "主面板" 
            and panelName ~= "MessagePanel"
            and panelName ~= "进入挑战窗口"
            and panelName ~= "挑战面板"
        then
			playCloseWinAnimation(gui)
		end
    end
end)

return module