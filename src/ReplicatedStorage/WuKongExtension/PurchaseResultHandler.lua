local MarketplaceService = game:GetService("MarketplaceService")

local localPlayer = game.Players.LocalPlayer
local purchaseEvent = game.ReplicatedStorage.WuKong.PurchasedEvent
local wukong, WuKongRobloxProductHelper, container

local module = {}
local function getProductPath(productId)
	if not wukong then
		wukong = require(game.ReplicatedStorage.WuKong)
		WuKongRobloxProductHelper = require(game.ReplicatedStorage.WuKong.WuKongRobloxProductHelper)	
		container = wukong:GetContainer()
	end
	local productPath = WuKongRobloxProductHelper.GetVendorPathByRobloxId(container, productId)
	return productPath
end

function module:Wait(path)
	local res = nil

	local c1 = purchaseEvent.OnClientEvent:Connect(function(...)
		local temp = table.pack(...)
		if temp[1] == "PurchaseResult" then
			if #temp == 3 then
				local productId = temp[2]
				local productPath = getProductPath(productId)
				if string.find(path, productPath) then
					res = temp[3]
				end
			elseif #temp == 4 then
				local productPath = temp[3]
				if string.find(path, productPath) then
					res = temp[4]
				end
			end
		end
	end)

	local c2 = MarketplaceService.PromptProductPurchaseFinished:Connect(function(playerId, productId, wasPurchased)
		if playerId == localPlayer.UserId then
			local productPath = getProductPath(productId)
			print(productPath)
			if string.find(path, productPath) then
				res = wasPurchased
			end
		end
	end)

	repeat
		wait()
	until res ~= nil

	c1:Disconnect()
	c2:Disconnect()

	return res
end

function module:Connect(path, callback)
	purchaseEvent.OnClientEvent:Connect(function(...)
		local temp = table.pack(...)
		-- if temp[1] == "PurchaseResult" then
		--     if #temp == 3 then
		--         local productId = temp[2]
		--         local productPath = getProductPath(productId)
		--         if string.find(path, productPath) then
		--             pcall(callback, temp[3])
		--         end
		--     elseif #temp == 4 then
		--         local productPath = temp[3]
		--         if string.find(path, productPath) then
		--             pcall(callback, temp[4])
		--         end
		--     end
		-- end

		if temp[1] == "PurchaseResult" then
			local productId = temp[2]
			local productPath = temp[3]
			local idx = 3
			local ispath = string.find(tostring(productPath), "/")
			if not ispath then
				productPath = getProductPath(productId)
				idx = 2
			end
			if typeof(path) == "function" then
				pcall(path, productPath, temp[idx + 1], temp[idx + 2])
			else
				if string.find(path, productPath) then
					pcall(callback, temp[idx + 1], temp[idx + 2])
				end
			end
		end
	end)
end

return module
