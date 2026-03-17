local IS_SERVER = game:GetService("RunService"):IsServer()
local defines = require(script.defines)
local module = {}

-- #region 邮件操作

-- 1. 发送邮件，仅服务器可用
-- @param userId number 用户ID
-- @param mail table 邮件对象
-- @return boolean 发送结果
function module.SendMail(userId, mail)
end

-- 发送邮件
-- @param senderId number 发送者ID
-- @param receiverId number 接收者ID
-- @param gift defines.Gift 礼物对象
-- @return boolean 发送结果
function module.SendGiftMail(senderId, receiverId, gift: defines.Gift)
end

-- 2. 获取邮件
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return table 邮件对象
function module.GetMail(userId, mailId)
end

-- 3. 获取邮件状态
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return number 邮件状态
function module.GetMailStatus(userId: number, mailId: number)
end

-- 4. 删除邮件
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return boolean 是否成功
function module.DeleteMail(userId, mailId)
end

-- 5. 标记邮件为已读
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return boolean 是否成功
function module.MarkMailAsRead(userId, mailId)
end

-- 6. 标记邮件为未读
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return boolean 是否成功
function module.MarkMailAsUnread(userId, mailId)
end

-- 7. 获取邮件列表
-- @param userId number 用户ID
-- @return table 邮件列表
function module.GetMailList(userId)
end

-- 8. 获取未读邮件列表
-- @param userId number 用户ID
-- @return table 未读邮件列表
function module.GetUnreadMailList(userId)
end

-- 9. 获取邮件数量
-- @param userId number 用户ID
-- @return number 邮件数量
function module.GetMailCount(userId)
end

-- 10. 获取未读邮件数量
-- @param userId number 用户ID
-- @return number 未读邮件数量
function module.GetUnreadMailCount(userId)
end

-- #endregion

-- #region 附件操作

-- 11. 获取邮件附件
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return table 邮件附件
function module.GetMailAttachment(userId, mailId)
end

-- 12. 领取邮件附件
-- @param userId number 用户ID
-- @param mailId number 邮件ID
-- @return boolean 是否成功
function module.ClaimMailAttachment(userId, mailId)
end

-- 处理所有邮件附件
-- @param userId number 用户ID
-- @param mailids table 邮件ID列表
-- @return boolean, string 成功时返回true，失败时返回false和错误信息
function module.ClaimAllMailsAttachment(userId, mailids: {string})
end

-- 删除所有邮件
-- @param userId number 用户ID
-- @return boolean 是否成功
function module.DeleteAllMails(userId: number)
end

-- 获取未领取邮件列表
-- @param userId number 用户ID
-- @return table 未领取邮件列表
function module.GetUnclaimedMailList(userId: number)
end

-- #根据附件Id获取物品数量
-- @param userId number 用户ID
-- @param attachmentId string 附件ID
-- @return number 物品数量
function module.GetAttachmentCountById(userId: number, attachmentId: string)
end

-- 获取已发送邮件列表
-- @param userId number 用户ID
-- @return table 已发送邮件列表
function module.GetSentMailList(userId: number)
end

-- #endregion

local client, server
if IS_SERVER then
    server = require(script.server)
else
    client = require(script.client)
end

local function delivery(key)
    local m = nil
    if IS_SERVER then
        m = server
    else
        m = client
    end
    return m[key]
end

table.clear(module)
setmetatable(module, {
    __index = function(_, key)
        return delivery(key)
    end,
    __newindex = function()
        error("Attempt to update")
    end
})

return module