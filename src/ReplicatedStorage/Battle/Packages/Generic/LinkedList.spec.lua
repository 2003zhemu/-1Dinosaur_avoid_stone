return function()
	local LinkedList = require(script.Parent.LinkedList)

	-- 运行每个测试前的初始化
	beforeEach(function() end)

	-- 运行每个测试后的清理
	afterEach(function() end)

	it("delete item  exist", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Prepend(0)
		list:Append(2)
		expect(list:Delete(1)).to.equal(true)
	end)

	it("delete item not exist", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Prepend(0)
		list:Append(2)
		expect(list:Delete(5)).to.equal(false)
	end)

	it("should append and prepend values ", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Prepend(0)
		list:Append(2)
		expect(list.head.Data).to.equal(0)
		expect(list.tail.Data).to.equal(2)
		expect(list:Count()).to.equal(3)
	end)

	it("should find and delete values", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Append(2)
		list:Append(3)

		local foundNode = list:Find(2)
		expect(foundNode.Data).to.equal(2)

		local result = list:Delete(2)
		expect(result).to.be.ok()
		expect(list:Find(2)).to.equal(nil)
		expect(list:Count()).to.equal(2)
	end)

	it("should add values at the end", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Append(2)

		list:Append(3)
		expect(list.tail.Data).to.equal(3)
		expect(list:Count()).to.equal(3)
	end)

	it("should initialize an empty list", function()
		local list = LinkedList.new()
		expect(list:IsEmpty()).to.be.ok()
		expect(list:Count()).to.equal(0)
	end)

	it("should append, prepend, and maintain size correctly", function()
		local list = LinkedList.new()
		list:Append(1)

		list:Prepend(0)
		list:Append(3)

		expect(list.head.Data).to.equal(0)
		expect(list.head.Next.Data).to.equal(1)
		expect(list.tail.Data).to.equal(3)
		expect(list:Count()).to.equal(3)
	end)

	it("should delete head, middle and tail nodes correctly", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Append(2)
		list:Append(3)

		list:Delete(1) -- Delete head
		expect(list.head.Data).to.equal(2)
		expect(list:Count()).to.equal(2)

		list:Delete(3) -- Delete tail
		expect(list.tail.Data).to.equal(2)
		expect(list:Count()).to.equal(1)

		list:Delete(2) -- Delete only remaining node (which is head and tail)
		expect(list:IsEmpty()).to.be.ok()
		expect(list:Count()).to.equal(0)
	end)

	it("should handle deletions for non-existent data", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Append(2)

		local result = list:Delete(3) -- Non-existent data
		expect(result).to.equal(false)
		expect(list:Count()).to.equal(2)
	end)

	it("should find nodes correctly", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Append(2)
		list:Append(3)

		local node = list:Find(2)
		expect(node.Data).to.equal(2)
		expect(node.Prev.Data).to.equal(1)
		expect(node.Next.Data).to.equal(3)
	end)

	it("should add values before a specified node", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Append(3)

		list:AddBefore(3, 2)
		expect(list.head.Next.Data).to.equal(2)
		expect(list:Count()).to.equal(3)
	end)

	it("should handle 'AddBefore'  for non-existent data", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Append(3)
		expect(list:Count()).to.equal(2)

		local result = list:AddBefore(4, 2) -- Non-existent data 4
		expect(result).to.equal(false)
		expect(list:Count()).to.equal(2)
	end)

	it("should maintain list consistency when various operations are performed", function()
		local list = LinkedList.new()
		list:Append(1)
		list:Append(2)
		list:Append(3)
		list:Append(4)
		list:Append(5)

		list:Delete(3)
		list:AddBefore(4, 3)
		list:Prepend(0)
		list:Append(6)

		expect(list.head.Data).to.equal(0)
		expect(list.head.Next.Data).to.equal(1)
		expect(list.tail.Prev.Data).to.equal(5)
		expect(list.tail.Data).to.equal(6)
		expect(list:Count()).to.equal(7)
	end)
end
