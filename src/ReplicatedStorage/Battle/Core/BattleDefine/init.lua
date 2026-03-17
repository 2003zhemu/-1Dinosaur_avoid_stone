--TODO: 所有枚举都迁移到这里来
local module = {}

module.MoveCapability = {
	NoMove = 0,
	Ground = 1,
	Fly = 2,
}
table.freeze(module.MoveCapability)

module.AttackCapability = {
	NoAttack = 0,
	Melee = 1,
	Range = 2,
	OnlyBuilding = 4, -- 只能攻击建筑
}
table.freeze(module.AttackCapability)

--单位类型 每个游戏可能不同
module.UnitType = {
	Basic = 1, --基础单位，玩家创建的
	Building = 2, --建筑
}
table.freeze(module.UnitType)

--目标类型 和单位类型相关
module.UnitTargetType = {
	Basic = 1, --基础单位
	Building = 2, --建筑
}
module.UnitTargetType.All = bit32.bor(module.UnitTargetType.Basic, module.UnitTargetType.Building)
-- print("=====", module.All)
-- print("=====%", 1 | 2)
table.freeze(module.UnitTargetType)

-- 目标标记 机制类型的过滤
module.UnitTargetFlag = {
	Ground = 1, --地面单位
	Sky = 2, --空中单位
	Titan = 4, --taitan
	UnSelectable = 8 --不能被选中的单位
	-- Melee = 4, --近战
	-- Range = 8, --远程
}
table.freeze(module.UnitTargetFlag)

module.ZoneType = {
	Ground = 1,
	Sky = 2,
}
table.freeze(module.ZoneType)

module.DamageCategoryType = {
	Attack = 1,
	Skill = 2,
}
table.freeze(module.DamageCategoryType)

export type DamageTable = {
	Attacker: number,
	Target: number,
	Damage: number?,
	OriginalDamage: number?,
	SkipCooldown: boolean?,
	Ranged: boolean?,
	DamageCategory: number?, --DamageCategoryType
}

module.EffectType = {
	AssetFixedPos = 1, --{CFrame}
	Composite = 2, --{CFrame,OtherInfo}
	Attach = 3,
}
table.freeze(module.EffectType)

module.BattleSignal = require(script.BattleSignal)

table.freeze(module)
return module
