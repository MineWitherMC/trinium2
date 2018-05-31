local api = trinium.api
local machines = trinium.machines
local S = machines.S
local recipes = trinium.recipes

local def, destruct = machines.parse_multiblock{
	controller = "trinium_machines:controller_chemicalreactor",
	casing = "trinium_machines:casing_chemical",
	size = {front = 0, back = 2, up = 1, down = 1, sides = 1},
	min_casings = 19,
	air_positions = {{x = 0, z = 1, y = 0}},
	color = 179,
	hatches = {"input.pressure", "input.item", "output.item", "input.heat"},
}

recipes.add_method("chemical_reactor", {
	input_amount = 4,
	output_amount = 4,
	get_input_coords = function(n)
		return recipes.get_coords(2, 0, 0, n)
	end,
	get_output_coords = function(n)
		return recipes.get_coords(2, 3, 0, n)
	end,
	formspec_width = 7,
	formspec_height = 5,
	formspec_name = S"Chemical Reactor",
	formspec_begin = function(data)
		local catalyst
		if not data.catalyst then
			catalyst = S"No catalyst needed"
		else
			local catalyst_item = minetest.registered_items["trinium_materials:catalyst_"..data.catalyst]
			if not catalyst_item then
				catalyst = "This recipe is broken, blame author of "..data.author_mod
			else
				catalyst = catalyst_item.description:split("\n")[1]
			end
		end
		local tbl = {}
		table.insert(tbl, S("Time: @1 seconds", data.time))
		if data.pressure then table.insert(tbl, S("Pressure: @1-@2 Bar",
				data.pressure - data.pressure_tolerance, data.pressure + data.pressure_tolerance
		)) end
		if data.temperature then table.insert(tbl, S("Temperature: @1-@2 K",
				data.temperature - data.temperature_tolerance, data.temperature + data.temperature_tolerance
		)) end
		return ("label[1,3.5;%s\n%s]"):format(catalyst, table.concat(tbl, "\n"))
	end,
})

minetest.register_node("trinium_machines:controller_chemicalreactor", {
	description = S"Chemical Reactor Controller",
	groups = {cracky = 1},
	tiles = {{name = "trinium_machines.casing.png", color = "#5575ff"}},
	overlay_tiles = {"", "", "", "", "", "trinium_machines.chemical_reactor_overlay.png"},
	palette = "trinium_api.palette8.png",
	paramtype2 = "colorfacedir",
	color = "white",
	on_destruct = destruct,

	on_timer = function(pos, elapsed)
		local meta, timer = minetest.get_meta(pos), minetest.get_node_timer(pos)
		local hatches = meta:get_string"hatches":data()
		if not hatches or not hatches["input.item"] then return end

		local output = meta:get_string"output"
		if output ~= "" then
			meta:set_string("output", "")
			local output = output:split";"
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

		local crrec = recipes.recipes_by_method.chemical_reactor
		local vars, func = api.exposed_var()
		table.iwalk(crrec, function(v)
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
			local time = ((data.temperature or data.pressure) and 1/2 or 1) * data.time / time_div
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