local TweenService = game:GetService("TweenService")
local module = {}

local PopupNumbers = function(context, position: Vector3, damage: number, type: string, prefix: string)
	task.spawn(function()
		local indicator = context.View.AssetsPool.GetAsset("PopupNumbers", type)

		indicator.Position = position
		local billboard = indicator:FindFirstChildOfClass("BillboardGui")
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		local t1 = TweenService:Create(billboard, TweenInfo.new(0.4, Enum.EasingStyle.Cubic), {
			StudsOffset = Vector3.new(context.Random:NextNumber() * 2 - 1, 5, 0),
		})
		local damageText = billboard:FindFirstChildOfClass("TextLabel")
		damageText.Text = `{prefix}{damage}`
		damageText.TextTransparency = 0

		local damageText2 = damageText:FindFirstChildOfClass("TextLabel")
		damageText2.Text = `{prefix}{damage}`
		damageText2.UIStroke.Transparency = 0
		--damageText2.TextTransparency = 0
		-- print("damageText.TextTransparency", damageText.TextTransparency)
		t1:Play()
		t1.Completed:Connect(function()
			TweenService:Create(damageText, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
				TextTransparency = 1,
			}):Play()
			TweenService:Create(damageText2.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
				Transparency = 1,
			}):Play()

			TweenService:Create(billboard, TweenInfo.new(0.3, Enum.EasingStyle.Cubic), {
				StudsOffset = Vector3.new(billboard.StudsOffset.X, 0, 0),
			}):Play()
		end)
		task.delay(1, function()
			context.View.AssetsPool.Return(indicator)
		end)
	end)
end

module.PopupHealing = function(context, position: Vector3, amount: number)
	PopupNumbers(context, position, amount, "Healing", "+")
end

module.PopupDamage = function(context, position: Vector3, amount: number)
	PopupNumbers(context, position, amount, "Damage", "-")
end

return module
