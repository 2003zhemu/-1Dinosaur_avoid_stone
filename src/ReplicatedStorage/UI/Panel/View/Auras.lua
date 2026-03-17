local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local auraConfig = require(game.ReplicatedStorage._genConfigs.battle_tbaura)
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local ContainerHelper = nil
local localPlayer = game.Players.LocalPlayer

local module = {}
local Icons1 = {
	[1] = "图标 dust 小",
	[2] = "图标 water 小",
	[3] = "图标 shadow 小",
	[4] = "图标 fire 小",
	[5] = "图标 snow 小",
	[6] = "图标 rainbow 小",
	[7] = "图标 light 小",
	[8] = "图标 starlight 小",
	[9] = "电 小",
	[10] = "符咒 小",
	[11] = "花 小",
	[12] = "音乐 小",
	[13] = "幽灵 小",
}
local Icons2 = {
	[1] = "图标 dust 大",
	[2] = "图标 water 大",
	[3] = "图标 shadow 大",
	[4] = "图标 fire 大",
	[5] = "图标 snow 大",
	[6] = "图标 rainbow 大",
	[7] = "图标 light 大",
	[8] = "图标 starlight 大",
	[9] = "电 大",
	[10] = "符咒 大",
	[11] = "花 大",
	[12] = "音乐 大",
	[13] = "幽灵 大",
}

function module:Load()
	self.AurasPanel = self:GetUI("PlayerGui.HUD.Auras")
	self.Close = self:GetUI("PlayerGui.HUD.Auras.Header.Close")
	self.ItemFrame = self:GetUI("PlayerGui.HUD.Auras.Content.Right")
	self.ContentFrame = self:GetUI("PlayerGui.HUD.Auras.Content.Content")
	self.ItemTemplate = self:GetUI("PlayerGui.HUD.Auras.Content.Content.ItemTemplate")

	self.EquipButton = self:GetUI("PlayerGui.HUD.Auras.Content.Right.Bottom.Button")
	self.RobuxButton = self:GetUI("PlayerGui.HUD.Auras.Content.Right.Button")

	self.SelectItem = nil

	self:SetContent(self.AurasPanel)
	self:RegisterAs("Panel", "Auras")

	self.status = 0
	self.id = 0
	self:Bind(function()
		self.DataContext:HidePanel("HUD", "Auras")
	end, self.Close)
end

function module:Start()
	--光圈旋转
	local spinInfo = TweenInfo.new(
		3, -- 转一圈所需时间
		Enum.EasingStyle.Linear, -- 匀速
		Enum.EasingDirection.Out,
		-1, -- 无限循环
		false, -- 不来回
		0
	)
	TweenService:Create(self.ItemFrame.Body.Effect, spinInfo, { Rotation = 360 }):Play()

	--监听更新装备的特性
	self:Connect("Property.AurasId", function()
		self:UpdateAuras()
	end)
end

function module:OnShow_Auras()
	self:UpdateAuras()
end

function module:UpdateAuras()
	for k, v in pairs(self.ContentFrame:GetChildren()) do
		if v:IsA("ImageButton") and v.Name ~= "ItemTemplate" then
			v:Destroy()
		end
	end

	for k, v in ipairs(auraConfig) do
		local item = self.ItemTemplate:Clone()
		item.Visible = true
		item.Name = v.Name
		item:SetAttribute("Id", v.Id)
		item.Parent = self.ContentFrame
		self:GetComponent(item.Icon):SetSprite("特性切图", Icons1[v.Id])
		item.Rainbow.Visible = v.Quality == Defines.AuraQuality.Rainbow
		item.Starlight.Visible = v.Quality == Defines.AuraQuality.Starlight
		item.Quality.Visible = false
		local auraShow = Defines.AuraQualityShow[v.Quality]
		if auraShow then
			if auraShow.Title and auraShow.Color then
				item.Quality.Text = auraShow.Title
				item.Quality.TextColor3 = auraShow.Color
				item.Quality.Visible = true
			end
		end

		if not self.SelectItem then
			self.SelectItem = item
		end
		if self.SelectItem == item then
			self:UpdateItemInfo(item)
		end

		--当前装备的特性
		item.Equiped.Visible = false
		if self.DataContext.Property.AurasId == v.Id then
			item.Equiped.Visible = true
			self.SelectItem = item
			self:UpdateItemInfo(item)
		end

		self:Bind(function()
			if self.SelectItem == item then
				return
			end
			self.SelectItem = item
			self:UpdateItemInfo(item)
		end, item)
	end
