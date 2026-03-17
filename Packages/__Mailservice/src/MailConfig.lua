--[=[
    @class MailConfig

    `配置项` `可补丁`

    数据迁移配置

]=]

local module = {} :: {
    AttachmentHandler: (number, table) -> boolean,
    DataProvider: (number, number) -> table,
    AttachmentItemCountProvider: (number, string) -> number,
}

-- 英文 您有新的礼物，请查收！
module.GiftMessage = "You have a new gift, please check it out!"

-- 给配置打补丁
local cfgPatcher = require(game.ReplicatedStorage.Packages.ConfigPatcher)
cfgPatcher.PatchConfig(module, script.Name)

return module