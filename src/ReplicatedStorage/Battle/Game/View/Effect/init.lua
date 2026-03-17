--TODO: 处理特效提前中止播放的逻辑

local Rewire = require(game.ReplicatedStorage.Battle.Packages.rewire)
local hotReloader = Rewire.HotReloader.new()
local module = {}
module.Enabled = true

local compositeEffectCache = {}

for _, descendant in pairs(script.Composite:GetDescendants()) do
	if descendant:IsA("ModuleScript") then
		compositeEffectCache[descendant.Name] = require(descendant)
		hotReloader:listen(descendant, function(newModule)
			local ok, effect = pcall(require, newModule)
			if not ok then
				warn("Error when hot-reloading buff", newModule.Name)
				return
			end
			compositeEffectCache[descendant.Name] = effect
		end, function(_, context)
			if context.isReloading then
				return
			end
			local originalModule = context.originalModule
			compositeEffectCache[originalModule.Name] = nil
		end)
	end
end

module.EffectHelper = require(script.EffectHelper)

-- EffectType 1 assetEffect纯资源位置特效   2 composite 复杂特效  3 绑定特效
module.PlayEffect = function(world, state, context, EffectName, EffectType, EffectInfo, effectSound)
	if EffectType == 1 then
		module.EffectHelper.PlayBurstEffectInPosition(
			world,
			state,
			context,
			EffectName,
			EffectInfo.CFrame,
			EffectInfo.Size
		)
	elseif EffectType == 2 then
		task.spawn(function()
			compositeEffectCache[EffectName](world, state, context, EffectInfo)
		end)
	end

	if effectSound then
		context.AudioManager:PlaySoundEffectAtPosition(effectSound, EffectInfo.CFrame.Position)
	end
end

return module
