
local module = {}
local config = require(script.Parent.Parent.WebInformationConfig)
--require主服务器模块
local serverService = require(game.ReplicatedStorage.Packages.ServerService)
local timers = {}
local syncTime = {}
local RS = game:GetService("ReplicatedStorage")
local memoryStoreService = game:GetService("MemoryStoreService")
local dataMap = memoryStoreService:GetSortedMap("WebInformationData")

--心跳
game["Run Service"].Heartbeat:Connect(function()
   --按配置时间间隔定时执行获取数据
    for k,v in pairs(config) do
        --是否主服务器
        local isMaster = serverService.IsPrimaryServer()

        --主服务器爬数据
        if not timers[k] or (os.clock() - timers[k] > v.Interval) then
            timers[k] = os.clock()
            if isMaster then
                task.spawn(function()
                    local result = v.Callback()
                    local ins = RS:FindFirstChild("WebInformation_"..k)
                    if result and ins then
                        ins.Value = result
                      --  print("获取的数据为：",result)
                        dataMap:SetAsync("WebInformation_"..k,result,v.Interval * 3)
                    end
                end)
            end    
        end
        
        if not syncTime[k] then
            syncTime[k] = {}
            syncTime[k].GetTime = os.clock()
            if v.Interval < 3 then
                syncTime[k].Interval = v.Interval
            else
                syncTime[k].Interval = v.Interval - 2
            end
        end

        --memory获取数据
        if os.clock() - syncTime[k].GetTime > syncTime[k].Interval then
            syncTime[k].GetTime = os.clock()
            local result = dataMap:GetAsync("WebInformation_"..k)
            local ins = RS:FindFirstChild("WebInformation_"..k)
            if result and ins then
                ins.Value = result
              --  print("抓到的数据为：",result)
            end
        end
    end
end)

return module


