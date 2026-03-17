local BattleDefine = require(game.ReplicatedStorage.Battle.Core.BattleDefine)
local tween = game:GetService("TweenService")
local EntityOrientationBand = 0b1111_1111_1111_1111
local module = {}

local HandleTransformSync = function(world, state, context, syncDatas)
	-- print("HandleTransformSync")
	for _, transformInfo in syncDatas do
		local entityId = transformInfo[1]
		-- print("transformInfo", transformInfo)
		if not world:contains(entityId) then
			-- print("not containd", entityId)
			continue
		end
		local compressedCframe = transformInfo[2]

		if compressedCframe then
			-- print("insertCframe")
			local orientationY = compressedCframe.X
			local x = compressedCframe.Y / 10
			local y = compressedCframe.Z / 10
			local cframe = CFrame.new(x, 0, y)
				* (CFrame.fromOrientation(0, ((orientationY / EntityOrientationBand) * 2 - 1) * math.pi, 0))
			world:insert(entityId, context.Components.Transform({ CFrame = cframe }))
		else
			world:remove(entityId, context.Components.Transform)
		end
	end
end

local TweenService = game:GetService("TweenService")
local tweenList = {}
local eventbus = require(game.ReplicatedStorage.Packages.EventBus)
local GetRewardGui = function(context, type, num)
	local character = game.Players.LocalPlayer.Character

	if not character:FindFirstChild("GetCoinGui") then
		local gui = context.View.AssetsPool.GetAsset("Projectile", "GetCoinGui")
		gui.Parent = character
		gui.Adornee = character.PrimaryPart
	end
	if not character:FindFirstChild("GetTreasureGui") then
		local gui = context.View.AssetsPool.GetAsset("Projectile", "GetTreasureGui")
		gui.Parent = character
		gui.Adornee = character.Head

		local effect = context.View.AssetsPool.GetAsset("Projectile", "TreasureEffect")

		for i, v in effect:GetChildren() do
			v.Parent = character.Head
		end
	end
	eventbus.FireServer("PlayerGetBattleReawrd", type, num)
	if type == "Coin" then
		if tweenList[1] and tweenList[1]:IsPlaying() then
			tweenList[1]:Cancel()
		end
		if tweenList[2] and tweenList[2]:IsPlaying() then
			tweenList[2]:Cancel()
		end
		if tweenList[3] and tweenList[3]:IsPlaying() then
			tweenList[3]:Cancel()
		end
		if tweenList[4] and tweenList[4]:IsPlaying() then
			tweenList[4]:Cancel()
		end
		local gui = character:FindFirstChild("GetCoinGui")

		if gui.Frame.ImageLabel.ImageTransparency == 1 then
			gui.Frame.TextLabel:SetAttribute("Num", 0)
		end
		num = gui.Frame.TextLabel:GetAttribute("Num") + num
		gui.Frame.TextLabel:SetAttribute("Num", num)
		gui.Frame.TextLabel.Text = num

		gui.Size = UDim2.new(0, 200, 0, 50)
		gui.StudsOffset = Vector3.new(0, 0, 0)
		gui.Frame.ImageLabel.ImageTransparency = 0
		gui.Frame.TextLabel.TextTransparency = 0

		local tweeninfo1 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
		local tweeninfo2 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local tweeninfo3 = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		tweenList[1] = TweenService:Create(gui, tweeninfo1, { Size = UDim2.new(0, 150, 0, 37.5) }):Play()
		tweenList[2] = TweenService:Create(gui, tweeninfo2, { StudsOffset = Vector3.new(0, 2, 0) }):Play()
		tweenList[3] = TweenService:Create(gui.Frame.ImageLabel, tweeninfo3, { ImageTransparency = 1 }):Play()
		tweenList[4] = TweenService:Create(gui.Frame.TextLabel, tweeninfo3, { TextTransparency = 1 }):Play()
	elseif type == "Treasure" then
		if tweenList[5] and tweenList[5]:IsPlaying() then
			tweenList[5]:Cancel()
		end

		if tweenList[6] and tweenList[6]:IsPlaying() then
			tweenList[6]:Cancel()
		end

		if tweenList[7] and tweenList[7]:IsPlaying() then
			tweenList[7]:Cancel()
		end
		local gui = character:FindFirstChild("GetTreasureGui")
		gui.Frame.ImageLabel.Size = UDim2.new(0, 0, 0, 0)
		gui.Frame.ImageLabel.ImageTransparency = 0
		gui.Frame.ImageLabel.Rotation = -10

		local tweeninfo1 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
		local tweeninfo2 = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local tweeninfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, -1, true, 0)

		for i, v in character.Head[2]:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				v:Emit()
			end
		end
		tweenList[5] = TweenService:Create(gui.Frame.ImageLabel, tweeninfo1, { Size = UDim2.new(1, 0, 1, 0) }):Play()
		tweenList[6] = TweenService:Create(gui.Frame.ImageLabel, tweeninfo2, { ImageTransparency = 1 }):Play()
		tweenList[7] = TweenService:Create(gui.Frame.ImageLabel, tweeninfo3, { Rotation = 10 }):Play()
	end

	if type == "Coin" then
		context.AudioManager:PlaySoundEffect("战斗_奖励掉落_拾取金币")
	elseif type == "Treasure" then
		context.AudioManager:PlaySoundEffect("战斗_奖励掉落_拾取宝箱")
	end
