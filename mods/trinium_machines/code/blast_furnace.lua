local api = trinium.api
local machines = trinium.machines
local S = machines.S
local recipes = trinium.recipes

local def, destruct, r_input, r_output, r_data = machines.parse_multiblock{
	controller = "trinium_machines:controller_crude_blast_furnace",
	casing = "trinium_machines:casing_heat_brick",
	size = {front = 0, back = 2, up = 2, down = 1, sides = 1},
	min_casings = 28,
	addon_map = {
		{x = 0, z = 1, y = 0, name = "air"},
		{x = 0, z = 1, y = 1, name = "air"},
		{x = 0, z = 1, y = 2, name = "air"},
	},
	color = 100,
	hatches = {"input.item", "output.item"},
}

recipes.add_method("crude_blast_furnace", {
	input_amount = 2,
	output_amount = 12,
	get_input_coords = recipes.coord_getter(1, -1, 0.5),
	get_output_coords = recipes.coord_getter(4, 1.5, 0),
	formspec_width = 7,
	formspec_height = 4.5,
	formspec_name = S"Crude Blast Furnace",
	implementing_object = "trinium_machines:controller_crude_blast_furnace",
})

local melting_time = 12
minetest.register_node("trinium_machines:controller_crude_blast_furnace", {
	description = S"Crude Blast Furnace Controller",
	groups = {cracky = 1},
	sounds = trinium.sounds.default_stone,
	tiles = {{name = "trinium_machines.brick.png", color = "#c7b671"}},
	overlay_tiles = {"", "", "", "", "", "trinium_machines.blast_furnace_overlay.png"},
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

		local cbf_recipes = recipes.recipes_by_method.crude_blast_furnace
		local vars, func = api.exposed_var()
		table.iwalk(cbf_recipes, function(v)
			local rec = recipes.recipe_registry[v]
			if not recipes.check_inputs(input_map, rec.inputs) then return end

			timer:stop()
			timer:start(melting_time * table.sum(table.map(rec.outputs, function(x)
				return tonumber(x:split" "[2]) or 1
			end)))
			recipes.remove_inputs(input, "input", rec.inputs)
			meta:set_string("output", rec.outputs_string)
			api.recolor_facedir(pos, 5)
			vars.good = false
		end, func)
		if vars.good then api.recolor_facedir(pos, 0) end
	end,
})

api.register_multiblock("crude blast furnace", def)
recipes.add("greggy_multiblock", r_input, r_output, r_data)
api.multiblock_rich_info"trinium_machines:controller_crude_blast_furnace"
