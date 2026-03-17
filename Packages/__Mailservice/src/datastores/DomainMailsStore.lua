local SETTING = require(script.Parent.Parent.SETTING)
local MemoryStoreService = game:GetService("MemoryStoreService")

local Mail = require(script.Parent.Parent.entities.Mail)
local module = {}

function module.GetStore(domain)
    domain = domain or SETTING.DEFAULT_DOMAIN
    local storeName = string.format(SETTING.STORENAME.DomainMailsStore, domain)
    return MemoryStoreService:GetSortedMap(storeName)
end

function module.SetAsync(domain, key, value: Mail.Type)
    local store = module.GetStore(domain)
    local expiration = math.clamp(value.Expiry - os.time() + SETTING.MAIL_EXPIRY_ADDITION, SETTING.MAIL_EXPIRY_ADDITION, SETTING.MAX_EXPIRATION)
    store:SetAsync(key, value, expiration, value.Timestamp)
end

function module.RemoveAsync(domain, key)
    local store = module.GetStore(domain)
    store:RemoveAsync(key)
end

function module.QueryAll(domain, lastestTimestamp)
    local exclusiveLowerBound
    if lastestTimestamp then
        exclusiveLowerBound = {
            sortKey = lastestTimestamp
        }
    end
    local mails = {}
    local store = module.GetStore(domain)
    local items = store:GetRangeAsync(Enum.SortDirection.Ascending, 10, exclusiveLowerBound)
    for _, item in ipairs(items) do
        local key = item.key
        local mail = store:GetAsync(key)
        table.insert(mails, mail)
    end
    return mails
end

return module