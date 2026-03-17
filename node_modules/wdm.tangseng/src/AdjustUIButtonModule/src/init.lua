local module = {}

local TweenService = game:GetService("TweenService")

local CollectionService = game:GetService("CollectionService")

-- eventbus
local eventBus = require(game.ReplicatedStorage.Packages.EventBus)

local uiManagerDefines = require(game.ReplicatedStorage.Packages.UIManager.Defines)

-- 对UDim进行插值
local function Lerp(udim: UDim, alpha: number): UDim
    return UDim.new(udim.Scale * alpha, udim.Scale * alpha)
end

-- 对UDim进行插值
local function Lerp2(udim2: UDim2, alpha: number): UDim2
    return UDim2.new(Lerp(udim2.X, alpha), Lerp(udim2.Y, alpha))
end

-- 设置鼠标悬停至UI上时UI自动放大, 鼠标离开时UI自动还原
--[[
	checkUI: 检测鼠标悬停的UI, 该UI的大小决定检测区域大小
	expandUI: 要扩展的UI(需要有Size属性[Size为UDim2类型], 之后可能会适配其它UI控件)
	scale: 缩放系数
	transformTime: 放大或还原的过渡时间
	
	注意:win的Size属性不能受其它控件影响
]]
local function setUIExpand(
    checkUI: GuiObject,
    expandUI: GuiObject?,
    scale: number?,
    transformTime: number?)

    if expandUI == nil then expandUI = checkUI end
    if scale == nil then scale = 1.1 end
    if transformTime == nil then transformTime = 0.1 end
	local DEFAULT_SIZE = expandUI.Size -- 记录默认大小

	local expandTween = nil
	local restoreTween = nil

	checkUI.MouseEnter:Connect(function()
		-- 若正在缩小, 停止缩小动画, 并立即释放内存
		if restoreTween ~= nil then
			restoreTween:Destroy()
			restoreTween = nil 
		end

		-- 计算播放放大动画的时间
		local uiCurScale: number
		if DEFAULT_SIZE.X.Scale ~= 0 then
			uiCurScale = expandUI.Size.X.Scale / DEFAULT_SIZE.X.Scale
		elseif DEFAULT_SIZE.X.Offset ~= 0 then
			uiCurScale = expandUI.Size.X.Offset / DEFAULT_SIZE.X.Offset
		end
		local expandTransformTime = (1 - (uiCurScale - 1) / (scale - 1)) * transformTime

		-- 创建放大动画, 并播放
		local expandTweenInfo = TweenInfo.new(expandTransformTime)
		local expandTweenGoal = { Size = Lerp2(DEFAULT_SIZE, scale) }
		expandTween = TweenService:Create(expandUI, expandTweenInfo, expandTweenGoal)
		expandTween:Play()
	end)
	checkUI.MouseLeave:Connect(function()
		-- 若正在放大, 停止放大动画, 并立即释放内存
		if expandTween ~= nil then
			expandTween:Destroy()
			expandTween = nil
		end

		-- 计算播放缩小动画的时间
		local uiCurScale: number
		if DEFAULT_SIZE.X.Scale ~= 0 then
			uiCurScale = expandUI.Size.X.Scale / DEFAULT_SIZE.X.Scale
		elseif DEFAULT_SIZE.X.Offset ~= 0 then
			uiCurScale = expandUI.Size.X.Offset / DEFAULT_SIZE.X.Offset
		end
		local restoreTransformTime = ((uiCurScale - 1) / (scale - 1)) * transformTime

		-- 创建缩小动画, 并播放
		local restoreTweenInfo = TweenInfo.new(restoreTransformTime)
		local restoreTweenGoal = { Size = DEFAULT_SIZE }
		restoreTween = TweenService:Create(expandUI, restoreTweenInfo, restoreTweenGoal)
		restoreTween:Play()
	end)
end

-- 为gui的所有孙子修改按钮时间
local function _modifyButtons(gui)
    for index, descendant:Instance in pairs(gui:GetDescendants()) do
        if 
            descendant:IsA("TextButton") or
            descendant:IsA("ImageButton") or
            CollectionService:HasTag(descendant,"scale")        
        then
            setUIExpand(descendant)
        end
        
    end
end



eventBus.Connect(function(eventName,...)
    if eventName == uiManagerDefines.EventAfterOpen then
        local arr = {...}
        local gui:Instance = arr[2]
        assert(gui)
        if not gui:GetAttribute("__isUIButtonAdjusted") then
            _modifyButtons(gui)
            gui:SetAttribute("__isUIButtonAdjusted",true)
        end
    end
end)

return module
