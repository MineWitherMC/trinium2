local api = trinium.api
local machines = trinium.machines
local S = machines.S
local recipes = trinium.recipes

local def, destruct, r_input, r_output, r_data = machines.parse_multiblock{
	controller = "trinium_machines:controller_precision_assembler",
	casing = "trinium_machines:casing_pressure",
	size = {front = 0, back = 3, up = 1, down = 1, sides = 1},
	min_casings = 27,
	addon_map = {
		{x = 0, z = 1, y = 0, name = "air"},
		{x = 0, z = 2, y = 0, name = "air"},
	},
	color = 159,
	hatches = {"input.pressure", "input.item", "output.item", "input.heat"},
}

recipes.add_method("precision_assembler", {
	input_amount = 8,
	output_amount = 1,
	get_input_coords = recipes.coord_getter(4, -1, 0),
	get_output_coords = recipes.coord_getter(1, 4.5, 0.5),
	formspec_width = 7,
	formspec_height = 5,
	formspec_name = S"Precision Assembler",
	formspec_begin = function(data)
		local tbl = {}
		table.insert(tbl, S("Time: @1 seconds", data.time))
		if data.pressure then table.insert(tbl, S("Pressure: @1-@2 kPa",
				(data.pressure - data.pressure_tolerance) * 100, (data.pressure + data.pressure_tolerance) * 100
		)) end
		if data.temperature then table.insert(tbl, S("Temperature: @1-@2 K",
				data.temperature - data.temperature_tolerance, data.temperature + data.temperature_tolerance
		)) end
		return ("textarea[1,3.5;6,1.5;;;%s]"):format(table.concat(tbl, "\n"))
	end,
	implementing_objects = {"trinium_machines:controller_precision_assembler"},
})

minetest.register_node("trinium_machines:controller_precision_assembler", {
	description = S"Precision Assembler Controller",
	groups = {cracky = 1},
	sounds = trinium.sounds.default_metal,
	tiles = {
			{name = "trinium_machines.casing.png", color = "#494949"}, {name = "trinium_machines.casing.png", color = "#494949"},
			{name = "trinium_machines.casing.png", color = "#494949"}, {name = "trinium_machines.casing.png", color = "#494949"},
			{name = "trinium_machines.casing.png", color = "#494949"},
			{name = "trinium_machines.casing.png^[multiply:#494949^trinium_machines.precision_assembler_const_overlay.png",
					color = "white"}},
	overlay_tiles = {"", "", "", "", "", "trinium_machines.precision_assembler_overlay.png"},
	palette = "trinium_api.palette8.png",
	paramtype2 = "colorfacedir",
	color = "white",
	on_destruct = destruct,

	on_timer = function(pos)
		local meta, timer = minetest.get_meta(pos), minetest.get_node_timer(pos)
		local hatches = meta:get_string"hatches":data()
		if not hatches or not hatches["input.item"][1] then return end

		local output = meta:get_string"output"
		if output ~= "" then
			meta:set_string("output", "")
			output = output:split";"
			local outputs = table.map(hatches["output.item"], function(x) return minetest.get_meta(x):get_inventory() end)

			local good
			for i = 1, #output do
				if output[i] ~= "" then
					good = false
					for j = 1, #outputs do
						if outputs[j]:room_for_item("output", output[i]) then
							outputs[j]:add_item("output", output[i])
							good = true
							break
						end
					end
					if not good then return end
				end
			end
		end

		local input = minetest.get_meta(hatches["input.item"][1]):get_inventory()
		local input_map = api.inv_to_itemmap(input:get_list"input")
		local temp, pressure = hatches["input.heat"][1], hatches["input.pressure"][1]
		temp = temp and minetest.get_meta(temp):get_int"temperature" or -1
		pressure = pressure and minetest.get_meta(pressure):get_int"pressure" or -1

		local pa_recipes = recipes.recipes_by_method.precision_assembler
		local vars, func = api.exposed_var()
		table.iwalk(pa_recipes, function(v)
			local rec = recipes.recipe_registry[v]
			if not recipes.check_inputs(input_map, rec.inputs) then return end
			local data = rec.data
			local time_div = 1

			if data.temperature then
				if temp == -1 then return end
				time_div = time_div * math.harmonic_distribution(data.temperature, data.temperature_tolerance, temp)
			end
			--[[if data.pressure then
				if pressure == -1 then return end
				time_div = time_div * math.harmonic_distribution(data.pressure, data.pressure_tolerance, pressure)
			end]]--
			if time_div < 0.005 then return end
			local time = ((data.temperature or data.pressure) and 1 / 2 or 1) * data.time / time_div
			timer:stop()
			timer:start(time)
			recipes.remove_inputs(input, "input", rec.inputs)
			meta:set_string("output", rec.outputs_string)
			api.recolor_facedir(pos, 2)
			vars.good = false
		end, func)
		if vars.good then api.recolor_facedir(pos, 7) end
	end,
})

api.add_multiblock("precision assembler", def)
recipes.add("greggy_multiblock", r_input, r_output, r_data)
api.multiblock_rich_info"trinium_machines:controller_precision_assembler"
