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
-- 设置特效的打开状态
module.SetEffectEnabled = function(root, enabled, delay)
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
		elseif effect:IsA("Trail") then
			effect.Enabled = enabled
		end
	end

	if delay then
		task.delay(delay, function()
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
		task.delay(delay, function()
			effect.Enabled = not enabled
		end)
	end
end

-- 设置特效的打开状态
module.SetChildEffectEnabled = function(root, enabled, delay)
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
		task.delay(delay, function()
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

return module
