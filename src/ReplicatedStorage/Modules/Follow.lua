local Follow = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Defines = require(game.ReplicatedStorage.Modules.Defines)

local followCache = {}
local FOLLOW_DISTANCE = 5

local function GetResource(player)
	local character = player.Character
	if character then
		return character, character:FindFirstChild("Humanoid"), character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
	end
	return nil, nil,nil
end

local function SetBasePartState(character)
	if not character then return {} end
	local state = {}
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			state[part] = {CanCollide = part.CanCollide, Messless = part.Massless, CollisionGroup = part.CollisionGroup}
			part.CanCollide = false
			part.Massless = true
			part.CollisionGroup = "Follower"
		end
	end
	return state
end

local function RestoreBasePartState(character, state)
	if not character or not state then return end
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") and state[part] then
			part.CanCollide = state[part].CanCollide
			part.Massless = state[part].Messless
			part.CollisionGroup = state[part].CollisionGroup
		end
	end
end

local function CreateFollowAlign(leader, follower, offset)
	local followerCharacter, followerHumanoid, followerRootPart = GetResource(follower)
	local leaderCharacter, leaderHumanoid, leaderRootPart = GetResource(leader)
	if not followerCharacter or not leaderCharacter then return false end
	if not followerRootPart or not leaderRootPart then return false end
	if not followerHumanoid or not leaderHumanoid then return false end
	followerHumanoid.PlatformStand = true
	local leaderCFrame = leaderCharacter:GetPivot()
	local leaderHip = leaderHumanoid.HipHeight
	local followerHip = followerHumanoid.HipHeight

	--followerRootPart:SetNetworkOwner(leader)
	followerRootPart:SetNetworkOwner(nil)
	local followerCFrame = leaderCFrame - leaderCFrame.LookVector * offset
	followerCharacter:PivotTo(followerCFrame + Vector3.new(0, followerHip - leaderHip, 0))
	local leaderAttachment = leaderRootPart:FindFirstChild(`FollowAttachment_{follower.UserId}`)
	if not leaderAttachment then
		leaderAttachment = Instance.new("Attachment")
		leaderAttachment.Parent = leaderRootPart
		leaderAttachment.Name = `FollowAttachment_{follower.UserId}`
	end
	leaderAttachment.Position = Vector3.new(0, -leaderHip, offset)

	local followerAttachment = followerRootPart:FindFirstChild("FollowAttachment")
	if not followerAttachment then
		followerAttachment = Instance.new("Attachment")
		followerAttachment.Parent = followerRootPart
		followerAttachment.Name = "FollowAttachment"
	end
	followerAttachment.Position = Vector3.new(0, -followerHip, 0)

	local alignPosition = followerRootPart:FindFirstChild("FollowAlignPosition")
	if not alignPosition then
		alignPosition = Instance.new("AlignPosition")
		alignPosition.Name = "FollowAlignPosition"
		alignPosition.Parent = followerRootPart
	end
	alignPosition.Attachment1 = leaderAttachment
	alignPosition.Attachment0 = followerAttachment
	alignPosition.MaxForce = math.huge
	alignPosition.RigidityEnabled = true
	alignPosition.Responsiveness = 200

	local AlignOrientation = followerRootPart:FindFirstChild("FollowAlignOrientation")
	if not AlignOrientation then
		AlignOrientation = Instance.new("AlignOrientation")
		AlignOrientation.Name = "FollowAlignOrientation"
		AlignOrientation.Parent = followerRootPart
	end	
	AlignOrientation.Attachment1 = leaderAttachment
	AlignOrientation.Attachment0 = followerAttachment
	AlignOrientation.MaxTorque = math.huge
	AlignOrientation.RigidityEnabled = true
	AlignOrientation.Responsiveness = 200
	return true
end

