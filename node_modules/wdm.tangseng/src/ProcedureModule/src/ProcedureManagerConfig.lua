local module = {}


-- 流程名称列表
module.ProcedureNames = {
	"Fighting",
	"Playing",
}

-- 默认流程名称
module.DefaultProcedure = "Playing"


module.ServerHandlers = {
    Fighting = {
        OnEnter = function(procedure)
            return {"Server Enter"};
		end,
        OnExit = function(procedure)
            return {"Server Exit"};
        end,
		OnUpdate = nil,
	}
}


module.ClientHandlers = {
    Fighting = {
        OnEnter = function(procedure,payload)
            print(procedure,payload)
        end,
        OnExit = function(procedure,payload)
            print(procedure,payload)
        end,
        OnUpdate = function()
            print("Update Fighting")
        end,
    }
}

return module
