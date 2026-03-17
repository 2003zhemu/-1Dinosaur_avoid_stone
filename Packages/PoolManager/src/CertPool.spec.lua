local Pool = require(script.Parent.CertPool)
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

	it("test return will clear the index ", function()
		local pool = Pool.new(poolConfig)
		local obj = pool:RentWithCertification(1)
		pool:TryAllocateByCertification(1)
		pool:Rent()
		local obj2 = pool:RentWithCertification(1)
		expect(obj == obj2).to.equal(false)
	end)

	it("test return will clear the index 2", function()
		local pool = Pool.new(poolConfig)
		local obj = pool:Rent(1, 2, 3)
		pool:TryAllocateByCertification(1)
		pool:Rent()
		local obj2 = pool:RentWithCertification(1, 2, 3)
		expect(obj == obj2).to.equal(false)
	end)

	it("rent with cert", function()
		local pool = Pool.new(poolConfig)
		local cert = {}
		local a1 = pool:RentWithCertification(cert)
		local a2 = pool:RentWithCertification(cert)
		expect(pool:Count()).to.equal(1)
		expect(pool:Count("notrented")).to.equal(0)
		expect(a1).to.be.ok(a2)
	end)

	it("TryAllocateByCertification() will be ok 1", function()
		local onReturnCalled = false
		poolConfig.OnReturnHandler = function()
			onReturnCalled = true
		end
		local pool = Pool.new(poolConfig)
		local obj = pool:RentWithCertification(1)
		expect(pool:Count("rented")).to.equal(1)
		expect(pool:Count("not rented")).to.equal(0)
		expect(pool:Count()).to.equal(1)
		local isAllocated = pool:TryAllocateByCertification(1)
		expect(isAllocated).to.equal(true)

		expect(onReturnCalled).to.equal(true)
		expect(pool:Count()).to.equal(1)
		expect(pool:Count("not rented")).to.equal(1)
	end)

	it("TryAllocateByCertification() will be ok 2", function()
		local onReturnCalled = false
		poolConfig.OnReturnHandler = function()
			onReturnCalled = true
		end
		local pool = Pool.new(poolConfig)
		local obj = pool:RentWithCertification(1)
		local obj2 = pool:RentWithCertification(2)
		local isAllocated = pool:TryAllocateByCertification(1)
		local isAllocated2 = pool:TryAllocateByCertification(2)
		expect(isAllocated).to.equal(true)
		expect(isAllocated2).to.equal(true)

		expect(onReturnCalled).to.equal(true)
		expect(pool:Count()).to.equal(2)
		expect(pool:Count("not rented2")).to.equal(2)
	end)

	it("TryAllocateByCertification() will be  ok 3", function()
		local onReturnCalled = false
		poolConfig.OnReturnHandler = function()
			onReturnCalled = true
		end
		local pool = Pool.new(poolConfig)
		pool:RentWithCertification(1)
		pool:RentWithCertification(2)
		pool:TryAllocateByCertification(1)
		pool:TryAllocateByCertification(2)
		local a = pool:RentWithCertification(1)
		local b = pool:RentWithCertification(1)
		expect(a).to.equal(b)
		local isAllocated = pool:TryAllocateByCertification(1)
		expect(isAllocated).to.equal(true)
		pool:RentWithCertification(2)
		expect(pool:Count("not rented2")).to.equal(1)
	end)
end
