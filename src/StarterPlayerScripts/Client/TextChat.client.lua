local TextChatService = game:GetService("TextChatService")

-- 通常系统消息发送到 "RBXGeneral" 频道
local generalChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")

-- 发送系统消息
generalChannel:DisplaySystemMessage("<font color='#FF0000'>[系统提示]：欢迎来到游戏！</font>")