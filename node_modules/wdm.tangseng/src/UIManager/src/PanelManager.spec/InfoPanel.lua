

local module = {}


module.Init = {}

module.GetViewObject = function ()
	
	local gui:GuiBase = nil -- get gui
	
	return {
		GUI = gui,
		
		Close = function()
			-- GUI
			gui:Destroy()
		end,
		
		Open = function()
			-- clone gui
			gui.Visible = true
		end,
	}
end


return module
