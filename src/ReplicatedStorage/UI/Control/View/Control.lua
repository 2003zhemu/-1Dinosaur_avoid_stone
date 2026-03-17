local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local StageCfg = require(game.ReplicatedStorage._genConfigs.battle_tbstage)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local PurchaseResult = require(game.ReplicatedStorage.WuKongExtension.PurchaseResultHandler)
local EventStartTimeCfg = require(game.ReplicatedStorage.Configs.EventStartTimeCfg)

local _Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local TweenService = game:GetService("TweenService")

local module = {} :: defines.View

-- 定义一个函数来创建抖动动画
local function createShakeTween(object, offsetX, offsetY, duration)
	return TweenService:Create(
		object,
		TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{ Position = UDim2.fromScale(0.5 + offsetX, 0.5 + offsetY) }
	)
end

function module:Load()
	self.GuiList = {
		ControlPanel = self:GetUI("PlayerGui.HUD.Control"),
		OpenBtn = self:GetUI("PlayerGui.TopBar.Control.ImageButton"),
		CloseBtn = self:GetUI("PlayerGui.HUD.Control.bg.Close"),
		SpawnModeBtn = self:GetUI("PlayerGui.HUD.Control.bg.ScrollingFrame.MapItem.Content.Right.Top.ImageButton"),
		ItemFrame = self:GetUI("PlayerGui.HUD.Control.bg.ScrollingFrame.MapItem.Content.Right.Bottom"),
		SpeedEdit = self:GetUI("PlayerGui.HUD.Control.bg.ScrollingFrame.Speed.Content.Right.Top.ImageLabel.TextBox"),
		StageTmp = self:GetUI("PlayerGui.HUD.Control.bg.ScrollingFrame.Stage.Content.Right.tmp"),
		EventTime = self:GetUI("PlayerGui.HUD.Control.bg.ScrollingFrame.line.TextLabel"),
		OwenItemFrame = self:GetUI("PlayerGui.HUD.Control.bg.ScrollingFrame.MapItemOwen.Content.Right.Bottom"),
		EventEffect = self:GetUI("PlayerGui.HUD.EventFrame"),
		Mark = self:GetUI("PlayerGui.HUD.Control.bg.ScrollingFrame.MapItem.mark"),
	}

	self.newWarnframe = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss") --新警告窗口
	self.warnBG1 = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.BG") --警告背景1
	self.warnBG2 = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.BG2") --警告背景2
	self.leftBG = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.leftBG") --左侧背景
	self.rightBG = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.rightBG") --右侧背景
	self.leftWarn = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.leftWarn") --左侧警告
	self.rightWarn = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.rightWarn") --右侧警告
	self.Circle = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.Circle") --圆形警告
	self.BossICon = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.BossIcon") --Boss图标
	self.leftEye = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.leftEye") --左眼
	self.rightEye = self:GetUI("PlayerGui.HUD.EventFrame.NewBoss.rightEye") --右眼
	self.bottomIcon = self:GetUI("PlayerGui.HUD.EventFrame.BottomIcon")

	self:SetContent(self.GuiList.ControlPanel)
	self:RegisterAs("Panel", "ControlPanel")

	self:BindEvents()
	self:ConnectEvents()
	self.StartFlag = false
	self:EventStart(EventStartTimeCfg)

	--圆圈旋转
	self.tween = TweenService:Create(
		self.Circle,
		TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
		{ Rotation = 360 }
	)
end

