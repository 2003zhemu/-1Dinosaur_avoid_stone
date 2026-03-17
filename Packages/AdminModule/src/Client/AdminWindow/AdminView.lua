local module = {}

local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local devScreen = Instance.new("ScreenGui")
devScreen.Name = "Dev Screen"
devScreen.DisplayOrder = 999
devScreen.Parent = playerGui

local gui = Instance.new("Frame")
gui.Parent = devScreen
-- set gui style | by: CatchMoon
gui.Size = UDim2.new(1,0,0.2,0)
gui.Position = UDim2.new(0,0,0.78,1)
gui.BackgroundTransparency = 1

-- layout
local layout = Instance.new("UIGridLayout")
layout.Parent = gui
-- set layout style | by: CatchMoon
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.CellSize = UDim2.new(0, 200, 0, 80)
layout.CellPadding = UDim2.new(0, 20, 0, 20)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom

-- 设置textButton风格 | by: CatchMoon
local _setTextButtonStyle = function(button: TextButton)
	task.spawn(function()
		button.Font = Enum.Font.Cartoon
		button.TextScaled = true
		button.Selectable = true
		button.AutoLocalize = false
		button.BorderMode = Enum.BorderMode.Outline
		button.BorderSizePixel = 4
		button.BackgroundTransparency = 0.4
		button.TextTransparency = 0.2
		local textSizeConstraint = Instance.new("UITextSizeConstraint", button)
		textSizeConstraint.MaxTextSize = 60
		Instance.new("UICorner", button)
		local uiStroke = Instance.new("UIStroke", button)
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Thickness = 3
		local uiGradient = Instance.new("UIGradient", button)
		uiGradient.Rotation = 90
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 160, 160)),
		})
		uiGradient.Color = colorSequence
	end)
end

local _createButton = function(id:string,isTest)
    if gui:FindFirstChild(id) then
        error("管理员工具栏已存在此按钮:"..id)
    end
    
    local button = Instance.new("TextButton")
    button.Name = id
	button.Text = id
	button.Parent = gui
	_setTextButtonStyle(button)
	
    if isTest then
		button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		button.LayoutOrder = 1
    else
        button.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
    end
    
    return button
end

module.Show = function(isShow)
    gui.Visible = isShow
end


module.CreateAdminButtons = function(ids)
    local arr = {}
    for i,v in ipairs(ids) do
        local button:Instance = _createButton(v)
        table.insert(arr,button)
    end
    return arr
end


module.CreateTestButtons = function(ids)
    local arr = {}
    for i,v in ipairs(ids) do
        local button:Instance = _createButton(v,true)
        table.insert(arr,button)
    end
    return arr
end

module.Init = function()
    
end

return module
