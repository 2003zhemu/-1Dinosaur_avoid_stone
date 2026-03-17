local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local UserInputService = game:GetService("UserInputService")
local module = {} :: defines.View

local INVITE_CD = 30

function module:Load()
	self.GuiList = {
		InviteCenterPanel = self:GetUI("PlayerGui.HUD.InviteCenter"),
		CloseBtn = self:GetUI("PlayerGui.HUD.InviteCenter.bg.closebtn"),
		AllowInvitedBtn = self:GetUI("PlayerGui.HUD.InviteCenter.bg.allow"),

		tmp = self:GetUI("PlayerGui.HUD.InviteCenter.bg.content.ScrollingFrame.tmp"),

		InviteAllBtn = self:GetUI("PlayerGui.HUD.InviteCenter.bg.InviteAll"),

		OpenBtn = self:GetUI("PlayerGui.MainGui.Right.InviteCenter"),
	}

	self:SetContent(self.GuiList.InviteCenterPanel)
	self:RegisterAs("Panel", "InviteCenter")

	self:BindEvents()
	self:ConnectEvents()

	self.playerTmp = {}
end

-- 目标玩家是否处于跟随会话中（作为跟随者或领队）
-- InviteStatus == 0 表示会话已结束；FollowPlayers 会话结束后被设为 "{}" 而非 nil，不可用于判断
function module:IsInFollowSession(targetPlayer)
	if not targetPlayer then
		return false
	end
	local inviteStatus = targetPlayer:GetAttribute("InviteStatus")
	return targetPlayer:GetAttribute("FollowPlayerId") ~= nil or (inviteStatus ~= nil and inviteStatus ~= 0)
end

-- 本地玩家是否可以邀请目标玩家
function module:CanInvite(targetPlayer)
	local localPlayer = game.Players.LocalPlayer
	if not targetPlayer then
		return false
	end
	-- 不能邀请自己
	if targetPlayer.UserId == localPlayer.UserId then
		return false
	end
	-- 本地玩家在局内不可邀请
	if not localPlayer:GetAttribute("InLobby") then
		return false
	end
	-- 目标玩家在局内不可被邀请
	if not targetPlayer:GetAttribute("InLobby") then
		return false
	end
	-- 目标玩家未开启接受邀请
	if not targetPlayer:GetAttribute("AcceptInvite") then
		return false
	end
	-- 目标玩家已在跟随会话中
	if self:IsInFollowSession(targetPlayer) then
		return false
	end
	return true
end

-- 刷新单个按钮的所有 image 显示状态
-- 优先级：followed > cd（保持） > caninvite > 全灭
function module:RefreshButtonState(userId)
	local item = self.playerTmp[userId]
	if not item then
		return
	end
	local targetPlayer = game.Players:GetPlayerByUserId(userId)
	local btn = item.bg.ImageButton
	local cd = btn.cd

	if not targetPlayer then
		btn.followed.Visible = false
		btn.caninvite.Visible = false
		cd.Visible = false
		btn.Interactable = false
		return
	end

	-- CD 进行中：InviteStatus 存在中间态，不能仅凭它判断是否已接受
	-- 只有 FollowPlayerId 已设置（已成为跟随者）或 InviteStatus == 4（已成为活跃领队）
	-- 才说明邀请被接受，此时关闭 CD 并切换到 followed；否则维持 CD 继续倒计时
	if cd.Visible then
		local accepted = targetPlayer:GetAttribute("FollowPlayerId") ~= nil
			or targetPlayer:GetAttribute("InviteStatus") == 4
		if accepted then
			btn.followed.Visible = true
			btn.caninvite.Visible = false
			cd.Visible = false
			btn.Interactable = false
		end
		return
	end

	if self:IsInFollowSession(targetPlayer) then
		-- 非 CD 状态下目标进入跟随会话，直接显示 followed
		btn.followed.Visible = true
		btn.caninvite.Visible = false
		cd.Visible = false
		btn.Interactable = false
		return
	end

	local invitable = self:CanInvite(targetPlayer)
	btn.followed.Visible = false
	btn.caninvite.Visible = invitable
	btn.Interactable = invitable
end

-- 启动邀请 CD 计时器，CD 结束后刷新按钮状态
function module:StartCDTimer(userId, btn)
	local cd = btn.cd
	btn.Interactable = false
	btn.caninvite.Visible = false
	btn.followed.Visible = false
	cd.Visible = true
	cd.TextLabel.Text = INVITE_CD .. "s"
	local startTime = tick()
	task.spawn(function()
		while true do
			task.wait(1)
			-- CD 被外部取消（如目标玩家进入跟随会话，RefreshButtonState 已关闭 cd）
			if not cd.Visible then
				break
			end
			local remaining = INVITE_CD - math.floor(tick() - startTime)
			if remaining <= 0 then
				cd.Visible = false
				self:RefreshButtonState(userId)
				break
			end
			cd.TextLabel.Text = remaining .. "s"
		end
	end)
end

