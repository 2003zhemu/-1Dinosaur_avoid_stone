local event: RemoteEvent = script.Parent:FindFirstChild("RemoteEvent")
local invoke = script.Parent:FindFirstChild("RemoteFunction")

local module = {}
local _cache = {}

local function remote(...)
	if event == nil then
		event = script.Parent:WaitForChild("RemoteEvent")
	end
	event:FireServer(...)
end

local function remoteInvoke(...)
	if invoke == nil then
		invoke = script.Parent:WaitForChild("RemoteFunction")
	end
	return invoke:InvokeServer(...)
end

function module.Redeem(player, codeStr)

	assert(typeof(player) == "Instance" and player:IsA("Player"), "Invalid player")
	assert(type(codeStr) == "string", "Invalid codeStr")

	codeStr = string.lower(codeStr)

	codeStr = codeStr:gsub("^%s*(.-)%s*$", "%1")

	if codeStr == "" then
		return false, "Invalid code"
	end

	if _cache[codeStr] then
		return _cache[codeStr][1], _cache[codeStr][2]
	end

	local res = table.pack(remoteInvoke("Redeem", codeStr))

	if #res == 1 then

		return false, res[1]

	else
		_cache[codeStr] = res

		delay(60, function()
			_cache[codeStr] = nil
		end)

		if res[1] then
			task.defer(function()
				_cache[codeStr][2] = "Code has been redeemed"
			end)
		end

		return res[1], res[2]
	end
end

return module