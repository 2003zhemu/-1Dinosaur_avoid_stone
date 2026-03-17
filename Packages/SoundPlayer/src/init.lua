local soundconfig =require(game.ReplicatedStorage.Configs.SoundConfig) 

local soundUtil =require(game.ReplicatedStorage.Packages.Utils.SoundUtil)

local module = {}

module.SoundDataConfig=soundconfig.soundData
module.BgSoundDataConfig=soundconfig.BgSoundIdArr



local function _getConfig(name:string)
	local data = module.SoundDataConfig[name]
	if data then
		return data
	else
		print("声音名称配置错误")
		return nil
	end
end


module.AddSoundConfig = function(configs:{[string]:{}})
	module.SoundDataConfig=soundconfig.soundData
	module.BgSoundDataConfig=soundconfig.BgSoundIdArr
end

module.PlaySound = function(name:string)
	local cfg = _getConfig(name)
	if cfg then
		
		soundUtil.PlaySound(cfg)
		
	end
end

module.PlayBgSound = function(name:string)
	soundUtil.PlayBgSound(module.BgSoundDataConfig)
end



return module
