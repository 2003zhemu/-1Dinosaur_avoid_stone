-- [unfinished] [该模块职责不单一] [<字符和文本工具>不知道谁放进来的]

local module = {}

-- 仅仅展示指定子节点(符合名称的第一个)，隐藏其他子节点
-- 如果子节点名称不存在，则报错
module.ShowChildOnly = function (parent:Instance,childName:string)  
    -- 检查
    if not childName then
        error("子节点名称不可为空")
    end
    local children  = parent:GetChildren()
    local child = parent:FindFirstChild(childName)
    if not child then
        error("未能找到指定子节点"..childName)
    end
    
    -- 业务
    for i,v in parent:GetChildren() do
        if v == child then
            v.Visible = true
		else
			if(v.ClassName~="UICorner" and v.ClassName~="UIStroke" and v.ClassName~="UIAspectRatioConstraint") then
				v.Visible = false
			end
        end
    end
end

-- 仅仅展示指定列表中的子节点(符合名称的第一个)，隐藏其他子节点
-- 如果子节点名称不存在，则报错
module.ShowChildrenOnly = function (parent:Instance,childrenNames:{string})  
    -- 检查
    if not childrenNames then
        error("子节点名称不可为空")
    end
    
    local children  = parent:GetChildren()
    
    -- 先全部取消显示
    for i,v in parent:GetChildren() do
        v.Visible = false
    end
    
    -- 再显示指定
    for i,v in pairs(childrenNames) do
        parent[v].Visible = true
    end
    
end

-- 隐藏所有子节点
module.HideAllChildren = function (parent:Instance)

    -- 检查
    local children  = parent:GetChildren()

    -- 业务
    for i,v in parent:GetChildren() do
        v.Visible = false
    end
end


-- 将数字转为字符串
--[[
    precision: 小数点后的位数, 默认值为2
    hideZero: 是否隐藏小数位末尾的0
]]
module.Num2Str=function(num: number, precision: number?, hideZero: boolean?): string
	if typeof(num) ~= "number" then warn("typeof(num) ~= number") return end
	if precision == nil then precision = 2 end
	if hideZero == nil then hideZero = false end

	if hideZero and num == 0 then return "0" end

	local str = ("%." .. precision .. 'f'):format(num)

	if hideZero and str:find('.') then
		local cnt = 0
		for i = #str, 1, -1 do
			if str:sub(i, i) == '0' then
				cnt = cnt + 1	
			elseif str:sub(i, i) == '.' then
				cnt = cnt + 1
				break
			else
				break
			end
		end

		str = str:sub(1, #str - cnt)
	end

	return str
end

--单位转换
module.AppendUnit=function(n: number, precision: number?, hideZero: boolean?)

	if precision == nil then precision = 2 end
	if hideZero == nil then hideZero = true end

	local Units = {
		'', 'K', 'M',
		'B', 'T', "Qa",
		"Qi", "Sx", "Sp",
		"Oc", 'N', 'D',
		"Ud", "Dd", "Td",
		"Qt", "Qd", "Sd",
		"St", "Od", "Nod",
		"V", "Cv",
	}

	for i = 22, 1, -1 do
		if n >= math.pow(10, 3 * i) then
			local res = module.Num2Str((n / math.pow(10, 3 * i)), precision, hideZero)
			if i ~= 22 and res == "1000" then
				return '1' .. Units[i + 2]
			else
				return res .. Units[i + 1]
			end
		end
	end
	local res = module.Num2Str(n, precision, hideZero)
	if res == "1000" then
		return '1' .. Units[2]
	else
		return res .. Units[1]
	end
end



return module
