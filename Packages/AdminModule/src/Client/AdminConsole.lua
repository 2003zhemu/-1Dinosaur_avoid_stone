local module = {}
-- Author:kk
-- Date:2023年6月8日

local wukong =require(game.ReplicatedStorage.WuKong)

-- 执行命令
local function _executeCommand(commandId)
    wukong.ExecuteCommand(commandId)  
end

-- 监听输入事件
-- todo，处理输入字符串的参数
game.TextChatService.SendingMessage:Connect(function(m)

    local text = m.Text

    if not text then
        return
    end

    if  string.sub(text,1,1) ~= "/" then
        return
    end

    local commandId = string.sub(text,2,#text)

    if  not commandId or commandId == "" then
        return
    end

    _executeCommand(commandId)

    print("命令执行成功！")
end)

return module
