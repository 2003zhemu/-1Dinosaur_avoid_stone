return function(v1, v2)
	v1 = v1 or "0.0.0"
	v2 = v2 or "0.0.0"

	local function splitVersion(version)
		local t = {}
		for i in string.gmatch(version, "%d+") do
			table.insert(t, tonumber(i))
		end
		return t
	end

	local t1 = splitVersion(v1)
	local t2 = splitVersion(v2)

	for i = 1, math.max(#t1, #t2) do
		local n1 = t1[i] or 0
		local n2 = t2[i] or 0
		if n1 > n2 then
			return 1
		elseif n1 < n2 then
			return -1
		end
	end

	return 0
end
