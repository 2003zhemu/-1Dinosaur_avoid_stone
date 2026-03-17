local SETTING = require(script.Parent.Parent.SETTING)

local Players = game:GetService("Players")
local PlayerMailsStore = require(script.Parent.Parent.datastores.PlayerMailsStore)
local DomainMailsStore = require(script.Parent.Parent.datastores.DomainMailsStore)
local PlayerDataProvider = require(script.Parent.Parent.PlayerDataProvider)
local Mail = require(script.Parent.Mail)

local module = {}
module.__index = module

export type Type = {
    Mails: {Mail.Type},             -- 收取的邮件
    HandleOver: boolean,            -- 是否处理完毕
}

function module.new()
    local self = {
        Mails = {},
    }
    setmetatable(self, module)
    self:AutoHandle()

    self:QueryAllPlayers()
    -- 慢慢查，服务器刚启动时，延迟处理
    Players.PlayerAdded:Connect(function(player)
        self:QueryMails(player.UserId)
    end)
    return self
end

-- #region 邮件投递
function module:QueryAllPlayers()
    local players = Players:GetPlayers()
    for i, player in ipairs(players) do
        delay(i, function()
            self:QueryMails(player.UserId)
        end)
    end
end

-- 玩家登录时调用，查询邮件, 并将邮件加入投递队列, 并发操作
function module:QueryMails(userId: number)
    local function query()
        pcall(self.QueryPersonalMails, self, userId)
        pcall(self.QueryDomainMails, self, userId)
    end
    coroutine.wrap(function()
        while true and game.Players:GetPlayerByUserId(userId) do
            query()
            wait(120)
        end
    end)()
end

function module:QueryPersonalMails(userId: number)
    local mails = PlayerMailsStore.QueryAll(userId)
    for _, mail in ipairs(mails) do
        table.insert(self.Mails, mail)
    end
end

function module:QueryDomainMails(userId: number)
    local defaultDomain = SETTING.DEFAULT_DOMAIN
    local domains = {
        defaultDomain,
    }
    local userData = PlayerDataProvider.Get(userId)
    if userData then
        for _, domain in ipairs(domains) do
            local lastestTimestamp = 0
            local playerMails = userData.Data.Mails or {}
            for _, mail: Mail.Type in ipairs(playerMails) do
                if mail.Expiry and ((not mail.Domains) or table.find(mail.Domains, domain)) then
                    if mail.Timestamp > lastestTimestamp then
                        lastestTimestamp = mail.Timestamp
                    end
                end
            end
            local mails = DomainMailsStore.QueryAll(domain, lastestTimestamp)
            for _, mail in ipairs(mails) do
                local existed = false
                for _, v in ipairs(playerMails) do
                    if v.Id == mail.Id then
                        existed = true
                        break
                    end
                end
                if not existed then
                    table.insert(self.Mails, mail)
                end
            end
        end
    end
end

-- 邮件自动投递
function module:AutoHandle()
    local function handleMails()
        for _, mail in ipairs(self.Mails) do
            local userId = mail.Receiver
            local suc, res = pcall(self.Deliver, self, userId, mail)
            if suc then
                local idx = nil
                for i, v in ipairs(self.Mails) do
                    if v.Id == mail.Id then
                        idx = i
                        break
                    end
                end
                if idx then
                    table.remove(self.Mails, idx)
                end
            else
                warn(res)
            end
        end
    end
    coroutine.wrap(function()
        while true do
            self.HandleOver = false
            -- 处理邮件
            if #self.Mails > 0 then
                handleMails()
            end
            if #self.Mails == 0 then
                self.HandleOver = true
            end
            wait(10)
        end
    end)()
end

-- 邮件投递
function module:Deliver(userId, mail: Mail.Type)
    local userData = PlayerDataProvider.Get(userId)
    if userData and userData.Data then
        if not userData.Data.Mails then
            userData.Data.Mails = {}
        end
        local existed = false
        for _, v in ipairs(userData.Data.Mails) do
            if v.Id == mail.Id then
                existed = true
                break
            end
        end
        if not existed then
            mail.Status = 1
            table.insert(userData.Data.Mails, mail)
        end

        local expiry = mail.Expiry
        if expiry then
            -- 千万不要移除，因为邮件可能会被多个领域共享
            -- local domain = mail.Domains and mail.Domains[1]
            -- DomainMailsStore.RemoveAsync(domain, mail.Id)
        else
            PlayerMailsStore.RemoveAsync(mail.Receiver, mail.Id)
        end
    end
end

-- #endregion

return module