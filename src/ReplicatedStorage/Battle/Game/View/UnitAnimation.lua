local module = {}
--缓存单位动作的ainmationtrack,key 是model
local moduleAnimTrackCache = {}
local initAnimationTrackPriority = function(animationName, track)
	if animationName == "Idle" then
		track.Priority = Enum.AnimationPriority.Idle
	elseif animationName == "Move" then
		track.Priority = Enum.AnimationPriority.Movement
	else
		track.Priority = Enum.AnimationPriority.Action
	end
end
module.TryInitAnimation = function(model)
	-- print("Try init animation")
	if moduleAnimTrackCache[model] then
		module.StopAllTrack()
		local trackCache = moduleAnimTrackCache[model]
		local trackInfo: AnimationTrack = trackCache.Tracks["Idle"]
		if trackInfo then
			trackInfo.Track:Play(0.1, 1, 1)
		end
		return
	end
	moduleAnimTrackCache[model] = {
		LastName = nil,
		Tracks = {},
	}
	local AnimationController = model:FindFirstChild("AnimationController")
	if AnimationController == nil then
		return
	end
	local animator: Animator = AnimationController:FindFirstChild("Animator")
	if animator == nil then
		return
	end
	local trackCache = moduleAnimTrackCache[model]

	local animations = animator:GetChildren()
	for _, animation in animations do
		if animation:IsA("Folder") then
			local trackInfo = {}
			-- animInfo.Random=false
			trackInfo.SubTracks = {}
			trackInfo.SubIndex = 1
			local childCount = #animation:GetChildren()
			for i = 1, childCount, 1 do
				-- print("SubAnima", i)
				local subAnimation = animation:FindFirstChild(tostring(i))
				if subAnimation == nil then
					warn("animation folder not order subIndex name", model.Name)
					continue
				end
				if subAnimation.AnimationId == "" then
					warn(model.name, subAnimation.Name, "animationId is Empty")
				end
				local subtrack = animator:LoadAnimation(subAnimation)
				initAnimationTrackPriority(animation.Name, subtrack)
				table.insert(trackInfo.SubTracks, subtrack)
			end
			-- for _, subAnimation in animation:GetChildren() do
			-- 	if subAnimation.AnimationId == "" then
			-- 		warn(model.name, subAnimation.Name, "animationId is Empty")
			-- 	end
			-- 	local subtrack = animator:LoadAnimation(subAnimation)
			-- 	initAnimationTrackPriority(animation.Name, subtrack)
			-- 	table.insert(trackInfo.SubTracks, subtrack)
			-- end
			if #trackInfo.SubTracks == 0 then
				warn("animfolder is empty")
			end
			trackCache.Tracks[animation.Name] = trackInfo
		else
			if animation.AnimationId == "" then
				warn(model.name, animation.Name, "animationId is Empty")
			end
			local track = animator:LoadAnimation(animation)
			initAnimationTrackPriority(animation.Name, track)
			trackCache.Tracks[animation.Name] = { Track = track }
		end
	end
	-- module.PlayInnerAnimation(model, "Idle", 1, 1)
	local track: AnimationTrack = trackCache.Tracks["Idle"].Track
	if track then
		-- print("Play Idle")
		track:Play(0.1, 1, 1)
	end
end

module.PlayInnerAnimation = function(model, animationName, speed, weight, fade)
	fade = fade or 0.1
	-- TODO: UseHook
	if not moduleAnimTrackCache[model] then
		return
	end
	local trackCache = moduleAnimTrackCache[model]
	local curTrackInfo = trackCache.Tracks[animationName]
	if curTrackInfo == nil then
		return
	end
	local lastSubTrackIndex = nil
	if trackCache.LastName then
		local lastTrackInfo = trackCache.Tracks[trackCache.LastName]
		if lastTrackInfo.SubTracks then
			lastSubTrackIndex = lastTrackInfo.SubIndex
		end
	end
	local track: AnimationTrack
	if curTrackInfo.SubTracks ~= nil then
		if curTrackInfo.LastTime == nil or (curTrackInfo.LastTime + 2/speed < os.clock()) then
			curTrackInfo.SubIndex = 1
		else
			curTrackInfo.SubIndex += 1
		end
		curTrackInfo.LastTime = os.clock()
		if curTrackInfo.SubIndex > #curTrackInfo.SubTracks then
			curTrackInfo.SubIndex = 1
		end
		track = curTrackInfo.SubTracks[curTrackInfo.SubIndex]
	else
		track = trackCache.Tracks[animationName].Track
	end
	if track == nil then
		return
	end

	if trackCache.LastName then
		--Action级别的动画会停止上一个动画
		if track.Priority.Value >= Enum.AnimationPriority.Action.Value then
			local moveTrack = trackCache.Tracks["Move"]
			if moveTrack ~= nil and moveTrack.IsPlaying then
				moveTrack:Stop()
			end

			local lastTrackInfo = trackCache.Tracks[trackCache.LastName]

			if lastTrackInfo.SubTracks then
				--如果当前动作不是子动作，则停止当前subindex子动作，否则停止上一个动作的子动作
				assert(lastSubTrackIndex ~= nil, "lastSubTrackIndex must not be nil here")
				-- local lastSubTrackIndex = lastSubTrackIndex or lastTrackInfo.SubIndex
				if lastTrackInfo.SubTracks[lastSubTrackIndex].IsPlaying then
					lastTrackInfo.SubTracks[lastSubTrackIndex]:Stop()
				end
			else
				if lastTrackInfo.Track.IsPlaying then
					lastTrackInfo.Track:Stop()
				end
			end
		else
			--action一下的级别理论上基本是循环动作,正在播放的不重新播放
			if animationName == trackCache.LastName and track.IsPlaying then
				return
			end
		end
	end

	track:Play(0.1, weight or 1, speed)

	trackCache.LastName = animationName
	return track
end

module.StopAnimation = function(model, animationName)
	if not moduleAnimTrackCache[model] then
		return
	end
	local trackCache = moduleAnimTrackCache[model]
	local trackInfo = trackCache.Tracks[animationName]
	if trackInfo == nil then
		return
	end
	if trackInfo.SubTracks then
		trackInfo.SubTracks[trackInfo.SubIndex]:Stop()
	else
		trackInfo.Track:Stop()
	end
	if trackCache.LastName == animationName then
		trackCache.LastName = nil
	end
end
module.GetTrackInfo = function(model)
	return moduleAnimTrackCache[model]
end

module.StopAllTrack = function(model)
	if moduleAnimTrackCache[model] then
		local trackCache = moduleAnimTrackCache[model]
		for _, trackInfo in pairs(trackCache.Tracks) do
			if trackInfo.SubTracks then
				trackInfo.SubTracks[trackInfo.SubIndex]:Stop()
			else
				trackInfo.Track:Stop()
			end
		end
		return
	end
end

return module
