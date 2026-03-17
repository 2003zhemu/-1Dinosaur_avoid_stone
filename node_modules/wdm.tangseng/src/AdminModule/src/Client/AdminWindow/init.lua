local module = {}

local model = require(script:WaitForChild("AdminModel"))
local view = require(script:WaitForChild("AdminView"))
local controller = require(script:WaitForChild("AdminController"))

local validator = require(script.Parent:WaitForChild("PermissionValidator"))

-- 添加测试方法
module.AddTestFunc = function(name,func:()->())
    controller.AddTestFunc(name,func)
end


controller.Init()

local UserInputService = game:GetService("UserInputService")


local _isShow = false

controller.Show(false)

local function _ShowReverse()
    _isShow = not _isShow
    controller.Show(_isShow)
end

-- 监听
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.F5 and validator.IsAdmin() then
        _ShowReverse()
    end
end)

return module
