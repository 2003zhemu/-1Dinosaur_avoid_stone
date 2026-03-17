
local module = {}
local configs = require(script.Parent.LikesConfig)
local eventBus = require(game.ReplicatedStorage.Packages.EventBus)
local UIManager = require(game.ReplicatedStorage.Packages.UIManager)
local WebInformation = require(game.ReplicatedStorage.Packages.WebInformationModule)
local WuKong = require(game.ReplicatedStorage.WuKong)
local stringHelper = require(game.ReplicatedStorage.Packages.Utils.StringUtil)  
local FlagIsClaimed = {}

local function _isClaimed(query)
    local success, result = pcall(function()
        return WuKong.ExecuteQuery(query)
    end)

    if success and result and result > 0 then
        return true
    else
        return false
    end
end

local function _showVotes(path, votes, target, command, detail)
    local LikesText = nil
    if type(path) == "string" then
        local segments = string.split(path, ".")
        for k2, v2 in pairs(segments) do
            if k2 == 1 then
                LikesText = game[v2]
            else
                LikesText = LikesText:WaitForChild(v2)
            end

            if k2 ~= #segments then
                continue
            end
        end
    else
        LikesText = path
    end
    assert(LikesText:IsA("TextLabel"), "配置错误，路径必须指向一个TextLabel")

    if not votes then
        LikesText.Text = "Locked"
        return
    end
    
    if votes >= target then
        if FlagIsClaimed[command] then
            LikesText.Text = "Claimed"
        else
            LikesText.Text = "Claim"
        end
    else
        if detail then
            LikesText.Text ="👍"..stringHelper.AppendUnit(votes).."/"..stringHelper.AppendUnit(target)
        end
    end
end

eventBus.ConnectS2C(function(eventName, result, config)
    if eventName == "TryGetLikes" then
        if result then 
            UIManager.ShowTextInfo("Like reward has been claimed")
            if config.ShowProgress then
                local path = config.ShowProgressText
                FlagIsClaimed[config.WuKongCommand] = true
                _showVotes(path, config.TargetLikes, config.TargetLikes, config.WuKongCommand)
            end
        else
            UIManager.ShowTextInfo("Failed to claim rewards")
        end
    elseif eventName == "LikesNotReached" then
        UIManager.ShowTextInfo("Not enough likes")
    end
end)

for _,config in pairs(configs) do
    if config.ShowLikes then
        local path = config.ShowLikesText
        local votes = WebInformation.GetData("Votes")
        if votes and votes >= config.TargetLikes then
            --初始化记录是否已领取
            if _isClaimed(config.WuKongCommand.."?获取已购买次数") then
                FlagIsClaimed[config.WuKongCommand] = true
            end
        end

        _showVotes(path, votes, config.TargetLikes,config.WuKongCommand,config.ShowDetail)
    end
end

task.spawn(function()
   local voteIns = WebInformation.GetInstance("Votes")
    while not voteIns do
        voteIns = WebInformation.GetInstance("Votes")
        wait(1)
    end
    
    voteIns.Changed:Connect(function(newValue)
        for _,config in pairs(configs) do
            if config.ShowLikes then
                local path = config.ShowLikesText
                _showVotes(path, newValue, config.TargetLikes,config.WuKongCommand,config.ShowDetail)
            end
        end
    end)
end)

return module


