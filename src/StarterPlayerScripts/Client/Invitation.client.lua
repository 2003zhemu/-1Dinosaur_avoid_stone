local RunService = game:GetService("RunService")
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")
local EventDefines = require(game.ReplicatedStorage.Modules.EventDefines)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)
local localPlayer = game.Players.LocalPlayer
local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local playerModule = nil
task.spawn(function()
	local module = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")
	if not module then
		repeat
			task.wait(0.1)
			module = localPlayer.PlayerScripts:FindFirstChild("PlayerModule")
		until module
	end
	local ControlModule = module:FindFirstChild("ControlModule")
	if not ControlModule then
		repeat
			task.wait(0.1)
			ControlModule = module:FindFirstChild("ControlModule")
		until ControlModule
	end
	playerModule = require(ControlModule)
end)

local stepTime = 0 --每秒检测跟随玩家，禁用跟随玩家的靠近触发
local followers = {}  --当前玩家后面跟随的其他玩家
local followPlayers = {} --当前玩家后面跟随的其他玩家数据
local Conns = {}

local function GetFollowers()
    followPlayers = {} 
    local followerStr = localPlayer:GetAttribute("FollowPlayers")
    followers = {}
    if followerStr and followerStr ~= "" then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(followerStr)
        end)
        if success then followers = decoded end
    end

    for pid, v in pairs(followers) do
        local userId = tonumber(pid)
        local plr = userId and game.Players:GetPlayerByUserId(userId)

        if plr then
            local data = {}
            data.Plr = plr
            data.Offset = plr:GetAttribute("FollowOffset") or 0
            table.insert(followPlayers, data)
        end
    end

    table.sort(followPlayers, function(a, b)
        return a.Offset < b.Offset
    end)
end

GetFollowers()
localPlayer:GetAttributeChangedSignal("FollowPlayers"):Connect(function()
    GetFollowers()
end)

RunService.Heartbeat:Connect(function(delta)
    --禁用邀请
    stepTime = stepTime + delta
    if stepTime >= 1 then
        stepTime = 0
        local isInLobby = localPlayer:GetAttribute("InLobby")  --当前玩家是否在大厅
        local inviteStatus = localPlayer:GetAttribute("InviteStatus") -- 2已接受 4被人跟随

        for _, plr in ipairs(game.Players:GetPlayers()) do
            local plrChar = plr.Character
            if not plrChar then continue end
            local RootPart = plr.Character.PrimaryPart or plr.Character:FindFirstChild("HumanoidRootPart")
            if not RootPart then continue end
            local prompt = RootPart:FindFirstChild("PlayerInvitePrompt")
            if not prompt then continue end

            local enabled = true
            if plr == localPlayer then
                enabled = false
            elseif not isInLobby then
                enabled = false
            elseif inviteStatus == 2 then
                enabled = false
            elseif inviteStatus == 4 then
                if followers[plr.UserId] or followers[tostring(plr.UserId)] then
                    enabled = false
                end
            end

            if prompt.Enabled ~= enabled then
                prompt.Enabled = enabled
            end
        end
    end
end)

--主动脱离跟随
local function releaseControls(actionName, inputState, inputObject)
    if inputState == Enum.UserInputState.Begin then
        --通知显示确认框
        EventBus.Fire(EventDefines["跟随状态确认"])
        -- if playerModule then 
        --     playerModule:Enable()
        -- end
        -- ContextActionService:UnbindAction("UnlockControls")
        -- EventBus.FireServer(EventDefines["取消跟随状态"])
    end
end

local RunService = game:GetService("RunService")
local followConn = nil
local function CheckFollow(isFollow)
    if followConn then
        followConn:Disconnect()
        followConn = nil
    end
    if not isFollow then return end
    followConn = RunService.Heartbeat:Connect(function()
        local followPlayerId = localPlayer:GetAttribute("FollowPlayerId")
        if not followPlayerId then return end
        local plr = game.Players:GetPlayerByUserId(followPlayerId)
        local targetChar = plr and plr.Character
        if targetChar and localCharacter then
            if localPlayer:GetAttribute("InviteStatus") ~= 2 then return end
            local offsetValue = localPlayer:GetAttribute("FollowOffset") or 0
            local targetCFrame = targetChar:GetPivot()  --领队位置
            targetCFrame = targetCFrame - targetCFrame.LookVector * offsetValue
            local leaderHeight = plr:GetAttribute("HeightDiff")
            local localHeight = localPlayer:GetAttribute("HeightDiff")
            if leaderHeight and localHeight then
                targetCFrame = targetCFrame - Vector3.new(0, leaderHeight - localHeight, 0)
            end

            local currentCFrame = localCharacter:GetPivot()
            localCharacter:PivotTo(currentCFrame:Lerp(targetCFrame, 0.5))
        end
    end)
