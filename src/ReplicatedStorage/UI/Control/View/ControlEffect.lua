local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)

local TextChatService = game:GetService("TextChatService")
local chatWindowConfiguration = TextChatService.ChatWindowConfiguration
local _EventBus = require(game.ReplicatedStorage.Packages.EventBus)

local module = {} :: defines.View

function module:Load() end

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 2, 234)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 226, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(134, 0, 255)),
})

function module:Start()
	TextChatService.OnChatWindowAdded = function(message)
		local textSource = message.TextSource
		local MessageUserId = textSource and textSource.UserId
		if not MessageUserId then
			return nil
		end
		local player = game.Players:GetPlayerByUserId(MessageUserId)
		if not player then
			return nil
		end
		local isVip = player:GetAttribute("IsAdmin") or player:GetAttribute("ConsolePass")
		if not isVip then
			return nil
		end
		local properties = chatWindowConfiguration:DeriveNewMessageProperties()

		properties.PrefixText = "<font color='rgb(255,255,255)'>[Server Admin]</font>"
		properties.Text = string.format("<font color='#F5CD30'>%s</font>", message.PrefixText) .. " " .. message.Text

		properties.PrefixTextProperties = chatWindowConfiguration:DeriveNewMessageProperties()
		gradient:Clone().Parent = properties.PrefixTextProperties

		return properties
	end
end

return module
