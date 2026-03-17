local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local AudioManager = require(game.ReplicatedStorage.Packages.AudioManager)
local rebirthConfig = require(game.ReplicatedStorage._genConfigs.battle_tbreborn)
local levelConfig = require(game.ReplicatedStorage._genConfigs.battle_tbplayerlevel)
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local module = {} :: defines.View

function module:Load()
    self.LeftFrame = self:GetUI("PlayerGui.MainGui.Left")
    self.RightFrame = self:GetUI("PlayerGui.MainGui.Right")
    self.BottomFrame = self:GetUI("PlayerGui.MainGui.Bottom")
    self.MaxSpeed = self:GetUI("PlayerGui.MainGui.Right.Frame.CustomSpeed.MaxSpeed")
    self.DoubleSpeed = self:GetUI("PlayerGui.MainGui.Right.Frame.DoubleSpeed")
    self.StartPack = self:GetUI("PlayerGui.MainGui.Right.GiftPack")
    self.DataContext.Main.Init()
    self:InitLeft()
    self:InitRight()
    self:InitBottom()
end

function module:Start()
    self.TextBox = self.RightFrame.Frame.CustomSpeed.TextBox
    local userMaxSpeed = localPlayer:GetAttribute("UserMaxSpeed")
    local userCustomSpeed = localPlayer:GetAttribute("UserCustomSpeed")
    if userCustomSpeed then
        self.TextBox.Text = userCustomSpeed
    else
        self.TextBox.Text = userMaxSpeed
    end
    self.MaxSpeed.Text = "MAX: " .. userMaxSpeed

    localPlayer:GetAttributeChangedSignal("UserMaxSpeed"):Connect(function()
        if not localPlayer:GetAttribute("UserCustomSpeed") then
            self.TextBox.Text = localPlayer:GetAttribute("UserMaxSpeed")
        end
        self.MaxSpeed.Text = "MAX: " .. localPlayer:GetAttribute("UserMaxSpeed")
    end)
end

function module:InitLeft()
    --打开重生页面
    self:Bind(function()
		self.DataContext:ShowPanel("HUD", "Rebirth")
	end, self.LeftFrame.Rebirth)

    --打开特性页面
   self:Bind(function()
		self.DataContext:ShowPanel("HUD", "Auras")
	end, self.LeftFrame.Aura)

    --打开七日签到
    self:Bind(function()
		--self.DataContext:ShowPanel("HUD", "Settings")
	end, self.LeftFrame.Day)

    --打开在线礼物页面
    self:Bind(function()
		self.DataContext:ShowPanel("HUD", "OnlinePanel")
	end, self.LeftFrame.Online)

    --显示奖杯数量
    self:Connect("Currency.Cups", function()
        self.LeftFrame.Cups.Count.Text = self.DataContext.Tool:AppendUnit(self.DataContext.Currency.Cups)
    end)
end

function module:InitRight()
    --自定义速度
    self.CustomSpeed = self.RightFrame.Frame.CustomSpeed
    self.CustomText = self.CustomSpeed.TextBox
    self.CustomText.FocusLost:Connect(function()
        local speed = tonumber(self.CustomText.Text)
        if speed then
            EventBus.FireServer(EventDefines["自定义速度"], {CustomSpeed = speed})
        end
    end)

    if self.DataContext.Main.IsBuyDoubleSpeed then
        self.DoubleSpeed.Visible = false
    else
        --购买双倍速度
        self:Bind(function()
            self.DataContext.Main.BuyDoubleSpeed()
        end, self.DoubleSpeed)
        --光圈旋转
        local spinInfo = TweenInfo.new(
            3, -- 转一圈所需时间
            Enum.EasingStyle.Linear, -- 匀速
            Enum.EasingDirection.Out,
            -1, -- 无限循环
            false, -- 不来回
            0
        )
        TweenService:Create(self.RightFrame.Frame.DoubleSpeed.Effect, spinInfo, { Rotation = 360 }):Play()

        self:Connect("Main.IsBuyDoubleSpeed", function()
            self.DoubleSpeed.Visible = not self.DataContext.Main.IsBuyDoubleSpeed
        end)
    end

    --购买新手礼包
    if self.DataContext.Main.IsBuyStartPack then
        self.StartPack.Visible = false
    else
        --购买新手礼包
        self:Bind(function()
            self.DataContext.Main.BuyStartPack()
        end, self.StartPack)
    
        self:Connect("Main.IsBuyStartPack", function()
            self.StartPack.Visible = not self.DataContext.Main.IsBuyStartPack
        end)
    end
end

function module:InitBottom()
    self:Connect("Property.Level", function()
        self:UpdateBottom()
    end)
    self:Connect("Property.MaxLevel", function()
        self:UpdateBottom()
    end)
    self:Connect("Property.Exp", function()
        self:UpdateBottom()
    end)

   -- self.BottomFrame.Multi.Text = "0"
    --显示经验总量
    self:Connect("Property.Exp", function(value)
       self.BottomFrame.Speed.Text = `Speed {self.DataContext.Tool:AppendUnit(self.DataContext.Property.Exp)}`
    end)

    --购买经验
    self:Bind(function()
        self.DataContext.Main.BuyExp("100K速度")
    end, self.BottomFrame.SpeedBtns["100k"])
    self:Bind(function()
        self.DataContext.Main.BuyExp("1M速度")
    end, self.BottomFrame.SpeedBtns["1m"])
    self:Bind(function()
        self.DataContext.Main.BuyExp("10M速度")
    end, self.BottomFrame.SpeedBtns["10m"])
    self:Bind(function()
        self.DataContext.Main.BuyExp("100M速度")
    end, self.BottomFrame.SpeedBtns["100m"])
end

function module:UpdateBottom()
    self.ProgressBar = self.BottomFrame.ProgressBar
    self.Progress = self.ProgressBar.Progress
    
    self.Level = self.ProgressBar.Left
    self.Exp = self.ProgressBar.Right

    if localPlayer:GetAttribute("InMaxLevel") then
        self.Level.Text = "level MAX"
        self:GetComponent(self.Progress.UIGradient):SetProgress(1)
        self.BottomFrame.Speed.Visible = false
        self.Exp.Text = ""
        return
    end

    local curExp = self.DataContext.Property.Exp  --当前总经验
    local curLevel = self.DataContext.Property.Level  --当前等级
    local rebirthTimes = self.DataContext.Property.RebirthTimes  --重生次数
    rebirthTimes = math.min(rebirthTimes, 23)
    local maxLevel = rebirthConfig["重生"..rebirthTimes].MaxLevel   --重生次数对应的最大等级
    local curLevelMinExp = levelConfig[curLevel].MinExp  --当前等级需要的最小经验
    local curLevelMaxExp = levelConfig[curLevel].MaxExp  --当前等级需要的最大经验
    
    local nextLevelExp = curLevelMaxExp - curLevelMinExp  --下一级需要的经验

    self.Level.Text = "level " .. curLevel
    local progress = (curExp - curLevelMinExp) / nextLevelExp
    self:GetComponent(self.Progress.UIGradient):SetProgress(math.clamp(progress, 0, 1))
    self.Exp.Text = self.DataContext.Tool:AppendUnit(math.max(0, curExp - curLevelMinExp)) .. "/" .. self.DataContext.Tool:AppendUnit(nextLevelExp)
end

return module
