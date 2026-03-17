local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local revive = require(script.Parent.Parent.Parent.View.Revive)
local wukong = require(game.ReplicatedStorage.WuKong)
local module = {} :: defines.Input

function module:Load()
	self:SetSinked(true)

	-- self:BindAction(function()
	-- 	self.DataContext:HidePanel("HUD", "Revive")
	-- end, Enum.KeyCode.ButtonB)

	local AuraIcon = self:GetUI("PlayerGui.HUD.Revive.Body.Cups.Xbox")
	self:BindAction(function()
		-- self.DataContext:ShowPanel("HUD", "Auras")
		revive:WinRevive()
	end, Enum.KeyCode.ButtonX):SetIcon(AuraIcon)

	local AuraIcon = self:GetUI("PlayerGui.HUD.Revive.Body.Robux.Xbox")
	self:BindAction(function()
		wukong:ExecuteQuery(`/现金/买功能/复活?弹出购买窗口`)
		-- self.DataContext:ShowPanel("HUD", "Auras")
	end, Enum.KeyCode.ButtonY):SetIcon(AuraIcon)

	local AuraIcon = self:GetUI("PlayerGui.HUD.Revive.Body.Cancel.Xbox")
	self:BindAction(function()
		revive:Cancel()
	end, Enum.KeyCode.ButtonB):SetIcon(AuraIcon)
end

function module:OnShow_Revive()
	self:SetActivated(true)
	self:EnableGamepadCursor()
end

function module:OnHide_Revive()
	self:SetActivated(false)
	self:DisableGamepadCursor()
end

return module
