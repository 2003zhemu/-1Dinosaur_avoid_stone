local MailService = require(game.ReplicatedStorage.Packages.MailService)
local player = game.Players.LocalPlayer
local module = {

}

function module:GetMailList()
    return MailService.GetMailList(player.UserId)
end

function module:GetMail(mailId)
    if not mailId then
        return
    end

    return MailService.GetMail(player.UserId, mailId)
end

function module:MarkMailAsRead(mailId)
    return MailService.MarkMailAsRead(player.UserId, mailId)
end

function module:ClaimMail(mailId)
    return MailService.ClaimMailAttachment(player.UserId, mailId)
end

function module:DeleteMail(mailId)
    return MailService.DeleteMail(player.UserId, mailId)
end

function module:ClaimAll(unclaimMails)
    return MailService.ClaimAllMailsAttachment(player.UserId, unclaimMails)
end

function module:DeleteAll()
    return MailService.DeleteAllMails(player.UserId)
end

function module:GetAttachmentItemCount(id)
    return MailService.GetAttachmentCountById(player.UserId, id) or 1
end

return module