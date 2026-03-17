local module = {}
module.deepCopyHelper = function(object, encountered)
	local result = table.create(#object)
	encountered[object] = result

	for k, v in pairs(object) do
		if type(k) == "table" then
			k = encountered[k] or module.deepCopyHelper(k, encountered)
		end

		if type(v) == "table" then
			v = encountered[v] or module.deepCopyHelper(v, encountered)
		end

		result[k] = v
	end

	return result
end

return module
