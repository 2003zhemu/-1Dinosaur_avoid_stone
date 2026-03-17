

local module = {}


module.Init = {}

local single =  {
	Visible = false,
	Close = function()
		-- GUI

	end,
	Gui = nil,
	Open = function()
		-- clone gui

	end,
}

module.GetViewObject = function ()
	return single
end

return module
