local Defines = {}

Defines.AuraQuality = {
	Dust = 1,
	Water = 2,
	Shadow = 3,
	Fire = 4,
	Snow = 5,
	Rainbow = 6,
	Light = 7,
	Starlight = 8,
	Electric = 9,
	Arcane = 10,
	Petals = 11,
	Music = 12,
	Phantom = 13,
}

Defines.AuraQualityShow = {
	[1] = { Title = "Dust", Color = Color3.fromRGB(153, 153, 153) },
	[2] = { Title = "Water", Color = Color3.fromRGB(42, 102, 212) },
	[3] = { Title = "Shadow", Color = Color3.fromRGB(42, 21, 102) },
	[4] = { Title = "Fire", Color = Color3.fromRGB(212, 42, 42) },
	[5] = { Title = "Snow", Color = Color3.fromRGB(223, 255, 243) },
	[7] = { Title = "Light", Color = Color3.fromRGB(255, 223, 102) },
	[8] = { Title = "Starlight", Color = Color3.fromRGB(255, 255, 255) },
	[9] = { Title = "Electric", Color = Color3.fromRGB(255, 170, 0) },
	[10] = { Title = "Arcane", Color = Color3.fromRGB(102, 0, 255) },
	[11] = { Title = "Petals", Color = Color3.fromRGB(255, 176, 221) },
	[12] = { Title = "Music", Color = Color3.fromRGB(255, 255, 0) },
	[13] = { Title = "Phantom", Color = Color3.fromRGB(0, 223, 223) },
}

Defines.GamePass = {
	["双倍速度"] = { Key = "DoubleSpeedPass", Path = "/现金/通行证/双倍速度" },
	["新手礼包"] = { Key = "NewbieGiftPass", Path = "/现金/通行证/新手礼包" },
	["双倍奖杯"] = { Key = "DoubleCupsPass", Path = "/现金/通行证/双倍奖杯" },
	["三倍跑步机"] = { Key = "TripleTreadmillPass", Path = "/现金/通行证/三倍跑步机" },
	["九倍跑步机"] = { Key = "NineTreadmillPass", Path = "/现金/通行证/九倍跑步机" },
	["25倍跑步机"] = { Key = "TwentyFiveTreadmillPass", Path = "/现金/通行证/25倍跑步机" },
	["付费恐龙"] = { Key = "PayDinoPass", Path = "/现金/通行证/付费恐龙" },
	["控制台"] = { Key = "ConsolePass", Path = "/现金/买功能/控制台" },
}

Defines.RespawnCFrames = {
	[1] = CFrame.new(-115.129, 87.367, -109.538),
	[2] = CFrame.new(-111.389, 90.115, -776.205),
	[3] = CFrame.new(-111.075, 90.115, -1290.901),
	[4] = CFrame.new(-112.583, 87.115, -1826.901),
	[5] = CFrame.new(-111.509, 88.115, -2353.901),
	[6] = CFrame.new(-106.571, 239.763, -2991.101),
	[7] = CFrame.new(-304.106, 239.763, -4651.79),
	[8] = CFrame.new(-304.64, 245.556, -5938.261),
	[9] = CFrame.new(-292.858, 265.428, -7076.255),
	[10] = CFrame.new(-297.702, 264.898, -8378.737),
	[11] = CFrame.new(-262.967, 471.251, -9915.48),
	[12] = CFrame.new(-266.907, 471.251, -11745.796),
	[13] = CFrame.new(-263.179, 464.678, -13103.081),
	[14] = CFrame.new(-261.248, 462.485, -14751.728),
	[15] = CFrame.new(-262.337, 462.634, -16720.754),
	[16] = CFrame.new(-264.983, 462.634, -22775.697),
	[17] = CFrame.new(-262.891, 461.635, -26614.465),
	[18] = CFrame.new(-257.185, 451.635, -30386.924),
	[19] = CFrame.new(-260.15, 460, -32381.998),

	[20] = CFrame.new(-260.813, 2310, -32722.055),
	[21] = CFrame.new(-261.55, 2280, -35329.797),
	[22] = CFrame.new(-266.58, 2290, -37428.391),
}

Defines.StageCount = 22

Defines.Tools = {
	["Fly"] = 1,
	["Dash"] = 2,
	["Jump"] = 3,
	["Immune"] = 4,
	["DinoBigger"] = 5,
	["DinoSmaller"] = 6,
	["DinoRandom"] = 7,
}
Defines.ToolByKey = {
    [1] = "Fly",
    [2] = "Dash",
    [3] = "Jump",
    [4] = "Immune",
    [5] = "DinoBigger",
    [6] = "DinoSmaller",
    [7] = "DinoRandom",
}

return Defines
