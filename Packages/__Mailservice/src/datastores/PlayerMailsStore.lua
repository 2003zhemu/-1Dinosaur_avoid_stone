local SETTING = require(script.Parent.Parent.SETTING)
local STORENAME = string.format(SETTING.STORENAME.PlayerMailsStore)

local DataStoreService = game:GetService("DataStoreService")
local module = {}


function module.GetStore(userId: number)
    local store = DataStoreService:GetDataStore(STORENAME, userId)
    return store
end

function module.SetAsync(userId: number, key: string, value: any)
    local store = module.GetStore(userId)
    store:SetAsync(key, value)
end

function module.RemoveAsync(userId: number, key: string)
    local store = module.GetStore(userId)
    store:RemoveAsync(key)
end

function module.QueryAll(userId: number)
    local mails = {}
    pcall(function()
        local store = module.GetStore(userId)
        local page = store:ListKeysAsync("", 10, "", true)
        local keys = page:GetCurrentPage()
        for _, key in ipairs(keys) do
            local keyName = key.KeyName
            local mail = store:GetAsync(keyName)
            table.insert(mails, mail)
        end
    end)
    return mails
end

return module