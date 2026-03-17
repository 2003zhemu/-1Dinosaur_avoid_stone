local v_u_1 = {
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
	"No",
	"Dc",
	"Ud",
	"Dd",
	"Td",
	"Qad",
	"Qid",
	"Sxd",
	"Spd",
	"Ocd",
	"Nod",
	"Vg",
	"Uvg",
	"Dvg",
	"Tvg",
}
return {
	["ToString"] = function(_, p2, p3)
		-- upvalues: (copy) v_u_1
		local v4 = p3 or 1
		local v5 = math.abs(p2)
		local v6 = math.max(1, v5)
		local v7 = math.log(v6, 1000)
		local v8 = math.floor(v7)
		local v9 = v_u_1[v8 + 1] or "e+" .. v8
		local v10 = p2 * (10 ^ v4 / 1000 ^ v8)
		local v11 = math.floor(v10) / 10 ^ v4
		return ("%." .. v4 .. "f"):format(v11):gsub("%.?0+$", "") .. v9
	end,
	["Comma"] = function(_, p12)
		local v13 = tostring(p12)
		while v13:match("^(-?%d+)(%d%d%d)") do
			v13 = v13:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		end
		return v13
	end,
}
