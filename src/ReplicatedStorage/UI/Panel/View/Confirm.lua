local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local ClickHelper = require(game.ReplicatedStorage.Helper.ClickHelper)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local RunService = game:GetService("RunService")
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local stageConfigs = require(game.ReplicatedStorage._genConfigs.battle_tbstage)
local localPlayer = game.Players.LocalPlayer
local module = {} :: defines.View

function module:Load()
	self.Confirm = self:GetUI("PlayerGui.HUD.Confirm")
	self.RefuseBtn = self:GetUI("PlayerGui.HUD.Confirm.Bottom.Refuse")
	self.AcceptBtn = self:GetUI("PlayerGui.HUD.Confirm.Bottom.Accept")
	self.Time = self:GetUI("PlayerGui.HUD.Confirm.Bottom.Refuse.Time")

	self:SetContent(self.Confirm)
	self:RegisterAs("Panel", "Confirm")
end

function module:Start()
	self:Bind(function()
		if not ClickHelper.CanActivate("CancelConfirm", 0.5) then
			return
		end
		if self.Conn then
			self.Conn:Disconnect()
		end
		--EventBus.Fire(EventDefines["确认不取消跟随"])
		self.DataContext:HidePanel("HUD", "Confirm")
	end, self.RefuseBtn)

	self:Bind(function()
		if not ClickHelper.CanActivate("OkConfirm", 0.5) then
			return
		end
		if self.Conn then
			self.Conn:Disconnect()
		end
		EventBus.Fire(EventDefines["确认取消跟随"])
		self.DataContext:HidePanel("HUD", "Confirm")
	end, self.AcceptBtn)

	EventBus.Connect(function(eventName, params)
		if eventName == EventDefines["跟随状态确认"] then
			self.DataContext:ShowPanel("HUD", "Confirm")
		end
	end)
end

function module:AcceptBtn()
	if not ClickHelper.CanActivate("OkConfirm", 0.5) then
		return
	end
	if self.Conn then
		self.Conn:Disconnect()
	end
	EventBus.Fire(EventDefines["确认取消跟随"])
	self.DataContext:HidePanel("HUD", "Confirm")
end

function module:CloseBtn()
	if not ClickHelper.CanActivate("CancelConfirm", 0.5) then
		return
	end
	if self.Conn then
		self.Conn:Disconnect()
	end
	--EventBus.Fire(EventDefines["确认不取消跟随"])
	self.DataContext:HidePanel("HUD", "Confirm")
end

function module:OnShow_Confirm()
	--self:UpdateInfo()
	self:UpdateTime()
end

function module:UpdateTime()
	local stepTime = 0
	local totalTime = 10
	if self.Conn then
		self.Conn:Disconnect()
	end
	self.Time.Text = `({totalTime}s)`
	self.Conn = RunService.Heartbeat:Connect(function(db)
		stepTime += db
		if stepTime >= 1 then
			stepTime = 0
			totalTime -= 1
			self.Time.Text = `({totalTime}s)`
			if totalTime <= 0 then
				-- 超时拒绝
				--EventBus.Fire(EventDefines["确认不取消跟随"])
				self.DataContext:HidePanel("HUD", "Confirm")
				self.Conn:Disconnect()
			end
		end
	end)
end

function module:UpdateInfo()
--	warn(self.Inviter)
	self.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={self.Inviter.UserId}&w=150&h=150`
	self.Title.Text =
		`<font color="#000000">[{self.Inviter.Name}] </font><font color="#4d6f44"> invited you to follow</font>`
	self:UpdateTime()
end

return module
