local api = trinium.api
local machines = trinium.machines
local S = machines.S
local recipes = trinium.recipes

local def, destruct, r_input, r_output, r_data = machines.parse_multiblock{
	controller = "trinium_machines:controller_chemical_reactor",
	casing = "trinium_machines:casing_chemical",
	size = {front = 0, back = 2, up = 1, down = 1, sides = 1},
	min_casings = 19,
	addon_map = {
		{x = 0, z = 1, y = 0, name = "air"},
	},
	color = 179,
	hatches = {"input.pressure", "input.item", "output.item", "input.heat"},
}

recipes.add_method("chemical_reactor", {
	input_amount = 4,
	output_amount = 4,
	get_input_coords = recipes.coord_getter(2, 0, 0),
	get_output_coords = recipes.coord_getter(2, 3, 0),
	formspec_width = 7,
	formspec_height = 5,
	formspec_name = S"Chemical Reactor",
	implementing_object = "trinium_machines:controller_chemical_reactor",

	formspec_begin = function(data)
		local tbl = {}
		if data.catalyst then
			local catalyst_item = minetest.registered_items["trinium_materials:catalyst_" .. data.catalyst]
			table.insert(tbl, catalyst_item.description:split("\n")[1])
		end
		table.insert(tbl, S("Time: @1 seconds", data.time))
		if data.pressure then table.insert(tbl, S("Pressure: @1-@2 kPa",
				(data.pressure - data.pressure_tolerance) * 100, (data.pressure + data.pressure_tolerance) * 100
		)) end
		if data.temperature then table.insert(tbl, S("Temperature: @1-@2 K",
				data.temperature - data.temperature_tolerance, data.temperature + data.temperature_tolerance
		)) end
		return ("textarea[1,3.5;6,1.5;;;%s]"):format(table.concat(tbl, "\n"))
	end,

	recipe_correct = function(data)
		return not data.catalyst or minetest.registered_items["trinium_materials:catalyst_" .. data.catalyst]
	end,
})

minetest.register_node("trinium_machines:controller_chemical_reactor", {
	description = S"Chemical Reactor Controller",
	groups = {cracky = 1},
	sounds = trinium.sounds.default_metal,
	tiles = {{name = "trinium_machines.casing.png", color = "#5575ff"}},
	overlay_tiles = {"", "", "", "", "", "trinium_machines.chemical_reactor_overlay.png"},
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

		local cr_recipes = recipes.recipes_by_method.chemical_reactor
		local vars, func = api.exposed_var()
		table.iwalk(cr_recipes, function(v)
			local rec = recipes.recipe_registry[v]
			if not recipes.check_inputs(input_map, rec.inputs) then return end
			local data = rec.data
			local time_div = 1

			if data.catalyst and not recipes.check_inputs(input_map, {"trinium_materials:catalyst_" .. data.catalyst}) then
				return
			end

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

api.register_multiblock("chemical reactor", def)
recipes.add("greggy_multiblock", r_input, r_output, r_data)
api.multiblock_rich_info"trinium_machines:controller_chemical_reactor"
