local module = {}
local event: RemoteEvent = script.Parent:WaitForChild("RemoteEvent")
local invoke = script.Parent:WaitForChild("RemoteFunction")
local MailConfig = require(script.Parent.MailConfig)

local function remote(...)
    if event == nil then
        event = script.Parent:WaitForChild("RemoteEvent")
    end
    event:FireServer(...)
end

local function remoteInvoke(...)
    if invoke == nil then
        invoke = script.Parent:WaitForChild("RemoteFunction")
    end
    return invoke:InvokeServer(...)
end

-- #region 邮件操作

-- 1. 发送邮件，仅服务端可用
-- @param userId number 用户ID
-- @param mail table 邮件对象
-- @return boolean 发送结果
function module.SendMail(userId, mail)
    -- return remoteInvoke("SendMail", userId, mail)
end

-- 2. 获取邮件
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return table 邮件对象
function module.GetMail(userId, mailId)
    return remoteInvoke("GetMail", userId, mailId)
end

-- 3. 获取邮件状态
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return number 邮件状态
function module.GetMailStatus(userId: number, mailId: number)
    return remoteInvoke("GetMailStatus", userId, mailId)
end

-- 4. 删除邮件
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return boolean 是否成功
function module.DeleteMail(userId, mailId)
    return remoteInvoke("DeleteMail", userId, mailId)
end

-- 5. 标记邮件为已读
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return boolean 是否成功
function module.MarkMailAsRead(userId, mailId)
    return remoteInvoke("MarkMailAsRead", userId, mailId)
end

-- 6. 标记邮件为未读
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return boolean 是否成功
function module.MarkMailAsUnread(userId, mailId)
    return remoteInvoke("MarkMailAsUnread", userId, mailId)
end

-- 7. 获取邮件列表
-- @param userId number 用户ID
-- @return table 邮件列表
function module.GetMailList(userId)
    return remoteInvoke("GetMailList", userId)
end

-- 8. 获取未读邮件列表
-- @param userId number 用户ID
-- @return table 未读邮件列表
function module.GetUnreadMailList(userId)
    return remoteInvoke("GetUnreadMailList", userId)
end

-- 9. 获取邮件数量
-- @param userId number 用户ID
-- @return number 邮件数量
function module.GetMailCount(userId)
    return remoteInvoke("GetMailCount", userId)
end

-- 10. 获取未读邮件数量
-- @param userId number 用户ID
-- @return number 未读邮件数量
function module.GetUnreadMailCount(userId)
    return remoteInvoke("GetUnreadMailCount", userId)
end

-- 获取未领取邮件列表
-- @param userId number 用户ID
-- @return table 未领取邮件列表
function module.GetUnclaimedMailList(userId: number)
    return remoteInvoke("GetUnclaimedMailList", userId)
end

-- #endregion

-- #region 附件操作

-- 11. 获取邮件附件
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return table 邮件附件
function module.GetMailAttachment(userId, mailId)
    return remoteInvoke("GetMailAttachment", userId, mailId)
end

-- 12. 领取邮件附件
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return boolean 是否成功
function module.ClaimMailAttachment(userId, mailId)
    return remoteInvoke("ClaimMailAttachment", userId, mailId)
end

-- 处理所有邮件附件
-- @param userId number 用户ID
-- @param mailids table 邮件ID列表
-- @return boolean, string 成功时返回true，失败时返回false和错误信息
function module.ClaimAllMailsAttachment(userId, mailids: {string})
    return remoteInvoke("ClaimAllMailsAttachment", userId, mailids)
end

-- 删除所有邮件
-- @param userId number 用户ID
-- @return boolean 是否成功
function module.DeleteAllMails(userId: number)
    return remoteInvoke("DeleteAllMails", userId)
end

-- #根据附件Id获取物品数量
-- @param userId number 用户ID
-- @param attachmentId string 附件ID
-- @return number 物品数量
function module.GetAttachmentCountById(userId: number, attachmentId: string)
    return (MailConfig.AttachmentItemCountProvider and MailConfig.AttachmentItemCountProvider(userId, attachmentId)) or 1
end

-- 获取已发送邮件列表
-- @param userId number 用户ID
-- @return table 已发送邮件列表
function module.GetSentMailList(userId: number)
    return remoteInvoke("GetSentMailList", userId)
end

-- #endregion

return module