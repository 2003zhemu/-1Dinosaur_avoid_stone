local panelManager = require(script.Parent.PanelManager)

local module = {
	

	-- 展示文字消息，该消息会慢慢消失
	-- 参数1: 消息内容
	-- 参数2: 面板名称，该面板必须为消息类型面板，将使用该面板展示消息.
	-- 参数3: 面板中将展示该ui对象，如果参数为数字，将使用该数字创建Image,并传递给面板
	ShowTextInfo= function(text:string,panelName:string?,uiObject:GuiBase|number|nil,...):()
		panelManager.OpenPanel("MessagePanel",text)
	end,

	-- 展示文字消息，该消息会慢慢消失
	-- 参数按照顺序为： panelName:string,text:string,uiObject:GuiBase?|number?,...any
	ShowTextInfoByArray= function(options:{}):()
	end,

	-- 展示提示信息
	ShowMessageBox= function(message:string,title:string?, hasCancle:boolean?,...):(boolean)
		return true
	end,

	-- 展示输入信息
	-- 用户输入并提交后，返回结果
	-- 如果用户取消输入，则返回空
	ShowInputBox= function(message:string,title:string?,hasCancle:boolean?,...):(string)
	end,
}

return module