function module:ShowAni()
	if self.StartFlag then
		return
	end
	-- 播放活动开始音效
	local SoundService = game:GetService("SoundService")
	local eventStartBGM = SoundService:FindFirstChild("活动开始")
	if eventStartBGM then
		eventStartBGM:Play()
	end
	self.StartFlag = true
	self.newWarnframe.Visible = true
	--new boss warn
	--背景出现
	TweenService:Create(
		self.warnBG1,
		TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
		{ Position = UDim2.fromScale(0.5, 0.5) }
	):Play()

	task.delay(0.2, function()
		--左侧背景出现
		TweenService:Create(
			self.leftBG,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
			{ Position = UDim2.fromScale(0.249, 0.23) }
		):Play()

		--右侧背景出现
		TweenService:Create(
			self.rightBG,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
			{ Position = UDim2.fromScale(0.75, 0.9) }
		):Play()

		--左侧警告出现
		TweenService:Create(
			self.leftWarn,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
			{ Position = UDim2.fromScale(0.2, 0.637) }
		):Play()

		--右侧警告出现
		TweenService:Create(
			self.rightWarn,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
			{ Position = UDim2.fromScale(0.8, 0.529) }
		):Play()

		self.Circle.ImageTransparency = 0
		self.tween:Play()
		--圆圈出现
		TweenService:Create(
			self.Circle,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
			{ Position = UDim2.fromScale(0.5, 0.5) }
		):Play()

		task.delay(0.2, function()
			-- 初始化透明度
			self.BossICon.ImageTransparency = 0
			-- 定义初始位置和抖动幅度
			local startPosition = UDim2.fromScale(0.5, 0.43)
			local shakeOffset = 0.02 -- 抖动的偏移量

			-- bossICon 出现动画
			local appearTween = TweenService:Create(
				self.BossICon,
				TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
				{ Position = startPosition }
			)

			-- 播放出现动画并在完成后执行抖动效果
			appearTween:Play()
			appearTween.Completed:Once(function()
				-- 抖动序列
				local shakeTweens = {
					createShakeTween(self.BossICon, shakeOffset, 0, 0.05),
					createShakeTween(self.BossICon, -shakeOffset, 0, 0.05),
					createShakeTween(self.BossICon, 0, shakeOffset, 0.05),
					createShakeTween(self.BossICon, 0, -shakeOffset, 0.05),
				}

				-- 按序播放抖动动画
				local function playShakeSequence(index)
					if index > #shakeTweens then
						-- 抖动结束后回到原位置
						TweenService:Create(
							self.BossICon,
							TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
							{ Position = startPosition }
						):Play()
						return
					end

					shakeTweens[index]:Play()
					shakeTweens[index].Completed:Once(function()
						playShakeSequence(index + 1)
					end)
				end

				-- 开始抖动
				playShakeSequence(1)
			end)
		end)
	end)

	task.delay(0.6, function()
		--背景2渐变
		TweenService:Create(
			self.warnBG2,
			TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 1, true),
			{ ImageTransparency = 0 }
		):Play()

		task.delay(0.1, function()
			--leftWarn渐变
			TweenService:Create(
				self.leftWarn,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 1, true),
				{ ImageTransparency = 0 }
			):Play()
			--rightWarn渐变
			TweenService:Create(
				self.rightWarn,
				TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 1, true),
				{ ImageTransparency = 0 }
			):Play()
		end)

		-- --左眼渐变
		-- TweenService:Create(
		-- 	self.leftEye,
		-- 	TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true),
		-- 	{ ImageTransparency = 0 }
		-- ):Play()

		-- --右眼渐变
		-- TweenService:Create(
		-- 	self.rightEye,
		-- 	TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, true),
		-- 	{ ImageTransparency = 0 }
		-- ):Play()
	end)

	--结束表现
	task.delay(1.2, function()
		--左侧背景消失
		TweenService:Create(
			self.leftBG,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
			{ Position = UDim2.fromScale(-0.5, 0.23) }
		):Play()

		--右侧背景消失
		TweenService:Create(
			self.rightBG,
			TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
			{ Position = UDim2.fromScale(1.5, 0.9) }
		):Play()

		task.delay(0.1, function()
			--背景消失
			TweenService:Create(
				self.warnBG1,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
				{ Position = UDim2.fromScale(-0.5, 0.5) }
			):Play()
			--左侧警告消失
			TweenService:Create(
				self.leftWarn,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
				{ Position = UDim2.fromScale(-0.5, 0.637) }
			):Play()

			--右侧警告消失
			TweenService:Create(
				self.rightWarn,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0),
				{ Position = UDim2.fromScale(1.5, 0.529) }
			):Play()

			self.warnBG2.ImageTransparency = 1
			task.delay(0.2, function()
				self.Circle.ImageTransparency = 1
			end)
		end)
	end)

	task.delay(1.5, function()
		local centerIcon = self.BossICon
		local bottomIcon = self.bottomIcon

		-- 第三步：位移并缩放到 bottomIcon 的绝对位置（两者不在同一 Frame 下，需换算）
		local parent = centerIcon.Parent
		local parentAbsPos = parent.AbsolutePosition
		local parentAbsSize = parent.AbsoluteSize
		local targetAbsPos = bottomIcon.AbsolutePosition
		local targetAbsSize = bottomIcon.AbsoluteSize

		-- AbsolutePosition 是左上角，需加上 centerIcon 锚点偏移才能让视觉位置对齐
		local anchorPoint = centerIcon.AnchorPoint
		local targetSizeX = targetAbsSize.X / parentAbsSize.X
		local targetSizeY = targetAbsSize.Y / parentAbsSize.Y
		local targetPosX = (targetAbsPos.X - parentAbsPos.X + targetAbsSize.X * anchorPoint.X) / parentAbsSize.X
		local targetPosY = (targetAbsPos.Y - parentAbsPos.Y + targetAbsSize.Y * anchorPoint.Y) / parentAbsSize.Y

		local tweenToBottom =
			TweenService:Create(centerIcon, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
				Position = UDim2.fromScale(targetPosX, targetPosY),
				Size = UDim2.fromScale(targetSizeX, targetSizeY),
			})
		tweenToBottom:Play()
		tweenToBottom.Completed:Wait()

		-- 第四步：交叉溶解——bottomIcon 从透明淡入，centerIcon 同步淡出
		--bottomIcon.ImageTransparency = 1
		bottomIcon.Visible = true
		local tweenFadeIn =
			TweenService:Create(bottomIcon, TweenInfo.new(0.25, Enum.EasingStyle.Linear), { ImageTransparency = 0 })
		local tweenFadeOut =
			TweenService:Create(centerIcon, TweenInfo.new(0.25, Enum.EasingStyle.Linear), { ImageTransparency = 1 })
		--tweenFadeIn:Play()
		tweenFadeOut:Play()
		--tweenFadeIn.Completed:Wait()

		-- 淡出完成后恢复初始状态
		centerIcon.ImageTransparency = 0
		centerIcon.Position = UDim2.fromScale(0.5, -1.5)
		self.tween:Cancel()
		self.warnBG1.Position = UDim2.fromScale(1.5, 0.5)
		self.Circle.Position = UDim2.fromScale(0.5, 2.5)
		self.newWarnframe.Visible = false
	end)
