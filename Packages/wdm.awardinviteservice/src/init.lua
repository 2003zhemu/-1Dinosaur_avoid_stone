local module = {}
local IS_SERVER = game:GetService("RunService"):IsServer()
--#region Client
-- 获取自己的邀请码
function module.GetInviteCode(player)
	
end

function module.GenerateQRCode(width)
	
end

-- 获取邀请链接
function module.GetInviteLink(t)
	
end

-- 发送游戏邀请
function module.PromptInGameInvite(player)
	
end
--#endregion

--#region Server

-- 设置数据提供者
function module.SetDataProvider(dataProvider)
end

-- 获取邀请的玩家列表
function module.GetInvitesInstantly(player)
end

--#endregion


--#region all

-- 获取邀请的玩家列表
function module.GetInvites()
	
end

--#endregion

local client, server
if IS_SERVER then
    server = require(script.server)
else
    client = require(script.client)
end
local function delivery(key)
    local m = nil
    if IS_SERVER then
        m = server
    else
        m = client
    end
    return m[key]
end

table.clear(module)
setmetatable(module, {
    __index = function(_, key)
        return delivery(key)
    end,
    __newindex = function()
        error("Attempt to update RankSystem")
    end
})

return module