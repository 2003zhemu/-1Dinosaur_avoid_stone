local module = {}
local viewConfig = require(script.FriendsAdditionViewConfig)

local Gui = script.Parent:WaitForChild("FriendsAdditionFrame",10)
local additionItem = script.Parent:WaitForChild("AdditionItem",10)
assert(Gui and additionItem,"获取好友加成面板失败")

local TopContainer = Gui.Top
local CloseBtn = TopContainer.Close

local ContentContainer = Gui.Content
local FriendCountContainer = ContentContainer.FriendCount
local FriendIcon = FriendCountContainer.Icon
local FriendCountText = FriendCountContainer.Count

local FriendAdditionContainer = additionItem

local BottomContainer = Gui.Bottom
local InviteBtn = BottomContainer.Invite

assert(viewConfig.ViewImage and viewConfig.Callback,"获取好友加成面板配置失败")

local function SetViewImage()
    local config = viewConfig.ViewImage

    TopContainer.Image = config.TitleBackground
    CloseBtn.Image = config.Close

    FriendCountContainer.Image = config.ContentBackground
    FriendAdditionContainer.Image = config.ContentBackground
    FriendIcon.Image = config.Icon

    InviteBtn.Image = config.Invite 
end

module.Init = function()
    SetViewImage()
end

module.Show = function(isShow,friendCount:number)
    if isShow then
        FriendCountText.Text = friendCount
        local awards = viewConfig.Callback(friendCount)
        for k, v in pairs(awards) do
            if k > 4 then break end
            local item = additionItem:Clone()
            item.Name = "addition"
            item.Title.Text = v.Item
            item.Count.Text = v.Count
            item.Parent = ContentContainer
        end
    else
        for _, v in pairs(ContentContainer:GetChildren()) do
            if v.Name == "addition" then
                v:Destroy()
            end
        end
    end
end

module.CloseBtnClick = function(fun)
    return CloseBtn.MouseButton1Click:Connect(fun)
end

module.InviteBtnClick = function(fun)
    return InviteBtn.MouseButton1Click:Connect(fun)
end

module.Gui = Gui
return module