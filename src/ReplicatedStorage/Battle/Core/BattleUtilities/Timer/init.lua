local module = {}
module.Loop = function(wolrd, state, context, firstDelay, intervalTime, Func, params)
	firstDelay = firstDelay or intervalTime
	wolrd:spawn(context.Components.TimerLoop({
		TriggerTime = context.GameTime.time + firstDelay,
		Interval = intervalTime,
		Func = Func,
		Params = params,
	}))
end
module.Delay = function(wolrd, state, context, delayTime, Func, params)
	wolrd:spawn(context.Components.TimerDelay({
		TriggerTime = context.GameTime.time + delayTime,
		Func = Func,
		Params = params,
	}))
end
return module
