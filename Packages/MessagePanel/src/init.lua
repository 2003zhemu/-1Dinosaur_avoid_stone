local module = {}

module.Name = "MessagePanel"

local queue = require(script.PanelQueue)
local runService = game:GetService("RunService")

local needPopList = queue.GetNeedPopList()

runService.Heartbeat:Connect(function()
    local popUpInfo = needPopList[1]
    if not queue.GetIsPoping() and popUpInfo ~= nil then
        queue.Pop(popUpInfo[1])
        table.remove(needPopList, 1)
    end
end)

local single =  {
	Visible = false,
	Close = function()
		-- MessagePanel 不执行Close
	end,
    Gui = queue.GetGui(),
	Open = function(...)
        local args = {...}
	    table.insert(needPopList, {args[1]})
	end,
}

module.GetViewObject = function ()
   return single
end

-- 适配 UIManager,返回 name,module,panelOptions(可忽略)
module.GetPanelConfig = function()
    return module.Name,module, {
        Layer="消息层", 			-- 面板归属层级
        FadeIn=-1,		-- 进入动画，-1  代表无动画
        FadeOut=-1,		-- 退出动画，-1  代表无动画
        IsModal = true,				-- 是否模态，如果某层不允许多个激活项，且其激活窗口是模态，则尝试打开其他窗口时，会报错并拒绝打开。
    }
end

return module