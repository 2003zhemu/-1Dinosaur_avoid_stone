# 事件总线模块

## 功能介绍

作为全局事件总线, 该模块实现以下功能:

* 发送事件
* 注册事件监听

## 安装

`npm install wdm.eventbus`
   
## 使用

### 发送事件

```lua
var eventBus = require(game.ReplicatedStorage.EventBus)
eventBus.Fire("eventName",...)          -- 向同一个域发送事件
eventBus.FireClient("eventName",...)    -- 服务端发送事件给客户端
eventBus.FireServer("eventName",...)    -- 客户端发送事件给服务端
```

### 注册事件监听

```lua
var eventBus = require(game.ReplicatedStorage.EventBus)
eventBus.Connect(function(eventName))
    print("event received: " .. eventName)
end
```


