local research = trinium.research
local S = research.S
local api = trinium.api
local M = trinium.materials.materials

local randomizer_formspec = ([=[
	size[8,6.7]
	image[0.5,0;1,1;%s]
	list[context;rhenium_alloy;0.5,1;1,1;]
	image[1.5,0;1,1;trinium_research.upgrade2.png^[brighten]
	list[context;upgrade;1.5,1;1,1;]
	image[6.5,0;1,1;trinium_research.press.png^[brighten]
	list[context;press;6.5,1;1,1;]
	list[current_player;main;0,2.7;8,4;]
	button[3.5,1;2,1;assemble_press;%s]
]=]):format(api.get_fs_texture(M.rhenium_alloy:get("ingot")), S"Randomize")

minetest.register_node("trinium_research:randomizer", {
	stack_max = 1,
	tiles = {"trinium_research.chassis.png"},
	description = S"Press Randomizer",
	groups = {cracky = 2},
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		["type"] = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.3, 0.5},
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.3, 0.35, 0.5, 0.4, 0.5},
			{-0.5, -0.3, -0.5, -0.35, 0.4, 0.35},
			{0.35, -0.3, -0.5, 0.5, 0.4, 0.35},

			{-0.15, -0.3, -0.15, 0.15, -0.22, -0.1},
			{-0.15, -0.3, 0.15, 0.15, -0.22, 0.1},
			{-0.025, -0.3, -0.1, 0.025, -0.18, 0.1},
			{-0.15, 0.4, -0.15, 0.15, 0.32, -0.1},
			{-0.15, 0.4, 0.15, 0.15, 0.32, 0.1},
			{-0.025, 0.4, -0.1, 0.025, 0.28, 0.1},
		}
	},

	after_place_node = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		api.initialize_inventory(inv, {rhenium_alloy = 1, upgrade = 1, press = 1})
	end,

	allow_metadata_inventory_move = function(pos, list1, index1, list2, index2, stacksize, player)
		return 0
	end,

	allow_metadata_inventory_put = function(pos, list, index, stack, player)
		local name,size = stack:get_name(), stack:get_count()
		return ((list == "rhenium_alloy" and name == M.rhenium_alloy:get"ingot") or
				(list == "upgrade" and minetest.get_item_group(name, "lens_upgrade") ~= 0)) and size or 0
	end,

	on_receive_fields = function(pos, formname, fields, player)
		if not fields["assemble_press"] then return end

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local alloy, upgrade, press1 =
				inv:get_stack("rhenium_alloy", 1),
				inv:get_stack("upgrade", 1),
				inv:get_stack("press", 1)

		if alloy:get_count() < research.constants.press_cost then
			cmsg.push_message_player(player, S"Add more Rhenium Alloy!")
			return
		end

		if not press1:is_empty() then
			cmsg.push_message_player(player, S"Extract press to continue!")
			return
		end

		local press = ItemStack"trinium_research:press"
		local pressmeta = press:get_meta()
		local upg = minetest.get_item_group(upgrade:get_name(), "lens_upgrade") + 1
		local shape = table.remap(table.keys(table.filter(research.lens_data.shapes, function(x)
			return x <= upg
		end)))

		local gem, metal, shape, tierexp =
			api.lograndom(research.constants.min_gems, research.constants.max_gems),
			api.lograndom(research.constants.min_metal, research.constants.max_metal),
			{table.random(shape)}, math.random(1, 2^(research.constants.max_tier - upg + 1) - 1)
		shape = shape[1]

		local tier = research.constants.max_tier - math.floor(0.01 + math.log(tierexp) / trinium.ln2)
		pressmeta:set_int("gem", gem)
		pressmeta:set_int("metal", metal)
		pressmeta:set_string("shape", shape)
		pressmeta:set_int("tier", tier)

		pressmeta:set_string("description",
				S("Research Press@nGem amount needed: @1@nMetal amount needed: @2@nShape: @3@nTier: @4",
						gem, metal, S(api.string_capitalization(shape)), tier))
		alloy:take_item(research.constants.press_cost)
		inv:set_stack("rhenium_alloy", 1, alloy)
		inv:set_stack("press", 1, press)
		upgrade:take_item()
		inv:set_stack("upgrade", 1, upgrade)
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.get_meta(pos):get_int("assembled") == 0 then
			cmsg.push_message_player(player, S"Multiblock not assembled!")
		end
	end,
})

api.register_multiblock("press randomizer", {
	width = 0,
	height_d = 0,
	height_u = 1,
	depth_b = 1,
	depth_f = 0,
	controller = "trinium_research:randomizer",
	activator = function(rg)
		local ctrl = table.exists(rg.region, function(x)
			return x.x == 0 and x.y == 1 and x.z == 1 and x.name == "trinium_research:node_controller"
		end)
		return ctrl and minetest.get_meta(rg.region[ctrl].actual_pos):get_int("assembled") == 1
	end,
	after_construct = function(pos, is_constructed)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", is_constructed and randomizer_formspec or "")
	end,
})
