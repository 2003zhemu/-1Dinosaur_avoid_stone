local module = {}

function module:Load()
    self:Register("Mail", "Window")
end

function module:CanSelectMail(mailId)
    return true
end

function module:SelectMail(mailId)
    self.State.SelectedMailId = mailId
    return self.Mail:MarkMailAsRead(mailId)
end

function module:ClaimMail(mailId)
    local res = self.Mail:ClaimMail(mailId)
    if res then
        self.State.ClaimedMailId = mailId
    end
    return res
end

function module:DeleteMail(mailId)
    self.State.SelectedMailId = nil
    local res = self.Mail:DeleteMail(mailId)
    if not res then
        self.State.SelectedMailId = mailId
    end
    return res
end

function module:ClaimAll(unclaimMails)
    self.Mail:ClaimAll(unclaimMails)
    self:Respond("State.SelectedMailId")
end

function module:DeleteAll()
    self.State.SelectedMailId = nil
    self.Mail:DeleteAll()
end

return module