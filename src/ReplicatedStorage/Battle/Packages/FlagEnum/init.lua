--[=[
	@class FlagEnum

	FlagEnum , 类似 c# [Flag] 的枚举,每个值为一个int32对象,可用于位运算

	为了实现代码提示, 枚举的构造应当在 .new() 以后进行, 且在构造完毕后,应调用 .freeze() 冻结枚举表.
	```lua
		local FlagEnum = require(game.ReplicatedStorage.Packages.FlagEnum)
		local enum = FlagEnum.new()
		enum.A = FlagEnum:LShift(1)     -- 注意, 点号, 参数不能重复
		enum.B = FlagEnum:LShift(2)     -- 注意, 点号, 参数不能重复
		enum.C = FlagEnum:LShift(3)     -- 注意, 点号, 参数不能重复
		enum.D = FlagEnum:LShift(4)     -- 注意, 点号, 参数不能重复
		enum:Freeze() 					-- 注意, 冒号
	```

	在上面的例子中, A 和 B 枚举项分别向左偏移了 1,2,3,4 位, 通过位运算,其代表的数字为:
	* .LShift(1) = 2
	* .LShift(2) = 4
	* .LShift(3) = 8
	* .LShift(4) = 16

	之后,我们可以通过 :HasFalg() 函数, 判断枚举项之间的关系.
]=]
local FlagEnum = {}

FlagEnum.__index = FlagEnum
--[=[
	Creates a new FlagEnum. 
	
	```lua
	local flagEnum = FlagEnum.new()
	```
	@param ... ...any -- param description
	@return FlagEnum
]=]
function FlagEnum.new()
	local flagEnum = {}
	setmetatable(flagEnum, FlagEnum)
	return flagEnum
end

--[=[
	[静态方法] 返回1向左位移之后的值
	@param offset number -- 偏移量,大于等于0, 如果大于等于32,则返回0
	@return number -- 32位数字
]=]
function FlagEnum.LShift(offset: number): number
	return bit32.lshift(1, offset)
end

--[=[
	[静态方法] 将多个枚举值使用 bor 运算符合并为一个枚举值
]=]
function FlagEnum.Bor(enum1: number, enum2: number, ...: number): number
	local tab = { ... }
	table.insert(tab, enum2)
	for _, value in tab do
		enum1 = bit32.bor(enum1, value)
	end
	return enum1
end

--[=[
	[静态方法] 判断枚举值(left) 是否包含某个枚举值 (right)
]=]
function FlagEnum.HasFalg(left: number, right: number): number
	-- print(111, left, right)
	return bit32.band(left, right) == right
end

--[=[
	设置枚举值完成后, 应当调用此函数, 冻结枚举表
]=]
function FlagEnum:Freeze()
	table.freeze(self)
end

export type Type = typeof(FlagEnum.new({}))

return FlagEnum
