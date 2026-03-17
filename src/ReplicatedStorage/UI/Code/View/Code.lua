local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local CodeService = require(game.ReplicatedStorage.Packages.CodeService)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local module = {} :: defines.View

function module:Load()
	self.CodeBtn = self:GetUI(`PlayerGui.HUD.Code.bg.ImageButton`)
	self.CodeTextBox = self:GetUI(`PlayerGui.HUD.Code.bg.TextBox`)

	self.CodeOpenBtn = self:GetUI("PlayerGui.MainGui.Right.Code")
	self.CodeCloseBtn = self:GetUI("PlayerGui.HUD.Code.bg.CloseBtn")

	self.CodePanel = self:GetUI("PlayerGui.HUD.Code")
	self:SetContent(self.CodePanel)
	self:RegisterAs("Panel", "CodePanel")

	self:Bind(function()
		self.DataContext:ShowPanel("HUD", "CodePanel")
	end, self.CodeOpenBtn)

	self:Bind(function()
		self.DataContext:HidePanel("HUD", "CodePanel")
	end, self.CodeCloseBtn)

	self:Bind("SubmitCode", self.CodeBtn)
	self.CodeTextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			self.DataContext.Panel.Submited = true
		end
	end)
	self:Connect("Panel.Submited", self.RedeemCode)
end
function module:RedeemCode(submited)
	if submited then
		self.DataContext.Panel.Submited = false
		local sus, mes = CodeService.Redeem(game.Players.LocalPlayer, self.CodeTextBox.Text)
		Alert.Info(mes, game.Players.LocalPlayer.UserId)
		self.CodeTextBox.Text = ""
	end
end

function module:Start() end

return module
