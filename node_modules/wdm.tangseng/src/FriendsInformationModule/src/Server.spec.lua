return function()
	if game["Run Service"]:IsClient() then
		return
	end
		task.wait(10)
    local server = require(script.Parent.Server)
		local player = game.Players:GetPlayerByUserId("2794649209")

	-- reset
	beforeEach(function(x) 


	end)
	it("好友个数有20个",function()
		local result = server.GetFriendList(player)
        expect(#result).to.equal(20)
	end)

	it("同服好友个数有0个",function()
		local result = server.GetFriendListInSameServer(player)
        expect(#result).to.equal(0)
	end)


end