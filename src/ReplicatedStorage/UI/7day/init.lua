local wukong = require(game.ReplicatedStorage.WuKong)
local module = {}
local EventBus = require(game.ReplicatedStorage.Packages.EventBus)
local Alert = require(game.ReplicatedStorage.Packages.Neza.Alert)

function module:Load() end

function module:Start() end

--7day函数

function module:ClickBtn(args, day)
	local list = self.AttendanceState:GetDailyRewardList()
	local days = 0
	local count = 0
	for i = 1, 7 do
		if list[i]["MoreInfo"]["CanGet"] then
			days = tonumber(i)
			count += 1
		end
	end
	self.AttendanceState.ClaimCount = count
	self.AttendanceState.RewardDay = days
	if args == "Attendance" then
		if self.AttendanceState:VerifyCanGet() then
			local suc, res = pcall(function()
				return wukong:ExecuteAction(
					"/活动/每日登录奖励/领取每日登录奖励?购买",
					"__null__",
					"__null__"
				)
			end)
			if suc and res then
				-- if day == 2 or day == 7 then
				-- 	EventBus.FireServer("7dayawrad", day)
				-- end
			--	warn(res)
				local type = res.Receive[day].Id
				local count = res.Receive[day].Count
				if type == "经验" then
					Alert.Success("Congrats! You gained " .. count .. " Speed!")
				elseif type == "奖杯" then
					Alert.Success("Congrats! You gained " .. count .. " Wins!")
				end
				-- warn(day)
				-- Alert.Success("Congrats! You gained " .. data.value .. " Speed!")

				self.AttendanceState.Panel = 2
				self.AttendanceState.RefreshDaliyFrame = not self.AttendanceState.RefreshDaliyFrame
				self.AttendanceState.OpenDailyFrame = false
				return true
			end
		end
	end
end
--End

function module:CheckSlotpostion()
	-- return game.Players.LocalPlayer:GetAttribute("BackPackFull") > 0
end

function module:ClaimReward(i)
	local list = self.OnlineState:GetList()
	local v = list[i]
	if v.MoreInfo.IsGet then
		Alert.Info("The reward has been claimed!")
	else
		if v.MoreInfo.CanGet then
			self.OnlineState.RewardShow = true
		else
			Alert.Info("Cannot be obtained before the bonus time!")
		end
	end
end

function module:SubmitCode()
	self.Panel.Submited = true
end

function module:OnOpen()
	--每日签到的状态开始
	self.AttendanceState.UpdatePanel = not self.AttendanceState.UpdatePanel
	self.AttendanceState.RefreshDaliyFrame = not self.AttendanceState.RefreshDaliyFrame
	--每日签到的状态结束
end

function module:OnClose()
	--每日签到的状态开始
	self.AttendanceState.RefreshDaliyFrame = not self.AttendanceState.RefreshDaliyFrame
	--每日签到的状态结束
end

return module
