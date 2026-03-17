--[=[
    @class Group
]=]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Group = {}
Group.__index = Group

-- group构造方法
-- @param name string
-- @return Group
function Group.new(name: string)
	local self = {}
	setmetatable(self, Group)
    
    self.name = name
    
	self.detections = {}        --分组detection
    self.showns = {}            --触发了promptshown的detection
    
    self._enabled = true        --是否可用
    self._shown = nil           --当前组别优先触发的detection
    self._update = nil          --更新

	return self
end

--[=[
    组内添加detection
    @param detection any
    @return void
]=]
function Group:addDetection(detection)
    table.insert(self.detections, detection)
end
--[=[
    组内删除detection
    @param detection any
    @return void
]=]
function Group:removeDetection(detection)
    local idx = table.find(self.detections, detection)
    if idx then
        self:setHidden(detection)
        table.remove(self.detections, idx)
    end
end

-- 添加detection到promptshown数组
-- @param detection any
-- @return void
function Group:setShown(detection)
    table.insert(self.showns, detection)
    self:_updadeClosest()
end

-- 从promptshown数组中移除detection
-- @param detection any
-- @return void
function Group:setHidden(detection)
    local idx = table.find(self.showns, detection)
    if idx then
        table.remove(self.showns, idx)
    end
    if self._shown == detection then
        detection:moveAway()
        self._shown = nil
    end
end

--设置group检测可用性，不可手动调用
function Group:setEnabled(enabled: boolean)
    if self.enabled == enabled then
        return
    end
    self._enabled = enabled
    if not enabled then
        if self._shown then
            self._shown:moveAway()
            self._shown = nil
        end
    else
        self:_updadeClosest()
    end
end

function Group:clearShowns()
    while #self.showns > 0 do
        local detection = self.showns[1]
        self:setHidden(detection)
    end
end

--[=[
    销毁分组中所有detection
    @return void
]=]
function Group:destroyAllDetections()
    while #self.detections > 0 do
        local detection = self.detections[1]
        detection:destroy()
    end
    if self._update then
        self._update:Disconnect()
        self._update = nil
    end
    self._shown = nil
end

--search the nearest prompt to character, then call "close"
function Group:_updadeClosest()
    if not self._update then
        self._update = RunService.Heartbeat:Connect(function(deltaTime)
            if #self.showns <= 1 or not self._enabled then
                self._update:Disconnect()
                self._update = nil
            end
            local closest = nil
            local dis = math.huge
            for i, detection in pairs(self.showns) do
                if not detection._activated then
                    continue
                end
                local prompt = detection.prompt
                local p = prompt.Parent.Position
                local d = Players.LocalPlayer:DistanceFromCharacter(p)
                if d > 0 and dis > d then
                    dis = d
                    closest = detection
                end
            end
            if closest and self._shown ~= closest then
                if self._shown then
                    self._shown:moveAway()
                    self._shown = nil
                end
                if self._enabled then
                    closest:getClose()
                    self._shown = closest
                end
            end
        end)

    end
end

return Group