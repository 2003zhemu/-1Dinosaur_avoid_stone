local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local HttpService = game:GetService("HttpService")
local unitConfig = require(game.ReplicatedStorage._genConfigs.battle_tbunit)
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local Colors ={
    ["Equipped"] = Color3.fromRGB(255, 255, 255),  --正在装备的
    ["CanEquip"] = Color3.fromRGB(0, 255, 0),  --能装备的
	["CanUnlock"] = Color3.fromRGB(255, 255, 0),  --能解锁的
    ["NotEnoughCups"] = Color3.fromRGB(255, 0, 0),  --未解锁
}

local function PlayerInit(world: Matter.World, state: typeof(State), context: typeof(Context))
	if Matter.useThrottle(0.3) then
        local Components = context.Components
        local dinosaurs = game.Workspace:FindFirstChild("Dinosaurs")
        if not dinosaurs then
            return
        end

		for _, unit in pairs(dinosaurs:GetChildren()) do
			if unit:IsA("Model") and unit.PrimaryPart then  --串流进场景内
				unit.PrimaryPart.Color = Colors.NotEnoughCups
				local text = unit.PrimaryPart:FindFirstChild("Text")
				if text then
					local equiped = text:FindFirstChild("Equip")
					if equiped then
						equiped.Visible = false
					end
				end
				local rideId = localPlayer:GetAttribute("RideId")
				local currentId = tonumber(unit.Name)
				if rideId ~= nil and rideId == currentId then
					unit.PrimaryPart.Color = Colors.Equipped
					local text = unit.PrimaryPart:FindFirstChild("Text")
					if text then
						local equiped = text:FindFirstChild("Equip")
						if equiped then
							equiped.Visible = true
						end
					end
					continue
				end
				local config = unitConfig[currentId]
				if config then
					if config.Id == 11 then  --付费恐龙
						if localPlayer:GetAttribute(Defines.GamePass["付费恐龙"].Key) then
							unit.PrimaryPart.Color = Colors.CanEquip
						end
					else
						if config.Id == 1 then  --免费恐龙
							unit.PrimaryPart.Color = Colors.CanEquip
						else
							local unlocked = {}
							local unlockedStr = localPlayer:GetAttribute("BuyedDinos")
							if unlockedStr then
								unlocked = HttpService:JSONDecode(unlockedStr)
							end
							
							if unlocked[`dino{config.Id}`] then
								unit.PrimaryPart.Color = Colors.CanEquip
							else  --未解锁
								local needCups = config.NeedCups
								local hasCups = localPlayer:GetAttribute("Cups")
								if needCups and hasCups and hasCups >= needCups then
									unit.PrimaryPart.Color = Colors.CanUnlock
								end
							end
						end
					end
				end
			end
		end
	end
end
return {
	system = PlayerInit,
	event = "default",
	env = {
		production = {
			disableServer = true,
			--disableClient = true,
			--onlyServer = true,
		},
		devClient = {
			disableServer = true,
			--disableClient = true,
			--onlyServer = true,
		},
		dev = {
			disableServer = true,
			--disableClient = true,
			--onlyServer = true,
		},
	},
}
