local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local PurchaseResult = require(game.ReplicatedStorage.WuKongExtension.PurchaseResultHandler)

local module = {} :: defines.View

function module:Load()
	self.GuiList = {
		ControlPurchase = self:GetUI("PlayerGui.HUD.ControlPurchase"),
		CloseBtn = self:GetUI("PlayerGui.HUD.ControlPurchase.bg.Close"),
		PurchaseBtn = self:GetUI("PlayerGui.HUD.ControlPurchase.bg.ImageButton"),
	}

	self:SetContent(self.GuiList.ControlPurchase)
	self:RegisterAs("Panel", "ControlPurchase")

	self:BindEvents()

	PurchaseResult:Connect(function(path, suc)
		if string.find(path, "控制台") and suc then
			self.DataContext:HidePanel("HUD", "ControlPurchase")
		end
	end)
end

function module:BindEvents()
	task.spawn(function()
		self.ControlPart = game.Workspace:WaitForChild("CodeNeed"):WaitForChild("Control")

		self.ControlPart.Touched:Connect(function(hit)
			local character = hit.Parent
			local player = game.Players:GetPlayerFromCharacter(character)
			if player and player == game.Players.LocalPlayer then
				local info = self.DataContext.ControlEvent:GetProductControlInfo()
				if info.PurchaseCount == 0 then
					self.DataContext:ShowPanel("HUD", "ControlPurchase")
				end
			end
		end)
	end)

	self:Bind(function()
		self.DataContext:HidePanel("HUD", "ControlPurchase")
	end, self.GuiList.CloseBtn)

	self:Bind(function()
		local info = self.DataContext.ControlEvent:GetProductControlInfo()
		if info.PurchaseCount == 0 then
			info.PurchaseFunc()
		end
	end, self.GuiList.PurchaseBtn)
end

function module:Start() end

return module
