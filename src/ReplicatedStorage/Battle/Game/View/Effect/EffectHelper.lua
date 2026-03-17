local AssetsPool = require(script.Parent.Parent.AssetsPool)
local module = {}

local playSingleEffect = function(effect)
	if effect:IsA("ParticleEmitter") then
		if effect:GetAttribute("Loop") ~= nil then
			effect.Enabled = true
			return 0
		else
			local emitCount = effect:GetAttribute("EmitCount")
			local emitDelay = effect:GetAttribute("EmitDelay")
			local particleMaxLifeTime = 0
			particleMaxLifeTime += effect.Lifetime.Max
			if emitDelay then
				particleMaxLifeTime += emitDelay
			end

			if emitCount then
				if emitDelay and emitDelay > 0 then
					task.delay(emitDelay, function()
						effect:Emit(emitCount)
					end)
				else
					effect:Emit(emitCount)
				end
			end
			return particleMaxLifeTime
		end
	end

	if effect:IsA("Beam") then
		effect.Enabled = true
	end
	return 0
end
module.PlaySingleEffect = function(effect)
	return playSingleEffect(effect)
end
local stopLoopEffect = function(effect)
	if effect:IsA("ParticleEmitter") then
		if effect:GetAttribute("Loop") ~= nil then
			effect.Enabled = false
		end
	end

	if effect:IsA("Beam") then
		effect.Enabled = false
	end
end

module.ScaleParticleSize = function(effect, scale)
	local newPoints = {}
	local originSize = effect:GetAttribute("OriginSize")
	if originSize == nil then
		effect:SetAttribute("OriginSize", effect.Size)
		originSize = effect.Size
	end
	local originSpeed = effect:GetAttribute("OriginSpeed")
	if originSpeed == nil then
		effect:SetAttribute("OriginSpeed", effect.Speed)
		originSpeed = effect.Speed
	end
	-- print(originSize)
	for k, v in ipairs(originSize.Keypoints) do
		newPoints[k] = NumberSequenceKeypoint.new(v.Time, v.Value * scale, v.Envelope * scale)
	end
	effect.Size = NumberSequence.new(newPoints)

	effect.Speed = NumberRange.new(originSpeed.Min * scale, originSpeed.Max * scale)
end

module.ScaleAttachment = function(attachment, scale)
	local originPosition = attachment:GetAttribute("OriginPosition")
	if originPosition == nil then
		attachment:SetAttribute("OriginPosition", attachment.Position)
		originPosition = attachment.Position
	end
	attachment.Position = originPosition * scale
end

module.ScaleAllParitcleSize = function(root, scale)
	if not root then
		return
	end
	for _, descend in pairs(root:GetDescendants()) do
		if descend:IsA("Attachment") then
			module.ScaleAttachment(descend, scale)
		end
		if descend:IsA("ParticleEmitter") then
			module.ScaleParticleSize(descend, scale)
		end
	end
end
module.EmitAll = function(root: Instance)
	if root == nil then
		return
	end
	local maxLifeTime = 0
	for _, descendant: Instance in root:GetDescendants() do
		local effect = descendant
		if descendant:IsA("ObjectValue") then
			effect = descendant.Value
		end

		local lifetime = playSingleEffect(effect)
		if lifetime > maxLifeTime then
			maxLifeTime = lifetime
		end
	end
	return maxLifeTime
end

module.StopAll = function(root: Instance)
	if root == nil then
		return
	end
	for _, descendant: Instance in root:GetDescendants() do
		local effect = descendant
		if descendant:IsA("ObjectValue") then
			effect = descendant.Value
		end
		stopLoopEffect(effect)
	end
end

--返回时间
module.PlayBurstEffectInPosition = function(world, state, context, effectName, cframe, size)
	if module.Enabled == false then
		return
	end
	local effect = AssetsPool.GetAsset("Effect", effectName)

	local originSize = effect:GetAttribute("originSize")
	if originSize == nil then
		local primaryPart = effect.PrimaryPart
		effect:SetAttribute("originSize", primaryPart.Size)
		originSize = primaryPart.Size
	end
	local effectSize = originSize
	local scale = 1
	if size ~= nil then
		scale = size / originSize.X
	end
	-- print("scale", scale, size, originSize.X)
	effect.PrimaryPart.Size = effectSize * scale
	-- effect.PrimaryPart.CFrame = cframe
	-- handle attachment pos

	context.View.Effect.EffectHelper.ScaleAllParitcleSize(effect, scale)
	effect:PivotTo(cframe)
	local maxLifeTime = module.EmitAll(effect)
	task.delay(maxLifeTime, function()
		AssetsPool.Return(effect)
	end)
