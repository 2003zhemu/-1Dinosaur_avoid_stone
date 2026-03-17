local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Connection = require(game.ReplicatedStorage.Packages.Neza.Connection)
local PurchaseResult = require(game.ReplicatedStorage.WuKongExtension.PurchaseResultHandler)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local module = {} :: defines.View

function module:Load()
	self.Items = {}
	self.OnlineFrame = self:GetUI("PlayerGui.HUD.Online")
	self.ScrollingFrame = self:GetUI("PlayerGui.HUD.Online.Content")
	self.CloseBtn = self:GetUI("PlayerGui.HUD.Online.Header.Close")
	self.Template = self:GetUI("PlayerGui.HUD.Online.Content.ItemTemplate")
	self.UpdateTimeStr = self:GetUI("PlayerGui.HUD.Online.Time")
	self.RedDot = self:GetUI("PlayerGui.MainGui.Left.Online.RedDot")

	self:SetContent(self.OnlineFrame)
	self:RegisterAs("Panel", "OnlinePanel")

	self:Bind(function()
		self.DataContext:HidePanel("HUD", "OnlinePanel")
	end, self.CloseBtn)

	self:UpdateList()
	self:UpdateRewardList(true)
	self:Connect("OnlineState.RewardShow", self.UpdateRewardShow)
	self:UpdateRedDot()
end

function module:Start()

end

function module:spinForever(obj: GuiObject, cycleTime: number)
	-- 锚点居中，旋转时不会位移
	obj.AnchorPoint = Vector2.new(0.5, 0.5)
	-- 无限旋转信息
	local spinInfo = TweenInfo.new(
		cycleTime, -- 转一圈所需时间
		Enum.EasingStyle.Linear, -- 匀速
		Enum.EasingDirection.Out,
		-1, -- 无限循环
		false, -- 不来回
		0
	)
	local goal = { Rotation = 360 } -- 定义旋转目标为360度
	TweenService:Create(obj, spinInfo, goal):Play()
end

function module:UpdateRedDot()
	local i = 1
	Connection.new(RunService.Heartbeat, function(db)
		i += db
		if i >= 1 then
			i = 0
			local CanClaimCount = 0
			local List = self.DataContext.OnlineState:GetList()
			if List == nil then return end
			local a = #List
			for _, v in ipairs(List) do
				if v.MoreInfo.CanGet then
					CanClaimCount += 1
				end
			end
			for i, v in ipairs(List) do
				if v.MoreInfo.IsGet == false then
					a = i
					break
				end
			end
			self.DataContext.OnlineState.maxReward = a
			self.RedDot.Visible = CanClaimCount > 0
		end
	end)
end

--主页面显示下次领取时间
function module:UpdateOnlineTime()
	self:Unbind("RewardOnlineTime")
	local i = 0
	Connection.new(RunService.Heartbeat, function(dt)
		i += dt
		if i >= 1 then
			i = 0
			local t = self.DataContext.OnlineState:GetOnlineTimeStr()
			self.OnlineLabel.Text = "Online:" .. t
		end
	end):Named("RewardOnlineTime")
end

function module:UpdateRewardShow(show)
	if show > 0 then
		local rewards = self.DataContext.OnlineState:GetCanClaimRewards()
		local cups = 0
		local speed = 0
		for _, v in ipairs(rewards) do
			if v.Id == "奖杯" then
				cups += v.Count
			else
				speed += v.Count
			end
		end
		if cups > 0 then
			Alert.Success(`Congrats! You earned {cups} Wins!`)
		end
		if speed > 0 then
			Alert.Success(`Congrats! You earned {speed} Speed!`)
		end
	end
end

function module:UpdateRewardList(isshow)
	self:Unbind("RewardList")
	local lastUpdateTime = 0
	local updateInterval = 1

	Connection.new(RunService.Heartbeat, function(dt)
		lastUpdateTime += dt
		if lastUpdateTime >= updateInterval then
			lastUpdateTime = 0
			self:UpdateList()
		end
	end):Named("RewardList")
end

function module:UpdateList()
	local List = self.DataContext.OnlineState:GetList()
	if not List then return end
	for _, child in ipairs(self.ScrollingFrame:GetChildren()) do
		if child:IsA("ImageButton") and child.Name ~= "ItemTemplate" then
			child:Destroy()
		end
	end

	local curIdx = 0
	if not self.Template then return end
	for i, v in ipairs(List) do
		local item = self.Template:Clone()
		item.Parent = self.ScrollingFrame
		item.Name = i
		item.Visible = true
		item.LayoutOrder = i

		if v.MoreInfo.IsGet then  --已领取
			item.ClaimedIcon.Visible = true
			curIdx = i
			if v.Id == "奖杯" then
				self:GetComponent(item.Icon):SetSprite("在线奖励", "奖杯")
				--self:GetComponent(item.Icon):SetSprite("在线奖励", "暗奖杯")
			else --速度
				self:GetComponent(item.Icon):SetSprite("在线奖励", "暗黄恐龙")
			end
			item.Claim.Text = "Claimed"
			item.Light.Visible = false
			item.Speed.Visible = false
			item.Time.Visible = false
			item.Ready.Visible = false
			item.Cups.Visible = false
		else  --未领取
			item.ClaimedIcon.Visible = false
			if v.Id == "奖杯" then
				self:GetComponent(item.Icon):SetSprite("在线奖励", "奖杯")
			else --速度
				self:GetComponent(item.Icon):SetSprite("在线奖励", "亮黄恐龙")
			end
			
			if v.MoreInfo.CanGet then  --可领取
				curIdx = i
				item.Claim.Visible = true
				item.Claim.Text = "Claim"
				item.Cups.Visible = false
				item.Speed.Visible = false
				item.Light.Visible = true  --显示光圈
				self:spinForever(item.Light, 10) --光圈转动
				item.Time.Visible = false
				item.Ready.Visible = true
				self:Unbind(item)
				self:Bind("ClaimOnlineReward", item, i):Then(function()
					item.Light.Visible = false
					item.Ready.Visible = false
					if v.Id == "奖杯" then
						self:GetComponent(item.Icon):SetSprite("在线奖励", "奖杯")
						--self:GetComponent(item.Icon):SetSprite("在线奖励", "暗奖杯")
					else --速度
						self:GetComponent(item.Icon):SetSprite("在线奖励", "暗黄恐龙")
					end
					self:Unbind(item)
					item.Claim.Visible = true
					item.Claim.Text = "Claimed"
					item.Cups.Visible = false
					item.Speed.Visible = false
				end)
			else  --时间不够
				item.Light.Visible = false
				item.Ready.Visible = false
				item.Claim.Visible = false
				item.Cups.Visible = v.Id == "奖杯"
				item.Speed.Visible = v.Id == "经验"
				if v.Id == "奖杯" then
					item.Cups.Text = `+{self.DataContext.Tool:AppendUnit(v.Count)} Wins`
				else
					item.Speed.Text = `+{self.DataContext.Tool:AppendUnit(v.Count)} SPD`
				end
				
				item.Time.Visible = true
				local t = v.MoreInfo.RequireProgress
				item.Time.Text = self.DataContext.OnlineState:FormatTime(t)
			end
		end
	end
	
	local t = self.DataContext.OnlineState:GetUpdateTime()
	self.UpdateTimeStr.Text = "Refresh: " .. self.DataContext.OnlineState:FormatTime(t)
end

return module
