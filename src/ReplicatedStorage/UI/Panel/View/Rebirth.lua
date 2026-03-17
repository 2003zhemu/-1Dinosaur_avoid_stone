local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local ClickHelper = require(game.ReplicatedStorage.Helper.ClickHelper)
local wukong = require(game.ReplicatedStorage.WuKong)
local RunService = game:GetService("RunService")
local Connection = require(game.ReplicatedStorage.Packages.Neza.Connection)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local rebirthConfig = require(game.ReplicatedStorage._genConfigs.battle_tbreborn)
local localPlayer = game.Players.LocalPlayer
local isMaxTimes = false
local module = {} :: defines.View

function module:Load()
	self.RebirthPanel = self:GetUI("PlayerGui.HUD.Rebirth")
	self.Close = self:GetUI("PlayerGui.HUD.Rebirth.Content.Header.Close")
	self.BeforeLevel = self:GetUI("PlayerGui.HUD.Rebirth.Content.Body.Left.Level.TextLabel")
	self.BeforeSpeed = self:GetUI("PlayerGui.HUD.Rebirth.Content.Body.Left.Speed.TextLabel")
	self.BeforeTimes = self:GetUI("PlayerGui.HUD.Rebirth.Content.Body.Left.Times.TextLabel")

	self.RedDot = self:GetUI("PlayerGui.MainGui.Left.Rebirth.RedDot")

	self.AfterLevel = self:GetUI("PlayerGui.HUD.Rebirth.Content.Body.Right.Level.TextLabel")
	self.AfterTimes = self:GetUI("PlayerGui.HUD.Rebirth.Content.Body.Right.Times.TextLabel")
	self.AfterSpeed = self:GetUI("PlayerGui.HUD.Rebirth.Content.Body.Right.Speed.TextLabel")

	self.Progress = self:GetUI("PlayerGui.HUD.Rebirth.Content.Bottom.ProgressBar.Progress.UIGradient")
	self.ProgressText = self:GetUI("PlayerGui.HUD.Rebirth.Content.Bottom.ProgressBar.TextLabel")

	self.RebirthButton = self:GetUI("PlayerGui.HUD.Rebirth.Btns.RebirthBtn")
	self.SkipRebirthButton = self:GetUI("PlayerGui.HUD.Rebirth.Btns.SkipRebirth")

	self:SetContent(self.RebirthPanel)
	self:RegisterAs("Panel", "Rebirth")
	self:UpdateRedDot()

	self:Bind(function()
		self.DataContext:HidePanel("HUD", "Rebirth")
	end, self.Close)
end

function module:Start()
	self:Bind(function()
		if not ClickHelper.CanActivate("Rebirth", 0.5) then
			return
		end
		if isMaxTimes then
			Alert.Warn("Max rebirth times.")
			return
		end

		local curLevel = self.DataContext.Property.Level
		local maxLevel = self.DataContext.Property.MaxLevel
		if curLevel < maxLevel then
			Alert.Warn("Level too low. Please level up.")
			return
		end
		EventBus.FireServer(EventDefines["玩家重生"])
		task.delay(0.5, function()
			self.DataContext:HidePanel("HUD", "Rebirth")
		end)
	end, self.RebirthButton)

	self:Bind(function()
		if not ClickHelper.CanActivate("SkipRebirth", 0.5) then
			return
		end
		if isMaxTimes then
			Alert.Warn("Max rebirth times.")
			return
		end
		local curTimes = self.DataContext.Property.RebirthTimes --当前重生次数
		local id = nil
		if curTimes < 4 then
			id = "跳过重生1"
		elseif curTimes < 6 then
			id = "跳过重生2"
		else
			id = "跳过重生3"
		end
		wukong:ExecuteQuery(`/现金/买功能/{id}?弹出购买窗口`)
		task.delay(0.5, function()
			self.DataContext:HidePanel("HUD", "Rebirth")
		end)
	end, self.SkipRebirthButton)

	self:Connect("Property.Level", function(propertyName)
		self:UpdateRebirth()
	end)
end

function module:OnShow_Rebirth()
	self:UpdateRebirth()
end

function module:UpdateRebirth()
	local curTimes = self.DataContext.Property.RebirthTimes --当前重生次数
	local nextTimes = curTimes + 1
	local curConfig = rebirthConfig["重生" .. curTimes]
	local nextConfig = rebirthConfig["重生" .. nextTimes]
	if not nextConfig then
		nextTimes = curTimes
		nextConfig = curConfig
		isMaxTimes = true
	end
	if localPlayer:GetAttribute("InMaxLevel") then
		isMaxTimes = true
	end

	self.BeforeLevel.Text = `Lv {curConfig.MaxLevel}`
	self.AfterLevel.Text = `Lv {nextConfig.MaxLevel}`
	self.BeforeSpeed.Text = `x{curConfig.ExpRate} spd`
	self.AfterSpeed.Text = `x{nextConfig.ExpRate} spd`
	self.BeforeTimes.Text = `{curTimes}`
	self.AfterTimes.Text = `{nextTimes}`

	local progress = self.DataContext.Property.Level / curConfig.MaxLevel
	self:GetComponent(self.Progress):SetProgress(math.clamp(progress, 0, 1))
	self.ProgressText.Text = `Level {self.DataContext.Property.Level}/{curConfig.MaxLevel}`
end

function module:UpdateRedDot()
	local i = 1
	Connection.new(RunService.Heartbeat, function(db)
		if localPlayer:GetAttribute("InMaxLevel") then
			self.RedDot.Visible = false
			return
		end
		i += db
		if i >= 1 then
			i = 0
			local curTimes = self.DataContext.Property.RebirthTimes --当前重生次数
			local curConfig = rebirthConfig["重生" .. curTimes]
			if not curConfig then
				return
			end

			local maxLevel = curConfig.MaxLevel
			local curLevel = self.DataContext.Property.Level
			self.RedDot.Visible = curLevel == maxLevel
		end
	end)
end

return module
