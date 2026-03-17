local Players = game:GetService("Players")
local CameraShaker = require(game.ReplicatedStorage.Battle.Packages.CameraShaker)
local camera = game.Workspace.CurrentCamera
local module = {}
local function ShakeCamera(shakeCf)
	-- shakeCf: CFrame value that represents the offset to apply for shake effect.
	-- Apply the effect:
	camera.CFrame = camera.CFrame * shakeCf
end
local renderPriority = Enum.RenderPriority.Camera.Value + 1
local camShake = CameraShaker.new(renderPriority, ShakeCamera)

task.delay(0.1, function()
	camShake:Start()
end)
module.CamShake = {}
module.GetSourceDistance = function(sourcePosition)
	local character = Players.LocalPlayer.Character
	if character == nil then
		return math.huge
	end
	return (character.PrimaryPart.Position - sourcePosition).Magnitude
end
module.CamShake.SlightEarthQuake = function(sourcePosition, MaxDistance, MinDistance)
	-- print("SlightEarthQuake")
	MaxDistance = MaxDistance or 100
	MinDistance = MinDistance or 20
	-- local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
	-- 	c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
	-- 	c.RotationInfluence = Vector3.new(1, 1, 1)
	local distance = module.GetSourceDistance(sourcePosition)
	if distance > MaxDistance then
		return
	end
	local intense = 1 - math.max(0, (distance - MinDistance) / (MaxDistance - MinDistance))
	camShake:ShakeOnce(4 * intense, 6, 0.1, 0.5, Vector3.new(0.5, 0.5, 0.5), Vector3.new(1, 1, 1))
end

---- 测试震动用，测试完关闭掉
-- script.AncestryChanged:Once(function(child, parent)
-- 	camShake:Stop()
-- end)



return module
