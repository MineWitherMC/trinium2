local api = trinium.api
local machines = trinium.machines
local S = machines.S
local recipes = trinium.recipes

local def, destruct, input, output, data = machines.parse_multiblock{
	controller = "trinium_machines:controller_distillationtower",
	casing = "trinium_machines:casing_chemical",
	size = {front = 0, back = 2, up = 1, down = 0, sides = 1},
	min_casings = 13,
	addon_map = {
		{x = 0, z = 1, y = 1, name = "hatch:output.item"},
		{x = 0, z = 1, y = 0, name = "trinium_machines:casing_distillation"},
	},
	color = 179,
	hatches = {"input.item"},
	fake_hatches = {"output.item"},
}

recipes.add_method("distillation_tower", {
	input_amount = 1,
	output_amount = 12,
	get_input_coords = recipes.coord_getter(1, -1, 1),
	get_output_coords = recipes.coord_getter(4, 1.5, 0),
	formspec_width = 7,
	formspec_height = 4.5,
	formspec_name = S"Distillation",
	formspec_begin = function(data)
		return ("textarea[0.25,3;6.75,1.5;;;%s\n%s]"):format(S("Pressure: @1-@2 kPa",
				(data.pressure - data.pressure_tolerance) * 100, (data.pressure + data.pressure_tolerance) * 100),
				S("Maximum recovery: @1", data.recovery))
	end,

	process = function(a, outputs, data)
		data.output_tooltips = {}

		for i = 1, #outputs do
			if data.temperatures[i] ~= -1 then
				data.output_tooltips[i] = api.get_field(outputs[i], "description").."\n"..
						minetest.colorize("#808080", S("Temperature: @1-@2K",
								data.temperatures[i] - 5, data.temperatures[i] + 5))
			else
				data.output_tooltips[i] = api.get_field(outputs[i], "description").."\n"..
						minetest.colorize("#808080", S("Extracted from upper Output Bus"))
			end
		end

		return a, outputs, data
	end,
})

local distillation_random = PcgRandom(math.random() * 10^8)
minetest.register_node("trinium_machines:controller_distillationtower", {
	description = S"Distillation Tower Controller",
	groups = {cracky = 1},
	tiles = {{name = "trinium_machines.casing.png", color = "#5575ff"}},
	overlay_tiles = {"", "", "", "", "", "trinium_machines.distillation_tower_overlay.png"},
	palette = "trinium_api.palette8.png",
	paramtype2 = "colorfacedir",
	color = "white",
	on_destruct = function(pos)
		local node
		repeat
			destruct(pos)
			minetest.get_meta(pos):from_table()
			pos = vector.add(pos, {x = 0, y = -1, z = 0})
			node = minetest.get_node(pos).name
		until node ~= "trinium_machines:controller_distillationlayer"
	end,

	on_timer = function(pos, elapsed)
		local meta, timer = minetest.get_meta(pos), minetest.get_node_timer(pos)
		local hatches = meta:get_string"hatches":data()
		if not hatches or not hatches["input.item"][1] then return end

		local output = meta:get_string"output"
		if output ~= "" then
			meta:set_string("output", "")
			local outputinv = minetest.get_meta(hatches["output.item"][1]):get_inventory()
			if outputinv:room_for_item("output", output) then
				outputinv:add_item("output", output)
			else
				api.recolor_facedir(pos, 3)
				return
			end
		end

		local input = minetest.get_meta(hatches["input.item"][1]):get_inventory()
		local input_map = api.inv_to_itemmap(input:get_list"input")

		local dtrec = recipes.recipes_by_method.distillation_tower
		local vars, func = api.exposed_var()
		table.iwalk(dtrec, function(v)
			local rec = recipes.recipe_registry[v]
			if not input_map[rec.inputs[1]] then return end
			if input_map["trinium_materials:cell_empty"] < rec.data.recovery - 1 then return end
			local data = rec.data

			local metas, timers = {}, {}
			for i = 2, #rec.outputs do
				local pos2 = vector.add(pos, vector.multiply({x = 0, y = -1, z = 0}, i - 1))
				local node = minetest.get_node(pos2).name
				if node ~= "trinium_machines:controller_distillationlayer" then
					api.recolor_facedir(pos, 3)
					return
				end
				metas[i - 1]  = minetest.get_meta(pos2)
				timers[i - 1] = minetest.get_node_timer(pos2)
				local hatches2 = metas[i - 1]:get_string"hatches":data()
				if not hatches2 then
					api.recolor_facedir(pos2, 3)
					return
				end
				local h = hatches2["input.heat"][1]
				if not hatches2 then
					api.recolor_facedir(pos2, 3)
					return
				end

				h = minetest.get_meta(h):get_int"temperature"
				if rec.data.temperatures[i] - 5 > h or rec.data.temperatures[i] + 5 < h then
					api.recolor_facedir(pos2, 3)
					return
				end

				api.recolor_facedir(pos2, 6)
			end

			timer:stop()
			timer:start(20)
			input:remove_item("input", rec.inputs[1])
			input:remove_item("input", "trinium_materials:cell_empty "..(rec.data.recovery - 1))

			local cache = {}
			local j = 0
			repeat
				local k = distillation_random:next(1, #rec.outputs)
				if not cache[k] then
					cache[k] = 1
					j = j + 1
					if k == 1 then
						meta:set_string("output", rec.outputs[1])
					else
						timers[k - 1]:stop()
						timers[k -1]:start(19)
						metas[k - 1]:set_string("output", rec.outputs[k])
					end
				end
			until j == rec.data.recovery
			api.recolor_facedir(pos, 2)

			vars.good = false
		end, func)
		if vars.good then api.recolor_facedir(pos, 7) end
	end,
})

api.register_multiblock("distillation layer", def)
recipes.add("greggy_multiblock", input, output, data)
