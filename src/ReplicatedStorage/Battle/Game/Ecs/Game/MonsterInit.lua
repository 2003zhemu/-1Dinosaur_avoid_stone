local Matter = require(game.ReplicatedStorage.Battle.Packages.Matter)
local State = require(game.ReplicatedStorage.Battle.Game.Ecs.ClientState)
local Context = require(game.ReplicatedStorage.Battle.Game.Context)
local players = game:GetService("Players")
local initGhost = false
local ghostCFrames ={
	CFrame.new(-191.03, 68, -1484.919) * CFrame.Angles(0, math.rad(180), 0),
	CFrame.new(-55.671, 68, -1519.253) * CFrame.Angles(0, math.rad(0), 0),
}

local sixGhostCFrames = {
	CFrame.new(-594.495, 220.257, -3357.113),
	CFrame.new(-86.05, 222.503, -3446.289),
}

local function GetTracks(model)
	local tracks = {}
	local AnimationController = model:FindFirstChild("AnimationController")
	if AnimationController then
		local Animator = AnimationController:FindFirstChild("Animator")
		if Animator then
			for _, animation in ipairs(Animator:GetChildren()) do
				if animation:IsA("Animation") then
					tracks[animation.Name] = Animator:LoadAnimation(animation)
				end
			end
		end
	end
	return tracks
end

local function MonsterInit(world: Matter.World, state: typeof(State), context: typeof(Context))
	if Matter.useThrottle(0.3) then
        local Components = context.Components
		--初始化两个第三关的鬼魂
		if not initGhost then
			--初始化第一个鬼魂
			local startCFrame1 = ghostCFrames[1]
			local model1 = game.Workspace.Obstacles.Stage3.Stage3_1
			local tracks1 = GetTracks(model1)
			world:spawn(
				Components.Monster({Key = "Stage3_1", Vector = 1, Stage = 3, Model = model1}),
				context.Components.Transform({ CFrame = startCFrame1 }),
				Components.MonsterData({StartCFrame = startCFrame1, MinX = -230, MaxX = -8, MinZ = -1790, MaxZ = -1400, Speed = 45}),
				Components.MonsterTrack({Tracks = tracks1})
			)
			--初始化第二个鬼魂
			local startCFrame2 = ghostCFrames[2]
			local model2 = game.Workspace.Obstacles.Stage3.Stage3_2
			local tracks2 = GetTracks(model2)
			world:spawn(
				Components.Monster({Key = "Stage3_2", Vector = -1, Stage = 3, Model = model2}),
				context.Components.Transform({ CFrame = startCFrame2 }),
				Components.MonsterData({StartCFrame = startCFrame2, MinX = -230, MaxX = -8, MinZ = -1790, MaxZ = -1400, Speed = 45}),
				Components.MonsterTrack({Tracks = tracks2})
			)


			--初始化六关第一个鬼魂
			local startCFrame6_1 = sixGhostCFrames[1]
			local model6_1 = game.Workspace.Obstacles.Stage6.Stage6_1
			local tracks6_1 = GetTracks(model6_1)
			world:spawn(
				Components.Monster({Key = "Stage6_1", Stage = 6, Model = model6_1}),
				context.Components.Transform({ CFrame = startCFrame6_1 }),
				Components.MonsterData({StartCFrame = startCFrame6_1, MinX = -660, MaxX = -360, MinZ = -4170 , MaxZ = -3280, Speed = 60}),
				Components.MonsterTrack({Tracks = tracks6_1})
			)
			--初始化六关第二个鬼魂
			local startCFrame6_2 = sixGhostCFrames[2]
			local model6_2 = game.Workspace.Obstacles.Stage6.Stage6_2
			local tracks6_2 = GetTracks(model6_2)
			world:spawn(
				Components.Monster({Key = "Stage6_2", Stage = 6, Model = model6_2}),
				context.Components.Transform({ CFrame = startCFrame6_2 }),
				Components.MonsterData({StartCFrame = startCFrame6_2, MinX = -130, MaxX = 120, MinZ = -4050 , MaxZ = -3420, Speed = 60}),
				Components.MonsterTrack({Tracks = tracks6_2})
			)

			initGhost = true 
		end
	end
end

return {
	system = MonsterInit,
	event = "default",
	env = {
		production = {
			-- disableServer = true,
			disableClient = true,
			--onlyServer = true,
		},
		devClient = {
			-- disableServer = true,
			disableClient = true,
			--onlyServer = true,
		},
		dev = {
			-- disableServer = true,
			disableClient = true,
			--onlyServer = true,
		},
	},
}