end

local leaderConn = nil
local history = {}
local cache = {}

local function GetFolder()
    local folder = game.Workspace:FindFirstChild("Followers")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Followers"
        folder.Parent = game.Workspace
    end
    return folder
end

local function AddCopyModel(plr)
    if not plr or not plr.Character then return nil end
    local character = plr.Character
    local localFollower = GetFolder()
    character.Archivable = true
    local copyModel = character:Clone()
    task.delay(2, function()
        character.Archivable = false
    end)
    local HeightDiff = plr:GetAttribute("HeightDiff")
    if HeightDiff then
        copyModel:SetAttribute("HeightDiff", HeightDiff)
    end
    copyModel.Name = tostring(plr.UserId)
    copyModel:PivotTo(character:GetPivot())
    copyModel.Parent = localFollower
    for _, part in pairs(copyModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            part.Massless = true
            part.CastShadow = false
        end
        if part:IsA("LocalScript") or part:IsA("Script") or part:IsA("Sound") or part:IsA("ProximityPrompt") then
            part:Destroy()
        end
    end

    --副本动画
    local Dinosaur = copyModel:FindFirstChild("RideDinosaur") 
    if Dinosaur then
        local AnimationController = Dinosaur:FindFirstChild("AnimationController")
        if AnimationController then
            local dinoAnimator = AnimationController:FindFirstChild("Animator")
            if dinoAnimator then
                for _, track in pairs(dinoAnimator:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
                local run = dinoAnimator:FindFirstChild("Move")
                if run then
                    local track = dinoAnimator:LoadAnimation(run)
                    track:Play()
                end
            end
        end
    end

    --隐藏玩家模型
    local state = {}
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			state[part] = part.Transparency
			part.Transparency = 1
		end
        if part:IsA("BillboardGui") then
            part.Enabled = false
        end
	end
    if Conns[plr.UserId] then
        Conns[plr.UserId]:Disconnect()
        Conns[plr.UserId] = nil
    end
    Conns[plr.UserId] = character.ChildAdded:Connect(function(part)
        if part:IsA("BasePart") then
			state[part] = part.Transparency
			part.Transparency = 1
		end
        if part:IsA("BillboardGui") then
            part.Enabled = false
        end
    end)
	cache[plr.UserId] = state
    return copyModel
end

local function RemoveCopyModel(data)
    if not data then return end
    local userId = nil
    if data and type(data) == "number" then
        userId = data
    elseif data and type(data) == "string" then
        userId = tonumber(data)
    else
        userId = data.UserId
    end
    if not userId then return end
    local localFollower = GetFolder()
    local copyModel = localFollower:FindFirstChild(tostring(userId))
    if copyModel then
        copyModel:Destroy()
    end

    local plr = game.Players:GetPlayerByUserId(userId)
    if not plr or not plr.Character then return end
    local character = plr.Character
    if Conns[plr.UserId] then
        Conns[plr.UserId]:Disconnect()
        Conns[plr.UserId] = nil
    end
    if character then
        local state = cache[plr.UserId]
        if state then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and state[part] then
                    part.Transparency = state[part]
                end
                if part:IsA("BillboardGui") then
                    part.Enabled = true
                end
            end
        end
        cache[plr.UserId] = nil
    end
end

local function CheckLead(isLeader)
    if leaderConn then
        leaderConn:Disconnect()
        leaderConn = nil
    end
    if not isLeader then
        local localFollower = GetFolder()
        localFollower:ClearAllChildren()
        for k, v in pairs(followPlayers) do
            RemoveCopyModel(v.Plr)
        end
        return 
    end
    history = {}
    for pid, state in pairs(cache) do
        local plr = game.Players:GetPlayerByUserId(tonumber(pid))
        if plr and plr.Character then
            for _, part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") and state[part] then
                    part.Transparency = state[part]
                end
            end
        end
    end
    cache = {}
    local deltaTime = 0
    leaderConn = RunService.Heartbeat:Connect(function(delta)
        deltaTime = deltaTime + delta
        --定时清理history
        if deltaTime >= 1 then
            deltaTime = 0
            local oldestTime = os.clock() - 10
            local cutIndex = 0
            local low, high = 1, #history
            while low <= high do
                local mid = math.floor((low + high) / 2)
                if history[mid].time < oldestTime then
                    cutIndex = mid
                    low = mid + 1
                else
                    high = mid - 1
                end
            end

            if cutIndex > 50 then
                local totalSize = #history
                local remainingSize = totalSize - cutIndex
                table.move(history, cutIndex + 1, totalSize, 1)
                for i = remainingSize + 1, totalSize do
                    history[i] = nil
                end
            end
        end

        --保存领队位置
        if not localCharacter then
            localCharacter = localPlayer.Character
        end
        if not localCharacter then return end
        table.insert(history, {time = os.clock(), CFrame = localCharacter:GetPivot()})

        local delayTime = 0.1
        local humanoid = localCharacter:FindFirstChild("Humanoid")
        if humanoid and humanoid.WalkSpeed > 0 then
            delayTime = 12 / humanoid.WalkSpeed
        end
        
        --更新队员位置
        local localFollower = GetFolder()
        local leaderCFrame = localCharacter:GetPivot()
        for k, follow in ipairs(followPlayers) do
            local plr = follow.Plr
            if plr and plr.Character then
                local copyModel = localFollower:FindFirstChild(tostring(plr.UserId))
                if not copyModel then
                    copyModel = AddCopyModel(plr)
                end
                
                local offsetTime = (follow.Offset / 5) * delayTime
                local targetTime = os.clock() - offsetTime
                local targetCFrame = leaderCFrame
                for i = #history, 1, -1 do
                    if history[i].time <= targetTime then
                        targetCFrame = history[i].CFrame
                        break
                    end
                end
                if copyModel then
                    targetCFrame = targetCFrame - targetCFrame.LookVector * (follow.Offset or 0)
                    local leaderHeight = localPlayer:GetAttribute("HeightDiff")
                    local localHeight = copyModel:GetAttribute("HeightDiff")
                    if leaderHeight and localHeight then
                        targetCFrame = targetCFrame - Vector3.new(0, leaderHeight - localHeight, 0)
                    end
                    local curCFrame = copyModel:GetPivot()
                    copyModel:PivotTo(curCFrame:Lerp(targetCFrame, 0.5))
                end
            else
                RemoveCopyModel(plr)
            end
        end

        for k, v in pairs(localFollower:GetChildren()) do
            if not followers[v.Name] then
                RemoveCopyModel(tonumber(v.Name))
            end
        end
    end)
end

localPlayer:GetAttributeChangedSignal("InviteStatus"):Connect(function()
    local status = localPlayer:GetAttribute("InviteStatus")
   -- warn(status)
    CheckFollow(status == 2)
    CheckLead(status == 4)
    if status ~= 2 then
            if playerModule then
                --("退出跟随状态，启用操作")
                playerModule:Enable()
            end
            ContextActionService:UnbindAction("UnlockControls") 
    end
end)

-- local function CheckPrompt()
--     for _, plr in ipairs(game.Players:GetPlayers()) do
--         if plr == localPlayer then
--             continue
--         end
        
--         if plr.Character then
--             local RootPart = plr.Character.PrimaryPart or plr.Character:FindFirstChild("HumanoidRootPart")
--             if RootPart then
--                 local prompt = RootPart:FindFirstChild("PlayerInvitePrompt")
--                 if prompt then
--                     local followPlayerId = localPlayer:GetAttribute("FollowPlayerId")
--                     prompt.Enabled = not (plr.UserId == followPlayerId)
--                 end
--             end
--         end
--     end
-- end

-- CheckPrompt()
-- localPlayer:GetAttributeChangedSignal("FollowPlayerId"):Connect(function()
--     CheckPrompt()
-- end)


EventBus.Connect(function(eventName, params)
    if eventName == EventDefines["确认取消跟随"] then
        if playerModule then
            playerModule:Enable()
        end
        ContextActionService:UnbindAction("UnlockControls") 
        EventBus.FireServer(EventDefines["取消跟随状态"])
    end
end)

EventBus.ConnectS2C(function(eventName, params)
    if eventName == EventDefines["进入跟随状态"] then
        if playerModule then
            --("进入跟随状态，禁用操作")
            playerModule:Disable()
        end
        ContextActionService:BindActionAtPriority("UnlockControls", releaseControls, true, 2000, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
        ContextActionService:SetTitle("UnlockControls", "Unfollow")
        -- ContextActionService:SetImage("UnlockControls", "rbxassetid://你的图片ID")
    end

    if eventName == EventDefines["服务端消息提示"] then
       -- warn(params)
        local Type = params.Type
        local message = params.Text
        if Type == "Success" then
            Alert.Success(message)
        elseif Type == "Error" then
            Alert.Error(message)
        elseif Type == "Info" then
            Alert.Info(message)
        elseif Type == "Warn" then     
            Alert.Warn(message)
        end
    end
    if eventName == EventDefines["玩家离开跟随"] then
        RemoveCopyModel(tonumber(params.UserId))
    end

    if eventName == EventDefines["回到出生点"] then
        local CFrame = params.CFrame
        local character = localPlayer.Character
        if CFrame and character then
            if followConn then
                followConn:Disconnect()
                followConn = nil
            end
            task.wait()
            --warn("通过事件回到重生点")
            character:PivotTo(CFrame)
        end
    end
end)