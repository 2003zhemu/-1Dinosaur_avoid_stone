local module = {}

function module:GetBit(num, bit)
	local bitIndex = bit - 1
	return bit32.band(bit32.rshift(num, bitIndex), 1)
end

function module:SetBit(num, bit, value)
	local bitIndex = bit - 1

	if value then
		-- 设置为1：使用 bit32.bor (位或)
		return bit32.bor(num, bit32.lshift(1, bitIndex))
	else
		-- 设置为0：先创建掩码，然后使用 bit32.band (位与)
		local mask = bit32.bnot(bit32.lshift(1, bitIndex))
		return bit32.band(num, mask)
	end
end

function module:GetFormatTime(totalSeconds)
	totalSeconds = math.abs(totalSeconds)
	local days = math.floor(totalSeconds / (24 * 3600))
	local hours = math.floor((totalSeconds % (24 * 3600)) / 3600)
	local minutes = math.floor((totalSeconds % 3600) / 60)
	local seconds = totalSeconds % 60

	local timeString = ""
	if days > 0 then
		timeString = tostring(days) .. "Days, "
	end
	if hours > 0 or days > 0 then
		timeString = timeString .. (hours < 10 and "0" or "") .. tostring(hours) .. " : "
	end
	if minutes > 0 or hours > 0 or days > 0 then
		timeString = timeString .. (minutes < 10 and "0" or "") .. tostring(minutes) .. " : "
	end
	timeString = timeString .. (seconds < 10 and "0" or "") .. tostring(seconds) .. ""

	return timeString
end

function module:GetDaysBySeconds(totalSeconds)
	totalSeconds = math.abs(totalSeconds)
	local days = math.floor(totalSeconds / (24 * 3600))
	if days > 0 and days < 1 then
		return 0
	end
	return days
end

local function Num2Str(num: number, precision: number?, hideZero: boolean?): string
	if typeof(num) ~= "number" then
		warn("typeof(num) ~= number")
		return
	end
	if precision == nil then
		precision = 2
	end
	if hideZero == nil then
		hideZero = false
	end

	if hideZero and num == 0 then
		return "0"
	end

	local str = ("%." .. precision .. "f"):format(num)

	if hideZero and str:find(".") then
		local cnt = 0
		for i = #str, 1, -1 do
			if str:sub(i, i) == "0" then
				cnt = cnt + 1
			elseif str:sub(i, i) == "." then
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

function module:formatTimeLeft(secondsLeft, flag)
	local days = math.floor(secondsLeft / 86400)
	local hours = math.floor((secondsLeft % 86400) / 3600)
	local minutes = math.floor((secondsLeft % 3600) / 60)
	local seconds = secondsLeft % 60

	-- 动态控制显示内容
	if days > 0 then
		if flag then
			return string.format("%dDays %02d:%02d:%02d", days, hours, minutes, seconds)
		else
			return string.format("%dDays\n%02d:%02d:%02d", days, hours, minutes, seconds)
		end
	elseif hours > 0 then
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	elseif minutes > 0 then
		return string.format("%02d:%02d", minutes, seconds)
	else
		return string.format("%02d", seconds)
	end
end

-- 给要显示在UI上的number加单位
function module:AppendUnit(n: number, precision: number?, hideZero: boolean?)
	if precision == nil then
		precision = 2
	end
	if hideZero == nil then
		hideZero = true
	end

	local Units = {
		"",
		"K",
		"M",
		"B",
		"T",
		"Qa",
		"Qi",
		"Sx",
		"Sp",
		"Oc",
		"N",
		"D",
		"Ud",
		"Dd",
		"Td",
		"Qt",
		"Qd",
		"Sd",
		"St",
		"Od",
		"Nod",
		"V",
		"Cv",
	}

	for i = 22, 1, -1 do
		if n >= math.pow(10, 3 * i) then
			local res = Num2Str((n / math.pow(10, 3 * i)), precision, hideZero)
			if i ~= 22 and res == "1000" then
				return "1" .. Units[i + 2]
			else
				return res .. Units[i + 1]
			end
		end
	end
	local res = Num2Str(n, precision, hideZero)
	if res == "1000" then
		return "1" .. Units[2]
	else
		return res .. Units[1]
	end
end

function module:GetLeftAndRightChars(str)
	local numberPattern = "%d+"
	local startIndex, endIndex = string.find(str, numberPattern)

	if startIndex and endIndex then
		local leftChar = string.sub(str, 1, startIndex - 1)
		local rightChar = string.sub(str, endIndex + 1)
		local numberString = string.sub(str, startIndex, endIndex)
		return leftChar, rightChar, numberString
	else
		return nil, nil, nil
	end
end

-- function module:ConvertUTCToLocal(utcTimeString)
--     -- 假设 utcTimeString 是一个格式为 "YYYY-MM-DD HH:MM:SS" 的字符串
--     local utcTime = os.time({
--         year = tonumber(utcTimeString:sub(1, 4)),
--         month = tonumber(utcTimeString:sub(6, 7)),
--         day = tonumber(utcTimeString:sub(9, 10)),
--         hour = tonumber(utcTimeString:sub(12, 13)),
--         min = tonumber(utcTimeString:sub(15, 16)),
--         sec = tonumber(utcTimeString:sub(18, 19)),
--     })

--     -- 获取玩家本地时间
--     local localTime = os.date("*t", utcTime)

--     -- 返回格式化的本地时间字符串
--     return string.format("%04d-%02d-%02d %02d:%02d:%02d",
--         localTime.year, localTime.month, localTime.day,
--         localTime.hour, localTime.min, localTime.sec)
-- end

function module:ConvertUTCToLocal(utcTimestamp)
	-- 假设 utcTimestamp 是一个数字，表示 UTC 时间的时间戳
	-- 获取玩家本地时间
	local localTime = os.date("*t", utcTimestamp)

	-- 返回格式化的本地时间字符串
	return string.format(
		"%04d-%02d-%02d %02d:%02d:%02d",
		localTime.year,
		localTime.month,
		localTime.day,
		localTime.hour,
		localTime.min,
		localTime.sec
	)
end

function module:ConvertUTCToLocalTimeOnly(utcTimestamp)
	local localTime = self:ConvertUTCToLocal(utcTimestamp)
	-- 假设 ConvertUTCToLocal 返回的格式是 "YYYY-MM-DD HH:MM:SS"
	-- 我们只需要提取时间部分
	local hour, minute, second = localTime:match("(%d+):(%d+):(%d+)$")
	return string.format("%02d:%02d:%02d", hour, minute, second)
end

return module
