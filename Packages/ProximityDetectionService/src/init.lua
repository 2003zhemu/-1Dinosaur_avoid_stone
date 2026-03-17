--[=[
    @class ProximityDetectionService
    @client

    靠近检测服务，使用ProximityPrompt实现。当客户端在BasePart上创建一个Detection，并设置到指定的分组（未指定分组分配到default）;
    当玩家靠近检测的部件，将会触发设置的“靠近触发方法（close）”，若有多个部件在检测距离内，最靠近玩家的会优先触发，
    当玩家远离部件，若当前部件已被触发“靠近触发方法（close）”，远离时将会触发“远离触发方法（away）”;
    本服务适用于：
    * 游戏中靠近物体时，弹出窗口
]=]

--[[

    Exmaple:
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local ProximityDetectionService = require(ReplicatedStorage.Packages.ProximityDetectionService)
        local r = ProximityDetectionService:createDetection("Red", workspace:WaitForChild("Red"), {
            Away = function()
                workspace.Red.BillboardGui.Enabled = false
            end,
            Close = function()
                workspace.Red.BillboardGui.Enabled = true
            end,
            Distance = 15,
            Group = "1"
        })


        local b = ProximityDetectionService:createDetection("Blue", workspace:WaitForChild("Blue"), {
            Away = function()
                workspace.Blue.BillboardGui.Enabled = false
            end,
            Close = function()
                workspace.Blue.BillboardGui.Enabled = true
            end,
            Distance = 15,
            Group = "1"
        })


        local y = ProximityDetectionService:createDetection("Yellow", workspace:WaitForChild("Yellow"), {
            Away = function()
                workspace.Yellow.BillboardGui.Enabled = false
            end,
            Close = function()
                workspace.Yellow.BillboardGui.Enabled = true
            end,
            Distance = 15
        }):activate()

        r:activate()
        b:activate()

        wait(5)
        r:deactivate()
        wait(5)
        r:activate()
        wait(5)
        r:destroy()
        wait(5)
        ProximityDetectionService:setEnabled(false)
        wait(5)
        ProximityDetectionService:setEnabled(true)

]]

local Detection = require(script.Detection)
local Defines = require(script.Defines)
local Group = require(script.Group)

local bindableEvent = script.BindableEvent      --prompt触发事件
--[=[
    服务可用性
    @prop Enabled boolean
    @within ProximityDetectionService
]=]

--[=[
    所有检测集合
    @readonly
    @prop Detections { Detection? }
    @within ProximityDetectionService
]=]

--[=[
    所有检测分组集合
    @readonly
    @prop Groups { Group? }
    @within ProximityDetectionService
]=]
local ProximityDetectionService = {
    Enabled = nil,
    Groups = nil,
    Detections = nil
}

local _props = {
    Enabled = true,
    Groups = {},
    Detections = {}
}

--set a prompt shown
--@param prompt any
local function setPromptShown(prompt)
    local detection = ProximityDetectionService:getDetectionByPrompt(prompt)
    if detection then
        local group = detection.group
        group:setShown(detection)
    end
end

--set a prompt hidden
--@param prompt any
local function setPromptHidden(prompt)
    local detection = ProximityDetectionService:getDetectionByPrompt(prompt)
    if detection then
        local group = detection.group
        group:setHidden(detection)
    end
end

--[=[
    创建一个靠近检测实例
    @param name string
    @param instance BasePart | Model
    @param options Options
    @return Detection
]=]
function ProximityDetectionService:createDetection(name: string, instance: BasePart | Model, options: Defines.Options)
    
    local detection = _props.Detections[name]
    local prompt = instance:FindFirstChildOfClass("ProximityPrompt")

    assert(typeof(name) == "string", "bad argument #1 - must be a string")
    assert(typeof(instance) == "Instance" and (instance:IsA("BasePart") or instance:IsA("Model")), "bad argument #2 - must be a instance (BasePart, Model with primartpart)")
    assert(not detection, ("detection '%s' already exists!"):format(name))
    assert(not prompt, ("prompt already exists in '%s'!"):format(instance.Name))
    options = options or {}
    local detection = Detection.new(name, instance, options)                        --创建detection
    _props.Detections[name] = detection                                             --添加到集合
    detection.group = ProximityDetectionService:getGroupByName(options.Group)       --设置分组
    detection.group:addDetection(detection)

    return detection
