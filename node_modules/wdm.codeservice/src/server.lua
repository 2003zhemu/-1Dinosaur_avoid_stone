local RunService = game:GetService("RunService")
local WuKongServer = require(game.ReplicatedStorage.WuKong.WuKongServer)
local event = script.Parent:FindFirstChild("RemoteEvent") or Instance.new("RemoteEvent", script.Parent)
local invoke = script.Parent:FindFirstChild("RemoteFunction") or Instance.new("RemoteFunction", script.Parent)

local module = {}
local _dataProvider = nil
local CodeStore = require(script.Parent.CodeStore)

local function getData(player)
	if _dataProvider then
		return _dataProvider(player)
	end
	return nil
end

local function getRewards(player, rewards)
	local results = {}
	local facade = WuKongServer.HasFacade(player.UserId) and WuKongServer.GetFacade(player.UserId)
	if facade then
		for i, args in ipairs(rewards) do
			local pathStr = args[1]
			local pathInfo = string.split(pathStr, "?")
			if #pathInfo > 1 then
				local path = pathInfo[1]
				if facade:TryGetChild(path) then
					local suc, res = pcall(function()
						return facade:ExecuteAction(table.unpack(args))
					end)

					results[i] = {
						Success = suc,
						Result = res
					}
					continue
				end
			end
			results[i] = {
				Success = false,
				Result = "Invalid path"
			}
		end
	end
	return results
end

local _lastRedeemTimes = {}
function module.Redeem(player, codeStr)
	local data = getData(player)
	if (not data) or (not data.Data) then
		return false, "Error"
	end

	if data.Data.Code and data.Data.Code[codeStr] then
		return false, "Code has been redeemed"
	end

	_lastRedeemTimes[player.UserId] = _lastRedeemTimes[player.UserId] or 0
	if tick() - _lastRedeemTimes[player.UserId] < 10 then
		local leftTime = 10 - (tick() - _lastRedeemTimes[player.UserId])
		return "Please try again in " .. math.ceil(leftTime) .. " seconds"
	end

	_lastRedeemTimes[player.UserId] = tick()

	local codeInfo = CodeStore.Get(codeStr)
	if not codeInfo then
		return false, "Invalid code"
	end

	local deadline = codeInfo.Deadline or codeInfo.DeadLine
	if deadline and deadline < os.time() then
		return false, "Code has expired"
	end

	local count = codeInfo.Count

    
	local suc = false
    if count ~= -1 and not RunService:IsStudio() then
        suc = CodeStore.Use(codeStr)
    else
        suc = true
    end

	if suc then
		local rewards = codeInfo.Awards
		if rewards then
			local res = getRewards(player, rewards)

			data.Data.Code = data.Data.Code or {}

			data.Data.Code[codeStr] = {
				Time = os.time(),
				Results = res
			}

			local des = codeInfo.Description or ""
			return true, des
		end
	end
end

function module.SetDataProvider(dataProvider)
	_dataProvider = dataProvider
end

invoke.OnServerInvoke = function(player, ...)
	local args = {...}
	local funcName = table.remove(args, 1)
	local func = module[funcName]
	if func then
		return func(player, table.unpack(args))
	end
end

game.Players.PlayerRemoving:Connect(function(player)
	_lastRedeemTimes[player.UserId] = nil
end)

return module