end

module.PauseEffect = function(root)
	if root == nil then
		return
	end
	for _, descendant: Instance in root:GetDescendants() do
		local effect = descendant
		if descendant:IsA("ObjectValue") then
			effect = descendant.Value
		end

		if effect:IsA("ParticleEmitter") then
			if not effect:GetAttribute("TimeScale") then
				effect:SetAttribute("TimeScale", effect.TimeScale)
			end
			effect.TimeScale = 0
		end

		if effect:IsA("Beam") then
			if not effect:GetAttribute("TextureSpeed") then
				effect:SetAttribute("TextureSpeed", effect.TextureSpeed)
			end
			effect.TextureSpeed = 0
		end
	end
end
module.ContinueEffect = function(root)
	if root == nil then
		return
	end

	for _, descendant: Instance in root:GetDescendants() do
		local effect = descendant
		if descendant:IsA("ObjectValue") then
			effect = descendant.Value
		end

		if effect:IsA("ParticleEmitter") then
			local a = effect:GetAttribute("TimeScale")
			if a then
				effect.TimeScale = a
			end
		end

		if effect:IsA("Beam") then
			local a = effect:GetAttribute("TextureSpeed")
			if a then
				effect.TextureSpeed = a
			end
		end
	end
end
-- 返回特效本身
module.LoadEffectInPosition = function(world, state, context, effectName, cframe, size)
	if module.Enabled == false then
		return
	end
	local effect = AssetsPool.GetAsset("Effect", effectName)

	local originSize = effect:GetAttribute("originSize")
	if originSize == nil then
		local primaryPart = effect.PrimaryPart
		effect:SetAttribute("originSize", primaryPart.Size)
		originSize = primaryPart.Size
	end
	local effectSize = originSize
	local scale = 1
	if size ~= nil then
		scale = size / originSize.X
	end
	effect.PrimaryPart.Size = effectSize * scale
	context.View.Effect.EffectHelper.ScaleAllParitcleSize(effect, scale)
	effect:PivotTo(cframe)
	return effect
end
-- 设置特效的打开状态
module.SetEffectEnabled = function(world, state, context, root, enabled, delay)
	if root == nil then
		return
	end
	for _, descendant: Instance in root:GetDescendants() do
		local effect = descendant
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = enabled
		elseif effect:IsA("Beam") then
			effect.Enabled = enabled
		elseif effect:IsA("PointLight") then
			effect.Enabled = enabled
		end
	end

	if delay then
		context.BattleUtilities.Timer.Delay(world, state, context, delay, function()
			for _, descendant: Instance in root:GetDescendants() do
				local effect = descendant
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = not enabled
				elseif effect:IsA("Beam") then
					effect.Enabled = not enabled
				elseif effect:IsA("PointLight") then
					effect.Enabled = not enabled
				end
			end
		end)
	end
end
-- 设置单个特效的打开状态
module.SetSingleEffectEnabled = function(world, state, context, effect, enabled, delay)
	if effect == nil then
		return
	end
	if effect:IsA("ParticleEmitter") then
		effect.Enabled = enabled
	elseif effect:IsA("Beam") then
		effect.Enabled = enabled
	elseif effect:IsA("PointLight") then
		effect.Enabled = enabled
	elseif effect:IsA("Trail") then
		effect.Enabled = enabled
	else
		warn("wrong type" .. effect.Name)
	end

	if delay then
		context.BattleUtilities.Timer.Delay(world, state, context, delay, function()
			effect.Enabled = not enabled
		end)
	end
