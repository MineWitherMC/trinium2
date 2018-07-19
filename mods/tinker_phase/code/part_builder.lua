local S = tinker.S
local api = trinium.api

local part_builder_formspec_basic = [[
	size[8,6.5]
	list[context;pattern;1.5,0.5;1,1;]
	list[context;inputs;3,0;1,2;]
	list[context;output;5.5,0.5;1,1;]
	image[0.5,0.5;1,1;tinker_phase.pattern_base.png^[brighten]
	image[4.25,0.5;1,1;trinium_gui.arrow.png]
	list[current_player;main;0,2.5;8,4;]
	listring[context;output]
	listring[current_player;main]
	listring[context;pattern]
]]

local part_builder_formspec_chest = [[
	size[13.5,6.5]
	list[context;pattern;1.5,0.5;1,1;]
	list[context;patterns;8.5,0.25;5,6;]
	list[context;inputs;3,0;1,2;]
	list[context;output;5.5,0.5;1,1;]
	image[0.5,0.5;1,1;tinker_phase.pattern_base.png^[brighten]
	image[4.25,0.5;1,1;trinium_gui.arrow.png]
	list[current_player;main;0,2.5;8,4;]
	listring[context;output]
	listring[current_player;main]
	listring[context;patterns]
	listring[context;pattern]
	listring[context;patterns]
]]

local function recalculate(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local pattern = table.concat(table.multi_tail(inv:get_stack("pattern", 1):get_name():split"_", 2), "_")
	local def = tinker.patterns[pattern]
	local count = inv:get_stack("inputs", 1):get_count() + inv:get_stack("inputs", 2):get_count()
	if not def or count < def.cost then
		inv:set_stack("output", 1, "")
	else
		local stack = ItemStack("tinker_phase:part_" .. pattern)
		local meta2 = stack:get_meta()
		local item = tinker.materials[inv:get_stack("inputs", 1):get_name()]
		item = item or tinker.materials[inv:get_stack("inputs", 2):get_name()]
		if not item then
			inv:set_stack("output", 1, "")
		else
			meta2:set_string("color", "#" .. item.color)
			meta2:set_string("description", S(def.description, item.description))
			meta2:set_string("material_data", minetest.serialize(item))
			inv:set_stack("output", 1, stack)
		end
	end
end

local function allow_put(pos, list_name, index, stack)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()

	local n = stack:get_name()
	if list_name == "pattern" or list_name == "patterns" then
		return minetest.get_item_group(n, "_tinker_phase_pattern")
	elseif list_name == "inputs" then
		local other = inv:get_stack("inputs", 3 - index)
		if not other:is_empty() and other:get_name() ~= n then return 0 end
		return minetest.get_item_group(n, "_tinker_phase_tool_material") * stack:get_count()
	else
		return 0
	end
end

local function on_take(pos, list_name)
	if list_name == "output" then
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pattern = table.concat(table.multi_tail(inv:get_stack("pattern", 1):get_name():split"_", 2), "_")
		local def = tinker.patterns[pattern]
		local c, l = def.cost, inv:get_list"inputs"

		if l[1]:get_count() >= c then
			l[1]:take_item(c)
			inv:set_stack("inputs", 1, l[1])
		else
			c = c - l[1]:get_count()
			l[2]:take_item(c)
			inv:set_stack("inputs", 1, "")
			inv:set_stack("inputs", 2, l[2])
		end
	end
	recalculate(pos)
end

minetest.register_node("tinker_phase:part_builder", {
	description = S"Part Builder",
	tiles = {"tinker_phase.parting_table.png", "tinker_phase.table_bottom.png", "tinker_phase.table_side.png"},
	sounds = trinium.sounds.default_wood,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, -0.25, 0.25, -0.25},
			{0.5, -0.5, -0.5, 0.25, 0.25, -0.25},
			{-0.5, -0.5, 0.5, -0.25, 0.25, 0.25},
			{0.5, -0.5, 0.5, 0.25, 0.25, 0.25},
			{-0.5, 0.25, -0.5, 0.5, 0.5, 0.5},
		}
	},
	groups = {choppy = 2},
	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		api.initialize_inventory(inv, {pattern = 1, inputs = 2, output = 1})
		meta:set_string("formspec", part_builder_formspec_basic)
	end,
	allow_metadata_inventory_put = allow_put,
	allow_metadata_inventory_move = function(_, from_list, _, to_list, _, count)
		return from_list == to_list and count or 0
	end,

	on_metadata_inventory_move = recalculate,
	on_metadata_inventory_put = recalculate,
	on_metadata_inventory_take = on_take,
})

minetest.register_node("tinker_phase:part_builder_with_chest", {
	description = S"Part Builder with Chest",
	tiles = {"tinker_phase.parting_table.png", "tinker_phase.table_bottom.png", "tinker_phase.table_side.png"},
	sounds = trinium.sounds.default_wood,
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, -0.25, 0.25, -0.25},
			{0.5, -0.5, -0.5, 0.25, 0.25, -0.25},
			{-0.5, -0.5, 0.5, -0.25, 0.25, 0.25},
			{0.5, -0.5, 0.5, 0.25, 0.25, 0.25},
			{-0.5, 0.25, -0.5, 0.5, 0.5, 0.5},
			{-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
		}
	},
	groups = {choppy = 2},
	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		api.initialize_inventory(inv, {pattern = 1, patterns = 30, inputs = 2, output = 1})
		meta:set_string("formspec", part_builder_formspec_chest)
	end,
	allow_metadata_inventory_put = allow_put,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, _, count)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return  (from_list == to_list or
				(from_list == "pattern" and to_list == "patterns") or
				(from_list == "patterns" and to_list == "pattern") or
				minetest.get_item_group(inv:get_stack(from_list, from_index), "_tinker_phase_pattern") > 0)
				and count or 0
	end,

	on_metadata_inventory_move = recalculate,
	on_metadata_inventory_put = recalculate,
	on_metadata_inventory_take = on_take,
})
