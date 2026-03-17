--[=[
	@within Plasma
	@function label
	@param text string
	@tag widgets

	Text.
]=]
return function(Plasma)
	local create = Plasma.create
	local style = Plasma.useStyle()
	return Plasma.widget(function(placeHolder)
		local refs = Plasma.useInstance(function(ref)
			local style = Plasma.useStyle()

			create("TextBox", {
				[ref] = "input",
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextColor3 = style.textColor,
				Size = UDim2.new(0, 100, 0, 40),
				TextSize = 20,
				RichText = false,
				Text = "",
				PlaceholderText = placeHolder or "",
				BorderSizePixel = 1,
			})

			return ref.input
		end)

		-- refs.input.Text = text

		local handle = {
			Text = function()
				return refs.input.Text
			end,
		}

		return handle
	end)
end
