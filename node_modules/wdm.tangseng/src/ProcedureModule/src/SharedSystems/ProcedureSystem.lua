
local Components = require(script.Parent.Parent.Components)

local config = require(script.Parent.Parent.ProcedureManagerConfig)

local Matter = require(game.ReplicatedStorage.Packages.Matter)

local handlers = nil

if game["Run Service"]:IsServer() then
	handlers = config.ServerHandlers
else
	handlers = config.ClientHandlers
end



local function updateProcedure(world,_,ui)
	for id,procedure,payload in world:query(Components.Procedure,Components.ProcedurePayload) do
		
		-- ui,only server
		if game["Run Service"]:IsServer() then
			ui.window("Procedure", function()
				for k,v in config.ProcedureNames do
					if ui.checkbox(v, {
						checked = v == procedure.Current,
						}):clicked() then
						local server = require(script.Parent.Parent.Server)
                         server.ChangeProcedure(procedure.Player,v)
						return
					end
				end
            end)
        else
            local i=1
		end
        
        local changed = false
		
		-- 如果存在 Previous，则调用 OnExit 方法
        if procedure.Previous then
            
            local canRun = handlers[procedure.Previous] and handlers[procedure.Previous]["OnExit"]
        
            
            -- 调用 OnExit
			if canRun then
                local result = handlers[procedure.Previous]["OnExit"](procedure,payload)
       
                assert(type(result)=="table" or result == nil,"Payload 必须为 table or nil")
                payload = Components.ProcedurePayload(result)
            end
            
            -- 移除Previous
            procedure = procedure:patch({
                Previous = Matter.None
            })
            
            
            if game["Run Service"]:IsServer() then
                world:insert(id,procedure,payload)
            end
            return
		end
		
		-- 如果未调用，则调用 OnEnter 方法
        if not procedure.IsEnter then
            
            local canRun = handlers[procedure.Current] and handlers[procedure.Current]["OnEnter"]
            -- 设置IsEnter
            procedure = procedure:patch({
                IsEnter = true
            })
            
            -- 调用 OnEnter
			if canRun then
                local result = handlers[procedure.Current]["OnEnter"](procedure,payload)
                assert(type(result)=="table" or result == nil,"Payload 必须为 table or nil")
                payload = Components.ProcedurePayload(result)
            end	
            
            if game["Run Service"]:IsServer() then
                world:insert(id,procedure,payload)
            end
            return
        end
        


	
		-- 每帧调用
        if handlers[procedure.Current] and handlers[procedure.Current]["OnUpdate"] then
			handlers[procedure.Current]["OnUpdate"]()			
		end
	end
end

return {
	system = updateProcedure,
	priority = math.huge - 1
}
