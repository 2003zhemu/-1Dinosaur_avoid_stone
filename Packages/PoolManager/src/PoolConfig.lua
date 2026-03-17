export type Type = {
	DefaultCount: number?, -- 对象池创建时，默认创建实例数
	CreateHandler: (...string | number) -> any, -- 创建新实例的回调，此处需要返回创建的新实例,回调参数为创建实例的标识
	OnRentHandler: (rentee: any) -> ()?, -- 出借回调
	OnReturnHandler: (rentee: any) -> ()?, -- 归还回调
	OnClearHandler: (rentee: any) -> ()?, -- 销毁回调
}

--[=[
	@interface PoolConfig
	.DefaultCount number? -- 对象池创建时，默认创建实例数
	.CreateHandler (...string | number |boolean) -> any -- 创建新实例时的回调，需要返回创建的实例,回调参数为创建实例的标识
	.OnRentHandler (rentee: any) -> ()? -- 出借回调
	.OnReturnHandler (rentee: any) -> ()? -- 归还回调
	.OnClearHandler (rentee: any) -> ()? -- 清空回调
	@within PoolManager
	对象池配置
	```lua
		{
			DefaultCount = 	10, 	-- 对象池创建时，默认创建实例数
			CreateHandler = function (...:string|number)  -- 创建新实例时的回调，需要返回创建的实例,回调参数为创建实例的标识
				return {}	-- 返回的对象
			end,
			OnRentHandler = function (rentee) -- 出借回调
				print("出借对象:",rentee)
			end,
			OnReturnHandler = function (rentee) -- 归还回调
				print("归还对象:",rentee)
			end,
			OnClearHandler = function (rentee) -- 销毁回调
				print("对象池已清空,请处置对象:",rentee) 
			end,
		}
	```
]=]

local PoolConfig = {}
return PoolConfig
