local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local AudioManager = require(game.ReplicatedStorage.Packages.AudioManager)
local TweenService = game:GetService("TweenService")
local module = {} :: defines.View

function module:Load()
	self.RewardFrame = self:GetUI("PlayerGui.RewardGui.Rewards")
	self.RewardCloseTips = self.RewardFrame.Content.CloseTips
	self.RewardCloseBtn = self:GetUI("PlayerGui.RewardGui.Rewards.TextButton")
	self:Bind("CloseReward", self.RewardCloseBtn)
	self:Connect("Panel.Info", self.ShowReward)
end

function module:ShowReward(rewards)
	if rewards then
		self.RewardFrame.Visible = true
		-- 清空旧的奖励项
		for i, v in pairs(self.RewardFrame.Content.Frame.List:GetChildren()) do
			if v:IsA("GuiObject") then
				v:Destroy()
			end
		end

		self.RewardFrame.Content.Frame.List.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		if #rewards >= 10 then
			self.RewardFrame.Content.Frame.List.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		end
		if #rewards > 0 and typeof(rewards[1]) ~= "Instance" or #rewards > 0 and typeof(rewards[1]) == "table" then
			for i, v in ipairs(rewards) do
				local Count = v.Count or v[2] or v.ActionResult.Count
				local Id = v.Id or v[1] or v.ActionResult.Id
				if Count == 0 then
					return
				end
				local item = self:GetNode("RewardPrefab")
				item.Count.Text = "×" .. tostring(Count)
				item.Parent = self.RewardFrame.Content.Frame.List
				if Id == "奖杯" then
					item.Icon.Visible = true
					self:GetComponent(item.Icon):SetSprite("主页面", "奖杯")
					--self:GetComponent(item.Bg):SetSprite(self.DataContext.Assets:StoreQuality(Id))
					--AudioManager:PlaySoundEffect("碰碰车_获得金币音效")
				elseif Id == "经验" then
					item.Icon.Visible = true
					self:GetComponent(item.Icon):SetSprite("主页面", "速度")
					--self:GetComponent(item.Bg):SetSprite(self.DataContext.Assets:StoreQuality(Id))
					--item.Count.Text = "Lv + " .. tostring(Count)
				else
					--item.Icon.Visible = false
					--self:DisposeModel(item, Id)
					--self:GetComponent(item.Bg):SetSprite(self.DataContext.Assets:GetIconBgById(Id))
				end
			end

			self:ShowCloseTips()
		end
	else
		if self.CloseTipsTween then
			self.CloseTipsTween:Cancel()
			self.CloseTipsTween = nil
			self.RewardCloseTips.TextTransparency = 1
		end
		self.RewardFrame.Visible = false
	end
end

function module:ShowCloseTips()
	self.RewardCloseTips.Visible = true
	self.RewardCloseBtn.Visible = true
	if self.CloseTipsTween then
		self.CloseTipsTween:Cancel()
		self.CloseTipsTween = nil
		self.RewardCloseTips.TextTransparency = 0
	end
	self.CloseTipsTween = TweenService:Create(
		self.RewardCloseTips,
		TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
		{ TextTransparency = 0.7 }
	)
	self.CloseTipsTween:Play()
end

return module
