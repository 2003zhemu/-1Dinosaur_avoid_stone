local SETTING = require(script.Parent.Parent.SETTING)
local module = {}
module.__index = module

export type Type = {
    Id: string,             -- Id, 邮件Id
    Sender: number?,        -- PlayerId, 发送者
    Receiver: number?,      -- PlayerId, 接收者
    Subject: string,        -- Subject, 主题
    Content: string,        -- Content, 内容
    Timestamp: number,      -- Timestamp, 时间戳
    Attachment: {[any]: any},    -- Attachment, 附件
    Expiry: number,         -- Expiry, 过期时间
    Domains: {string},       -- Domains, 领域
    Status: number          -- Status, 状态
}

function module.new(): Type
    local self = {}
    setmetatable(self, module)
    self:GenerateId()
    self:SetTimestamp(os.time())
    self:SetStatus(SETTING.MAIL_STATUS.CREATE)
    return self
end

function module:GenerateId()
    self.Id = game.HttpService:GenerateGUID(false)
end

function module:SetStatus(status: number)
    assert(type(status) == "number", "Status must be a number")
    self.Status = status
end

function module:SetSender(sender: number)
    assert(type(sender) == "number", "Sender must be a number")
    self.Sender = sender
    local player = game.Players:GetPlayerByUserId(sender)
    if player then
        self:SetSenderName(player.Name)
    end
end

function module:SetSenderName(name: string)
    assert(type(name) == "string", "Sender must be a string")
    self.SenderName = name
end

function module:SetReceiver(receiver: number)
    assert(type(receiver) == "number", "Receiver must be a number")
    self.Receiver = receiver
end

function module:SetSubject(subject: string)
    assert(type(subject) == "string", "Subject must be a string")
    self.Subject = subject
end

function module:SetContent(content: string)
    assert(type(content) == "string", "Content must be a string")
    self.Content = content
end

function module:SetTimestamp(timestamp: number)
    assert(type(timestamp) == "number", "Timestamp must be a number")
    self.Timestamp = timestamp
end

function module:SetAttachment(Attachment: {[any]: any})
    assert(type(Attachment) == "table", "Attachment must be a table")
    self.Attachment = Attachment
end

function module:SetExpiry(expiry: number)
    assert(type(expiry) == "number", "Expiry must be a number")
    self.Expiry = expiry
end

function module:SetDomains(domains: {string})
    assert(type(domains) == "table", "Domains must be a table")
    self.Domains = domains
end

function module:GetSender(): number?
    return self.Sender
end

function module:GetSenderName(): string?
    return self.SenderName
end

function module:GetReceiver(): number?
    return self.Receiver
end

function module:GetSubject(): string
    return self.Subject
end

function module:GetContent(): string
    return self.Content
end

function module:GetTimestamp(): number
    return self.Timestamp
end

function module:GetAttachment(): {[any]: any}
    return self.Attachment
end

function module:GetExpiry(): number
    return self.Expiry
end

function module:GetDomains(): {string}
    return self.Domains
end

function module:AddAttachment(attachment: table)
    if not self.Attachment then
        self.Attachment = {}
    end
    table.insert(self.Attachment, attachment)
end

return module