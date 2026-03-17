local module = {}

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
return module
