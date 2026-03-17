local module = {}

local defines = require(script.Parent.Parent.Defines)

local function checkIndexAndNameRepeat (layers)
	
	local suc=true
	local ero ={}
	
	if layers==nil then
		return false,{"配置为nil"}
	end
	
	for i,v in layers  do
		if  layers[i].Index == nil or layers[i].Name ==nil then			
			continue
		end
		
		for j,k in layers  do
			if i==j then
				continue
			end
			
			if layers[i].Index == layers[j].Index then	
				suc=false
				table.insert(ero," 不得重复  :  错误Index   "..v.Index)
			end
			
			if layers[i].Name == layers[j].Name then
				suc=false
				table.insert(ero,"Name 不得重复  :  错误name   "..v.Name)
			end
			
		end
		
	end
	
	return suc,ero
end

local function checkIndexformat(Index)
	local suc=true
	local ero ={}
	
	if typeof(Index) ~= "number" then
		suc=false
		table.insert(ero,"Index must be a number  : 错误Index   "..Index)
		return suc,ero
	end
	
	
	if math.floor(Index)~=Index then
		suc=false
		table.insert(ero,"Index 不能是浮点型数字 : 错误Index   "..Index)
	end
	
	return suc,ero
end

local function checkNameformat(Name)

	local suc=true
	local ero ={}
	if typeof(Name) ~= "string" then
		suc=false
		table.insert(ero,"Name must be a string  : 错误name   "..Name)
		return  suc,ero
	end
	
	return suc,ero
end

local function checkmodeformat (Mode:string)
	local suc=true
	local ero ={}
	if Mode~="single" and Mode~="multiple" then
		suc=false
		table.insert(ero,"Mode 指定类型错误 :错误mode    "..Mode)
	end
	return suc,ero
end

local function clonetabletotable(errormessage,ero)
	if ero==nil then
		return
	end
	for i,v in ero do
		table.insert(errormessage,v)
	end
	
end

-- 验证LayerConfigs，如果不符合要求，返回 false,错误信息
module.Validate = function(layers:defines.LayerConfigs)
	
	local success ={}
	local errormessage={}
	
	
	local suc,ero = checkIndexAndNameRepeat(layers)
	table.insert(success,suc)
	clonetabletotable(errormessage,ero)
	
	
	for i,v in pairs(layers) do
		
		if not v.Name or v.Name=="" then
			table.insert(success,false)
			table.insert(errormessage,"Name 不能为空 ")
			continue
		end
		
		if not v.Index then
			table.insert(success,false)
			table.insert(errormessage,"Name 不能为空 ")
			continue
		end
		
		local suc,ero = checkIndexformat(v.Index)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)

		
		local suc,ero = checkNameformat(v.Name)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)

		if v.Mode then
			local suc,ero= checkmodeformat(v.Mode)
			table.insert(success,suc)
			clonetabletotable(errormessage,ero)

		end
	end
	
	for i,v in success do
		if v==false then
			return false,errormessage
		end
	end
	
	return true
end

return module
