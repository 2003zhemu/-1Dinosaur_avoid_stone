local module = {}


local RunService= game:GetService("RunService")
local Zone =require(script.Zone)
local Defines =require(script.Parent.Defines)
local ProximityDetectionService =require(game.ReplicatedStorage.Packages.ProximityDetectionService)
local ProximityDefines =require(game.ReplicatedStorage.Packages.ProximityDetectionService.Defines)
local bindableEvent=Instance.new("BindableEvent")
--创建一个空的区域检测的缓存表
local ZoneCache ={}

--创建一个鼠标点击触发器
--ClickButton 为触发器的BasePart或者是Button
module.CreateMouseClickSource = function(ClickButton:ImageButton|TextButton|BasePart)
	
	if ClickButton:IsA("BasePart") then
		local part = ClickButton
		ClickButton = ClickButton:FindFirstChildOfClass("ClickDetector")
		if ClickButton == nil then
			ClickButton=Instance.new("ClickDetector",part)
		end
		
		local connect = function(func)
			ClickButton.MouseClick:Connect(func)
		end
	
		local disConnect = function()
			ClickButton.MouseClick:Disconnect()
		end
		local source:Defines.EventSource ={
			_Connect=connect,
			_Disconnect=disConnect
	
		}  
		return source
	else
		local connect = function(func)
		ClickButton.MouseButton1Down:Connect(func)
	end

	local disConnect = function()
		ClickButton.MouseButton1Down:Disconnect()
	end
	local source:Defines.EventSource ={
		_Connect=connect,
		_Disconnect=disConnect

	}  
	return source

	end

	
end


module.CreateKeyboardSource = function(key:string)
	
	
	print(key)

end

local function IgnoreY (vector3: Vector3)
	-- 忽略Vector3的y轴(即将Y设为0)
	
	return Vector3.new(vector3.X, 0, vector3.Z)

end


--创建一个距离触发器
--part 为触发器的Part
--distance 为触发器的距离
module.CreateDistanceSource =function(part:Part,distance:number)
	local player =game.Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	
	local connect =nil
	
	local _connect =function(func:()->())
		
		local isshow =false

		local function HandleGachaShowOrHide(part: BasePart, HumanoidRootPartPos: Vector3,func)

			local dPos = IgnoreY(HumanoidRootPartPos - part:GetPivot().Position)
			local dist = dPos.Magnitude
			if dist <= distance and isshow==false then
				isshow =true
			
				func(true,part)
			elseif dist > distance and isshow==true then
				isshow =false
				func(false,part)
			end

		end
		
		connect = RunService.Heartbeat:Connect(function()	
			
			if character == nil then return end
			local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
			if humanoidRootPart == nil then return end
			local humanoidRootPartPos = humanoidRootPart.Position
			HandleGachaShowOrHide(part, humanoidRootPartPos,func)
		end)
	end

	local _disconnect= function()
		connect:Disconnect()
	end
	
	local source:Defines.EventSource ={
		_Connect=_connect,
		_Disconnect=_disconnect
		
	}  

	return source
end

--使用Zone创建一个玩家进入某个区域触发器
--zonePart 为区域的Part 
module.CreatePlayerEnterZoneSource =function(zonePart:Part)
    local SearchRegion=nil
    local connect =nil

	--在区域检测缓存中查询是否存在该区域的检测,如果存在则直接返回，不存在就创建一个新的区域检测，将其加入缓存，缓存中key值为数值，value为一张表存放zonePart和SearchRegion
	for i,v in pairs(ZoneCache) do
		if v[1] == zonePart then
			SearchRegion = v[2]
			break
		end
	end
	--如果没有查到，就创建一个新的区域检测
	if SearchRegion == nil then
		SearchRegion= Zone.new(zonePart)
		table.insert(ZoneCache,{zonePart,SearchRegion})
	end
	
	
	
    local _connect =function(func:()->())
        local connect =SearchRegion.playerEntered:Connect(function(char)
			func(char)
        end)
    
    end
      
	local _disconnect= function()
		connect:Disconnect()
	end
	
	local source:Defines.EventSource ={
		_Connect=_connect,
		_Disconnect=_disconnect
		
	}  
	return source
end

--使用Zone创建一个玩家离开某个区域触发器
--zonePart 为区域的Part 
module.CreatePlayerLeaveZoneSource =function(zonePart:Part)
	local SearchRegion=nil
    local connect =nil
	
	--在区域检测缓存中查询是否存在该区域的检测,如果存在则直接返回，不存在就创建一个新的区域检测，将其加入缓存，缓存中key值为数值，value为一张表存放zonePart和SearchRegion
	for i,v in pairs(ZoneCache) do
		if v[1] == zonePart then
			SearchRegion = v[2]
			break
		end
	end
	--如果没有查到，就创建一个新的区域检测
	if SearchRegion == nil then
		SearchRegion= Zone.new(zonePart)
		table.insert(ZoneCache,{zonePart,SearchRegion})
	end
	

    local _connect =function(func:()->())
        connect =SearchRegion.playerExited:Connect(function(char)
			func(char)
        end)
    
    end
      
	local _disconnect= function()
		connect:Disconnect()
	end
	
	local source:Defines.EventSource ={
		_Connect=_connect,
		_Disconnect=_disconnect
		
	}  
	return source
end

--创建一个基于ProximityPrompt的距离触发器
--name 为触发器的名字
--instance 为触发器的Part
--distance 为触发器的距离
module.CreateDistanceSourceByProximityPrompt =function(name:string,instance:BasePart|Model,distance:number)
	local options:ProximityDefines.Options ={}

	local connect =nil
	options.Distance = distance
	
	options.Away = function()
		bindableEvent:Fire(name,false)
	end
	options.Close = function()
		bindableEvent:Fire(name,true)
	end
	options.Group=nil

	local detection= ProximityDetectionService:createDetection(name,instance,options)

	local _connect =function(func:()->())
		detection:activate()
		connect = bindableEvent.Event:Connect(function(eventname: string, isShow: boolean)
			if eventname == name then
				func(isShow)
			end
		end)

	end

	local _disconnect =function()
		detection:deactivate()
		connect:Disconnect()
	end

	

	local source:Defines.EventSource ={
		_Connect=_connect,
		_Disconnect=_disconnect
		
	}  
	return source
	
end

return module