end

function module:EventStart(refs)
	local CYCLE_DURATION = 7 * 24 * 60 * 60 -- 每周循环（秒）
	local EVENT_DURATION = 1 * 60 * 60 -- 活动时长 1 小时（秒）

	local function formatTime(seconds)
		seconds = math.floor(seconds)
		return self.DataContext.Tool:GetFormatTime(seconds)
	end

	-- 根据基准时间判断当前是否在活动窗口内，返回剩余秒数或 nil
	local function getRemaining(ref)
		local elapsed = game.Workspace:GetServerTimeNow() - ref
		if elapsed < 0 then
			return nil, -elapsed -- 首次活动未开始
		end
		local cycleElapsed = elapsed % CYCLE_DURATION
		if cycleElapsed < EVENT_DURATION then
			return EVENT_DURATION - cycleElapsed, nil -- 活动进行中
		else
			return nil, CYCLE_DURATION - cycleElapsed -- 活动未开始
		end
	end

	local function updateCountdown()
		local activeRemain = nil
		local nextStart = math.huge

		for _, ref in ipairs(refs) do
			local remain, next = getRemaining(ref)
			if remain then
				-- 找最大剩余（多窗口重叠时取最长的那个）
				if not activeRemain or remain > activeRemain then
					activeRemain = remain
				end
			elseif next then
				if next < nextStart then
					nextStart = next
				end
			end
		end

		if activeRemain then
			-- 有活动正在进行
			self.GuiList.EventTime.Text = "Admin Abuse End in: " .. formatTime(activeRemain)
			self.bottomIcon.TextLabel.Text = "Admin Abuse End in: " .. formatTime(activeRemain)
			self:ShowAni()
			self.GuiList.Mark.Visible = false
		else
			-- 所有活动均未开始，显示最近的那个
			self.GuiList.EventTime.Text = "Admin Abuse Start in: " .. formatTime(nextStart)
			self.bottomIcon.TextLabel.Text = "Admin Abuse Start in: " .. formatTime(nextStart)
			self.StartFlag = false
			self.GuiList.Mark.Visible = true
		end
	end

	task.spawn(function()
		while true do
			updateCountdown()
			task.wait(1)
		end
	end)
end

function module:ConnectEvents()
	-- self:Connect("ControlEvent.ItemSelect", function(new, old)
	-- 	if new then
	-- 		local item = self.GuiList.ItemFrame:FindFirstChild(tostring(new))
	-- 		item.ImageLabel.Visible = true
	-- 	end
	-- 	if old then
	-- 		local oldItem = self.GuiList.ItemFrame:FindFirstChild(tostring(old))
	-- 		oldItem.ImageLabel.Visible = false
	-- 	end
	-- end)

	-- self:Connect("ControlEvent.ItemSelect_Owen", function(new, old)
	-- 	if new then
	-- 		local item = self.GuiList.OwenItemFrame:FindFirstChild(tostring(new))
	-- 		item.ImageLabel.Visible = true
	-- 	end
	-- 	if old then
	-- 		local oldItem = self.GuiList.OwenItemFrame:FindFirstChild(tostring(old))
	-- 		oldItem.ImageLabel.Visible = false
	-- 	end
	-- end)

	-- self:Connect("ControlEvent.StageSelect", function(new, old)
	-- 	if new then
	-- 		local item = self.GuiList.StageTmp.Parent:FindFirstChild(tostring(new))
	-- 		item.ImageLabel.Visible = true
	-- 	end
	-- 	if old then
	-- 		local oldItem = self.GuiList.StageTmp.Parent:FindFirstChild(tostring(old))
	-- 		oldItem.ImageLabel.Visible = false
	-- 	end
	-- end)
