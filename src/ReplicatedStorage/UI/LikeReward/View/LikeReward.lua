local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)

local module = {} :: defines.View

function module:Load()
	-- self.pp = game.ReplicatedStorage.PP.LikeReward.Part.ProximityPrompt
	-- game.ReplicatedStorage.PP.LikeReward.Parent = game.Workspace:WaitForChild("CodeNeed").PP
	-- self.LikeRewardGui = game.ReplicatedStorage.BillboardGui.LikeReward.BillboardGui.Frame
	-- game.ReplicatedStorage.BillboardGui.Parent = game.Workspace:WaitForChild("CodeNeed")
end

local function tryShowGroupInvitePrompt()
	do
		local ok, res = pcall(function()
			return game:GetService("GroupService"):PromptJoinAsync(212251875)
		end)
		if ok then
			return res
		end
	end
end

function module:Start()
	self:Connect("LikeRewardEvent.Isbuy", function(new)
		local canGet = self.DataContext.LikeRewardEvent:GetCanGetLikeReward()
		if self.pp then
			self.pp.Enabled = canGet
		end
		if self.LikeRewardGui then
			self.LikeRewardGui.Parent.Enabled = canGet
		end
	end)
	--初始化
	task.spawn(function()
		local canGet = self.DataContext.LikeRewardEvent:GetCanGetLikeReward()
		local path = game.Workspace.CodeNeed.PP.LikeReward
		local billGuiPath = game.Workspace.CodeNeed.BillboardGui
		local ppPart = path:FindFirstChild("Part")
		local guiPart = billGuiPath:FindFirstChild("LikeReward")
		if not ppPart or not guiPart then
			repeat
				ppPart = path:FindFirstChild("Part")
				guiPart = billGuiPath:FindFirstChild("LikeReward")
				task.wait(0.1)
			until ppPart and guiPart
		end
		self.pp = ppPart.ProximityPrompt
		self.LikeRewardGui = guiPart.BillboardGui.Frame
		self.pp.Enabled = true
		self.LikeRewardGui.Parent.Enabled = canGet

		-- self.pp.PromptShown:Connect(function()
		-- 	local canGet = self.DataContext.LikeRewardEvent:GetCanGetLikeReward()
		-- 	self.pp.Enabled = canGet
		-- 	self.LikeRewardGui.Parent.Enabled = canGet
		-- end)

		self:Bind(function()
			local isInGroup = game.Players.LocalPlayer:GetRankInGroup(212251875) > 0
			local claimed = self.DataContext.LikeRewardEvent:GetTodayIsGet()
			if isInGroup then
				if claimed then
					return
				end
				self.DataContext.LikeRewardEvent:GetLikeReward()
			else
				local result = tryShowGroupInvitePrompt()
				if result == Enum.GroupMembershipStatus.Joined then
					self.DataContext.LikeRewardEvent:GetLikeReward()
				end
			end
		end, self.pp.Triggered)
	end)

	EventBus.ConnectS2C(function(event, data)
		if event == "LikeReward" then
			if data.type == "Speed" then
				Alert.Success("Congrats! You gained " .. data.value .. " Speed!")
			elseif data.type == "Wins" then
				Alert.Success("Congrats! You gained " .. data.value .. " Wins!")
			end
		end
	end)
end

return module