local function CreateFollow(leader, follower, offset)
	local followerCharacter, followerHumanoid, followerRootPart = GetResource(follower)
	local leaderCharacter, leaderHumanoid, leaderRootPart = GetResource(leader)
	if not followerCharacter or not leaderCharacter then return false end
	if not followerHumanoid or not leaderHumanoid then return false end
	local leaderCFrame = leaderCharacter:GetPivot()
	local leaderHip = leaderHumanoid.HipHeight
	local followerHip = followerHumanoid.HipHeight
	local followerCFrame = leaderCFrame - leaderCFrame.LookVector * offset
	followerCharacter:PivotTo(followerCFrame + Vector3.new(0, followerHip - leaderHip, 0))

	if followerRootPart then
		local BodyVelocity = followerRootPart:FindFirstChild("FollowBodyVelocity")
		if not BodyVelocity then
			BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.Name = "FollowBodyVelocity"
			BodyVelocity.Parent = followerRootPart
		end
		BodyVelocity.MaxForce = Vector3.new(0, 5000000, 0)
		BodyVelocity.Velocity = Vector3.new(0, 0, 0)
	end

	follower:SetAttribute("FollowOffset", offset)
	follower:SetAttribute("FollowPlayerId", leader.UserId)
	return true
end

local function CleanupFollowAlign(follower, states)
	local followerCharacter, followerHumanoid, followerRootPart = GetResource(follower)
	if followerHumanoid then 
		followerHumanoid.PlatformStand = false
	end
	
	if followerRootPart then
		local alignPosition = followerRootPart:FindFirstChild("FollowAlignPosition")
		if alignPosition then
			if alignPosition.Attachment1 then
				alignPosition.Attachment1:Destroy()
				alignPosition.Attachment1 = nil
			end
			if alignPosition.Attachment0 then
				alignPosition.Attachment0:Destroy()
				alignPosition.Attachment0 = nil
			end
			alignPosition:Destroy()
		end
		local alignOrientation = followerRootPart:FindFirstChild("FollowAlignOrientation")
		if alignOrientation then
			if alignOrientation.Attachment1 then
				alignOrientation.Attachment1:Destroy()
				alignOrientation.Attachment1 = nil
			end
			if alignOrientation.Attachment0 then
				alignOrientation.Attachment0:Destroy()
				alignOrientation.Attachment0 = nil
			end
			alignOrientation:Destroy()
		end
	end
		
	local state = states[follower]
	RestoreBasePartState(followerCharacter, state)
	states[follower] = nil
	task.delay(0.5, function()
		if followerRootPart and follower then
			followerRootPart:SetNetworkOwner(follower)
		end
		follower:SetAttribute("InviteStatus", 0)
    end)
    follower:SetAttribute("FollowPlayerId", nil)
end

local function CleanupFollow(follower, states)
	local followerCharacter, followerHumanoid, followerRootPart = GetResource(follower)
	local state = states[follower]
	RestoreBasePartState(followerCharacter, state)
	states[follower] = nil
	follower:SetAttribute("InviteStatus", 5)
	task.delay(1, function()
		-- if followerRootPart and follower then
		-- 	followerRootPart:SetNetworkOwner(follower)
		-- end
		if follower then
			follower:SetAttribute("InviteStatus", 0)
		end
    end)

	if followerRootPart then
		local BodyVelocity = followerRootPart:FindFirstChild("FollowBodyVelocity")
		if BodyVelocity then
			BodyVelocity:Destroy()
		end
	end
	
	local pid = follower:GetAttribute("FollowPlayerId")
	if pid then
		local leader = Players:GetPlayerByUserId(pid)
		if leader then
			--通知领队有队员离开跟随
			EventBus.FireClient(leader, EventDefines["玩家离开跟随"], {UserId = follower.UserId})
		end
	end
    follower:SetAttribute("FollowPlayerId", nil)
	follower:SetAttribute("FollowOffset", nil)
end

local function SetFollowPlayers(leader, players)
	local followed = {}
	local count = 0
	for _, player in ipairs(players) do
		followed[player.UserId] = true
		count = count + 1
	end
	if count == 0 then
		leader:SetAttribute("InviteStatus", 0)
	end
	leader:SetAttribute("FollowPlayers", HttpService:JSONEncode(followed))
