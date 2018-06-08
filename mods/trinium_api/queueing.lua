local api = trinium.api
local queue = {} -- no need to make it global

function api.send_init_signal()
	local mod = minetest.get_current_modname()
	if queue[mod] then
		for i = 1, #queue[mod] do
			queue[mod][i]()
		end
		queue[mod] = nil
	end
end

function api.init_wrap(func, ...)
	local args = {...}
	return function()
		func(unpack(args))
	end
end

function api.delayed_call(modname, func, ...)
	if not minetest.get_modpath(modname) then return end -- simplest compat ever!
	if not queue[modname] then queue[modname] = {} end
	table.insert(queue[modname], api.init_wrap(func, ...))
end
