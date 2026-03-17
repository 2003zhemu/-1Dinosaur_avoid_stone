local module = {}
local config = require(script.Parent.WebInformationConfig)
local RS = game:GetService("ReplicatedStorage")

-- config validation, 遍历 config, 要求每个成员都包含 ValueType,Interval,Callback 属性
for k, v in pairs(config) do
    assert(v.ValueType and v.Interval and v.Callback and type(v.Callback) == "function", "WebInformationConfig." .. k .. " is invalid")
    local ins = Instance.new(v.ValueType,RS)
    ins.Name = "WebInformation_"..k
end

-- local loop = require(script.Loop)
-- local observer = require(script.MessageObserver)
local loop = require(script.Loops)


-- 获取指定 id 的数据
function module.GetData(id:string)
    if not id then return end
    local ins = RS:FindFirstChild("WebInformation_"..id)
    assert(ins)
    return ins.Value
end

-- 获取指定 id 的数据存储对象
function module.GetInstance(id:string)
    if not id then return end
    local ins = RS:FindFirstChild("WebInformation_"..id)
    assert(ins)
    return ins
end

return module