end

function module:BindEvents()
	local info = self.DataContext.ControlEvent:GetProductControlInfo()
	if info.PurchaseCount == 0 then
		self.GuiList.OpenBtn.Parent.Visible = false
	else
		self.GuiList.OpenBtn.Parent.Visible = true
	end
	PurchaseResult:Connect(function(path, suc)
		if string.find(path, "控制台") and suc then
			local info = self.DataContext.ControlEvent:GetProductControlInfo()
			if info.PurchaseCount == 0 then
				self.GuiList.OpenBtn.Parent.Visible = false
			else
				self.GuiList.OpenBtn.Parent.Visible = true
			end
		end
	end)
	self:Bind(function()
		local info = self.DataContext.ControlEvent:GetProductControlInfo()
		if info.PurchaseCount == 0 then
			return
		end
		self.DataContext:ShowPanel("HUD", "ControlPanel")
	end, self.GuiList.OpenBtn)

	self:Bind(function()
		self.DataContext:HidePanel("HUD", "ControlPanel")
	end, self.GuiList.CloseBtn)

	self.CurrentMode = "Current"
	self:Bind(function()
		self:SwitchSpawnMode(self.CurrentMode)
	end, self.GuiList.SpawnModeBtn)

	for idx, child in ipairs(self.GuiList.ItemFrame:GetChildren()) do
		if child:IsA("ImageButton") then
			self:Bind(function()
				EventBus.FireServer("SpawnItem_All", tonumber(child.Name))
				self.DataContext.ControlEvent.ItemSelect = tonumber(child.Name)
			end, child)
		end
	end

	for idx, child in ipairs(self.GuiList.OwenItemFrame:GetChildren()) do
		if child:IsA("ImageButton") then
			self:Bind(function()
				EventBus.FireServer("SpawnItem_Owen", tonumber(child.Name))
				self.DataContext.ControlEvent.ItemSelect_Owen = tonumber(child.Name)
				self.DataContext:HidePanel("HUD", "ControlPanel")
			end, child)
		end
	end

	local function BindNumericInput(textBox, getMax)
		-- 实时过滤非数字字符
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			local filtered = textBox.Text:gsub("%D", "")
			if textBox.Text ~= filtered then
				textBox.Text = filtered
			end
		end)
		textBox.FocusLost:Connect(function(enterPressed)
			local num = tonumber(textBox.Text)
			EventBus.FireServer("ControlEditSpeed", num)
		end)
		local num = getMax()
		textBox.Text = tostring(num)
	end

	BindNumericInput(self.GuiList.SpeedEdit, function()
		return game.Players.LocalPlayer:GetAttribute("UserMaxSpeed") or 0 or math.huge
	end)

	local StageCount = #StageCfg
	for stage = 1, StageCount do
		local stageBtn = self.GuiList.StageTmp:Clone()
		stageBtn.Name = tostring(stage)
		stageBtn.TextLabel.Text = "Stage " .. stage
		stageBtn.Parent = self.GuiList.StageTmp.Parent
		stageBtn.Visible = true

		self:Bind(function()
			EventBus.FireServer("ControlEditStage", stage)
			self.DataContext:HidePanel("HUD", "ControlPanel")

			self.DataContext.ControlEvent.StageSelect = stage
		end, stageBtn)
	end
end

function module:SwitchSpawnMode()
	if self.CurrentMode == "Current" then
		self.GuiList.SpawnModeBtn.ImageLabel.LayoutOrder = 0
		self.GuiList.SpawnModeBtn.ImageLabel.LayoutOrder = 1
		self.GuiList.SpawnModeBtn.TextLabel.Text = "All Stage"

		self:GetComponent(self.GuiList.SpawnModeBtn):SetSprite("管理员", "全部关卡")
		game.Players.LocalPlayer:SetAttribute("SpawnMode", "All")

		EventBus.FireServer("SpawnMode", "All")

		self.CurrentMode = "All"
	else
		self.GuiList.SpawnModeBtn.ImageLabel.LayoutOrder = 1
		self.GuiList.SpawnModeBtn.ImageLabel.LayoutOrder = 0
		self.GuiList.SpawnModeBtn.TextLabel.Text = "This Stage"

		self:GetComponent(self.GuiList.SpawnModeBtn):SetSprite("管理员", "当前关卡")
		game.Players.LocalPlayer:SetAttribute("SpawnMode", "Current")

		EventBus.FireServer("SpawnMode", "Current")

		self.CurrentMode = "Current"
	end
end

function module:Start() end

return module
