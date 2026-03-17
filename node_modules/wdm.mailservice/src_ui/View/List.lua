local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {}:: defines.View

function module:Start()
    local gui = self.DataContext.State.Gui
    self.MailListFrame = self:GetUI("Frame.Content.Bottom.Left.ScrollingFrame", gui)
    self.EmptyTips = self:GetUI("Frame.Content.Bottom.Left.EmptyTips", gui)
    self.DeleteAllBtn = self:GetUI("Frame.Content.Bottom.Left.Bottom.Del", gui)
    self.ClaimAllBtn = self:GetUI("Frame.Content.Bottom.Left.Bottom.Claim", gui)

    self.MailListFrame.Visible = false
    self.EmptyTips.Visible = true

    self:After("DeleteMail", self.RemoveMail)
    self:Connect("State.SelectedMailId", self.UpdateSelected)
    self:Connect("State.ClaimedMailId", self.UpdateClaimed)

    
end

function module:OnOpen()
    self:LoadMails()
end

function module:UpdateClaimed(mailId)
    if mailId then
        local item = self.MailListFrame:FindFirstChild(mailId)
        if item then
            item.Btn.Marks.Read.Visible = false
        end
    end
end

function module:UpdateSelected(mailId, old)
    if old then
        local item = self.MailListFrame:FindFirstChild(old)
        if item then
            item.Btn.SelectedBg.Visible = false
            item.Btn.Content.Top.Title.TextColor3 = Color3.fromRGB(133, 96, 62)
            item.Btn.Content.Bottom.Date.TextColor3 = Color3.fromRGB(133, 96, 62)
            item.Btn.Content.Bottom.Expiry.TextColor3 = Color3.fromRGB(181, 156, 115)
        end
    end
    if mailId then
        local item = self.MailListFrame:FindFirstChild(mailId)
        if item then
            item.Btn.SelectedBg.Visible = true

            local selectedColor = Color3.fromRGB(238, 223, 220)
            item.Btn.Content.Top.Title.TextColor3 = selectedColor
            item.Btn.Content.Bottom.Date.TextColor3 = selectedColor
            item.Btn.Content.Bottom.Expiry.TextColor3 = selectedColor
        end
    end
end

function module:RemoveMail(mailId)
    if mailId then
        local item = self.MailListFrame:FindFirstChild(mailId)
        if item then
            self:Unbind(item.Btn)
            self:PutNode(item)
        end
    end
end

function module:LoadMails()
    for i, item in pairs(self.MailListFrame:GetChildren()) do
        if item:IsA("Frame") then
            self:Unbind(item.Btn)
        end
    end
    self:Unbind(self.ClaimAllBtn.Btn)
    self:Unbind(self.DeleteAllBtn.Btn)
    
    local mails = self.DataContext.Mail:GetMailList()
    if mails then
        local temp = {}
        local unclaimMails = {}
        local showMails = {}
        for i, mail in pairs(mails) do
            if mail.Status >= 4 then
                continue
            end
            table.insert(showMails, mail.Id)
            temp[mail.Id] = true
            local item = self.MailListFrame:FindFirstChild(mail.Id)
            if not item then
                item = self:GetNode("MailItem")
                item.Name = mail.Id
                item.Parent = self.MailListFrame
                item.Btn.Content.Top.Title.Text = mail.Subject
                item.Btn.Content.Bottom.Date.Text = DateTime.fromUnixTimestamp(mail.Timestamp):FormatLocalTime("l", "en-us")
                item.LayoutOrder = -mail.Timestamp
                item.Btn.SelectedBg.Visible = false
                item.Btn.Content.Top.Title.TextColor3 = Color3.fromRGB(133, 96, 62)
                item.Btn.Content.Bottom.Date.TextColor3 = Color3.fromRGB(133, 96, 62)
                item.Btn.Content.Bottom.Expiry.TextColor3 = Color3.fromRGB(181, 156, 115)
                self:Unbind(item.Btn)
            end
            if mail.Expiry then
                local d = math.floor((mail.Expiry - os.time()) / 86400)
                local h = math.floor((mail.Expiry - os.time() - d * 86400) / 3600)
                if d > 0 then
                    item.Btn.Content.Bottom.Expiry.Text = d .. " day(s) left"
                elseif h >= 0 then
                    item.Btn.Content.Bottom.Expiry.Text = h .. " hour(s) left"
                else
                    item.Btn.Content.Bottom.Expiry.Text = "Expiried"
                end
            else
                item.Btn.Content.Bottom.Expiry.Text = ""
            end
            if mail.Status < 3 then
                item.Btn.Marks.Read.Visible = true
                table.insert(unclaimMails, mail.Id)
            else
                item.Btn.Marks.Read.Visible = false
            end

            self:Bind("SelectMail", item.Btn, mail.Id)
            self:GetComponent(item.Btn):SetHoverScale(nil, 1.05)
        end
        for i, item in pairs(self.MailListFrame:GetChildren()) do
            if item:IsA("Frame") then
                if not temp[item.Name] then
                    self:Unbind(item.Btn)
                    self:PutNode(item)
                end
            end
        end

        if #showMails == 0 then
            self.MailListFrame.Visible = false
            self.EmptyTips.Visible = true
        else
            self.MailListFrame.Visible = true
            self.EmptyTips.Visible = false

            self:Bind("ClaimAll", self.ClaimAllBtn.Btn, unclaimMails):Then(function()
                self:LoadMails()
            end)
            self:Bind("DeleteAll", self.DeleteAllBtn.Btn):Then(function()
                self:LoadMails()
            end)
        end
    end
end

return module