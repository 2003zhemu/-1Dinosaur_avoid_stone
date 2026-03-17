local RunService = game:GetService("RunService")
if not RunService:IsServer() then return {} end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Defines = require(game.ReplicatedStorage.Modules.Defines)
local ToolModels = game.ServerStorage.ToolModels
local Matter = require(ReplicatedStorage.Packages.Matter)

local module = {}

-- 存储点数据
local ToolPoints = {}
local ToolKeys = {}
local ToolValues = {}

-- 初始化点数据
module.Init = function()
    for key, v in pairs(Defines.Tools) do
        table.insert(ToolKeys, key)
        ToolValues[v] = key
    end

	local ToolSpawns = game.Workspace:FindFirstChild("ToolSpawns")
	if ToolSpawns then
        for _, stage in pairs(ToolSpawns:GetChildren()) do
            local stagePoints = {}
            local index = 0
            for _, point in pairs(stage:GetChildren()) do
                index = index + 1
                stagePoints[index] = {
                    Id = index,
                    Point = point,
                    Size = point.Size,
                    CFrame = point.CFrame,
                }
            end
            ToolPoints[tonumber(stage.Name)] = {Points = stagePoints, PointCount = index}
        end
        return true
	end

	return false
end

-- 生成关卡道具
module.SpawnTool = function(world, state, context, stage)
	-- 获取随机点
    local stagePoints = ToolPoints[stage]
   -- warn(ToolPoints, stage, stagePoints)

    if not stagePoints then return end
    if not stagePoints.Points or stagePoints.PointCount < 1 then return end
    
    --随机区域
    local randomPoint = stagePoints.Points[math.random(1, stagePoints.PointCount)]
    --随机道具
    local tool = ToolKeys[math.random(1, #ToolKeys)]
    --区域内随机位置
    local size = randomPoint.Size
    local offsetX = math.random(0, size.X) - size.X / 2
    local offsetZ = math.random(0, size.Z) - size.Z / 2
    local spawnCFrame = randomPoint.CFrame * CFrame.new(offsetX, 0, offsetZ)

    local modelTemp = ToolModels:FindFirstChild(tool)
    if not modelTemp then
        warn("[ToolHelper] 道具模型不存在", tool)
        return
    end
    local model = modelTemp:Clone()
    model:PivotTo(spawnCFrame)
    local toolParent = game.Workspace:FindFirstChild("ActiveTools")
    if not toolParent then
        toolParent = Instance.new("Folder")
        toolParent.Name = "ActiveTools"
        toolParent.Parent = game.Workspace
    end
    model.Parent = toolParent

	-- 创建ECS实体
	local entity = world:spawn(
        context.Components.Tool({ Key = Defines.Tools[tool] }),  --道具标识
		context.Components.Stage({ Value = stage }),  --所在关卡
		context.Components.ServerModel({ Model = model }),  --道具模型
		context.Components.ExpireTime({ Value = os.clock() + 30 })  --过期时间
	)
    model:SetAttribute("entityType", entity)
end

--生成自定道具
module.SpawnCustomTool = function(world, state, context, stage, toolIndex)
    if not stage or not toolIndex then return end

    local stagePoints = ToolPoints[stage]
    local tool = ToolValues[toolIndex]

    if not stagePoints or not tool then return end
    if not stagePoints.Points or stagePoints.PointCount < 1 then return end
    
    --随机区域
    local randomPoint = stagePoints.Points[math.random(1, stagePoints.PointCount)]
    
    --区域内随机位置
    local size = randomPoint.Size
    local offsetX = math.random(0, size.X) - size.X / 2
    local offsetZ = math.random(0, size.Z) - size.Z / 2
    local spawnCFrame = randomPoint.CFrame * CFrame.new(offsetX, 0, offsetZ)

    local modelTemp = ToolModels:FindFirstChild(tool)
    if not modelTemp then
        warn("[ToolHelper] 道具模型不存在", tool)
        return
    end
    local model = modelTemp:Clone()
    model:PivotTo(spawnCFrame)
    local toolParent = game.Workspace:FindFirstChild("ActiveTools")
    if not toolParent then
        toolParent = Instance.new("Folder")
        toolParent.Name = "ActiveTools"
        toolParent.Parent = game.Workspace
    end
    model.Parent = toolParent

	-- 创建ECS实体
	local entity = world:spawn(
        context.Components.Tool({ Key = Defines.Tools[tool] }),  --道具标识
		context.Components.Stage({ Value = stage }),  --所在关卡
		context.Components.ServerModel({ Model = model }),  --道具模型
		context.Components.ExpireTime({ Value = os.clock() + 30 })  --过期时间
	)
    model:SetAttribute("entityType", entity)
end

return module