end

function module:UpdateItemInfo(item)
	if not item then
		return
	end
	local id = item:GetAttribute("Id") --当前选中的特性
	self.id = id
	local curAurasId = self.DataContext.Property.AurasId --当前装备的特性
	local config = auraConfig[id]
	if not config then
		return
	end
	--品质
	self.ItemFrame.Title.Rainbow.Visible = config.Quality == Defines.AuraQuality.Rainbow
	self.ItemFrame.Title.Starlight.Visible = config.Quality == Defines.AuraQuality.Starlight
	self.ItemFrame.Title.Quality.Visible = false
	local auraShow = Defines.AuraQualityShow[config.Quality]
	if auraShow then
		if auraShow.Title and auraShow.Color then
			self.ItemFrame.Title.Quality.Text = auraShow.Title
			self.ItemFrame.Title.Quality.TextColor3 = auraShow.Color
			self.ItemFrame.Title.Quality.Visible = true
		end
	end

	--图标
	self:GetComponent(self.ItemFrame.Body.Icon):SetSprite("特性切图", Icons2[config.Id])

	--底部效果
	self.ItemFrame.Bottom.Info.Text = `+{config.ExpBonus} speed`

	--已解锁特性
	local buyed = {}
	if not ContainerHelper then
		ContainerHelper = require(game.ReplicatedStorage.Helper.ContainerHelper)
	end
	if ContainerHelper then
		local suc, data = ContainerHelper.GetContainerValue(localPlayer.UserId, `属性`, `购买特性`)
		if suc and data then
			buyed = HttpService:JSONDecode(data)
		end
	end
	self.EquipButton.TextLabel.Visible = false
	self.EquipButton.Buy.Visible = false
	self.RobuxButton.Visible = false

	-- local status = 0
	if buyed[item.Name] then --已解锁
		self.EquipButton.TextLabel.Visible = true
		if id == curAurasId then --当前正在装备的特性
			self.EquipButton.TextLabel.Text = "UnEquip" --卸下
			self.status = 1
		else
			self.EquipButton.TextLabel.Text = "Equip" --可装备
			self.status = 2
		end
	else --需解锁
		self.status = 3
		self.EquipButton.Buy.Visible = true
		local needCups = config.CostCup --需要的奖杯数
		self.EquipButton.Buy.TextLabel.Text = self.DataContext.Tool:AppendUnit(needCups)

		local needRobux = config.Robux --需要的Robux
		if needRobux > 0 then
			self.RobuxButton.Visible = true
			self.RobuxButton.Buy.TextLabel.Text = needRobux
		end
	end

	self:Unbind(self.EquipButton)
	self:Bind(function()
		-- if status == 1 then --卸下
		-- 	self.EquipButton.TextLabel.Text = "Equip"
		-- 	EventBus.FireServer(EventDefines["装备特性"], { Id = 0 })
		-- elseif status == 2 then --装备
		-- 	self.EquipButton.TextLabel.Text = "UnEquip"
		-- 	EventBus.FireServer(EventDefines["装备特性"], { Id = id })
		-- elseif status == 3 then --购买
		-- 	EventBus.FireServer(EventDefines["奖杯购买特性"], { Id = id })
		-- end
		self:EquipAura()
	end, self.EquipButton)

	self:Unbind(self.RobuxButton)
	self:Bind(function()
		--R币购买特性
		self.DataContext.Panel.BuyAura(id)
	end, self.RobuxButton)
end

function module:EquipAura()
	if self.status == 1 then --卸下
		self.EquipButton.TextLabel.Text = "Equip"
		self.status = 2
		EventBus.FireServer(EventDefines["装备特性"], { Id = 0 })
	elseif self.status == 2 then --装备
		self.status = 1
		self.EquipButton.TextLabel.Text = "UnEquip"
		EventBus.FireServer(EventDefines["装备特性"], { Id = self.id })
	elseif self.status == 3 then --购买
		EventBus.FireServer(EventDefines["奖杯购买特性"], { Id = self.id })
	end
end

return module
