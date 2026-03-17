local MemoryStoreService = game:GetService("MemoryStoreService")
local _store = MemoryStoreService:GetSortedMap("Code")

local module = {}

local _cache = {}

function module.Get(codeStr)
	local info = _cache[codeStr]

	if not info then
		info = _store:GetAsync(codeStr)
		if info then
			_cache[codeStr] = info
		end
	end

	if info and info.Count == info.Used then
		return
	end

	return info and table.clone(info)
end

function module.Use(codeStr)
	local setted = false
    local info = module.Get(codeStr)
	if info.Count ~= info.Used then
		_store:UpdateAsync(codeStr, function(oldValue)
			if oldValue then
				if not oldValue.Used then
                    oldValue.Used = 0
				end
                if oldValue.Count == -1 or oldValue.Count > oldValue.Used then
                    oldValue.Used = oldValue.Used + 1
                    setted = true
                    return oldValue
                end
			end
		end, 3888000)
	else
		setted = true
	end
	return setted
end

return module