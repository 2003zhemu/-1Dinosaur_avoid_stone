local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local eventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local module = {} :: defines.View

function module:Load()
	self.GuiList = {
		FollowSettlePanel = self:GetUI("PlayerGui.HUD.FollowSettle"),
		claimBtn = self:GetUI("PlayerGui.HUD.FollowSettle.bg.claim"),
		CupNumLabel = self:GetUI("PlayerGui.HUD.FollowSettle.bg.Frame.TextLabel"),
		addAll = self:GetUI("PlayerGui.HUD.FollowSettle.bg.addall"),
		thumbupAll = self:GetUI("PlayerGui.HUD.FollowSettle.bg.thumbupall"),
		tmp = self:GetUI("PlayerGui.HUD.FollowSettle.bg.content.ScrollingFrame.tmp"),
		tmp_player = self:GetUI("PlayerGui.HUD.FollowSettle.bg.content.ScrollingFrame.tmp_player"),
	}
	self:SetContent(self.GuiList.FollowSettlePanel)
	self:RegisterAs("Panel", "FollowSettle")
	self:ConnectEvents()
	self:BindEvents()

	self.tmpList = {}
	self.thumbedUpSet = {}
	self.friendRequestedSet = {}
	self.settlePlayerList = {}
	-- 好友缓存：游戏开启时初始化一次，后续通过乐观更新维护，避免重复 HTTP 请求
	self.friendCache = {}
end

function module:DoThumbUp(player, item)
	if self.thumbedUpSet[player.UserId] then
		return
	end
	self.thumbedUpSet[player.UserId] = true
	eventBus.FireServer("ThumbUp", { TargetUserId = player.UserId })
	self:GetComponent(item.thumbup):SetSprite("跟随结算", "已点赞")
	item.thumbup.Interactable = false
end

function module:DoAddFriend(player, item)
	-- 以 friendCache 为唯一守卫，同时覆盖本轮 friendRequestedSet
	if self.friendCache[player.UserId] then
		return
	end
	local targetPlayer = game.Players:GetPlayerByUserId(player.UserId)
	if not targetPlayer then
		return
	end
	-- 乐观更新：发出请求后即视为好友，避免重复弹窗
	self.friendCache[player.UserId] = true
	self.friendRequestedSet[player.UserId] = true
	item.add.Interactable = false
	self:GetComponent(item.add):SetSprite("跟随结算", "好友")
	pcall(function()
		game:GetService("StarterGui"):SetCore("PromptSendFriendRequest", targetPlayer)
	end)
end

function module:BindEvents()
	local lastThumbupAllTime = 0
	self:Bind(function()
		local now = tick()
		if now - lastThumbupAllTime < 1 then
			return
		end
		lastThumbupAllTime = now
		for _, player in pairs(self.settlePlayerList) do
			if player.UserId ~= game.Players.LocalPlayer.UserId then
				local item = self.tmpList[player.UserId]
				if item then
					self:DoThumbUp(player, item)
				end
			end
		end
	end, self.GuiList.thumbupAll)

	self:Bind(function()
		for _, player in pairs(self.settlePlayerList) do
			if player.UserId ~= game.Players.LocalPlayer.UserId then
				local item = self.tmpList[player.UserId]
				if item then
					self:DoAddFriend(player, item)
				end
			end
		end
	end, self.GuiList.addAll)

	self:Bind(function()
		self.DataContext:HidePanel("HUD", "FollowSettle")
	end, self.GuiList.claimBtn)
end

function module:ShowAlert(likedCount: number)
	if likedCount > 0 then
		local text = likedCount == 1 and "1 player liked you!" or (likedCount .. " players liked you!")
		Alert.Info(text)
	end
end

