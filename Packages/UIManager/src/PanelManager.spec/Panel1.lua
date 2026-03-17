local module = {}

module.Init = {}

local single =  {
	Visible = false,
	Gui = nil,
	Close = function()
		-- GUI
		
	end,

	Open = function()
		-- clone gui
		
	end,
}

module.GetViewObject = function ()
   return single
end


return module