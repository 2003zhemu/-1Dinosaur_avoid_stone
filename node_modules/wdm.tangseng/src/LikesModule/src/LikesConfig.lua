--[=[
    @interface likesConfig
    .WuKongCommand string --悟空指令（领取和查询奖励需要的指令）
    .ProximityPrompt Instance|string --ProximityPrompt对象或者路径 
    .ShowLikes boolean --是否显示领取详情 （客户端是否显示领取详情）
    .TargetLikes number --目标点赞数 （可领取奖励需要达到的点赞数）
    .ShowLikesText Instance|string --显示点赞数的Text对象或者路径
    .ShowDetail boolean --未达到目标点赞数时，是否显示点赞数值
    @within LikesModule
]=]
export type likesConfig={
    WuKongCommand:string,
    ProximityPrompt:Instance|string,
    ShowLikes:boolean,
    TargetLikes:number,
    ShowLikesText:Instance|string,
    ShowDetail:boolean
}

--[=[
    @prop LikesConfig {configValue}
    @within LikesModule
    * 模块启动后，会自动遍历该配置，根据配置的点赞显示内容
    * 每个游戏通过打补丁单独配置
]=]
local module = {
    {
        WuKongCommand = "/点赞/GetLikes1",
        ProximityPrompt = nil,
        TargetLikes = 1000,
        ShowLikes = true,
        ShowLikesText = nil,
        ShowDetail = false
    },
    {
        WuKongCommand = "/点赞/GetLikes2",
        ProximityPrompt = nil,
        TargetLikes = 2000,
        ShowLikes = true,
        ShowLikesText = nil,
        ShowDetail = false
    }

}
-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module,script.Name)
return module