local MarketplaceService = game:GetService("MarketplaceService")
local rs = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

local uiManager = require(rs.Packages.UIManager)

local player = players.LocalPlayer
local playerGui = player.PlayerGui

local moreGameFrame: Frame = script.Parent.MoreGameFrame
local mainScreen = playerGui:WaitForChild("MainScreen", 5)
if not mainScreen then
	mainScreen = Instance.new("ScreenGui", playerGui)
	mainScreen.Name = "MainScreen"
end
mainScreen.IgnoreGuiInset = true
moreGameFrame.Parent = mainScreen
moreGameFrame.Visible = true
local displayFrame = moreGameFrame.DisplayFrame
local closeButton = displayFrame.CloseButton
local GameFrame = displayFrame.GameFrame
local itemFrame = moreGameFrame.GameElement

displayFrame.Visible = false
displayFrame.Parent = playerGui:WaitForChild("MainScreen")

local isTeleporting = false

local define = require(script.Parent.Define)
local eventBus = require(rs.EventBus)
local helper = require(script.Parent.Helper)

-- scrollingFrame简单适配
local RowNum = 5
local Item_Scale_X = nil
local Item_Scale_Y = nil
local offset_x = nil
local offset_y = nil
local gaspX = 0.5
local gaspY = 0.02
local gasp_X = nil
local gasp_Y = nil

local ClientModule = {}

local function CanvasChanging()
	local parentWidth = GameFrame.AbsoluteSize.X
	local parentHeight = GameFrame.AbsoluteSize.Y

	if parentHeight > parentWidth then
		local tp = parentHeight
		parentHeight = parentWidth
		parentWidth = tp
	end

	local scr_offset_x = parentWidth - GameFrame.ScrollBarThickness

	-- 默认Item的X轴比例，根据默认几列，以及总共间隔之和占单个ITEM的比例求得（视觉上根据Item来算间隔比例，且不会超出）
	Item_Scale_X = 1/(RowNum + gaspX)

	-- 当前Item的X绝对值
	offset_x = scr_offset_x * Item_Scale_X
	gasp_X = gaspX * offset_x/(1 + RowNum)
	-- 根据X轴比例求默认Item的Y轴比例，根据给的Item模板配置的X\Y绝对值求得

	Item_Scale_Y = itemFrame.Size.Y.Offset / itemFrame.Size.X.Offset

	-- 当前Item的y绝对值
	offset_y = Item_Scale_Y * offset_x
	gasp_Y = gaspY * offset_y / (1+2)
end

local function updatePos()
	local childs = GameFrame:GetChildren()
	local totalR = 0
	for _,item in pairs(childs) do
		local sort = item.LayoutOrder
		local posR = math.ceil(sort /RowNum)
		local posL = sort - (posR-1)*RowNum
		item.Size = UDim2.new(0,offset_x,0,offset_y)
		item.Position = UDim2.new(0,(posL-1)*offset_x +posL*gasp_X,0,(posR-1)*offset_y +posR*gasp_Y)
		if posR > totalR then
			totalR = posR
		end
	end
	GameFrame.CanvasSize = UDim2.new(0,0,0,offset_y * totalR +gasp_Y*(totalR+1))
end

local function SwitchFrame()
	if displayFrame.Visible then
		uiManager.ClosePanel("MoreGamePanel")
	else
		uiManager.OpenPanel("MoreGamePanel")
	end
end

local function InitGameInfo()
	local gameData = workspace:GetAttribute("MoreGameInfoList")
	if not gameData then return end
	local array = string.split(gameData, ";")
	if not array then return end

	CanvasChanging()
	GameFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		CanvasChanging()
		updatePos()
	end)

	local moreGamesInfo_Json = workspace:GetAttribute("MoreGamesInfo")
	local moreGamesInfo = moreGamesInfo_Json and httpService:JSONDecode(moreGamesInfo_Json)
	for idx, v in array do
		task.spawn(function()
			local info = string.split(v, "@")
			if not info then
				return
			end
			local placeId = info[2]
			if not placeId then return end

			local data = moreGamesInfo and moreGamesInfo[placeId]

			if data == nil then
				local success = nil

				local st = os.clock()
				while not success do
					task.wait(0.1)
					success, data = pcall(function()
						return MarketplaceService:GetProductInfo(placeId)
					end)
				end

				--print(string.format("读取游戏信息耗时:%ds [%s]", os.clock() - st, data.Name))
			end

			local GameElement: Frame = itemFrame:Clone()
			GameElement.Visible = true
			GameElement.LayoutOrder = #array - idx
			GameElement.Parent = GameFrame
			GameElement.ImageButton.Image = "rbxassetid://"..data.IconImageAssetId
			GameElement.GameName.Text = data.Name
			GameElement.Name = placeId
			
			if tonumber(placeId) ~= game.PlaceId then
				GameElement.ImageButton.MouseButton1Click:Connect(function()
					if isTeleporting then return end
					isTeleporting = true
	
					eventBus.FireServer(define.Event.RequestGoToOtherGame, tonumber(placeId))
				end)
			end
			CanvasChanging()
			updatePos()
		end)
	end

	eventBus.FireServer(define.Event.GetMoreGameWinEveryGameClickTimes)
end

local function RefreshTeleportCount(countData)
	if countData then
		for i,v in pairs(countData) do
			local GameElement = GameFrame:FindFirstChild(i)
			if GameElement then
				GameElement.Count.Visible = true
				GameElement.ImageLabel.Visible = true
				GameElement.Count.Text = v
			end
		end
	end
end

closeButton.MouseButton1Click:Connect(function()
	uiManager.ClosePanel("MoreGamePanel")
end)

local btnConnection = moreGameFrame.MenuIconHolder.MoreGame.ImageButton.MouseButton1Click:Connect(function()
	SwitchFrame()
	eventBus.FireServer(define.Event.GetMoreGameWinEveryGameClickTimes)
end)

-- init
if workspace:GetAttribute("MoreGameInfoList") then
	InitGameInfo()
else
	workspace:GetAttributeChangedSignal("MoreGameInfoList"):Connect(function()
		InitGameInfo()
	end)
end

-- update
eventBus.ConnectS2C(function(eventName, ...)
	local args = {...}
	if eventName == define.Event.SendMoreGameWinEveryGameClickTimes then
		local cntData = args[1]
		RefreshTeleportCount(cntData)
	end
end)

--[=[
	@server
	@within MoreGameModule
	@function GetButton
	@return ImageButton -- 获取MoreGameButton
]=]
function ClientModule.GetButton(): ImageButton
	return moreGameFrame.MenuIconHolder.MoreGame.ImageButton
end

--[=[
	@server
	@within MoreGameModule
	@function SetButton
	@return ImageButton -- 设置自定义的MoreGameButton
]=]
function ClientModule.SetButton(btn: ImageButton) 
	-- 注销默认的按钮委托并隐藏按钮
	moreGameFrame.MenuIconHolder.MoreGame.ImageButton.Visible = false
	btnConnection:Disconnect()
	btnConnection = nil

	-- 为新的按钮设置委托
	btnConnection = btn.MouseButton1Click:Connect(function()
		SwitchFrame()
		eventBus.FireServer(define.Event.GetMoreGameWinEveryGameClickTimes)
	end)
end

return ClientModule