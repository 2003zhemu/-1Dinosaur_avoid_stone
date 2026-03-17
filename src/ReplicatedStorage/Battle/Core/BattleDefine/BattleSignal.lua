local BattleSignal = {}

BattleSignal.PreAttack = 1 --{casterId,targetId}
BattleSignal.PerformAttack = 2 --{casterId,targetId}
BattleSignal.AttackLanded = 3 --{casterId,targetId}
BattleSignal.SpellStart = 4 --{casterId,targetInfo}  单位开始放技能，传递给客户端播放一些特效
BattleSignal.SyncTransform = 5 --单机模式不会发送这个事件
BattleSignal.FixedTimeBullet = 6 --发送定子弹效果
BattleSignal.Effect = 7 --播放特效
BattleSignal.ChannelFinish = 8 --{casterId,targetInfo}   单位释放持续施法技能
BattleSignal.PreSkill = 9
BattleSignal.Damage = 10
BattleSignal.Heal = 11
BattleSignal.SpawnReward = 12
BattleSignal.BuffStackChanged = 13
BattleSignal.UnitRemove = 14
BattleSignal.WeaponControl = 15
BattleSignal.PopupText = 16 --
BattleSignal.StopAnimation = 17
table.freeze(BattleSignal)

return BattleSignal