function module:ConnectEvents()
	eventBus.ConnectS2C(function(eventName: string, param)
		if eventName == "FollowSettle" then
			-- 监听本次结算窗口内的点赞属性变化，精确统计本次获赞数
			local localPlayer = game.Players.LocalPlayer
			local sessionLikeCount = 0
			local prevNum = localPlayer:GetAttribute("ThumbUpNum") or 0
			local thumbConn = localPlayer:GetAttributeChangedSignal("ThumbUpNum"):Connect(function()
				local newNum = localPlayer:GetAttribute("ThumbUpNum") or 0
				local delta = newNum - prevNum
				if delta > 0 then
					sessionLikeCount += delta
				end
				prevNum = newNum
			end)
			task.delay(15, function()
				thumbConn:Disconnect()
				self:ShowAlert(sessionLikeCount)
			end)
			local followPlayer = param.FollowPlayer
			local leaderPlayer = param.LeaderPlayer
			local rewardCup = param.RewardCup

			-- 每次结算重置状态
			self.thumbedUpSet = {}
			self.friendRequestedSet = {}
			self.settlePlayerList = followPlayer

			-- 重置所有已缓存 item 的按钮状态
			for _, item in pairs(self.tmpList) do
				item.Visible = false
				local btn = item:FindFirstChild("thumbup")
				if btn then
					btn.Interactable = true
					self:GetComponent(btn):SetSprite("跟随结算", "点赞")
				end
				local addBtn = item:FindFirstChild("add")
				if addBtn then
					addBtn.Interactable = false
					-- 重置好友按钮 Sprite，避免上次结算的好友状态残留到本次异步检查完成前
					self:GetComponent(addBtn):SetSprite("跟随结算", "添加好友")
				end
			end

			self.GuiList.CupNumLabel.Text = tostring(rewardCup)
			for _, player in pairs(followPlayer) do
				local item = self.tmpList[player.UserId]
				local isLeader = player.UserId == leaderPlayer.UserId
				local isYour = player.UserId == game.Players.LocalPlayer.UserId
				if not item then
					if isLeader and isYour then
						item = self.GuiList.tmp:Clone()
						item.head.crown.Visible = true
						item.head.icon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=48&h=48"
						item.head.namelabel.Text = player.DisplayName
						item.playermark.Visible = true
						item.add.Visible = false
						item.thumbup.Visible = false
					elseif isLeader then
						item = self.GuiList.tmp:Clone()
						item.head.crown.Visible = true
						item.head.icon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=48&h=48"
						item.head.namelabel.Text = player.DisplayName
						item.playermark.Visible = false
					elseif isYour then
						item = self.GuiList.tmp_player:Clone()
						item.playermark.namelabel.Text = player.DisplayName
						item.head.icon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=48&h=48"
					else
						item = self.GuiList.tmp:Clone()
						item.head.crown.Visible = false
						item.head.icon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=48&h=48"
						item.head.namelabel.Text = player.DisplayName
						item.playermark.Visible = false
					end
					item.Parent = self.GuiList.tmp.Parent
					self.tmpList[player.UserId] = item
				end

				item.Visible = true
				-- 排序：领队第一，自己第二，其他随机
				if isLeader then
					item.LayoutOrder = 1
				elseif isYour then
					item.LayoutOrder = 2
				else
					item.LayoutOrder = 3
				end
				if not isYour then
					self:Unbind(item.thumbup)
					self:Unbind(item.add)

					-- 点赞按钮：每次结算重置为可用
					item.thumbup.Interactable = true
					self:Bind(function()
						self:DoThumbUp(player, item)
					end, item.thumbup)

					-- 加好友按钮：直接读缓存，无需异步 HTTP
					item.add.Interactable = false
					if self.friendCache[player.UserId] then
						self.friendRequestedSet[player.UserId] = true
						self:GetComponent(item.add):SetSprite("跟随结算", "好友")
					else
						self:GetComponent(item.add):SetSprite("跟随结算", "添加好友")
						item.add.Interactable = true
						self:Bind(function()
							self:DoAddFriend(player, item)
						end, item.add)
					end
				end
			end

			self.DataContext:ShowPanel("HUD", "FollowSettle")
		end
	end)
end

function module:Start()
	-- 游戏开启时，对当前服务器内所有玩家执行一次好友检查，填充缓存
	-- 后续通过乐观更新维护，整个生命周期内每位玩家只调用一次 IsFriendsWithAsync
	task.spawn(function()
		local localPlayer = game.Players.LocalPlayer
		local function checkAndCache(player)
			if player.UserId == localPlayer.UserId then
				return
			end
			if self.friendCache[player.UserId] ~= nil then
				return
			end
			local ok, isFriend = pcall(function()
				return localPlayer:IsFriendsWithAsync(player.UserId)
			end)
			self.friendCache[player.UserId] = ok and isFriend == true
		end

		for _, player in game.Players:GetPlayers() do
			checkAndCache(player)
		end
		-- 新玩家加入时也补充检查
		game.Players.PlayerAdded:Connect(checkAndCache)
	end)
end

return module
