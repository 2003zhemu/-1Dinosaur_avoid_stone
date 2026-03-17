local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.View

function module:Load()
	self.GuiList = {
		Icon = self:GetUI("PlayerGui.HUD.CountDowns.icon"),
	}
end

function module:StartCountDown()
	self.CountDown = task.spawn(function()
		while task.wait(1) do
			local equipedToolExpire = game.Players.LocalPlayer:GetAttribute("EquipedToolExpire")
			local endUTCTime = tonumber(equipedToolExpire)
			local ConsolePass = game.Players.LocalPlayer:GetAttribute("ConsolePass")
			if ConsolePass or not endUTCTime then
				self.GuiList.Icon.Visible = false
				continue
			end
			local leftTime = endUTCTime - game.Workspace:GetServerTimeNow()
			if leftTime <= 0 then
				self.GuiList.Icon.Visible = false
			else
				self.GuiList.Icon.Visible = true
				leftTime = math.floor(leftTime)
				self.GuiList.Icon.TextLabel.Text = self.DataContext.Tool:GetFormatTime(leftTime)
			end
		end
	end)
end

function module:Start()
	self:StartCountDown()
	local equipedTool = game.Players.LocalPlayer:GetAttribute("EquipedTool")
	if equipedTool then
		local info = self.DataContext.CountDownEvent:GetProductControlInfo()
		if info.PurchaseCount > 0 then
			self.GuiList.Icon.Visible = false

			return
		end
		self.GuiList.Icon.Visible = true
		self:GetComponent(self.GuiList.Icon):SetSprite("道具图标", tostring(equipedTool))
	else
		self.GuiList.Icon.Visible = false
	end
	game.Players.LocalPlayer:GetAttributeChangedSignal("EquipedTool"):Connect(function()
		local equipedTool = game.Players.LocalPlayer:GetAttribute("EquipedTool")
		local info = self.DataContext.CountDownEvent:GetProductControlInfo()
		if info.PurchaseCount > 0 then
			self.GuiList.Icon.Visible = false

			return
		end

		if equipedTool then
			self.GuiList.Icon.Visible = true
			self:GetComponent(self.GuiList.Icon):SetSprite("道具图标", tostring(equipedTool))
		else
			self.GuiList.Icon.Visible = false
		end
	end)
end

return module
