-- 双向链表，数据唯一

local LinkedList = {}
LinkedList.__index = LinkedList

-- 节点定义
local Node = {}
Node.__index = Node

-- 创建新的节点
function Node.new(data)
	local node = {
		Data = data,
		Prev = nil,
		Next = nil,
	}
	setmetatable(node, Node)
	return node
end

-- 创建新的双向链表
function LinkedList.new()
	local list = {
		head = nil,
		tail = nil,
		size = 0,
		cache = {}, -- 添加缓存
	}
	setmetatable(list, LinkedList)
	return list
end

-- 元素数量
function LinkedList:Count()
	return self.size
end

-- 检查链表是否为空
function LinkedList:IsEmpty()
	return self.size == 0
end

-- 在链表末尾添加节点
function LinkedList:Append(data)
	assert(not self.cache[data], "data already exists in the list")
	local newNode = Node.new(data)
	if not self.head then
		self.head = newNode
		self.tail = newNode
	else
		newNode.Prev = self.tail
		self.tail.Next = newNode
		self.tail = newNode
	end
	self.size = self.size + 1
	self.cache[data] = newNode -- 更新缓存
end

-- 在链表开头添加节点
function LinkedList:Prepend(data)
	assert(not self.cache[data], "data already exists in the list")
	local newNode = Node.new(data)
	if not self.head then
		self.head = newNode
		self.tail = newNode
	else
		newNode.Next = self.head
		self.head.Prev = newNode
		self.head = newNode
	end
	self.size = self.size + 1
	self.cache[data] = newNode -- 更新缓存
end

-- 删除指定数据的节点
function LinkedList:Delete(data)
	local current = self.head
	while current do
		if current.Data == data then
			if current.Prev then
				current.Prev.Next = current.Next
			else
				self.head = current.Next
			end

			if current.Next then
				current.Next.Prev = current.Prev
			else
				self.tail = current.Prev
			end
			self.size = self.size - 1
			self.cache[data] = nil -- 从缓存中移除
			return true
		end
		current = current.Next
	end
	return false
end

-- 查找指定数据的节点
function LinkedList:Find(data)
	return self.cache[data]
end

-- 查找最后一个节点
function LinkedList:Last()
	if self.tail then
		return self.tail.Data
	end
	return nil
end

-- 查找第一个节点
function LinkedList:First()
	if self.head then
		return self.head.Data
	end
	return nil
end

-- 在给定节点前添加新节点
function LinkedList:AddBefore(existingNodeData, newData)
	assert(not self.cache[newData], "data already exists in the list")
	local existingNode = self:Find(existingNodeData)
	if not existingNode then
		return false -- 如果不存在指定节点，则返回false
	end

	local newNode = Node.new(newData)
	newNode.Next = existingNode
	newNode.Prev = existingNode.Prev

	if existingNode.Prev then
		existingNode.Prev.Next = newNode
	else
		self.head = newNode -- 如果给定节点是头节点，则更新头节点
	end
	existingNode.Prev = newNode

	self.size = self.size + 1
	self.cache[newData] = newNode
	return true
end

return LinkedList
