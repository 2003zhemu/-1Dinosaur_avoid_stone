local module = {}

export type Mail = {
    Id: string,             -- Id, 邮件Id
    Sender: number?,        -- PlayerId, 发送者
    SenderName: string?,        -- PlayerId, 发送者
    Receiver: number?,      -- PlayerId, 接收者
    Subject: string,        -- Subject, 主题
    Content: string,        -- Content, 内容
    Timestamp: number,      -- Timestamp, 时间戳
    Attachment: Attachment,    -- Attachment, 附件
    Expiry: number,         -- Expiry, 过期时间
    Domains: {string},       -- Domains, 领域
    Status: number          -- Status, 状态
}

-- 数组
export type Attachment = {
    [number]: any | Gift
}

export type Gift = {
    Type: string,
    Id: number,
    Count: number
}

return module