local module = {}
local defines = require(script.Parent.Parent.Defines)

--OptionConfig检查name
local function OptionConfigCheckName(name)
	local suc=true
	local ero ={}

	if typeof(name)~="string" then
		suc=false
		table.insert(ero,"name must be a string  :   错误name   "..name)
	end

	return suc,ero
end
--OptionConfig检查 layer
local function OptionConfigCheckLayer(layer)
	local suc=true
	local ero ={}

	if typeof(layer) ~= "number" then
		suc=false
		table.insert(ero,"layer must be a number  : 错误layer  "..layer)
		return suc,ero
	end


	if math.floor(layer)~=layer then
		suc=false
		table.insert(ero,"layer 不能是浮点型数字 : 错误layer   "..layer)
	end

	if math.abs(layer)~=layer then
		suc=false
		table.insert(ero,"layer 须是正整数 : 错误layer   "..layer)
	end

	if layer==0 then
		suc=false
		table.insert(ero,"layer 不为0   :     错误layer   "..layer)
	end

	return suc,ero
end
--OptionConfig检查 FadeIn
local function OptionConfigCheckFadeIn(fadeIn)
	local suc=true
	local ero ={}

	if typeof(fadeIn)~="number" and  typeof(fadeIn)~="string" and typeof(fadeIn)~="table" and fadeIn~=nil then

		suc=false
		table.insert(ero,"FadeIn  must be number|string|table   :   错误FadeIn   "..tostring(fadeIn) )
	end

	if typeof(fadeIn)=="number" then
		if fadeIn ~= -1 then
			suc=false
			table.insert(ero,"FadeIn number must be -1  :   错误FadeIn   "..fadeIn)
		end

	end

	return suc,ero
end
--OptionConfig检查 FadeOut
local function OptionConfigCheckFadeOut(fadeout)
	local suc=true
	local ero ={}
	
	if typeof(fadeout)~="number" and  typeof(fadeout)~="string" and typeof(fadeout)~="table" and fadeout~=nil then

		suc=false
		table.insert(ero,"FadeOut  must be number|string|table   :   错误FadeOut   "..tostring(fadeout))
	end
	
	if typeof(fadeout)=="number" then
		if fadeout ~= -1 then
			suc=false
			table.insert(ero,"FadeOut number must be -1  :   错误FadeOut   "..fadeout)
		end
	end

	return suc,ero
end
--OptionConfig检查 IsModal
local function OptionConfigCheckIsModal(ismodal)
	local suc=true
	local ero ={}

	if typeof(ismodal)~="boolean" then
		suc=false
		table.insert(ero,"IsModal must be boolean  :   错误IsModal   "..ismodal)
	end

	return suc,ero
end
--OptionConfig检查 PrevFadeOut
local function OptionConfigCheckPrevFadeOut(prevfadeout)
	local suc=true
	local ero ={}

	if typeof(prevfadeout)~="number" and  typeof(prevfadeout)~="string" and typeof(prevfadeout)~="table" and prevfadeout~=nil then

		suc=false
		table.insert(ero,"PrevFadeOut  must be number|string|table   :   错误PrevFadeOut   "..tostring(prevfadeout))
	end

	if typeof(prevfadeout)=="number" then
		if prevfadeout ~= -1 then
			suc=false
			table.insert(ero,"PrevFadeOut number must be -1  :   错误PrevFadeOut   "..prevfadeout)
		end
	end



	return suc,ero
end
--OptionConfig检查 NextFadeIn
local function OptionConfigCheckNextFadeIn(nextfadein)
	local suc=true
	local ero ={}
	
	if typeof(nextfadein)~="number" and  typeof(nextfadein)~="string" and typeof(nextfadein)~="table" and nextfadein~=nil then

		suc=false
		table.insert(ero,"NextFadeIn  must be number|string|table   :   错误NextFadeIn   "..tostring(nextfadein))
	end

	if typeof(nextfadein)=="number" then
		if nextfadein ~= -1 then
			suc=false
			table.insert(ero,"NextFadeIn number must be -1  :   错误NextFadeIn  "..nextfadein)
		end
	end


	
	return suc,ero
end
--OptionConfig检查 autocloseafter
local function OptionConfigCheckAutoCloseAfter(autocloseafter)
	local suc=true
	local ero ={}
	
	if typeof(autocloseafter) ~= "number" then
		suc=false
		table.insert(ero,"AutoCloseAfter must be a number  : 错误AutoCloseAfter   "..autocloseafter)
		return suc,ero
	end

	if math.abs(autocloseafter)~=autocloseafter then
		suc=false
		table.insert(ero,"AutoCloseAfter 须是正整数 : 错误AutoCloseAfter   "..autocloseafter)
	end

	
	return suc,ero
end
--OptionConfig检查 Context
local function OptionConfigCheckContext(context)
	local suc=true
	local ero ={}

	return suc,ero
end
--OptionConfig检查 Next
local function OptionConfigCheckNext(next_)
	local suc=true
	local ero ={}

	return suc,ero
end

--合并报错信息
local function clonetabletotable(errormessage,ero)
	if ero==nil then
		return
	end
	for i,v in ero do
		table.insert(errormessage,v)
	end

end

--验证PanelOptions的合法性
module.ValidatePanelOption = function(
	optionconfig:defines.PanelOptions,
	layerConfigs:defines.LayerConfigs,
	animationConfigs:defines.AnimationConfigs)
	local success ={}
	local errormessage={}
	if optionconfig==nil then
		return false,"Optionconfig为nil"
	end
	
	if optionconfig=={} then
		return true
	end
	
	if optionconfig.Name~=nil then
		local suc,ero =OptionConfigCheckName(optionconfig.Name)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)
	end

	if optionconfig.Layer~=nil then
		local suc,ero =OptionConfigCheckLayer(optionconfig.Layer)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)
	end

	if optionconfig.FadeIn~=nil then
		local suc,ero =OptionConfigCheckFadeIn(optionconfig.FadeIn)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)
	end
	if optionconfig.FadeOut~=nil then
		local suc,ero =OptionConfigCheckFadeOut(optionconfig.FadeOut)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)
	end
	if optionconfig.IsModal~=nil then
		local suc,ero =OptionConfigCheckIsModal(optionconfig.IsModal)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)
	end
	if optionconfig.PrevFadeOut~=nil then
		local suc,ero =OptionConfigCheckPrevFadeOut(optionconfig.PrevFadeOut)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)
	end

	if optionconfig.NextFadeIn~=nil then
		local suc,ero =OptionConfigCheckNextFadeIn(optionconfig.NextFadeIn)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)
	end
	if optionconfig.autocloseafter~=nil then
		local suc,ero =OptionConfigCheckAutoCloseAfter(optionconfig.autocloseafter)
		table.insert(success,suc)
		clonetabletotable(errormessage,ero)
	end


	if optionconfig.Next~=nil then
		module.ValidatePanelOption(optionconfig.Next)
	end


	for i,v in success do
		if v==false then
			return false,errormessage
		end
	end

	return true
end


module.ValidatePanelConfigs = function(configs:defines.PanelConfigs):(boolean,string?)
    return true
end


module.ValidatePanelConfig = function()

end


return module
