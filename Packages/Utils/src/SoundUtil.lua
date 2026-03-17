local LocRandom = Random.new(tick())

local module = {}

module.BgSound =nil

local function GetSoundInstance(soundConfig:{})
	local sound = Instance.new("Sound")
	--
	for key, val in pairs(soundConfig) do
		sound[key] = val
	end
	sound.Parent = game.SoundService

	return sound
end

--播放音乐
module.PlaySound = function(soundConfig:{})
	local sound = GetSoundInstance(soundConfig)

	sound.TimePosition = 0
	sound.Playing = true
	
end


--播放背景音乐
module.PlayBgSound =function(BgSoundIdArr:{})
	if module.BgSound then return end

	local sound = Instance.new("Sound")
	sound.Name = "BGSound"
	sound.Looped = false
	sound.Volume = 0.5
	sound.SoundId = BgSoundIdArr[LocRandom:NextInteger(1,#BgSoundIdArr)]
	sound.Parent = game.SoundService
	sound.Ended:Connect(function()
		sound.SoundId = BgSoundIdArr[LocRandom:NextInteger(1,#BgSoundIdArr)]

		sound.TimePosition = 0
		sound.Playing = true
	end)
	module.BgSound = sound

	sound.TimePosition = 0
	sound.Playing = true

end

return module
