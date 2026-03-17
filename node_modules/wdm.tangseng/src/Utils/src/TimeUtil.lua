local module = {}

-- 参数为多少秒时间，转化为0H:0M:0S形式
module.SecondFormat=function(num)
	--if num < 60 then
	--	return num
	if num < 3600 then
		local mTime = math.floor(num/60)
		local sTime = num - mTime * 60
		return string.format("%02d",mTime)..":"..string.format("%02d",sTime)
	else
		local hTime = math.floor(num/3600)
		local mTime = math.floor((num - hTime * 3600)/60)
		local sTime = num - mTime * 60 - hTime * 3600
		return string.format("%02d",hTime)..":"..string.format("%02d",mTime)..":"..sTime
	end
end

return module
