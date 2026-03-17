--[=[
	@class ServerService
	@server
		服务器服务模块, 只能用script脚本require
	https://create.roblox.com/docs/cloud-services/memory-stores/observability#identifying-peak-times-and-performance-bottlenecks
]=]
local ServerService = {}

local MAP_PREFIX = "V." .. game.PlaceVersion .. "."
local MAP_NAME = MAP_PREFIX .. "PrimaryServer"
local CURRENT_ID = nil
local UPDATE_DURATION = 10
local SERVER_CREATE_TIME = tick()
local SERVER_ID = nil

local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")
local PrimaryServerMap = MemoryStoreService:GetSortedMap(MAP_NAME)

local function update()
	coroutine.wrap(function()
		
		pcall(function()
			PrimaryServerMap:SetAsync(SERVER_ID, SERVER_CREATE_TIME, UPDATE_DURATION + 1, SERVER_CREATE_TIME)
		end)

		pcall(function()
			local jobIds = PrimaryServerMap:GetRangeAsync(Enum.SortDirection.Ascending, 1)
			if jobIds and #jobIds > 0 then
				CURRENT_ID = jobIds[1].key
			end
		end)

		wait(UPDATE_DURATION)
		
		update()
	end)()
end

if not RunService:IsStudio() then

	SERVER_ID = game.JobId

	update()

	game:BindToClose(function()
		local suc
		repeat
			suc = pcall(function()
				PrimaryServerMap:RemoveAsync(SERVER_ID)
			end)
			wait(.1)
		until suc
	end)
end

--[=[
	@server
	@within ServerService
	@function IsPrimaryServer
	@return boolean -- 本服务器是否为主服务器(studio 返回true)
]=]
function ServerService.IsPrimaryServer(): boolean
	return CURRENT_ID == SERVER_ID
end

return ServerService