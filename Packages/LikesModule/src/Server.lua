
local module = {}
local configs = require(script.Parent.LikesConfig)
local eventBus = require(game.ReplicatedStorage.Packages.EventBus)
local WebInformation = require(game.ReplicatedStorage.Packages.WebInformationModule)

for _,config in pairs(configs) do
    local path = config.ProximityPrompt
    local prompt = nil
    if type(path) == "string" then
        local segments = string.split(path, ".")
        for k2, v2 in pairs(segments) do
            if k2 == 1 then
                prompt = game[v2]
            else
                prompt = prompt:WaitForChild(v2)
            end

            if k2 ~= #segments then
                continue
            end
        end
    else
        prompt = path
    end
    assert(prompt:IsA("ProximityPrompt"), "配置错误，路径必须指向一个ProximityPrompt")
    prompt.Triggered:Connect(function(player)
        local votes = WebInformation.GetData("Votes")
       -- if votes < config.TargetLikes then return end
        if votes < config.TargetLikes then
            eventBus.FireClient(player,"LikesNotReached")
            return
        end
        local wukongServer = require(game.ServerScriptService.WuKongServer)
        local facade = wukongServer.GetFacade(player.UserId)
        local success, err = pcall(function()
           return facade:ExecuteAction(config.WuKongCommand.."?购买","__null__","__null__")
        end)
        eventBus.FireClient(player,"TryGetLikes",success, config)
    end)
end

return module


