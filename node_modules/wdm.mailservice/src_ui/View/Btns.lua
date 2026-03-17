local defines = require(game.ReplicatedStorage.Packages.Neza.Defines)
local module = {}:: defines.View

function module:Start()
    local gui = self.DataContext.State.Gui
    self.CloseBtn = self:GetUI("Frame.Content.Top.Close.Btn", gui)
    self:BindBtns()
end

function module:BindBtns()
    self:Bind("Back", self.CloseBtn, "Mail")
end

return module