local rs = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")

local adminModule = require(rs.Packages.AdminModule)

local UniverseUrl = "https://xujz0123.github.io/roblox/index.html"


local Helper = {}
function Helper.IsAdmin(player: Player)
    adminModule.IsAdmin(player)
end

function Helper.GetGameData()
	local tries = 0	
	local success,data
	repeat
		tries += 1
		success,data = pcall(function()
			local Response = httpService:RequestAsync({
				Url = UniverseUrl,  -- 此网站可用来调试 HTTP 请求
				Method = "GET"
			});
			return Response
		end)
		if not success then wait(1) end
	until tries == 3 or success

	if success and data.Body then
		return string.gsub(data.Body,"\r\n\t","")
	end
end

return Helper