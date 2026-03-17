return function()
  local md = nil
  if game["Run Service"]:IsClient() then
		  md = require(script.Parent.Client)
    else
      md = require(script.Parent.Server)
	end

  task.wait(10)
		local player = game.Players:GetPlayerByUserId("2794649209")
		
	-- reset
	beforeEach(function(x) 


	end)
	it("好友个数有20个",function()
		local result = md.GetFriendList(player)
        expect(#result).to.equal(20)
	end)

	it("同服好友个数有0个",function()
		local result = md.GetFriendListInSameServer(player)
        expect(#result).to.equal(0)
	end)

end
