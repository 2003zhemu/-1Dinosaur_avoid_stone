local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local Players = game:GetService("Players")
local module = {} :: defines.View

local THUMBUP_ATTRIBUTE = "ThumbUpNum"

function module:Load()
	self.billboards = {}
	self.playerConns = {}
	self.rootConns = {}
end

function module:SetThumbUpInfo(item, num)
	if not item then
		return
	end
	if num == nil then
		num = 0
	end
	local content = item:FindFirstChild("Content")
	if not content then
		return
	end
	local level = content:FindFirstChild("level")
	if not level or not level:IsA("TextLabel") then
		return
	end
	level.Text = tostring(num)
end

function module:GetOrCreateBillboard(player: Player)
	local existing = self.billboards[player.UserId]
	if existing then
		local ok = pcall(function()
			return existing.Parent
		end)
		if ok then
			return existing
		end
	end

	local assets = game.ReplicatedStorage:WaitForChild("Assets")
	local prefab = assets:WaitForChild("ThumbUpInfo")
	local billboard = prefab:Clone()
	self.billboards[player.UserId] = billboard
	return billboard
end

function module:AttachBillboardToCharacter(player: Player, character: Model)
	local billboard = self:GetOrCreateBillboard(player)
	local adornee = character:FindFirstChild("Head") or character:WaitForChild("Head", 2)
	if not adornee then
		adornee = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 2)
	end
	if not adornee then
		adornee = character:FindFirstChildWhichIsA("BasePart")
	end
	if not adornee then
		return
	end
	billboard.Adornee = adornee
	billboard.Parent = adornee
end

function module:RefreshPlayer(player: Player)
	local billboard = self.billboards[player.UserId]
	if not billboard then
		return
	end
	local num = player:GetAttribute(THUMBUP_ATTRIBUTE)
	if type(num) ~= "number" then
		num = 0
	end
	self:SetThumbUpInfo(billboard, num)
end

function module:CleanupPlayer(player: Player)
	local conns = self.playerConns[player.UserId]
	if conns then
		for _, c in ipairs(conns) do
			c:Disconnect()
		end
		self.playerConns[player.UserId] = nil
	end

	local billboard = self.billboards[player.UserId]
	if billboard then
		billboard:Destroy()
		self.billboards[player.UserId] = nil
	end
end

function module:TrackPlayer(player: Player)
	if self.playerConns[player.UserId] then
		return
	end

	local conns = {}
	self.playerConns[player.UserId] = conns

	local billboard = self:GetOrCreateBillboard(player)
	self:SetThumbUpInfo(billboard, player:GetAttribute(THUMBUP_ATTRIBUTE) or 0)

	if player.Character then
		self:AttachBillboardToCharacter(player, player.Character)
	end

	table.insert(
		conns,
		player.CharacterAdded:Connect(function(character)
			self:AttachBillboardToCharacter(player, character)
			self:RefreshPlayer(player)
		end)
	)

	table.insert(
		conns,
		player:GetAttributeChangedSignal(THUMBUP_ATTRIBUTE):Connect(function()
			self:RefreshPlayer(player)
		end)
	)
end

function module:Start()
	for _, p in ipairs(Players:GetPlayers()) do
		self:TrackPlayer(p)
	end

	table.insert(
		self.rootConns,
		Players.PlayerAdded:Connect(function(player)
			self:TrackPlayer(player)
		end)
	)

	table.insert(
		self.rootConns,
		Players.PlayerRemoving:Connect(function(player)
			self:CleanupPlayer(player)
		end)
	)
end

return module
