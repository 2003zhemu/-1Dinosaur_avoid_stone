
--[=[
    @interface configValue
    .ValueType string --获取的数据类型，存储获取的数据，存储在ReplicatedStorage.WebInformationModule下
    .Interval number --定时任务间隔
    .Callback ()->any --获取数据以及数据处理，返回需要的数据
    @within WebInformation
]=]
export type configValue={
    ValueType:string,
    Interval:number,
    Callback:() -> any,
}
local HttpService = game:GetService("HttpService")

local function _sendRequest(requestParams:HttpRequest):any
	local success, response = pcall(function()
		return HttpService:RequestAsync(requestParams)
	end)
	if success and response.Success then
		return response.Body
	end
end

--[=[
@prop WebInformationConfig {[string]: configValue}
@within WebInformation
* 模块启动后，会自动遍历该配置，根据配置的Interval定时执行Callback获取数据
* 每个游戏通过打补丁单独配置

]=]

local module = {
    Votes = {
        ValueType = "IntValue",
        Interval = 10,
        Callback = function()
            local HttpRequest = {
                Url = "https://games.roproxy.com/v1/games/4879904252/votes",
                Method = "GET",
            }
            local rep = _sendRequest(HttpRequest)
            if rep then
                local data = HttpService:JSONDecode(rep)
               return data["upVotes"]
            end
        end
    },
}
-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module,script.Name)
return module