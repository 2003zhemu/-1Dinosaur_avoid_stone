# Upstash 云数据库服务

- 服务商 : upstash.com

我们使用 upstash.com 作为云存储服务商, 它们提供一个关键服务: 使用 http 接口存储和查询对象.

这样, 我们就可以使用 roblox 的 HttpService, 来操作云端数据.


# 数据库操作

## 保存数据

发送

- url:  Https://{EndPoint}/set/{key}
- method: Post
- body: 需要保存的 json 对象的字符串

返回
```
{
    "result": "OK"
}
```
## 读取数据

发送

- url:  Https://{EndPoint}/get/{key}
- method: Get
- body: 需要保存的 json 对象的字符串

返回

## 储存的 json 对象

```
Http Codes
200 OK: When request is accepted and successfully executed.
400 Bad Request: When there’s a syntax error, an invalid/unsupported command is sent or command execution fails.
401 Unauthorized: When authentication fails; auth token is missing or invalid.
405 Method Not Allowed: When an unsupported HTTP method is used. Only HEAD, GET, POST and PUT methods are allowed.
```

存储对象约定

1. 以 userId 作为 key
2. value为 json 对象,比如:
```
{
    "Level": 1,
    "OnlineSec": 1000
}
```

# NPM 包

针对以上数据库操作, 提供 wdm.cloud-upstash 扩展包, 用来访问云数据库.

# 接口

```
-- Upstash云服务
export type ICloudUpstash = {

    -- 创建 store
    CreateStore: (storeName:string,endpoint:string,pass:string)
    
    -- 通过 secret 服务创建 store
    CreateStoreBySecretAsync: (storeName:string,secretKeyEndpoint:string,secretKeyPass:string)
    
    -- 是否拥有 store
    HasStore:(storeName:string)->bool,
    
    -- 是否正在创建 store
    IsStoreCreating:(storeName:string)->bool,
    
    -- 获取已经创建的 store, 允许返回空
    GetStore:(storeName:string)->ICloudUpstashStore?,
}
```

```
-- Upstash云数据库
export type ICloudUpstashStore = {
    SetAsync:(key:number|string,value:{})->(),
    GetAsync:(key:number|string)->{} 
}
```

初始化

```
local CloudUpstash = require(game.ReplicatedStorage.Packages.CloudUpstash)

-- 创建
CloudUpstash.CreateStore("s1","{endpoint}","{pass}")

-- 使用
local store = CloudUpstash.GetStore("s1")
store.SetAsync(32343434,{Level=3})
```

安全性
为避免机密信息泄露, EndPoint 和 Pass 必须保存在 Secrets 里, 由游戏管理员在后台设置.

[图片]

-- 使用机密信息初始化
```
local CloudUpstash = require(game.ReplicatedStorage.Packages.CloudUpstash)

-- 初始化 (仅一次,注意这是异步调用)
CloudUpstash.InitBySecret("{secret-key-endpoint}","{secret-key-pass}")

-- 使用
CloudUpstash.SetAsync(32343434,{Level=3})
```

其他
数据库生命周期
在项目结束后, 操作员需要删除其负责的数据库, 保证不再产生费用.
