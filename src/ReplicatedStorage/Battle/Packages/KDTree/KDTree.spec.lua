return function()
	-- reset
	local KDTree=require(script.Parent)
	local tree:typeof(KDTree)=nil
	beforeEach(function() 
		tree=KDTree.New()
	end)

	afterEach(function() end)

	it("test build tree", function()
		local position={
			Vector2.new(2,5),
			Vector2.new(0,3),
			Vector2.new(4,4),
			Vector2.new(2.3,1),
			Vector2.new(7,0),}
		local entityIds={
			1,
			2,
			3,
			4,
			5,
			}
        -- tree:BuildAgentTree(position,entityIds)
	end)

	
end
