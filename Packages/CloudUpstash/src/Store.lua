local HttpService = game:GetService("HttpService")
local Interface = require(script.Parent.Interface)

type ICloudUpstashStore = Interface.ICloudUpstashStore

local Store = {}
Store.__index = Store

function Store.new(endpoint: string, pass: string): ICloudUpstashStore
	local self = setmetatable({}, Store)
	self._endpoint = endpoint
	self._pass = pass
	return self
end

function Store:SetAsync(key: number | string, value: {})
	local url = string.format("%s/set/%s", self._endpoint, tostring(key))
	local headers = {
		["Authorization"] = "Bearer " .. self._pass,
		["Content-Type"] = "application/json",
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = headers,
			Body = HttpService:JSONEncode(value),
		})
	end)

	if not success then
		error("Failed to set data: " .. tostring(response))
		return tostring(response)
	end

	if response.StatusCode ~= 200 then
		error("Failed to set data. Status: " .. response.StatusCode)
		return tostring(response.StatusCode)
	end
end

function Store:GetAsync(key: number | string): {}
	local url = string.format("%s/get/%s", self._endpoint, tostring(key))
	local headers = {
		["Authorization"] = "Bearer " .. self._pass,
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers,
		})
	end)

	if not success then
		error("Failed to get data: " .. tostring(response))
		return tostring(response)
	end

	if response.StatusCode ~= 200 then
		error("Failed to get data. Status: " .. response.StatusCode)
		return tostring(response.StatusCode)
	end

	return HttpService:JSONDecode(response.Body)
end

return Store