function module:ConnectEvents()
	game.Players.PlayerRemoving:Connect(function(player)
		local item = self.playerTmp[player.UserId]
		if item then
			item:Destroy()
			self.playerTmp[player.UserId] = nil
		end
	end)

	local function refreshAll()
		for userId in self.playerTmp do
			self:RefreshButtonState(userId)
		end
	end

	-- 监听影响邀请状态的所有属性
	local function setupPlayerListener(p)
		p:GetAttributeChangedSignal("FollowPlayerId"):Connect(refreshAll)
		p:GetAttributeChangedSignal("InviteStatus"):Connect(refreshAll)
		p:GetAttributeChangedSignal("AcceptInvite"):Connect(refreshAll)
		p:GetAttributeChangedSignal("InLobby"):Connect(refreshAll)
	end
	-- 本地玩家进出局内也需要刷新所有按钮
	game.Players.LocalPlayer:GetAttributeChangedSignal("InLobby"):Connect(refreshAll)
	for _, p in game.Players:GetPlayers() do
		setupPlayerListener(p)
	end
	game.Players.PlayerAdded:Connect(setupPlayerListener)

	-- AllowInvitedBtn 状态
	local localPlayer = game.Players.LocalPlayer
	local function refreshAllowBtn()
		local attribute = localPlayer:GetAttribute("AcceptInvite")
		if attribute then
			self.GuiList.AllowInvitedBtn.TextLabel.Text = "Accept the invitation"
			self.GuiList.AllowInvitedBtn.TextLabel.LayoutOrder = 1
			self.GuiList.AllowInvitedBtn.ImageLabel.LayoutOrder = 0
			self:GetComponent(self.GuiList.AllowInvitedBtn):SetSprite("邀请中心", "接受邀请")
		else
			self.GuiList.AllowInvitedBtn.TextLabel.Text = "Decline the invitation"
			self.GuiList.AllowInvitedBtn.TextLabel.LayoutOrder = 0
			self.GuiList.AllowInvitedBtn.ImageLabel.LayoutOrder = 1
			self:GetComponent(self.GuiList.AllowInvitedBtn):SetSprite("邀请中心", "拒绝邀请")
		end
	end
	refreshAllowBtn()
	localPlayer:GetAttributeChangedSignal("AcceptInvite"):Connect(refreshAllowBtn)
end

function module:OnShow_InviteCenter()
	local players = game.Players:GetPlayers()
	for _, player in pairs(players) do
		local item = self.playerTmp[player.UserId] or self.GuiList.tmp:Clone()
		self.playerTmp[player.UserId] = item
		item.Name = player.Name
		item.Parent = self.GuiList.tmp.Parent
		item.Visible = player.UserId ~= game.Players.LocalPlayer.UserId

		item.bg.namelabel.Text = player.DisplayName
		item.bg.headicon.icon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=48&h=48"

		if player.UserId == game.Players.LocalPlayer.UserId then
			continue
		end

		-- 刷新按钮状态（CD 进行中时不重置）
		self:RefreshButtonState(player.UserId)

		-- 重新绑定点击事件
		local btn = item.bg.ImageButton
		self:Unbind(btn)
		self:Bind(function()
			if not self:CanInvite(player) then
				return
			end
			EventBus.FireServer("InvitePlayer", { InviteId = player.UserId })
			self:StartCDTimer(player.UserId, btn)
		end, btn)
	end
end

function module:BindEvents()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.V then
			if self.GuiList.InviteCenterPanel.Visible then
				self.DataContext:HidePanel("HUD", "InviteCenter")
			else
				self.DataContext:ShowPanel("HUD", "InviteCenter")
			end
		end
	end)

	self:Bind(function()
		self.DataContext:ShowPanel("HUD", "InviteCenter")
	end, self.GuiList.OpenBtn)

	self:Bind(function()
		self.DataContext:HidePanel("HUD", "InviteCenter")
	end, self.GuiList.CloseBtn)

	local lastClickTime = 0
	self:Bind(function()
		local currentTime = tick()
		if currentTime - lastClickTime < 0.5 then
			Alert.Warn("Please do not click frequently")
			return
		end
		lastClickTime = currentTime
		local attribute = game.Players.LocalPlayer:GetAttribute("AcceptInvite")
		local newValue = not attribute
		self.DataContext.ContainerHelper.SetContainerValue(
			game.Players.LocalPlayer.UserId,
			"属性",
			"接受邀请",
			newValue
		)
	end, self.GuiList.AllowInvitedBtn)

	self:Bind(function()
		local localPlayer = game.Players.LocalPlayer
		-- 本地玩家在局内不可发起一键邀请
		if not localPlayer:GetAttribute("InLobby") then
			return
		end
		self.GuiList.InviteAllBtn.Interactable = false
		for userId, item in self.playerTmp do
			-- 跳过自己
			if userId == localPlayer.UserId then
				continue
			end
			local btn = item.bg.ImageButton
			-- 只邀请当前按钮可交互（未在 CD、未跟随、可被邀请）的玩家
			if not btn.Interactable then
				continue
			end
			EventBus.FireServer("InvitePlayer", { InviteId = userId })
			self:StartCDTimer(userId, btn)
		end
		task.delay(INVITE_CD, function()
			self.GuiList.InviteAllBtn.Interactable = true
		end)
	end, self.GuiList.InviteAllBtn)
end

function module:Start() end

return module
