local module = {}

local view = require(script.Parent.AdminView)
local model = require(script.Parent.AdminModel)
local connections = {}

local _onButtonClick = function(x)
    model.ExecuteCommand(x)
end

module.Show = function(isShow)
    view.Show(isShow)
end

module.AddTestFunc = function(name,func)
    local buttons = view.CreateTestButtons({name})
    for k,v:TextButton in pairs(buttons) do
        local connection = v.MouseButton1Click:Connect(func) 
        table.insert(connections,connection)
    end
end


module.Init = function()
    local ids = model.GetCommandIds()
    local buttons = view.CreateAdminButtons(ids)
    for k,v:TextButton in pairs(buttons) do
        local connection = v.MouseButton1Click:Connect(function()
            _onButtonClick(v.Name)
        end) 
        table.insert(connections,connection)
    end
end

return module
