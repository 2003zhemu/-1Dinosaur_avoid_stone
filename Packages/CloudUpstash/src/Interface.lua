--[=[
    @interface ICloudUpstashStore
    存储接口,用于对单个数据库进行读写操作
]=]
export type ICloudUpstashStore = {
	--[=[
        @param key number|string -- 存储键
        @param value {} -- 要存储的值
        @return nil
        异步保存数据到云端
    ]=]
	SetAsync: (key: number | string, value: {}) -> (),

	--[=[
        @param key number|string -- 存储键
        @return {} -- 存储的值
        异步从云端读取数据
    ]=]
	GetAsync: (key: number | string) -> {},
}

--[=[
    @interface ICloudUpstash
    云存储服务接口,用于管理多个数据库实例
]=]
export type ICloudUpstash = {
	--[=[
        @param storeName string -- 存储实例名称
        @param endpoint string -- 服务端点
        @param pass string -- 访问密码
        @return nil
        创建一个新的存储实例
    ]=]
	CreateStore: (storeName: string, endpoint: string, pass: string) -> (),

	--[=[
        @param storeName string -- 存储实例名称
        @param secretKeyEndpoint string -- 端点密钥名称
        @param secretKeyPass string -- 密码密钥名称
        @return nil
        通过密钥异步创建存储实例
    ]=]
	CreateStoreBySecretAsync: (storeName: string, secretKeyEndpoint: string, secretKeyPass: string) -> (),

	--[=[
        @param storeName string -- 存储实例名称
        @return boolean -- 是否存在该存储实例
        检查是否存在指定名称的存储实例
    ]=]
	HasStore: (storeName: string) -> boolean,

	--[=[
        @param storeName string -- 存储实例名称
        @return boolean -- 是否正在创建中
        检查指定名称的存储实例是否正在创建中
    ]=]
	IsStoreCreating: (storeName: string) -> boolean,

	--[=[
        @param storeName string -- 存储实例名称
        @return ICloudUpstashStore? -- 存储实例,不存在时返回nil
        获取指定名称的存储实例
    ]=]
	GetStore: (storeName: string) -> ICloudUpstashStore?,
}

return {}
