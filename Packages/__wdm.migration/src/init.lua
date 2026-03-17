local module = {}
local UserDatas = require(script.UserDatas)
require(script.WatchUser)

function module.SetUserDataProvider(userDataProvider)
    UserDatas.UserDataProvider = userDataProvider
end

return module