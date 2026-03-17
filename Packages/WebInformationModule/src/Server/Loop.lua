
-- 心跳
-- 遍历配置 ，interval
-- if master do
local module = {}
local config = require(script.Parent.Parent.WebInformationConfig)
local MessagingService = game:GetService("MessagingService")
--require主服务器模块
local serverService = require(game.ReplicatedStorage.Packages.ServerService)
local timers = {}
local updateTime = 10 --主服务器每隔10s更新一次全部数据，防止新建服务器没有数据
local publishTime = os.clock()  --记录主服务器最新一次同步全部数据时间

--心跳
game["Run Service"].Heartbeat:Connect(function()
   
   --按配置时间间隔定时执行获取数据
    for k,v in pairs(config) do
        if not timers[k] or (os.clock() - timers[k] > v.Interval) then
            timers[k] = os.clock()
            
            --如果是主服务器
          local isMaster = serverService.IsPrimaryServer()
            if isMaster then
                task.spawn(function()
                    local result = v.Callback()
                    local ins = script.parent.parent:FindFirstChild(k)
                    if result then
                        ins.Value = result
                        MessagingService:PublishAsync("WebInformation",{Type = k, Data = result})
                    end
                end)
            end    
        end
    end

    if os.clock() - publishTime > updateTime then
        publishTime = os.clock()
        local isMaster = serverService.IsPrimaryServer()
        if not isMaster then return end
        for k, v in pairs(config) do
            if v.Interval and v.Interval > updateTime then  --时间间隔大于10的才需要定时通知到其他从服务器
                local ins = script.parent.parent:FindFirstChild(k)
                if ins and ins.Value then
                    MessagingService:PublishAsync("WebInformation",{Type = k, Data = ins.Value})
                end
            end
        end
    end
end)

return module


