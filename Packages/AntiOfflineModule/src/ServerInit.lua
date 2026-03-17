local module = {}
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local rs = game:GetService("ReplicatedStorage")

local tdProvider = require(script.Parent.TeleportDataProvider)

local teleportDatas = {}

local SafeTeleport = require(script.Parent.ServerTeleport)

function GetTeleportOptions(player: Player,option:{
    AutoMode:number
    })
    local teleportOptions = Instance.new("TeleportOptions")

    teleportOptions.ShouldReserveServer = option.ShouldReserveServer
    
    -- teleportOptions.ShouldReserveServer = false

    teleportOptions:SetTeleportData(option)
    return teleportOptions
end

function buildOption(player,option)

    if not option then
        option = {}
    end

    -- 合并之前传送带来的数据
    local previousOption = teleportDatas[player.UserId]

    if previousOption then
        local tmp = previousOption
        for k,v in pairs(option) do
            tmp[k] = v
        end
        option = tmp
    end

    -- count
    local count = option.Count
    if not count then
        count = 1
    else
        count = count + 1
    end

    option.Count = count

    -- ShouldReserveServer

    if not option.ShouldReserveServer then
        option.ShouldReserveServer = true
    else
        option.ShouldReserveServer = false
    end
    
    return option
end

function ChangeServer(player: Player,option:any)
    
    option = buildOption(player,option)
    
    local success,result = SafeTeleport(game.PlaceId, {player}, GetTeleportOptions(player,option))
    
    return success,result
end

script.Parent.TeleportRequestEvent.OnServerInvoke = ChangeServer



-- 用户加入
local function OnPlayerAdded(player:Player)

    local options: {} = player:GetJoinData().TeleportData -- maybe need pcall

    if options then
        teleportDatas[player.UserId] = options
		if options.Count == nil then
			warn("玩家传送到本服务器:" .. player.UserId, options)
		else
			print("玩家传送到本服务器:" .. player.UserId .. ", 次数:" .. options.Count)
		end
        tdProvider.SetTeleportData(player,options)
    end

end


-- player 

local players = game:GetService("Players")

for _idx, player in pairs(players:GetPlayers()) do
    task.spawn(OnPlayerAdded, player)
end

players.PlayerAdded:Connect(OnPlayerAdded)	


Players.PlayerRemoving:Connect(function(player)
    teleportDatas[player.UserId] = nil
end)

return module
