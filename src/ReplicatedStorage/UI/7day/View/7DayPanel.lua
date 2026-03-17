local Players = game:GetService("Players")
local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local Timer = require(game.ReplicatedStorage.Packages.Neza.Timer)
local wukong = require(game.ReplicatedStorage.WuKong)
local module = {} :: defines.View

function module:Load()
	self.contentFrame = self:GetUI("PlayerGui.HUD.DailyRewards")
	self:SetContent(self.contentFrame)
	self:RegisterAs("Panel", "7Day")

	-- self.TimeLabel = self:GetUI("PlayerGui.HUD.7DayPanel.Foreground.ImageLabel.CountDown")

	self.ContentList = {
		self:GetUI("PlayerGui.HUD.DailyRewards.SmallContainers.Day1"),
		self:GetUI("PlayerGui.HUD.DailyRewards.SmallContainers.Day2"),
		self:GetUI("PlayerGui.HUD.DailyRewards.SmallContainers.Day3"),
		self:GetUI("PlayerGui.HUD.DailyRewards.SmallContainers.Day4"),
		self:GetUI("PlayerGui.HUD.DailyRewards.SmallContainers.Day5"),
		self:GetUI("PlayerGui.HUD.DailyRewards.SmallContainers.Day6"),
		self:GetUI("PlayerGui.HUD.DailyRewards.Day7"),
	}

	self.CloseBtn = self:GetUI("PlayerGui.HUD.DailyRewards.Header.Button")
	self.SevenDayIcon = self:GetUI("PlayerGui.MainGui.Left.Day")
	--self.SevenDayIcon = self:GetUI("PlayerGui.HUD.MainScreen.right.7day")

	self:Bind(function()
		self.DataContext:HidePanel("HUD", "7Day")
	end, self.CloseBtn)
	self:Bind(function()
		self.DataContext:ShowPanel("HUD", "7Day")
	end, self.SevenDayIcon)

	--self.SevenDayIcon.Parent.Visible = false
	self.SevenDayIcon.Visible = false
	local arg = self.DataContext.AttendanceState:GetCurrentDaily()

	-- if tonumber(arg) < 7 then
	-- 	self.SevenDayIcon.Parent.Visible = true
	-- end
	if tonumber(arg) < 7 then
		self.SevenDayIcon.Visible = true
	end

	self.RedDot = self.SevenDayIcon.RedDot
	self.RedDot.Visible = false

	self:Connect("AttendanceState.RefreshDaliyFrame", self.UpdateDailyFrame)
	-- self:InitViewAward()
	task.spawn(function()
		while task.wait(0.01) do
			for index, value in pairs(self.ContentList) do
				local btn = value.Button
				btn.Light.Rotation = btn.Light.Rotation + 2
			end
		end
	end)
end
function module:Start()
	-- self:UpdateDailyFrame2222()
end

function module:UpdatePanel(val)
	if val == 2 then
		local rewardList = self.DataContext.AttendanceState:GetDailyRewardList()
		local receive = {}
		local startDay, endDay = self.DataContext.AttendanceState:GetRewardStarAndEnd()
		for i = startDay, endDay do
			table.insert(receive, rewardList[i])
		end
		self:Using("Reward")
		-- self.DataContext.Panel.Info = receive
		self:UsingEnd()
		self.DataContext.AttendanceState.Panel = 1
	end
end

function module:UpdateCurrentActivity(frameName)
	if frameName == "7Day" then
		self.contentFrame.Visible = true
	end
end

-- function module:InitViewAward()
-- 	self:DisposeModel(self.ContentList[2].Foreground.Bg, "引擎四级")
-- 	self:DisposeModel(self.ContentList[3].Foreground.Bg, "尖刺护栏三级")
-- 	self:DisposeModel(self.ContentList[5].Foreground.Bg, "装甲四级")
-- 	self:DisposeModel(self.ContentList[6].Foreground.Bg, "方块五级")
-- 	self:DisposeModel(self.ContentList[7].Foreground.Bg, "装甲五级")
-- end

-- function module:DisposeModel(item, id)
-- 	-- local modelAssestPath = game.ReplicatedStorage.Assets.BackPackModel
-- 	-- if not modelAssestPath:FindFirstChild(id) then
-- 	-- 	warn("Model not exist")
-- 	-- 	return
-- 	-- end
-- 	-- local model = modelAssestPath:FindFirstChild(id):Clone()
-- 	-- model.Parent = item.ViewportFrame

-- 	-- local BackPackViewCF = model:GetAttribute("BackPackViewCF") or CFrame.new(0, 0, 0)
-- 	-- model:PivotTo(BackPackViewCF)

