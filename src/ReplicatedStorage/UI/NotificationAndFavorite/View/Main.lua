local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {} :: defines.View

function module:Load() end

function module:Start()
	local localPlayer = game.Players.LocalPlayer
	task.spawn(function()
		-- 等待 5 分钟
		task.wait(5 * 60)
		-- 检查玩家是否仍在大厅
		if not localPlayer:GetAttribute("IsInLobby") then
			-- 不在大厅，等到下次回到大厅再触发
			local conn
			conn = localPlayer:GetAttributeChangedSignal("IsInLobby"):Connect(function()
				if localPlayer:GetAttribute("IsInLobby") then
					conn:Disconnect()
					self:HandlePrompts()
				end
			end)
			return
		end
		self:HandlePrompts()
	end)
end

-- 根据玩家类型分发弹窗逻辑：
-- 第一类（未收藏提示过）：先弹收藏窗口，5 分钟后再弹通知
-- 第二类（已收藏提示过，未开启通知）：直接弹通知
-- 第三类（已收藏提示过，已开启通知）：Notification 内部 canPromptOptIn 为 false，不弹任何窗口
function module:HandlePrompts()
	local flag = game.Players.LocalPlayer:GetAttribute("FavoriteFlag")
	if not flag then
		self:Favorite()
		task.delay(5 * 60, function()
			self:Notification()
		end)
	else
		self:Notification()
	end
end

function module:Favorite()
	local flag = game.Players.LocalPlayer:GetAttribute("FavoriteFlag")
	if flag then
		return
	end
	game:GetService("AvatarEditorService"):PromptSetFavorite(game.PlaceId, Enum.AvatarItemType.Asset, true)
	self.DataContext.ContainerHelper:SetContainerValue(
		game.Players.LocalPlayer.UserId,
		"属性",
		"已经收藏提示过",
		true
	)
end

function module:Notification()
	local ExperienceNotificationService = game:GetService("ExperienceNotificationService")
	-- Function to check whether the player can be prompted to enable notifications
	local function canPromptOptIn()
		local success, canPrompt = pcall(function()
			return ExperienceNotificationService:CanPromptOptInAsync()
		end)
		return success and canPrompt
	end
	local canPrompt = canPromptOptIn()
	if canPrompt then
		local success, errorMessage = pcall(function()
			ExperienceNotificationService:PromptOptIn()
		end)
	end
	-- Listen to opt-in prompt closed event
	ExperienceNotificationService.OptInPromptClosed:Connect(function() end)
end

return module
