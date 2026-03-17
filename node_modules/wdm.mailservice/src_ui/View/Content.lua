local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {}:: defines.View

function module:Start()
    local gui = self.DataContext.State.Gui
    self.MailListFrame = self:GetUI("Frame.Content.Bottom.Left.ScrollingFrame", gui)

    self.MailContent = self:GetUI("Frame.Content.Bottom.Right.Content", gui)
    self.MailTitleLabel = self.MailContent.Top.Title
    self.SenderLabel = self.MailContent.Top.Sender
    self.ContentLabel = self.MailContent.Content.ScrollingFrame.TextBox
    self.AttachmentContent = self.MailContent.Attachment.Content
    self.DateLabel = self.MailContent.Bottom.Date.TextLabel
    self.ClaimBtn = self.MailContent.Bottom.Btns.Claim
    self.DeleteBtn = self.MailContent.Bottom.Btns.Del

    self:Connect("State.SelectedMailId", self.ReloadContent)
    self.ContentLabel.TextSize = 40
    self.ContentLabel.RichText = true
end

function module:ReloadContent(mailId)
    local absoluteX = self.ContentLabel.AbsoluteSize.X
    local size = math.clamp(40 * absoluteX / 600, 20, 40)
    self.ContentLabel.TextSize = size

    for i, v in pairs(self.AttachmentContent:GetChildren()) do
        if v:IsA("ImageLabel") then
            self:PutNode(v)
        end
    end
    self:Unbind(self.ClaimBtn.Btn)
    self:Unbind(self.DeleteBtn.Btn)
    local mail = self.DataContext.Mail:GetMail(mailId)
    if self.DataContext.State.SelectedMailId == mailId then
        if mail then
            self.MailTitleLabel.Text = mail.Subject
            self.SenderLabel.Text = mail.SenderName or mail.Sender
            self.ContentLabel.Text = string.format("\t%s", mail.Content)
            self.DateLabel.Text = DateTime.fromUnixTimestamp(mail.Timestamp):FormatLocalTime("l", "en-us")
            if mail.Attachment and next(mail.Attachment) then
                self.AttachmentContent.Visible = true
                if mail.Status < 3 then
                    self.DeleteBtn.Visible = false
                    self.ClaimBtn.Visible = true
                else
                    self.DeleteBtn.Visible = true
                    self.ClaimBtn.Visible = false
                end
            else
                self.AttachmentContent.Visible = false
                self.ClaimBtn.Visible = false
                self.DeleteBtn.Visible = true
            end
            self:UpdateAttachment(mail.Attachment, mail.Status >= 3)
        else
            self.MailTitleLabel.Text = ""
            self.SenderLabel.Text = ""
            self.ContentLabel.Text = ""
            self.DateLabel.Text = ""
            self.AttachmentContent.Visible = false
            self.ClaimBtn.Visible = false
            self.DeleteBtn.Visible = false
        end
        if self.ClaimBtn.Visible then
            self:Bind("ClaimMail", self.ClaimBtn.Btn, mailId):Then(function(value)
                if self.DataContext.State.SelectedMailId == mailId then
                    self:ReloadContent(mailId)
                end
            end)
        end
        if self.DeleteBtn.Visible then
            self:Bind("DeleteMail", self.DeleteBtn.Btn, mailId)
        end
    end
end

function module:UpdateAttachment(attachments, claimed)
    for i, v in pairs(self.AttachmentContent:GetChildren()) do
        if v:IsA("ImageLabel") then
            self:PutNode(v)
        end
    end
    if attachments then
        for i, v in pairs(attachments) do
            local id = v.Id
            local count = self.DataContext.Mail:GetAttachmentItemCount(id)
            local item = self:GetNode("MailAttachmentItem")
            self:GetComponent(item.Icon):SetSprite("付费商品图标", id)
            item.Count.Text = count
            item.Parent = self.AttachmentContent
            item.Claimed.Visible = claimed
        end
    end
end
return module