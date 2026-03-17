local config = {
    ["棒球棍"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 30, --击飞距离
        Hight = 10, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = false,
        HasAccessory = false,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true
    },
    ["普通马桶塞"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 33, --击飞距离
        Hight = 11, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = false,
        HasAccessory = false,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true
    },
    ["尖刺马桶栓"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 36, --击飞距离
        Hight = 12, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = false,
        HasAccessory = false,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true
    },
    ["黄金圣剑"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 39, --击飞距离
        Hight = 13, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = false,
        HasAccessory = false,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true
    },
    ["时钟拳套"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 42, --击飞距离
        Hight = 14, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = true,
        HasAccessory = true,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true
    },
    ["铁镐"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 45, --击飞距离
        Hight = 15, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = false,
        HasAccessory = false,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true,
        SetEffect = {Distance = 3}
    },
    ["圆锯"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 48, --击飞距离
        Hight = 16, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = false,
        HasAccessory = false,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true
    },
    ["能量刀片"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 51, --击飞距离
        Hight = 17, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = false,
        HasAccessory = false,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true,
        SetEffect = {Distance = 4}
    },
    ["铅笔拳套"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 54, --击飞距离
        Hight = 18, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = true,
        HasAccessory = true,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true,
        SetEffect = {Distance = 3}
    },
    ["音箱镰刀"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 57, --击飞距离
        Hight = 19, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = false,
        HasAccessory = false,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true,
        SetEffect = {Distance = 7}
    },
    ["音箱十字架"] = {
        ColdTime = 1,--冷却时间
        Damage = 40,  --对炮台的伤害
        Distance = 60, --击飞距离
        Hight = 20, --击飞高度
        Duration = 3, --布娃娃持续时间
        CloseIdle = true,
        HasAccessory = true,
        AttackSoundName = "Attack",
        AttackAnimateName = "Attack",
        FlyAway = true
    },
    ["时停手枪"] = {
        ColdTime = 5, --冷却时间
        Damage = 40,  --对炮台的伤害
        MaxDistance = 200,  --子弹最大飞行距离
        Speed = 150, --子弹飞行速度
        HitType = "Touched", --目标检测方式   Touched 碰撞检测  Ray 射线检测
        BulletName = "时停枪子弹", --子弹名称
        AttackSoundName = "Attack", --攻击音效
        AttackAnimateName = "Attack", --攻击动画
        CloseIdle = true, --是否关闭默认音效
        HasAccessory = true --是否有饰品
    },
    ["套索枪"] = {
        ColdTime = 20, --冷却时间
        Damage = 40,  --对炮台的伤害
        MaxDistance = 200,  --子弹最大飞行距离
        Speed = 150, --子弹飞行速度
        Duration = 10, --被控制时间
        HitType = "Touched", --目标检测方式   Touched 碰撞检测  Ray 射线检测
        BulletName = "套索枪子弹", --子弹名称
        AttackSoundName = "Attack", --攻击音效
        AttackAnimateName = "Attack", --攻击动画
        CloseIdle = true, --是否关闭默认音效
        HasAccessory = true, --是否有饰品
    },
    ["女巫扫把"] = {
        ColdTime = 1,--冷却时间
        --Damage = 40,  --对炮台的伤害
       -- Distance = 42, --击飞距离
       -- Hight = 14, --击飞高度
        --Duration = 3, --布娃娃持续时间
        CloseIdle = true,
        HasAccessory = true,
        AttackSoundName = "Attack",                                                                                                               AttackAnimateName = "Attack",
       -- FlyAway = true
    },
    ["喷气背包1"] = {
        ColdTime = 5,--冷却时间
        TweenTime = 0.3,
        Distance = 30, --击飞距离
        CloseIdle = true,
        HasAccessory = true,
        AttackSoundName = "Attack",                                                                                                              AttackAnimateName = "Attack"
    },
    ["喷气背包2"] = {
        ColdTime = 8,--冷却时间
        TweenTime = 0.3,
        Distance = 50, --击飞距离
        CloseIdle = true,
        HasAccessory = true,
        AttackSoundName = "Attack",                                                                                                               AttackAnimateName = "Attack"
    },
    ["喷气背包3"] = {
        ColdTime = 10,--冷却时间
        TweenTime = 0.3,
        Distance = 70, --击飞距离
        CloseIdle = true,
        HasAccessory = true,
        AttackSoundName = "Attack",                                                                                                               AttackAnimateName = "Attack"
    },
    ["稻草人法杖"] = {
        ColdTime = 6,--冷却时间
        Speed = 10, --移动速度
        Duration = 2, --被控制时间
        ReturnTime = 5, --区域存在时间
        CloseIdle = true,
        HasAccessory = true,
        AttackSoundName = "Attack",                                                                                                               AttackAnimateName = "Attack"
    },
    ["彩蛋枪"] = {
        ColdTime = 7, --冷却时间
        Damage = 40,  --对炮台的伤害
        MaxDistance = 200,  --子弹最大飞行距离
        Speed = 150, --子弹飞行速度
        HitType = "Touched", --目标检测方式   Touched 碰撞检测  Ray 射线检测
        BulletName = "彩弹枪子弹", --子弹名称
        AttackSoundName = "Attack", --攻击音效
        AttackAnimateName = "Attack", --攻击动画
        CloseIdle = true, --是否关闭默认音效
        HasAccessory = true, --是否有饰品
        --NoHitCheck = true  --测试
    },
}

return config