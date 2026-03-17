local Defines = {}

--[=[
	@interface Options
	.Group string? -- 分组名
	.Distance number? -- 检测距离
	.Away (detection: Detection) -> () -- 离开触发方法
	.Close (detection: Detection) -> () -- 靠近触发方法
	@within ProximityDetectionService
	Detection配置
]=]

export type Options = {
    Group: string | nil,     --分组名
    Distance: number,   --检测距离
    Away: () -> (),     --离开触发
    Close: () -> (),    --靠近触发
}

return Defines