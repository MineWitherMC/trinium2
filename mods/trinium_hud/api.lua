local hud = trinium.hud

hud.steps = {} -- Map
local steps = hud.steps
function hud.register_globalstep(name, def)
	steps[name] = def
	steps[name].counter = 0
end

local consistent = {} -- for very long globalsteps
minetest.register_globalstep(function(dtime)
	for k, v in pairs(steps) do
		if not consistent[k] then
			if v.consistent then consistent[k] = true end
			if v.counter <= 0 then
				v.callback(dtime)
				if type(v.period) == "function" then
					v.counter = v.period(v.counter)
				else
					v.counter = v.period
				end
			else
				v.counter = v.counter - dtime
			end
			consistent[k] = nil
		end
	end
end)

hud.configurators = {}
function hud.configurator(id, x, y, desc)
	hud.configurators[id] = {x = x, y = y, desc = desc, fields = {}}
	local z = {}
	local t = hud.configurators[id].fields

	function z:add(name, y1, label, callback)
		t[name] = {y = y1, label = label, func = callback}
	end

	return z
end