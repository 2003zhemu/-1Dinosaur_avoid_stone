local module = {}


-- 深度补丁时，将某个属性设为nil，使用此值
module.Nil = {}

-- 深克隆 (不包括metatable),返回新表
module.DeepClone = function (original):{}
    assert(type(original)=="table","参数必须为 table")
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = module.DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

-- 将patch属性递归补丁到目标表
module.DeepPatch = function (patch,target)
    assert(type(patch)=="table","patch 参数必须为 table")
    assert(type(target)=="table","target 参数必须为 table")
    for k, v in pairs(patch) do
        if type(v) == "table" and type(target[k])=="table" then
            module.DeepPatch(v,target[k])
        elseif v== module.Nil then
            target[k] = nil
        else 
            target[k] = v
        end
    end
end


-- 浅相等
module.IsShallowEqual = function(left,right):boolean
    assert(type(left)=="table","left 参数必须为 table")
    assert(type(right)=="table","right 参数必须为 table")
    for k, v in pairs(left) do
        if right[k] ~= v then
            return false
        end
    end
    
    for k, v in pairs(right) do
        if left[k] ~= v then
            return false
        end
    end
    
    return true
end


-- 反转表
module.Reverse = function(target)
    for i = 1, math.floor(#target/2) do
        local j = #target - i + 1
        target[i], target[j] = target[j], target[i]
    end
end


return module
