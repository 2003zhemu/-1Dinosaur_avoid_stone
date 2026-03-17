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
	self.InviteFollow = self:GetUI("PlayerGui.HUD.InviteFollow")
	self.Close = self:GetUI("PlayerGui.HUD.InviteFollow.Background.Header.Close")
	self.RefuseBtn = self:GetUI("PlayerGui.HUD.InviteFollow.Bottom.Refuse")
	self.AcceptBtn = self:GetUI("PlayerGui.HUD.InviteFollow.Bottom.Accept")
	self.Time = self:GetUI("PlayerGui.HUD.InviteFollow.Bottom.Refuse.Time")
	self.Title = self:GetUI("PlayerGui.HUD.InviteFollow.Background.Content.Title.One")
	self.Avatar = self:GetUI("PlayerGui.HUD.InviteFollow.Background.Content.Icon.Avatar")

	self:SetContent(self.InviteFollow)
	self:RegisterAs("Panel", "InviteFollow")
	self:Bind(function()
		if not ClickHelper.CanActivate("CloseInvite", 0.5) then
			return
		end
		if self.Conn then
			self.Conn:Disconnect()
		end
		if self.Inviter then
			EventBus.FireServer(EventDefines["邀请拒绝"], { PlayerId = self.Inviter.UserId })
		end

		self.DataContext:HidePanel("HUD", "InviteFollow")
	end, self.Close)
end

function module:Accept()
	if not ClickHelper.CanActivate("AcceptInvite", 0.5) then
		return
	end
	if self.Conn then
		self.Conn:Disconnect()
	end
	if self.Inviter then
		EventBus.FireServer(EventDefines["同意邀请"], { PlayerId = self.Inviter.UserId })
	end
	self.DataContext:HidePanel("HUD", "InviteFollow")
end

function module:Cancel()
	if not ClickHelper.CanActivate("RefuseInvite", 0.5) then
		return
	end
	if self.Conn then
		self.Conn:Disconnect()
	end
	if self.Inviter then
		EventBus.FireServer(EventDefines["邀请拒绝"], { PlayerId = self.Inviter.UserId })
	end
	self.DataContext:HidePanel("HUD", "InviteFollow")
end

function module:Start()
	self:Bind(function()
		if not ClickHelper.CanActivate("RefuseInvite", 0.5) then
			return
		end
		if self.Conn then
			self.Conn:Disconnect()
		end
		if self.Inviter then
			EventBus.FireServer(EventDefines["邀请拒绝"], { PlayerId = self.Inviter.UserId })
		end
		self.DataContext:HidePanel("HUD", "InviteFollow")
	end, self.RefuseBtn)

	self:Bind(function()
		if not ClickHelper.CanActivate("AcceptInvite", 0.5) then
			return
		end
		if self.Conn then
			self.Conn:Disconnect()
		end
		if self.Inviter then
			EventBus.FireServer(EventDefines["同意邀请"], { PlayerId = self.Inviter.UserId })
		end
		self.DataContext:HidePanel("HUD", "InviteFollow")
	end, self.AcceptBtn)

	EventBus.ConnectS2C(function(eventName, params)
		if eventName == EventDefines["被邀请"] then
			self.Inviter = game.Players:GetPlayerByUserId(params.PlayerId)
			self.DataContext:ShowPanel("HUD", "InviteFollow")
		end
	end)
end

function module:OnShow_InviteFollow()
	self:UpdateInfo()
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
				EventBus.FireServer(EventDefines["邀请拒绝"], { PlayerId = self.Inviter.UserId })
				self.DataContext:HidePanel("HUD", "InviteFollow")
				self.Conn:Disconnect()
			end
		end
	end)
end

function module:UpdateInfo()
	--warn(self.Inviter)
	self.Avatar.Image = `rbxthumb://type=AvatarHeadShot&id={self.Inviter.UserId}&w=150&h=150`
	self.Title.Text =
		`<font color="#000000">[{self.Inviter.Name}] </font><font color="#4d6f44"> invited you to follow</font>`
	self:UpdateTime()
end

return module
