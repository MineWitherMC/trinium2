local api = trinium.api
local queue = {} -- no need to make it global
local signals_sent = {}

function api.send_init_signal()
	local mod = minetest.get_current_modname()
	assert(not signals_sent[mod], "\n" .. mod .. " sent its init signal twice!")
	signals_sent[mod] = true
	if queue[mod] then
		for i = 1, #queue[mod] do
			queue[mod][i](mod)
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
	if type(modname) == "string" then
		modname = {modname}
	end
	local args = {...}
	if not table.every(modname, minetest.get_modpath) then return end
	local function wrap(mod)
		modname = table.remap(table.filter(modname, function(k) return k ~= mod end))
		if #modname == 0 then
			func(unpack(args))
		end
	end

	modname = table.remap(table.filter(modname, function(k) return not signals_sent[k] end))
	if #modname == 0 then func(...) end
	for i = 1, #modname do
		local mod = modname[i]
		queue[mod] = queue[mod] or {}
		table.insert(queue[mod], wrap)
	end
end
