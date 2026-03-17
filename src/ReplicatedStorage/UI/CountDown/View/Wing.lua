local TweenService = game:GetService("TweenService")
local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.View

local WingMaxTime = 15

function module:Load()
	self.GuiList = {
		WingPro = self:GetUI("PlayerGui.HUD.CountDowns.1pro"),
		pro = self:GetUI("PlayerGui.HUD.CountDowns.1pro.bar.pro.UIGradient"),
		icon = self:GetUI("PlayerGui.HUD.CountDowns.1pro.bar.icon"),
	}
end

function module:StartCountDown()
	self.CountDown = task.spawn(function()
		while task.wait(0.1) do
			local ConsolePass = game.Players.LocalPlayer:GetAttribute("ConsolePass")
			if ConsolePass then
				self.GuiList.WingPro.Visible = false
				continue
			end
			local equipedToolExpire = game.Players.LocalPlayer:GetAttribute("EquipedToolExpire")
			if equipedToolExpire then
				local leftTime = equipedToolExpire - game.Workspace:GetServerTimeNow()
				local equipedTool = game.Players.LocalPlayer:GetAttribute("EquipedTool")
				if tonumber(equipedTool) == 1 then
					if leftTime <= 0 then
						self.GuiList.WingPro.Visible = false
						continue
					else
						self.GuiList.WingPro.Visible = true
						local progress = leftTime / WingMaxTime
						self:GetComponent(self.GuiList.pro):SetProgress(progress)
						local position = math.clamp(1 - progress, 0, 1)
						self.GuiList.icon.Position = UDim2.new(0.5, 0, position, 0)
					end
				else
					self.GuiList.WingPro.Visible = false
				end
			else
				self.GuiList.WingPro.Visible = false
			end
		end
	end)
end

function module:Start()
	self:StartCountDown()
end

return module
