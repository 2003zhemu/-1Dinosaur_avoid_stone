local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
-- local GiftBag = require(game.ReplicatedStorage.UI.Main.View.Giftbag)
local module = {} :: defines.Input

function module:Load()
	-- self:SetSinked(true)

	-- self:BindAction("ShowPanel", Enum.KeyCode.ButtonB, "HUD", "MainScreen")

	-- local gamepadIcon = self:GetUI("PlayerGui.HUD.Awardgift.GamePadIcon")
	-- self:BindAction(function()
	-- 	self.DataContext.GiftBagState:BuyGiftBag()
	-- end, Enum.KeyCode.ButtonX):SetIcon(gamepadIcon)
end

-- function module:OnShow_GiftBag()
-- 	self:SetActivated(true)
-- 	self:EnableGamepadCursor()
-- end

-- function module:OnHide_GiftBag()
-- 	self:SetActivated(false)
-- 	self:DisableGamepadCursor()
-- end

return module
