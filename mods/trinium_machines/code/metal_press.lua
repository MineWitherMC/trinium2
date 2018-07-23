local api = trinium.api
local machines = trinium.machines
local S = machines.S
local recipes = trinium.recipes

local item_buffer_fs = "size[8,8.5]list[context;main;1,0;6,4]list[current_player;main;0,4.5;8,4]listring[]"
minetest.register_node("trinium_machines:item_buffer", {
	tiles = {"conduits.buffer.png"},
	description = S"Item Buffer",
	groups = {cracky = 1, conduit_insert = 1, conduit_extract = 1},
	sounds = trinium.sounds.default_metal,
	after_place_node = api.initializer{main = 24, formspec = item_buffer_fs},
	conduit_insert = function()
		return "main"
	end,
	conduit_extract = {"main"},
})

local def, destruct, r_input, r_output, r_data = machines.parse_multiblock{
	controller = "trinium_machines:controller_industrial_metal_press",
	casing = "trinium_machines:casing_pressure",
	size = {front = 0, back = 2, up = 1, down = 1, sides = 1},
	min_casings = 20,
	addon_map = {
		{x = 0, z = 1, y = 0, name = "air"},
		{x = 0, z = 1, y = 1, name = "hatch:input.pressure"},
		{x = 0, z = 0, y = 1, name = "trinium_machines:item_buffer"},
	},
	color = 159,
	hatches = {"input.item", "output.item"},
	fake_hatches = {"input.pressure"},
}

recipes.add_method("industrial_metal_press", {
	input_amount = 2,
	output_amount = 2,
	get_input_coords = function(n)
		if n == 1 then
			return 3, 1
		else
			return 1.5, 2
		end
	end,
	get_output_coords = recipes.coord_getter(1, 3.5, 0.5),
	formspec_width = 7,
	formspec_height = 5,
	formspec_name = S"Industrial Metal Press",
	formspec_begin = function(data)
		local tbl = {}
		table.insert(tbl, S("Time: @1 seconds", data.time))
		table.insert(tbl, S("Pressure: @1-@2 kPa",
			(data.pressure - data.pressure_tolerance) * 100, (data.pressure + data.pressure_tolerance) * 100
		))
		return ("image[3,2;1,1;trinium_gui.arrow.png]textarea[2,3.5;5,1.5;;;%s]"):format(table.concat(tbl, "\n"))
	end,
	implementing_objects = {"trinium_machines:controller_industrial_metal_press"},
})

minetest.register_node("trinium_machines:controller_industrial_metal_press", {
	description = S"Industrial Metal Press Controller",
	groups = {cracky = 1},
	sounds = trinium.sounds.default_metal,
	tiles = {{name = "trinium_machines.casing.png", color = "#494949"}},
	overlay_tiles = {"", "", "", "", "", "trinium_machines.industrial_metal_press_overlay.png"},
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
		local second_input = minetest.get_meta(vector.add(pos, {x = 0, y = 1, z = 0})):get_inventory()
		local pressure = hatches["input.pressure"][1]
		if not pressure then return end
		pressure = minetest.get_meta(pressure):get_int"pressure" or -1

		local imp_recipes = recipes.recipes_by_method.industrial_metal_press
		local vars, func = api.exposed_var()
		table.iwalk(imp_recipes, function(v)
			local rec = recipes.recipe_registry[v]
			if not recipes.check_inputs(input_map, {rec.inputs[2]}) then return end
			if not second_input:contains_item("main", rec.inputs[1]:split" "[1]) then return end
			-- local time_div = math.harmonic_distribution(data.pressure, data.pressure_tolerance, pressure)
			local time_div = 1

			if time_div < 0.005 then return end
			local time = rec.data.time / time_div
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

api.add_multiblock("industrial metal press", def)
recipes.add("greggy_multiblock", r_input, r_output, r_data)
api.multiblock_rich_info"trinium_machines:controller_industrial_metal_press"
