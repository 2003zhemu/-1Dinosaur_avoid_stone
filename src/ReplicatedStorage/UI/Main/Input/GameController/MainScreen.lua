local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local TweenService = game:GetService("TweenService")
-- local Guidance = require(game.ReplicatedStorage.UI.Guidance.View.Guidance)
-- local VehiclePanel = require(game.ReplicatedStorage.UI.VehiclePanel.View.VehiclePanel)
local camera = {
	[1] = 5,
	[2] = 15,
	[3] = 30,
}
local index = 0
local tween = nil
local module = {} :: defines.Input

function module:Load()
	self.IsFocues = false
	self:SetSinked(false)
	self:BindLeft()
	self:SetActivated(true)
	game.UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.KeyCode == Enum.KeyCode.ButtonR3 then
			index += 1
			if index > #camera then
				index = 1
			end
			self:SetCamerAnim()
		end
	end)
end

function module:SetCamerAnim()
	if tween then
		tween:Cancel()
	end
	local tweenInfo = TweenInfo.new(
		0.2, -- 持续时间（秒）
		Enum.EasingStyle.Quad, -- 缓动样式
		Enum.EasingDirection.Out -- 缓动方向
	)
	local tween = TweenService:Create(
		game:GetService("Players").LocalPlayer,
		tweenInfo,
		{ CameraMaxZoomDistance = camera[index], CameraMinZoomDistance = camera[index] }
	)
	tween:Play()
end

function module:BindLeft()
	local AuraIcon = self:GetUI("PlayerGui.MainGui.Left.Aura.xbox")
	self:BindAction(function()
		self.DataContext:ShowPanel("HUD", "Auras")
	end, Enum.KeyCode.DPadRight):SetIcon(AuraIcon)

	local DayIcon = self:GetUI("PlayerGui.MainGui.Left.Day.xbox")
	self:BindAction(function()
		self.DataContext:ShowPanel("HUD", "7Day")
	end, Enum.KeyCode.DPadDown):SetIcon(DayIcon)

	local OnlineIcon = self:GetUI("PlayerGui.MainGui.Left.Online.xbox")
	self:BindAction(function()
		self.DataContext:ShowPanel("HUD", "OnlinePanel")
	end, Enum.KeyCode.DPadLeft):SetIcon(OnlineIcon)

	local RebirthIcon = self:GetUI("PlayerGui.MainGui.Left.Rebirth.xbox")
	self:BindAction(function()
		self.DataContext:ShowPanel("HUD", "Rebirth")
	end, Enum.KeyCode.DPadUp):SetIcon(RebirthIcon)

	local speedicon = self:GetUI("PlayerGui.MainGui.Right.Frame.CustomSpeed.xbox")
	local textbox = self:GetUI("PlayerGui.MainGui.Right.Frame.CustomSpeed.TextBox")
	self:BindAction(function()
		if not self.IsFocues then
			self.IsFocues = true
			textbox:CaptureFocus()
		else
			self.IsFocues = false
			textbox:ReleaseFocus()
		end
	end, { Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonY }):SetIcon(speedicon)

	-- local gamepadIcon = self:GetUI("PlayerGui.HUD.MainScreen.Top.GoBattle.GamePadIcon")
	-- self:UnbindAction(Enum.KeyCode.ButtonY)
	-- self:BindAction(function()
	-- 	Guidance:GoBattleFunc()
	-- 	VehiclePanel:GoBattleFunc()
	-- end, Enum.KeyCode.ButtonY):SetIcon(gamepadIcon)

	-- local gamepadIcon = self:GetUI("PlayerGui.HUD.MainScreen.Left.Shop.GamePadIcon")
	-- self:BindAction(function()
	-- 	self.DataContext:ShowPanel("HUD", "ShopPanel")
	-- end, Enum.KeyCode.DPadUp):SetIcon(gamepadIcon)

	-- local gamepadIcon = self:GetUI("PlayerGui.HUD.MainScreen.Left.Level.GamePadIcon")
	-- self:BindAction(function()
	-- 	self.DataContext:ShowPanel("HUD", "LevelPanel")
	-- end, Enum.KeyCode.DPadLeft):SetIcon(gamepadIcon)

	-- local gamepadIcon = self:GetUI("PlayerGui.HUD.MainScreen.Left.CarSave.GamePadIcon")
	-- self:BindAction(function()
	-- 	self.DataContext:ShowPanel("HUD", "CarSavePanel")
	-- end, Enum.KeyCode.DPadDown):SetIcon(gamepadIcon)

	-- local gamepadIcon = self:GetUI("PlayerGui.HUD.MainScreen.right.7day.GamePadIcon")
	-- self:BindAction(function()
	-- 	self.DataContext:ShowPanel("HUD", "7Day")
	-- end, { Enum.KeyCode.ButtonR2, Enum.KeyCode.DPadUp }):SetIcon(gamepadIcon)

	-- local gamepadIcon = self:GetUI("PlayerGui.HUD.MainScreen.right.Online.GamePadIcon")
	-- self:BindAction(function()
	-- 	self.DataContext:ShowPanel("HUD", "OnlinePanel")
	-- end, { Enum.KeyCode.ButtonR2, Enum.KeyCode.DPadLeft }):SetIcon(gamepadIcon)

	-- local gamepadIcon = self:GetUI("PlayerGui.BackpackGui.BarFrame.btnIcon")
	-- local idx = 0
	-- self:BindAction(function()
	-- 	idx = idx + 1
	-- 	if idx > 10 then
	-- 		idx = 1
	-- 	end
	-- 	self.DataContext.BackPackEvent.CurrentSelectIdx_BackPack = idx
	-- end, Enum.KeyCode.ButtonR1):SetIcon(gamepadIcon)
	-- self:BindAction(function()
	-- 	idx = idx - 1
	-- 	if idx < 1 then
	-- 		idx = 10
	-- 	end
	-- 	self.DataContext.BackPackEvent.CurrentSelectIdx_BackPack = idx
	-- end, Enum.KeyCode.ButtonL1):SetIcon(gamepadIcon)

	-- self:BindAction(function()
	-- 	idx = 0
	-- 	self.DataContext.BackPackEvent.CurrentSelectIdx_BackPack = nil
	-- end, Enum.KeyCode.ButtonB):SetIcon(gamepadIcon)
end

function module:OnShow_MainScreen()
	self:SetActivated(true)
	self:DisableGamepadCursor()
end
function module:OnHide_MainScreen()
	self:SetActivated(false)
	self:DisableGamepadCursor()
end

return module
