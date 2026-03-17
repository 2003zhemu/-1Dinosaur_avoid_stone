local module = {}
--[=[
    客户端调用兑换
    @param player Player
    @param codeStr string --兑换码
    @return boolean, table, string --是否成功, 返回信息(错误信息), 描述(结果为true时有效)
]=]
function module.Redeem(player, codeStr)
    
end
--[=[
    服务端调用, 设置数据提供者
    @param dataProvider function --数据提供者
]=]
function module.SetDataProvider(dataProvider)
    
end

table.clear(module)
local IS_SERVER = game:GetService("RunService"):IsServer()
local server, client

if IS_SERVER then
    server = require(script.server)
else
    client = require(script.client)
end

module.__index = function(_, key)
    if IS_SERVER then
        return server[key]
    else
        return client[key]
    end
end

setmetatable(module, module)

return module