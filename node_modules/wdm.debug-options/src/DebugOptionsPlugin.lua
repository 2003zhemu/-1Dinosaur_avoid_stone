local Toolbar = plugin:CreateToolbar("DebuggingOptions")
local CommentButton = Toolbar:CreateButton("ClickHere", "ClickHere", "rbxassetid://14134158045")

local debugger = {
	["客户端调试开关"] = "1_ClientDebugSwitch",
	["悟空客户端调试开关"] = "2_WukongClientDebugSwitch",
	["禁用数据库存储"] = "3_DisableDatabaseStorage",
	["重置用户数据开关"] = "4_ResetUserDataSwitch",
}

local function checkConfiguration(userID)
	local RsPlugins = game.ReplicatedStorage:FindFirstChild("__developer")
	local playerFolder

	if not RsPlugins then
		RsPlugins = Instance.new("Folder", game.ReplicatedStorage)
		RsPlugins.Name = "__developer"
	end

	if not RsPlugins:FindFirstChild(userID) then
		playerFolder = Instance.new("Folder", RsPlugins)
		playerFolder.Name = userID
	else
		playerFolder = RsPlugins:FindFirstChild(userID)
	end

	local selection = game.Selection:Set({ playerFolder })

	if next(playerFolder:GetChildren()) == nil then
		for k, v in pairs(debugger) do
			local boolValue = Instance.new("BoolValue", playerFolder)
			boolValue.Name = k

			-- 添加别名
			boolValue:SetAttribute("Alias", v)

			boolValue.Changed:Connect(function()
				playerFolder:SetAttribute(v, boolValue.Value)
			end)

			playerFolder:SetAttribute(v, boolValue.Value)
		end
	end

	for k, v in pairs(debugger) do
		local isTrue = false
		for _, value in ipairs(playerFolder:GetChildren()) do
			if k == value.Name then
				isTrue = true
				playerFolder:SetAttribute(v, value.Value)

				-- 检查别名是否已经被设置
				if not value:GetAttribute("Alias") then
					-- 如果别名还没有被设置，那么就为它设置别名
					value:SetAttribute("Alias", v)
				end

				value.Changed:Connect(function()
					playerFolder:SetAttribute(v, value.Value)
				end)

				break
			end
		end
		if not isTrue then
			local boolValue = Instance.new("BoolValue", playerFolder)
			boolValue.Name = k

			-- 添加别名
			boolValue:SetAttribute("Alias", v)

			boolValue.Changed:Connect(function()
				playerFolder:SetAttribute(v, boolValue.Value)
			end)

			playerFolder:SetAttribute(v, boolValue.Value)
		end
	end

	playerFolder.AttributeChanged:Connect(function(attributeName)
		for _, v in ipairs(playerFolder:GetChildren()) do
			if debugger[v.Name] == attributeName then
				v.Value = playerFolder:GetAttribute(attributeName)
			end
		end
	end)
end

local function debounce(func)
	local isRunning = false
	return function(...)
		if not isRunning then
			isRunning = true
			func(...)
			isRunning = false
		end
	end
end

local function onCommentButtonClick()
	if not game.Players:GetPlayers()[1] then
		warn("请打开组队创作模式")
	else
		debounce(checkConfiguration(game.Players:GetPlayers()[1].UserId))
	end
end

CommentButton.Click:Connect(onCommentButtonClick)