end

--[=[
    通过prompt获取detection
    @param prompt ProximityPrompt
    @return Detection
]=]
function ProximityDetectionService:getDetectionByPrompt(prompt: ProximityPrompt)
    local detection = _props.Detections[prompt.Name]
    return detection
end

--[=[
    通过name获取detection
    @param name string
    @return Detection
]=]
function ProximityDetectionService:getDetectionByName(name: string)
    local detection = _props.Detections[name]
    if not detection then
        return false
    end
    return detection
end

--[=[
    获取所有detection
    @return {Detection?}
]=]
function ProximityDetectionService:getAllDetections()
    local allDetections = {}
    for _, detection in _props.Detections do
        table.insert(allDetections, detection)
    end
    return allDetections
end

--[=[
    通过name删除一个detection
    @param name string
    @return boolean
]=]
function ProximityDetectionService:removeDetection(name: string)
    local detection = ProximityDetectionService:getDetectionByName(name)
    assert(detection, ("detection '%s' not found!"):format(name))

    detection:destroy()
    _props.Detections[name] = nil

    return true
end

--[=[
    删除一个分组内所有detection
    @param groupName string
    @return void
]=]
function ProximityDetectionService:removeGroupDetections(groupName: string)
    local group = ProximityDetectionService:getGroupByName(groupName)
    for i, v in pairs(group.detections) do
        _props.Detections[v.name] = nil
    end
    group:destroyAllDetections()
end

--[=[
    设置服务可用
    @param enabled string
    @return void
]=]
function ProximityDetectionService:setEnabled(enabled: boolean)
    if _props.Enabled == enabled then
        return
    end
    _props.Enabled = enabled
    if not enabled then
        for i, group in pairs(_props.Groups) do
            group:clearShowns()
        end
    end
end

--[=[
    创建一个新的分组
    @param groupName string
    @return Group
]=]
function ProximityDetectionService:addGroup(groupName: string)
    _props.Groups[groupName] = Group.new(groupName)
    return _props.Groups[groupName]
end

--[=[
    获取一个分组，若没有直接创建
    @param groupName string
    @return Group
]=]
function ProximityDetectionService:getGroupByName(groupName: string)
    groupName = groupName or "default"
    if not _props.Groups[groupName] then
        ProximityDetectionService:addGroup(groupName)
    end
    return _props.Groups[groupName]
end

--[=[
    设置分组可用
    @param groupName string
    @param enabled boolean
    @return void
]=]
function ProximityDetectionService:setGroupEnabled(groupName: string, enabled: boolean)
    local group = ProximityDetectionService:getGroupByName(groupName)
    group:setEnabled(enabled)
end

--[=[
    设置检测可用
    @param detectionName string
    @param enabled boolean
    @return void
]=]
function ProximityDetectionService:setDetectionEnabled(detectionName: string, enabled: boolean)
    local detection = ProximityDetectionService:getDetectionByName(detectionName)
    detection:activate(enabled)
end

--prompt hidden shown 抛出事件
--@param prompt ProximityPrompt
--@param inputType any
bindableEvent.Event:Connect(function(prompt: ProximityPrompt, inputType)
    if not _props.Enabled then
        return
    end
    if inputType then
        setPromptShown(prompt)
        
    else
        setPromptHidden(prompt)
    end
end)

--属性监听
setmetatable(ProximityDetectionService, {
    __index = function(t, k)
        local prop = _props[k]
        if prop ~= nil then
            return prop
        end
        return rawget(t, k)
    end,
    __newindex = function(t, k, v)
        local prop = _props[k]
        if prop ~= nil then
            local set: (this:any, val: any) -> nil = rawget(t, "set" .. k)
            if set then
                set(t, v)
            end
        else
            return error("Cannot edit.")
        end
    end
})

return ProximityDetectionService