local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.View
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local PDS = require(game.ReplicatedStorage.Packages.ProximityDetectionService)
-- function module:Load()
-- 	self.PopupFolder = workspace:WaitForChild("PopUp")
-- 	self.GuiList = {
-- 		Property = self:GetUI("PlayerGui.HUD.Property"),
-- 	}
-- 	self.Events = {}
-- end

-- function module:Start()
-- 	self:InitTrigger()
-- end

-- local list = {
-- 	"CoinShop",
-- 	"SpecialPart",
-- 	"Spin",
-- 	"LevelPanel",
-- 	"FinishedCar",
-- 	"GiftBag",
-- }

-- function module:InitTrigger()
-- 	for i, v in pairs(self.PopupFolder:GetChildren()) do
-- 		if v:IsA("BasePart") then
-- 			if string.find(v.Name, "UGC") then
-- 			elseif table.find(list, v.Name) then
-- 				local trigger = PDS:createDetection("closeto" .. v.Name, v, {
-- 					Away = function()
-- 						if localPlayer:GetAttribute("PlayerInBattle") then
-- 							return
-- 						end
-- 						self.DataContext:ShowPanel("HUD", "MainScreen")
-- 					end,
-- 					Close = function()
-- 						if localPlayer:GetAttribute("PlayerInBattle") then
-- 							return
-- 						end
-- 						if v.Name == "GiftBag" then
-- 							local idx = self.DataContext.GiftBagState:GetGiftBuyindex()
-- 							if idx == 0 then
-- 								return
-- 							end
-- 						end
-- 						self:GetEvent("closeto" .. v.Name):Fire()
-- 					end,
-- 					Distance = 15,
-- 				})
-- 				trigger.prompt.KeyboardKeyCode = Enum.KeyCode.End
-- 				trigger.prompt.GamepadKeyCode = Enum.KeyCode.ButtonR3
-- 				self:Bind("ShowPanel", self:GetEvent("closeto" .. v.Name).Event, "HUD", v.Name)
-- 				trigger:activate()
-- 			elseif string.find(v.Name, "Property") then
-- 				local trigger = PDS:createDetection("closeto" .. v.Name, v, {
-- 					Away = function()
-- 						if localPlayer:GetAttribute("PlayerInBattle") then
-- 							return
-- 						end
-- 						self.GuiList.Property.Visible = false
-- 					end,
-- 					Close = function()
-- 						if localPlayer:GetAttribute("PlayerInBattle") then
-- 							return
-- 						end
-- 						self.GuiList.Property.Visible = true
-- 					end,
-- 					Distance = 35,
-- 				})
-- 				trigger.prompt.KeyboardKeyCode = Enum.KeyCode.End
-- 				trigger.prompt.GamepadKeyCode = Enum.KeyCode.ButtonR3
-- 				-- self:Bind("ShowPanel", self:GetEvent("closeto" .. v.Name).Event, "HUD", v.Name)
-- 				trigger:activate()
-- 			end
-- 		end
-- 	end
-- end

-- function module:GetEvent(name)
-- 	if not self.Events[name] then
-- 		self.Events[name] = Instance.new("BindableEvent")
-- 		self.Events[name].Name = name
-- 		self.Events[name].Parent = self.PopupFolder
-- 	end
-- 	return self.Events[name]
-- end

return module
