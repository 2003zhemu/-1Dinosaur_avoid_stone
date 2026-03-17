local Pool = require(script.Parent.Pool)
local PoolConfig = require(script.Parent.PoolConfig)
return function()
	local poolConfig
	beforeEach(function(x)
		poolConfig = {
			DefaultCount = 0, -- 对象池创建时，默认创建实例数
			CreateHandler = function(...: string | number) -- 创建新实例时的回调，需要返回创建的实例,回调参数为创建实例的标识
				return {} -- 返回的对象
			end,
			OnRentHandler = function(rentee) -- 出借回调
				print("出借对象:", rentee)
			end,
			OnReturnHandler = function(rentee) -- 归还回调
				print("归还对象:", rentee)
			end,
			OnDestroyHandler = function(rentee) -- 销毁回调
				print("销毁对象 :", rentee)
			end,
		}
		poolConfig.DefaultCount = 0
	end)

	it("init pool with default count", function()
		poolConfig.DefaultCount = 5
		local pool = Pool.new(poolConfig)
		expect(pool.__countAll).to.equal(5)
	end)

	it("should create a new pool 2", function()
		local pool = Pool.new(poolConfig)
		expect(pool).to.be.ok()
	end)

	it("rent with  args ", function()
		poolConfig.CreateHandler = function(k1, k2, k3)
			return { k1, k2, k3 }
		end
		local pool = Pool.new(poolConfig)
		local a1 = pool:Rent("a1", "a2", "a3")
		expect(a1[1]).to.equal("a1")
		expect(a1[2]).to.equal("a2")
		expect(a1[3]).to.equal("a3")
		pool:Return(a1)
		expect(pool:Count()).to.equal(1)
		local a2 = pool:Rent("a1", "a2", "a3")
		expect(a1).to.equal(a2)
		expect(pool:Count()).to.equal(1)
		local a3 = pool:Rent("a1", "a2", "a3")
		expect(a2 ~= a3).to.ok()
	end)

	it("should create a new object when the pool is empty", function()
		local pool = Pool.new(poolConfig)
		expect(pool:Count()).to.equal(0)
		local obj = pool:Rent()
		expect(pool:Count()).to.equal(1)
		expect(obj).to.be.ok()
	end)

	it("should return success ", function()
		local pool = Pool.new(poolConfig)
		local obj = pool:Rent()
		pool:Return(obj)
		expect(pool:Count()).to.equal(1)
		expect(pool:Count("not rented")).to.equal(1)
	end)

	it("should reuse an object from the pool", function()
		local pool = Pool.new(poolConfig)
		local obj1 = pool:Rent()
		pool:Return(obj1)
		local obj2 = pool:Rent()
		expect(pool:Count()).to.equal(1)
		expect(obj1).to.equal(obj2)
	end)

	it("should create the default number of objects when the pool is created", function()
		local pool = Pool.new(poolConfig)
		expect(pool.__countAll).to.equal(poolConfig.DefaultCount)
	end)

	it("should call the OnRentHandler when an object is rented", function()
		print("start debug")
		local onRentCalled = false
		poolConfig.OnRentHandler = function()
			onRentCalled = true
		end
		local pool = Pool.new(poolConfig)
		pool:Rent()
		expect(pool:Count()).to.equal(1)
		expect(pool:Count("not rented")).to.equal(0)

		expect(onRentCalled).to.equal(true)
	end)

	it("should call the OnReturnHandler when an object is returned 1", function()
		local onReturnCalled = false
		poolConfig.OnReturnHandler = function()
			onReturnCalled = true
		end
		local pool = Pool.new(poolConfig)
		local obj = pool:Rent()
		expect(pool:Count()).to.equal(1)
		pool:Return(obj)
		expect(onReturnCalled).to.equal(true)
	end)

	it("allocate all rentees", function()
		local count = 0
		poolConfig.CreateHandler = function(...: string | number) -- 创建新实例时的回调，需要返回创建的实例,回调参数为创建实例的标识
			return { "allocate all rentees" } -- 返回的对象
		end
		poolConfig.OnReturnHandler = function(rentee)
			print("returned ", rentee)
			count = count + 1
		end
		local pool = Pool.new(poolConfig)
		local obj = pool:Rent()
		local obj = pool:Rent()
		local obj = pool:Rent()
		expect(pool:Count()).to.equal(3)

		print("start to allocate all 1")
		pool:AllocateAll()
		print("allocate end")
		expect(count).to.equal(3)
	end)

	it("should call the OnDestroyHandler when  an object is destroyed", function()
		local onClearCalled = false
		poolConfig.OnClearHandler = function()
			onClearCalled = true
		end
		local pool = Pool.new(poolConfig)
		local obj = pool:Rent()
		pool:Clear()
		expect(onClearCalled).to.equal(true)
	end)
end