end
-- 设置特效的打开状态
module.SetChildEffectEnabled = function(world, state, context, root, enabled, delay)
	if root == nil then
		return
	end
	for _, child: Instance in root:GetChildren() do
		local effect = child
		if effect:IsA("ParticleEmitter") then
			effect.Enabled = enabled
		elseif effect:IsA("Beam") then
			effect.Enabled = enabled
		elseif effect:IsA("PointLight") then
			effect.Enabled = enabled
		elseif effect:IsA("Trail") then
			effect.Enabled = enabled
		end
	end

	if delay then
		context.BattleUtilities.Timer.Delay(world, state, context, delay, function()
			for _, child: Instance in root:GetChildren() do
				local effect = child
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = not enabled
				elseif effect:IsA("Beam") then
					effect.Enabled = not enabled
				elseif effect:IsA("PointLight") then
					effect.Enabled = not enabled
				elseif effect:IsA("Trail") then
					effect.Enabled = not enabled
				end
			end
		end)
	end
end
--给模型增加特效组件
module.CloneEffectInModel = function(effect, weldPart, parent)
	local returnToPool = parent
	effect.Parent = returnToPool
	local weld = effect:FindFirstChild("AttachWeld")
	if weld == nil then
		weld = Instance.new("WeldConstraint")
		weld.Name = "AttachWeld"
		weld.Parent = effect
		weld.Part0 = effect.PrimaryPart
	end

	weld.Part1 = weldPart

	if effect:GetAttribute("isEmit") then
		module.EmitAll(effect)
	end

	return effect
end

module.ReturnEffectInModel = function(effect)
	effect.AttachWeld.Part1 = nil
	AssetsPool.Return(effect)
end
module.PlayAnimeInEffect = function(world, state, context, effect, animeName, speed, delay)
	local animationController = effect:FindFirstChild("AnimationController") or effect:FindFirstChild("Humanoid")
	if not animationController then
		return
	end
	local animator = animationController:FindFirstChild("Animator")
	if not animator then
		return
	end
	local animation = animator:FindFirstChild(animeName)
	if not animation then
		return
	end
	local track = animationController:LoadAnimation(animation)

	if delay then
		context.BattleUtilities.Timer.Delay(world, state, context, delay, function()
			track:Play(0.1, 1, speed)
		end)
	else
		track:Play(0.1, 1, speed)
	end

	return track
end

-- 添加停止动画的方法
module.StopAnime = function(effect, animeName)
    if not effect then return end
    local animationController = effect:FindFirstChild("AnimationController") or effect:FindFirstChild("Humanoid")
    if not animationController then return end
    local animator = animationController:FindFirstChild("Animator")
    if not animator then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
        if not animeName or track.Name == animeName then
            track:Stop()  -- 停止动画
            track.TimePosition = 0  -- 重置时间轴到开始
            track:AdjustWeight(0)  -- 立即停止混合
        end
    end
end
export type BiggerOptions = {
	Duration: number, --变化持续时间
	StepTime: number, --变化间隔时间
	Size: number, --特效最终大小
	CFrame: Vector3, --特效播放位置
	Debris: boolean?, --变化结束后是否回收
}

module.BiggerEffectInPosition = function(world, state, context, effect, options: BiggerOptions)
	local whileTime = options.Duration
	local stepTime = options.StepTime
	local totalTime = 0
	local step = (options.Size / whileTime) * stepTime --每次循环增加的大小
	local curSize = step
	task.spawn(function()
		while totalTime < whileTime and effect do
			if not effect.Parent then
				break
			end
			local originSize = effect:GetAttribute("originSize")
			if originSize == nil then
				local primaryPart = effect.PrimaryPart
				effect:SetAttribute("originSize", primaryPart.Size)
				originSize = primaryPart.Size
			end
			local scale = curSize / originSize.X
			effect.PrimaryPart.Size = originSize * scale
			context.View.Effect.EffectHelper.ScaleAllParitcleSize(effect, scale)
			effect:PivotTo(options.CFrame)
			context.View.Effect.EffectHelper.EmitAll(effect)
			curSize = curSize + step
			totalTime = totalTime + stepTime
			task.wait(stepTime)
		end
		if options.Debris and effect and effect.Parent then
			context.View.AssetsPool.Return(effect)
		end
	end)
end

return module
