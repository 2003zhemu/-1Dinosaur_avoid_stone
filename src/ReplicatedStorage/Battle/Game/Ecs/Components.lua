local merger = require(game.ReplicatedStorage.Battle.Packages.MatterExtension.ComponentsMerger)
local module: { [string]: merger.ComponentConfig } = {
	--View
	Model = { Sync = false, Default = { Model = nil } },
	ServerModel = { Sync = true, Default = { Model = nil,PurchasedUnit = false } },
	Player = { Sync = true, Default = {} },
	Monster = { Sync = false, Default = {} },  --怪物标识
	MonsterData = { Sync = false, Default = {} },  --怪物数据标识
	MonsterTrack = { Sync = false, Default = {} },  --怪物动画标识
	Target = { Sync = false, Default = {} },  --目标标识
	
	Path = { Sync = false, Default = {} },  --路径标识
	Request_FindPath = { Sync = false, Default = {} },  --请求查找路径标识
	Movable = { Sync = false, Default = {} },  --可移动标识
	MoveSpeed = { Sync = false, Default = {} },  --移动速度标识
	MoveTarget = { Sync = false, Default = {} },  --移动目标标识
	M = { Sync = false, Default = {} },  --正在移动标识
	Velocity = { Sync = false, Default = {} },  --速度标识
	Threat = { Sync = false, Default = {} },  --威胁标识

	Stage = { Sync = false, Default = {} },  --所在关卡标识
	ServerModel = {Sync = false, Default = { Model = nil } }, --服务端模型
	ExpireTime = { Sync = false, Default = {} },  --过期时间标识
	Tool = { Sync = false, Default = {} },  --道具标识
}
 
return module
