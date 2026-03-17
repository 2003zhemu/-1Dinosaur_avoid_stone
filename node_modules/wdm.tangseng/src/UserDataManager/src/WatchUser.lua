local UserDataManager = {}
local LoggerManager = require(game.ReplicatedStorage.Packages.LoggerManager)
local logger = LoggerManager.GetLogger("UserDataManager")

local WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)

local Players = game:GetService("Players")

local userDatas = require(script.Parent.UserDatas)

local storeProvider = require(script.Parent.StoreProvider)

local ProfileStore = storeProvider.GetStore()

local function _updateProfile(player, profile)
	if player:IsDescendantOf(Players) == true then
		logger.Info(function(name)
			print(name, "更新用户数据:", player.UserId, profile.Data)
		end)

		local containerData = nil
		if profile.Data then
			containerData = profile.Data.Container
		end

		WuKongServer.RegisterUser(player.UserId, containerData)
	else
		-- Player left before the profile loaded:
		profile:Release()
	end
end

local function kickPlayer(player, message)
	player:Kick(message)
	warn("kick player: ", message)
	if not WuKongServer.HasFacade(player.UserId) then
		return
	end
	WuKongServer.UnregisterUser(player.UserId)
end

local function PlayerAdded(player)
	logger.Info(function(name)
		print(name, "User Added:", player.UserId)
	end)
	local profile = ProfileStore:LoadProfileAsync(tostring(player.UserId))
	logger.Info(function(name)
		print(name, "Success load profile:" .. player.UserId)
	end)
	if profile == nil then
		return kickPlayer(
			player,
			"The profile couldn't be loaded possibly due to other Roblox servers trying to load this profile at the same time"
		)
	end

	profile:AddUserId(player.UserId) -- GDPR compliance

	userDatas.SetData(player.UserId, profile)

	profile:ListenToRelease(function()
		userDatas.DeleteData(player.UserId)
	end)

	local success, result = pcall(function()
		_updateProfile(player, profile)
	end)

	if not success then
		kickPlayer(player, result.message or result)
	end
end

-- In case Players have joined the server earlier than this script ran:
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

local isQuit = false

Players.PlayerRemoving:Connect(function(player)
	local profile = userDatas.GetData(player.UserId)
	if profile ~= nil then
		local container = WuKongServer.UnregisterUser(player.UserId)
		if not container then
			profile:Release()
			return
		end

		profile.Data.Container = container

		logger.Info(function(name)
			print(name, "保存用户数据", player.UserId, profile.Data)
		end)
		profile:Release()
		isQuit = true
	end
end)

if game["Run Service"]:IsStudio() then
	game:BindToClose(function()
		for i = 1, 10 do
			if isQuit then
				return
			end
			task.wait(0.2)
		end
	end)
end

return UserDataManager