end

local function ClearFollowPlayers(self, leader)
	--解除无效跟随 刷新跟随位置
	local newFollowers = {}
	local index = 0
	for k, player in ipairs(self.FollowPlayers) do
		if player and player.Parent == Players then  --玩家在线
			table.insert(newFollowers, player)
			CreateFollow(leader, player, (index + 1) * FOLLOW_DISTANCE)
			index = index + 1
		else
			CleanupFollow(player, self.CollisionStates)
		end
	end
	
	self.FollowPlayers = newFollowers
	SetFollowPlayers(leader, self.FollowPlayers)

	if #self.FollowPlayers == 0 then  --无有效跟随
		leader:SetAttribute("InviteStatus", 0)
	end
end

function Follow.Init(player)
	if followCache[player] then return end
	local self = setmetatable({}, Follow)
    self.Leader = player
	self.FollowPlayers = {}
	self.CollisionStates = {}
    followCache[player] = self

	-- task.spawn(function()
	-- 	local character = player.Character
	-- 	if not character then
	-- 		repeat
	-- 			task.wait(0.1)
	-- 			character = player.Character
	-- 		until character
	-- 	end
	-- 	local humanoid = character:FindFirstChild("Humanoid")
	-- 	if not humanoid then
	-- 		repeat
	-- 			task.wait(0.1)
	-- 			humanoid = character:FindFirstChild("Humanoid")
	-- 		until humanoid
	-- 	end


	-- end)

    return self
end

function Follow.AddFollower(leader, follower)
	if leader == follower then return false end
	local self = followCache[leader]
	if not self then
		self = Follow.Init(leader)
	end
	--已经跟随
	for _, player in ipairs(self.FollowPlayers) do
		if player == follower then
			return false
		end
	end
	self.CollisionStates[follower] = SetBasePartState(follower.Character)
	local index = #self.FollowPlayers + 1
	local offset = index * FOLLOW_DISTANCE
	local result = CreateFollow(leader, follower, offset)
	if not result then 
		CleanupFollow(follower, self.CollisionStates)
		return false 
	end

	-- local result = CreateFollowAlign(leader, follower, offset)
	-- if not result then 
	-- 	CleanupFollowAlign(follower, self.CollisionStates)
	-- 	return false 
	-- end
	table.insert(self.FollowPlayers, follower)
	SetFollowPlayers(leader, self.FollowPlayers)
	leader:SetAttribute("InviteStatus", 4)
	return true
end

function Follow.RemoveFollower(leader, follower)
	local self = followCache[leader]
	if not self then return false end
	
	CleanupFollow(follower, self.CollisionStates)

	local idx = table.find(self.FollowPlayers, follower)
    if idx then
        table.remove(self.FollowPlayers, idx)
    end

	ClearFollowPlayers(self, leader)
	return true
end

function Follow.UpdateFollowPlayers(leader)
	local self = followCache[leader]
	if not self then return false end
	ClearFollowPlayers(self, leader)
	return true
end

function Follow.RemoveAllFollowers(leader)
	local self = followCache[leader]
	if not self then return end
	
	for k, player in ipairs(self.FollowPlayers) do
		--warn(`移除玩家{player.Name}跟随`)
		--CleanupFollowAlign(player, self.CollisionStates)
		CleanupFollow(player, self.CollisionStates)
	end
	self.CollisionStates = {}
	self.FollowPlayers = {}
	SetFollowPlayers(leader, self.FollowPlayers)
	leader:SetAttribute("InviteStatus", 0)
end

function Follow.GetFollowers(leader)
	local self = followCache[leader]
	if not self then return {} end
	return self.FollowPlayers
end

function Follow.GetFollowerCount(leader)
	local self = followCache[leader]
	if not self then return 0 end
	return #self.FollowPlayers
end

function Follow.Destroy(leader)
	Follow.RemoveAllFollowers(leader)
	followCache[leader] = nil
end

return Follow
