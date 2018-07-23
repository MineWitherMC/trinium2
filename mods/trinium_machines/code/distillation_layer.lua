local api = trinium.api
local machines = trinium.machines
local S = machines.S
local recipes = trinium.recipes

local def, destruct, r_input, r_output, r_data = machines.parse_multiblock{
	controller = "trinium_machines:controller_distillation_layer",
	casing = "trinium_machines:casing_chemical",
	size = {front = 0, back = 2, up = 0, down = 0, sides = 1},
	min_casings = 5,
	addon_map = {
		{x = 0, z = 1, y = 0, name = "trinium_machines:casing_distillation"},
	},
	color = 135,
	hatches = {"output.item", "input.heat"},
}

minetest.register_node("trinium_machines:controller_distillation_layer", {
	description = S"Distillation Layer Core",
	groups = {cracky = 1},
	sounds = trinium.sounds.default_metal,
	tiles = {{name = "trinium_machines.casing.png", color = "#9a00ff"}},
	overlay_tiles = {"", "", "", "", "", "trinium_machines.distillation_tower_overlay.png"},
	palette = "trinium_api.palette8.png",
	paramtype2 = "colorfacedir",
	color = "white",
	on_destruct = destruct,

	on_timer = function(pos)
		local meta = minetest.get_meta(pos)

		local hatches = meta:get_string"hatches":data()
		if not hatches or not hatches["output.item"][1] then return end

		local output = meta:get_string"output"
		if output ~= "" then
			local inv = minetest.get_meta(hatches["output.item"][1]):get_inventory()
			if inv:room_for_item("output", output) then
				inv:add_item("output", output)
			end
			meta:set_string("output", "")
		end
	end,
})

api.add_multiblock("distillation layer", def)
recipes.add("greggy_multiblock", r_input, r_output, r_data)
api.multiblock_rich_info"trinium_machines:controller_distillation_layer"
