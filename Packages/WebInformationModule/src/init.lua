--[=[
    @class WebInformation
    @server 
    @client
    该模块用于获取网络信息：
    * 该模块启动一个定时任务，根据WebInformationConfig里配置，在主服务器上定时获取数据;
    * 任务间隔时间由WebInformationConfig里的Interval决定；
    * 获取的数据会自动同步到其他服务器；
    * 在客户端和服务端都可以通过WebInformation.GetData(id)获取数据，id为WebInformationConfig里的key
]=]
local WebInformation = {}
local requireModule = nil

if game["Run Service"]:IsServer() then
    requireModule = require(script.Server)
else
    requireModule = require(script.Client)
end


--[=[
    @param id string  --要获取的数据id(WebInformationConfig里的key)
    @return any  --获取到的数据
    获取指定 id 的数据，id为WebInformationConfig里的key值
]=]
function WebInformation.GetData(id:string):any
    assert(requireModule)
    return requireModule.GetData(id)
end

--[=[
    @param id string  --要获取的数据id(WebInformationConfig里的key)
    @return any  --获取到的数据存储对象
    获取指定 id 的数据存储对象，id为WebInformationConfig里的key值
]=]
function WebInformation.GetInstance(id:string):Instance
    assert(requireModule)
    return requireModule.GetInstance(id)
end

-- 心跳
-- 遍历配置 ，interval
-- if master do

return WebInformation


