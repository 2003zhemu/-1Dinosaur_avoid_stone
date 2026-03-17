local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local ClickHelper = require(game.ReplicatedStorage.Helper.ClickHelper)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local stageConfigs = require(game.ReplicatedStorage._genConfigs.battle_tbstage)
local localPlayer = game.Players.LocalPlayer
local module = {} :: defines.View

function module:Load()
	self.Revive = self:GetUI("PlayerGui.HUD.Revive")
	self.Close = self:GetUI("PlayerGui.HUD.Revive.Header.Close")
	self.CupsBtn = self:GetUI("PlayerGui.HUD.Revive.Body.Cups")
	self.CupsBtnShade = self:GetUI("PlayerGui.HUD.Revive.Body.Cups.Frame")
	self.RobuxBtn = self:GetUI("PlayerGui.HUD.Revive.Body.Robux")
	self.CancelBtn = self:GetUI("PlayerGui.HUD.Revive.Body.Cancel")
	self.CupsCost = self:GetUI("PlayerGui.HUD.Revive.Body.Cups.TextLabel")

	self:SetContent(self.Revive)
	self:RegisterAs("Panel", "Revive")
	self.Close.Visible = false
	-- self:Bind(function()
	-- 	self.DataContext:HidePanel("HUD", "Revive")
	-- end, self.Close)
end

function module:Start()
	self:Bind(function()
		self:Cancel()
	end, self.CancelBtn)

	self:Bind(function()
		self:WinRevive()
	end, self.CupsBtn)

	self:Bind(function()
		if not ClickHelper.CanActivate("RobuxRevive", 0.5) then
			return
		end
		if localPlayer:GetAttribute("IsDead") then
			self.DataContext.Panel:BuyRevive()
			return
		end
	end, self.RobuxBtn)

	EventBus.Connect(function(eventName, params)
		if eventName == EventDefines["客户端显示复活页面"] then
			self.DataContext:ShowPanel("HUD", "Revive")
		end
		if eventName == EventDefines["客户端隐藏复活页面"] then
			self.DataContext:HidePanel("HUD", "Revive")
		end
	end)
end

function module:Cancel()
	if not ClickHelper.CanActivate("NoRevive", 0.5) then
		return
	end
	if localPlayer:GetAttribute("IsDead") then
		EventBus.FireServer(EventDefines["取消复活"])
		return
	end
end

function module:WinRevive()
	if not ClickHelper.CanActivate("CupRevive", 0.5) then
		return
	end
	if localPlayer:GetAttribute("IsDead") then
		--warn("发送奖杯复活")
		EventBus.FireServer(EventDefines["奖杯复活"])
		return
	end
end

function module:OnShow_Revive()
	self:UpdateCups()
end

function module:UpdateCups()
	self.CupsBtnShade.Visible = false
	local curCups = localPlayer:GetAttribute("Cups") --当前奖杯数
	local stage = localPlayer:GetAttribute("InStage") --当前关卡
	--warn("更新复活奖杯数", curCups, stage)
	if stage and curCups then
		local stageConfig = stageConfigs[stage]
		self.CupsCost.Text = `{stageConfig.CostCup} Wins`
		if stageConfig and stageConfig.CostCup > curCups then
			self.CupsBtnShade.Visible = true
		else
			self.CupsBtnShade.Visible = false
		end
	end
end

return module
