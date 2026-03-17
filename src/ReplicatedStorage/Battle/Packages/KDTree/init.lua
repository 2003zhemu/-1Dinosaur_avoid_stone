type KDTreeNode = {
	_begin: number,
	_end: number,
	_left: number,
	_right: number,
	_maxX: number,
	_minX: number,
	_maxY: number,
	_minY: number,
}

local module = {}

local MAX_LEAF_SIZE=5
module.__index=module
module.New=function()
	local self=setmetatable({},module)
	self.Agents = {}
	self.AgentsTree = {}
	return self
end

function module:buildAgentTreeRecursive(Begin: number, End: number, Node: number)
	self.AgentsTree[Node]._begin = Begin
	self.AgentsTree[Node]._end = End
	self.AgentsTree[Node]._maxX = self.Agents[Node]._position.X
	self.AgentsTree[Node]._minX = self.AgentsTree[Node]._maxX
	self.AgentsTree[Node]._maxY = self.Agents[Node]._position.Y
	self.AgentsTree[Node]._minY = self.AgentsTree[Node]._maxY

	for i=Begin+1, End,1 do
		self.AgentsTree[Node]._maxX=math.max(self.AgentsTree[Node]._maxX,self.Agents[i]._position.X)
		self.AgentsTree[Node]._minX=math.max(self.AgentsTree[Node]._minX,self.Agents[i]._position.X)
		self.AgentsTree[Node]._maxY=math.max(self.AgentsTree[Node]._maxY,self.Agents[i]._position.Y)
		self.AgentsTree[Node]._minY=math.max(self.AgentsTree[Node]._minY,self.Agents[i]._position.Y)
	end

	--需要划分
	if End-Begin>MAX_LEAF_SIZE then
		local isVertical=self.AgentsTree[Node]._maxX-self.AgentsTree[Node]._minX>self.AgentsTree[Node]._maxY-self.AgentsTree[Node]._minY
		local splitValue=0.5*(isVertical and(self.AgentsTree[Node]._maxX+self.AgentsTree[Node]._minX) or(self.AgentsTree[Node]._maxY+self.AgentsTree[Node]._minY))
		local left=Begin
		local right=End
		while (left<right) do

			while right>left and (isVertical and self.Agents[left].position.X or self.Agents[left].position.Y)<splitValue do
				left+=1
			end
			while right>left and (isVertical and self.Agents[right-1].position.X or self.Agents[right-1].position.Y)>=splitValue do
				right-=1
			end
			if left<right then
				self.Agents[left],self.Agents[right-1]=self.Agents[right-1],self.Agents[left]
				left+=1
				right-=1
			end
		end
		local leftSize=left-Begin
		if leftSize==0 then
			leftSize+=1
			left+=1
			right+=1
		end

		self.AgentsTree[Node]._left=Node+1
		self.AgentsTree[Node]._right=Node+2*leftSize
		module.buildAgentTreeRecursive(Begin,left,self.AgentsTree[Node]._left)
		module.buildAgentTreeRecursive(left,End,self.AgentsTree[Node]._right)
	end
end

 function module:BuildAgentTree(position: { Vector2 }, entityIds: { number }, dirty: boolean)
	dirty = dirty or true

	if #position ~= #entityIds then
		error("position and entityIds must be same length")
	end
	if dirty then
		table.clear(self.Agents)
	end

	for i = 1, #position do
		self.Agents[i] = {
			_position = position[i],
			_entityId = entityIds[i],
		}
		table.insert(self.AgentsTree,{})
		table.insert(self.AgentsTree,{})
	end
	local agentCount = #self.Agents
	if agentCount > 0 then
		self:buildAgentTreeRecursive(1, agentCount+1, 0)
	end
end

export type KDTreeType=typeof(module)

return module