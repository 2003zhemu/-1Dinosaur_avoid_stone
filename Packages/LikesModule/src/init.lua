--[=[
    @class LikesModule
    @server 
    @client
    该模块用于领取点赞奖励
]=]
local LikesModule = {}
local WebInformation = require(game.ReplicatedStorage.Packages.WebInformationModule)

if game["Run Service"]:IsServer() then
    require(script.Server)
else
    require(script.Client)
end

--[=[
    @return number  --点赞数量
]=]
function LikesModule.GetVotesData():number
    local data = WebInformation.GetData("Votes")
    return data
end

return LikesModule