-- 	-- local camera = Instance.new("Camera")
-- 	-- camera.Parent = item.ViewportFrame

-- 	-- camera.CameraType = Enum.CameraType.Scriptable
-- 	-- camera.CFrame = CFrame.new(0, 0, 0)

-- 	-- item.ViewportFrame.CurrentCamera = camera
-- end

function module:UpdateDailyFrame()
	local SignedinCount = self.DataContext.AttendanceState:GetSignedinCount()
	local pass = self.DataContext.AttendanceState:VerifyCanGet()
	SignedinCount = tonumber(SignedinCount)
	if pass then
		--处理可领取
		local frame = nil
		frame = self.ContentList[SignedinCount + 1]
		local btn = frame.Button
		self:Unbind(btn)
		self.RedDot.Visible = true
		btn.Light.Visible = true
		btn.Shadow.Visible = false
		btn.BG.Visible = false
		btn.BG2.Visible = true
		-- self:GetComponent(btn.BG):SetSprite("七日签到", "底图 2 ")
		self:Bind("ClickBtn", btn, "Attendance", SignedinCount + 1):Then(function()
			self:Unbind(btn)
		end)
	else
		--处理已林区
		local frame = nil
		if SignedinCount == 7 then
			frame = self.ContentList[7]
		else
			frame = self.ContentList[SignedinCount + 1]
		end
		local btn = frame.Button
		self:Unbind(btn)
		btn.BG.Visible = true
		btn.BG2.Visible = false
		-- self:GetComponent(btn.BG):SetSprite("七日签到", "底图 1 ")
		self.RedDot.Visible = false
		btn.Light.Visible = false
		-- btn.Shadow.Visible = true
	end

	if SignedinCount >= 1 then
		for i = 1, SignedinCount do
			local frame = nil
			frame = self.ContentList[i]
			local btn = frame.Button
			btn.Light.Visible = false
			btn.Shadow.Visible = true
			btn.BG.Visible = true
			btn.BG2.Visible = false
			-- self:GetComponent(btn.BG):SetSprite("七日签到", "底图 1 ")
		end
	end
	-- self:DisposeTextlabel(SignedinCount, pass)
end

-- function module:UpdateDailyFrame2222()
-- 	local pass = self.DataContext.AttendanceState:VerifyCanGet()
-- 	local suc, data =
-- 		self.DataContext.ContainerHelper.GetContainerValue(Players.LocalPlayer.UserId, "属性", "新手引导标记")
-- 	if pass then
-- 		self.RedDot.Visible = true
-- 	else
-- 		self.RedDot.Visible = false
-- 	end
-- 	if data["切换物品栏"] and pass then
-- 		if not Players.LocalPlayer:GetAttribute("PlayerInBattle") then
-- 			self.DataContext:ShowPanel("HUD", "7Day")
-- 		end
-- 	end
-- end

-- function module:DisposeTextlabel(signedinCount, pass)
-- 	if self.Timer then
-- 		self.Timer:Destroy()
-- 		self.Timer = nil
-- 	end
-- 	if signedinCount == 7 then
-- 		self.TimeLabel.Text = "You have received the rewards!"
-- 		self.TimeLabel.Visible = true
-- 	else
-- 		if pass then
-- 			self.TimeLabel.Text = "Click to claim your reward!"
-- 			self.TimeLabel.Visible = true
-- 		else
-- 			local totalTime = self.DataContext.AttendanceState:GetRefreshTime()
-- 			if totalTime > 0 then
-- 				if self.Timer then
-- 					self.Timer:Destroy()
-- 					self.Timer = nil
-- 				end
-- 				self.Timer = Timer:SetInterval(function()
-- 					local totalTime = self.DataContext.AttendanceState:GetRefreshTime()
-- 					local hours = math.floor(totalTime / 3600)
-- 					local minutes = math.floor((totalTime % 3600) / 60)
-- 					local seconds = math.floor(totalTime % 60)
-- 					local str = string.format("%02d:%02d:%02d", hours, minutes, seconds)
-- 					self.TimeLabel.Text = "Reward reset in: <font color='rgb(252, 228, 146)'>" .. str .. "</font>"
-- 				end, 1, true)
-- 			end
-- 		end
-- 	end
-- end

function module:OnShow_7Day() end

function module:OnHide_7Day() end
function module:ApplyTransitionIn(container, panel)
	return "Bottom", TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function module:ApplyTransitionOut(container, panel)
	return "Bottom", TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end
return module
