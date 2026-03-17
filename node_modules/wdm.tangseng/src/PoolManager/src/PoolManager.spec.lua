return function()
	local poolManager = nil
	-- reset
	beforeEach(function(x)
		local folder = script.Parent:Clone()
		poolManager = require(game.ReplicatedStorage.Packages.PoolManager:Clone())
	end)

	local function _createPool()
		local cfg = {

			Name = "p1",
			DefaultCount = 0,
			CreateHandler = function()
				return Instance.new("Part")
			end,
		}
		return poolManager.SetPool(cfg)
	end

	it("set pool成功", function()
		local cfg = {

			Name = "p1",
			DefaultCount = 0,
			CreateHandler = function()
				return Instance.new("Part")
			end,
		}
		local pool = poolManager.SetPool(cfg)
		expect(pool).to.ok()
	end)

	it("get pool成功", function()
		local cfg = {

			Name = "p1",
			DefaultCount = 0,
			CreateHandler = function()
				return Instance.new("Part")
			end,
		}
		poolManager.SetPool(cfg)
		local pool = poolManager.GetPool("p1")
		expect(pool).to.ok()
	end)

	it("从pool 里租界对象成功", function()
		local pool = _createPool()
		local rentee = pool:Rent()
		expect(rentee).to.ok()
		expect(pool:Count("all")).to.equal(1)
		expect(pool:Count("rented")).to.equal(1)
		expect(pool:Count("not rented")).to.equal(0)
	end)

	it("从pool 里租界2x对象成功 ", function()
		local pool = _createPool()
		pool:Rent()
		pool:Rent()
		expect(pool:Count("all")).to.equal(2)
		expect(pool:Count("rented")).to.equal(2)
		expect(pool:Count("not rented")).to.equal(0)
	end)

	it("从pool 里租界并归还对象成功", function()
		local pool = _createPool()
		local rentee = pool:Rent()
		pool:Return(rentee)
		expect(pool:Count("all")).to.equal(1)
		expect(pool:Count("rented")).to.equal(0)
		expect(pool:Count("not rented")).to.equal(1)
	end)

	it("从pool 里租界并归还对象2x成功", function()
		local pool = _createPool()
		local rentee = pool:Rent()
		local rentee2 = pool:Rent()
		pool:Return(rentee)
		pool:Return(rentee2)

		expect(pool:Count("all")).to.equal(2)
		expect(pool:Count("rented")).to.equal(0)
		expect(pool:Count("not rented")).to.equal(2)
	end)
end
