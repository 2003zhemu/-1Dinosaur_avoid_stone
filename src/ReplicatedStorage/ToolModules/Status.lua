local FlagEnum = require(game.ReplicatedStorage.Battle.Packages.FlagEnum)

--[=[
	@class StateTypes

	FlagEnum StateTypes
]=]
local Status = FlagEnum.new()

--[=[
	时停状态
	@within Status
]=]
Status.TimeStop = FlagEnum.LShift(1)

--[=[
	击飞状态 
	@within Status
]=]
Status.FlyAway = FlagEnum.LShift(2)

--[=[
	被困状态（套索，麦克风护盾）
	@within Status
]=]
Status.Trapped = FlagEnum.LShift(3)

--[=[
	隐身状态
	@within Status
]=]
Status.Hidden = FlagEnum.LShift(4)

--[=[
	飞行状态
	@within Status
]=]
Status.Fly = FlagEnum.LShift(5)

--不能使用道具
Status.DisableTool = FlagEnum.Bor(Status.FlyAway, Status.Trapped, Status.TimeStop)

--不能被攻击
Status.DisableAttacked = FlagEnum.Bor(Status.FlyAway, Status.TimeStop, Status.Trapped)

--不能被时停
Status.DisableTimeStop = FlagEnum.Bor(Status.FlyAway, Status.TimeStop, Status.Trapped)

--不能使用分身
Status.DisableClone = FlagEnum.Bor(Status.FlyAway, Status.TimeStop, Status.Trapped)

--不能被击飞
Status.DisableFlyAway = FlagEnum.Bor(Status.FlyAway, Status.TimeStop, Status.Trapped)

--不能被困住
Status.DisableTrapped = FlagEnum.Bor(Status.FlyAway, Status.TimeStop, Status.Trapped)

--不能飞行
Status.DisableFly = FlagEnum.Bor(Status.FlyAway, Status.TimeStop, Status.Trapped)


-- Status.COMPOSITE_CAN_MAGIC_IMMUNE = FlagEnum.Bor(Status.INVINCIBLE, Status.MAGIC_IMMUNE)

-- Status.COMPOSITE_CAN_TIMEPAUSE_IMMUNE = FlagEnum.Bor(Status.INVINCIBLE, Status.MAGIC_IMMUNE,Status.TIMEPAUSE_IMMUNE)

-- Status.COMPOSITE_MAGIC_IMMUNE_CONFLICT = FlagEnum.Bor(Status.ROOTED, Status.STUN)

-- 冻结枚举表
Status:Freeze()

return Status