end

local HandleGetReward = function(world, state, context, coin, Pos)
	task.spawn(function()
		local startPosition = Pos
		-- local lastPositon=startPosition
		local targetPart = game.Players.LocalPlayer.Character.PrimaryPart
		local targetPosition = targetPart.CFrame.Position

		local distance = (startPosition - targetPosition).Magnitude
		local flytime = math.min(distance / 100, 2)
		flytime = math.max(flytime, 0.5)
		local startTime = os.clock()
		local endTime = startTime + flytime
		while os.clock() < endTime do
			targetPosition = targetPart.Parent.Parent == nil and targetPosition or targetPart.CFrame.Position
			local currentPositon = startPosition:Lerp(targetPosition, (os.clock() - startTime) / flytime)
			coin.CFrame = CFrame.new(currentPositon)
			task.wait()
		end
		targetPosition = targetPart.Parent.Parent == nil and targetPosition or targetPart.CFrame.Position
		coin.CFrame = CFrame.new(targetPosition)
		task.wait()
		GetRewardGui(context, coin:GetAttribute("Type"), coin:GetAttribute("Num"))
		context.View.AssetsPool.Return(coin)
	end)
end

local function CoinJump(
	world,
	state,
	context,
	coin: Part,
	jumpY: number,
	jumpTime: number,
	jumpX: number,
	jumpZ: number
)
	local jumpTween = TweenService:Create(
		coin,
		TweenInfo.new(jumpTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{ Position = coin.Position + Vector3.new(jumpX / 2, jumpY, jumpZ / 2) }
	)
	jumpTween:Play()
	jumpTween.Completed:Connect(function()
		local fallTween = TweenService:Create(
			coin,
			TweenInfo.new(1.5 * jumpTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0),
			{ Position = coin.Position - Vector3.new(-jumpX / 2, jumpY, -jumpZ / 2) }
		)
		fallTween:Play()
		fallTween.Completed:Connect(function()
			jumpY = jumpY / 6
			jumpX = jumpX / 6
			jumpZ = jumpZ / 6

			jumpTime = jumpTime / 2.4
			if jumpY > 0.1 then
				CoinJump(world, state, context, coin, jumpY, jumpTime, jumpX, jumpZ)
			else
				HandleGetReward(world, state, context, coin, coin.Position)
			end
		end)
	end)
end

local HandleSpawnReward = function(world, state, context, patch)
	if patch.UserId ~= game.Players.LocalPlayer.UserId then
		return
	end
	task.spawn(function()
		context.Helper.DropRewardHelper:generateReward(world, state, context, patch)
		--随机num个数，使得这num个数的和为TotalNum
		local res = {}
		local t = {}
		if patch.Num == 1 then
			res[1] = patch.Count
		else
			if patch.Type == "Coin" then
				for i = 1, patch.Num - 1 do
					local num = patch.Count - patch.Num + 1
					if num < 1 then
						num = 1
					end
					t[i] = math.random(1, num)
				end
				table.sort(t)
				res[1] = t[1]
				for i = 2, patch.Num - 1 do
					res[i] = t[i] - t[i - 1]
				end
				res[patch.Num] = patch.Count - t[patch.Num - 1]
			else
				for i = 1, patch.Num do
					res[i] = 1
				end
			end
		end

		for i = 1, patch.Num do
			wait()
			local coin = context.View.AssetsPool.GetAsset("Projectile", patch.Type)
			if patch.Type == "Coin" then
				if res[i] < 100 then
					coin.BillboardGui.Frame[1].Visible = true
					coin.BillboardGui.Frame[2].Visible = false
					coin.BillboardGui.Frame[3].Visible = false
				elseif res[i] > 500 then
					coin.BillboardGui.Frame[1].Visible = false
					coin.BillboardGui.Frame[2].Visible = false
					coin.BillboardGui.Frame[3].Visible = true
				else
					coin.BillboardGui.Frame[1].Visible = false
					coin.BillboardGui.Frame[2].Visible = true
					coin.BillboardGui.Frame[3].Visible = false
				end
			end

			coin.CFrame = CFrame.new(patch.Pos)
			coin:SetAttribute("Type", patch.Type)
			coin:SetAttribute("Num", res[i])

			local jumpY = math.random(400, 800) / 100
			local jumpX = math.random(-500, 500) / 100
			local jumpZ = math.random(-500, 500) / 100
			local jumpTime = (math.sqrt(jumpY / 8)) * 0.25
			CoinJump(world, state, context, coin, jumpY, jumpTime, jumpX, jumpZ)
		end
	end)
end

local HandlePopup = function(world, state, context, payload)
	if payload.UserId == game.Players.LocalPlayer.UserId then
		context.PopupText[payload.PopType](payload.PopText)
	end
end
local Handles = {}
Handles[BattleDefine.BattleSignal.SyncTransform] = HandleTransformSync
Handles[BattleDefine.BattleSignal.SpawnReward] = HandleSpawnReward
Handles[BattleDefine.BattleSignal.PopupText] = HandlePopup

module.Handles = Handles
return module
