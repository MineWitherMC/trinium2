local research = trinium.research
local S = research.S
local M = trinium.materials.materials
local api = trinium.api

local infuser_formspec = ([=[
	size[10,7.5]
	list[context;lens;4,0;1,1;]
	image[3,0;1,1;trinium_research.lens.png^[brighten]
	list[context;parchment;4,1;1,1;]
	image[3,1;1,1;%s]
	list[context;chapter_core;4,2;1,1;]
	image[3,2;1,1;trinium_research.undiscovered_notes.png^[brighten]
	image_button[5,1;1,1;trinium_gui.arrow.png;infuse_map;]
	list[context;output;6,1;1,1;]
	image[6,2;1,1;trinium_research.uncompleted_notes.png^[brighten]
	list[current_player;main;1,3.5;8,4;]

	list[context;catalysts;0,0;1,3;]
	image[1,0;1,1;%s]
	image[1,1;1,1;%s]
	image[1,2;1,1;%s]
	list[context;catalysts;9,0;1,3;3]
	image[8,0;1,1;%s]
	image[8,1;1,1;%s]
	image[8,2;1,1;%s]
]=]):format(api.get_fs_texture(M.parchment:get"sheet", "trinium_materials:stardust", M.pyrocatalyst:get"dust",
		M.bifrost:get"dust", M.xpcatalyst:get"dust", M.imbued_forcillium:get"dust", M.endium:get"dust"))

minetest.register_node("trinium_research:sheet_infuser", {
	stack_max = 1,
	tiles = {"trinium_research.wall.png"},
	description = S"Sheet Infuser",
	groups = {cracky = 1, conduit_insert = 1},
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.3, 0.5},
			{-0.5, 0.4, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.3, 0.35, 0.5, 0.4, 0.5},
			{-0.5, -0.3, -0.5, -0.35, 0.4, 0.35},
			{0.35, -0.3, -0.5, 0.5, 0.4, 0.35},

			{-0.2, -0.3, -0.2, 0.2, -0.22, 0.2},
			{-0.1, 0.4, -0.2, 0.1, 0.32, 0.2},
			{-0.2, 0.4, -0.1, 0.2, 0.32, 0.1},
			{-0.1, 0.32, -0.1, 0.1, 0.29, 0.1},
		}
	},
	sounds = trinium.sounds.default_stone,

	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		api.initialize_inventory(inv, {catalysts = 6, parchment = 1, lens = 1, chapter_core = 1, output = 1})
	end,
	allow_metadata_inventory_move = function()
		return 0
	end,
	allow_metadata_inventory_put = function(_, list, index, stack)
		local name, size = stack:get_name(), stack:get_count()
		return ((list == "parchment" and name == M.parchment:get"sheet") or
				(list == "chapter_core" and name == "trinium_research:notes_3") or
				(list == "lens" and name == "trinium_research:lens") or
				(list == "catalysts" and
						((index == 1 and name == "trinium_materials:stardust") or
								(index == 2 and name == M.pyrocatalyst:get"dust") or
								(index == 3 and name == M.bifrost:get"dust") or
								(index == 4 and name == M.xpcatalyst:get"dust") or
								(index == 5 and name == M.imbued_forcillium:get"dust") or
								(index == 6 and name == M.endium:get"dust"))
				)) and size or 0
	end,

	conduit_insert = function(stack)
		if stack:get_name() == M.parchment:get"sheet" then
			return "parchment", 1
		elseif stack:get_name() == "trinium_materials:stardust" then
			return "catalysts", 1
		elseif stack:get_name() == M.pyrocatalyst:get"dust" then
			return "catalysts", 2
		elseif stack:get_name() == M.bifrost:get"dust" then
			return "catalysts", 3
		elseif stack:get_name() == M.xpcatalyst:get"dust" then
			return "catalysts", 4
		elseif stack:get_name() == M.imbued_forcillium:get"dust" then
			return "catalysts", 5
		elseif stack:get_name() == M.endium:get"dust" then
			return "catalysts", 6
		end
		return false
	end,

	on_receive_fields = function(pos, _, fields, player)
		if not fields.infuse_map then return end
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		-- Crutch for fast checking of emptiness of slots
		if inv:room_for_item("catalysts", "trinium_research:casing") then
			cmsg.push_message_player(player, S"Insufficient Catalysts!")
			return
		end
		if inv:get_stack("parchment", 1):get_count() < 2 then
			cmsg.push_message_player(player, S"Insufficient Parchment!")
			return
		end
		local lens, map = inv:get_stack("lens", 1), inv:get_stack("chapter_core", 1)
		if lens:is_empty() then
			cmsg.push_message_player(player, S"Insert Lens to continue!")
			return
		end
		if map:is_empty() then
			cmsg.push_message_player(player, S"Insert Research Map to continue!")
			return
		end
		if not inv:get_stack("output", 1):is_empty() then
			cmsg.push_message_player(player, S"Extract Research Notes to continue!")
			return
		end

		local map_data = research.bound_to_maps[inv:get_stack("chapter_core", 1):get_meta():get_string("chapter_id")]
		if not map_data then return end

		for i = 1, 6 do
			local s = inv:get_stack("catalysts", i)
			s:take_item()
			inv:set_stack("catalysts", i, s)
		end

		local lens_meta = lens:get_meta()
		local map_res = table.exists(map_data, function(x)
			return (x.band_material or lens_meta:get_string"metal") == lens_meta:get_string"metal" and
					(x.lens_core or lens_meta:get_string"gem") == lens_meta:get_string"gem" and
					(x.band_tier or 0) <= lens_meta:get_int"tier" and
					(x.band_shape or lens_meta:get_string"shape") == lens_meta:get_string"shape"
		end)
		if not map_res then
			cmsg.push_message_player(player, S"Infusion has failed!")
			return
		end

		local s = inv:get_stack("parchment", 1)
		s:take_item(2)
		inv:set_stack("parchment", 1, s)
		local res = map_data[map_res].apply

		local stack = ItemStack("trinium_research:notes2")
		stack:set_string("research_id", res)
		stack:set_string("description", S("Infused Research Notes - @1", research.researches[res].name))
		inv:set_stack("output", 1, stack)
	end,
})

local infuser_mb = {
	width = 2,
	height_d = 1,
	height_u = 3,
	depth_b = 4,
	depth_f = 0,
	controller = "trinium_research:sheet_infuser",
	map = {
		{x = 0, y = -1, z = 2, name = "default:reflector_glass"},
		{x = 0, y = -1, z = 1, name = "trinium_research:casing"},
		{x = 1, y = -1, z = 1, name = "trinium_research:casing"},
		{x = 1, y = -1, z = 2, name = "trinium_research:casing"},
		{x = 1, y = -1, z = 3, name = "trinium_research:casing"},
		{x = 0, y = -1, z = 3, name = "trinium_research:casing"},
		{x = -1, y = -1, z = 3, name = "trinium_research:casing"},
		{x = -1, y = -1, z = 2, name = "trinium_research:casing"},
		{x = -1, y = -1, z = 1, name = "trinium_research:casing"},
		{x = -1, y = -1, z = 0, name = "trinium_research:wall"},
		{x = 0, y = -1, z = 0, name = "trinium_research:wall"},
		{x = 1, y = -1, z = 0, name = "trinium_research:wall"},
		{x = -1, y = -1, z = 4, name = "trinium_research:wall"},
		{x = 0, y = -1, z = 4, name = "trinium_research:wall"},
		{x = 1, y = -1, z = 4, name = "trinium_research:wall"},
		{x = -2, y = -1, z = 1, name = "trinium_research:wall"},
		{x = -2, y = -1, z = 2, name = "trinium_research:wall"},
		{x = -2, y = -1, z = 3, name = "trinium_research:wall"},
		{x = 2, y = -1, z = 1, name = "trinium_research:wall"},
		{x = 2, y = -1, z = 2, name = "trinium_research:wall"},
		{x = 2, y = -1, z = 3, name = "trinium_research:wall"},
		{x = -2, y = -1, z = 0, name = "trinium_research:casing"},
		{x = 2, y = -1, z = 0, name = "trinium_research:casing"},
		{x = -2, y = -1, z = 4, name = "trinium_research:casing"},
		{x = 2, y = -1, z = 4, name = "trinium_research:casing"},

		{x = 0, y = 0, z = 2, name = "default:forcillium_lamp"},
		{x = 0, y = 0, z = 1, name = "default:reflector_glass"},
		{x = 1, y = 0, z = 1, name = "trinium_research:casing"},
		{x = 1, y = 0, z = 2, name = "default:reflector_glass"},
		{x = 1, y = 0, z = 3, name = "trinium_research:casing"},
		{x = 0, y = 0, z = 3, name = "default:reflector_glass"},
		{x = -1, y = 0, z = 3, name = "trinium_research:casing"},
		{x = -1, y = 0, z = 2, name = "default:reflector_glass"},
		{x = -1, y = 0, z = 1, name = "trinium_research:casing"},
		{x = -1, y = 0, z = 0, name = "trinium_research:wall"},
		{x = 1, y = 0, z = 0, name = "trinium_research:wall"},
		{x = -1, y = 0, z = 4, name = "trinium_research:wall"},
		{x = 0, y = 0, z = 4, name = "trinium_research:casing"},
		{x = 1, y = 0, z = 4, name = "trinium_research:wall"},
		{x = -2, y = 0, z = 1, name = "trinium_research:wall"},
		{x = -2, y = 0, z = 2, name = "trinium_research:casing"},
		{x = -2, y = 0, z = 3, name = "trinium_research:wall"},
		{x = 2, y = 0, z = 1, name = "trinium_research:wall"},
		{x = 2, y = 0, z = 2, name = "trinium_research:casing"},
		{x = 2, y = 0, z = 3, name = "trinium_research:wall"},
		{x = -2, y = 0, z = 0, name = "trinium_research:casing"},
		{x = 2, y = 0, z = 0, name = "trinium_research:casing"},
		{x = -2, y = 0, z = 4, name = "trinium_research:casing"},
		{x = 2, y = 0, z = 4, name = "trinium_research:casing"},

		{x = 0, y = 1, z = 2, name = "default:reflector_glass"},
		{x = 0, y = 1, z = 1, name = "default:forcillium_lamp"},
		{x = 1, y = 1, z = 1, name = "trinium_research:chassis"},
		{x = 1, y = 1, z = 2, name = "default:forcillium_lamp"},
		{x = 1, y = 1, z = 3, name = "trinium_research:chassis"},
		{x = 0, y = 1, z = 3, name = "default:forcillium_lamp"},
		{x = -1, y = 1, z = 3, name = "trinium_research:chassis"},
		{x = -1, y = 1, z = 2, name = "default:forcillium_lamp"},
		{x = -1, y = 1, z = 1, name = "trinium_research:chassis"},
		{x = -1, y = 1, z = 0, name = "trinium_research:wall"},
		{x = 0, y = 1, z = 0, name = "trinium_research:wall"},
		{x = 1, y = 1, z = 0, name = "trinium_research:wall"},
		{x = -1, y = 1, z = 4, name = "trinium_research:wall"},
		{x = 0, y = 1, z = 4, name = "trinium_research:wall"},
		{x = 1, y = 1, z = 4, name = "trinium_research:wall"},
		{x = -2, y = 1, z = 1, name = "trinium_research:wall"},
		{x = -2, y = 1, z = 2, name = "trinium_research:wall"},
		{x = -2, y = 1, z = 3, name = "trinium_research:wall"},
		{x = 2, y = 1, z = 1, name = "trinium_research:wall"},
		{x = 2, y = 1, z = 2, name = "trinium_research:wall"},
		{x = 2, y = 1, z = 3, name = "trinium_research:wall"},
		{x = -2, y = 1, z = 0, name = "trinium_research:casing"},
		{x = 2, y = 1, z = 0, name = "trinium_research:casing"},
		{x = -2, y = 1, z = 4, name = "trinium_research:casing"},
		{x = 2, y = 1, z = 4, name = "trinium_research:casing"},

		{x = 0, y = 2, z = 1, name = "trinium_research:casing"},
		{x = 1, y = 2, z = 1, name = "trinium_research:casing"},
		{x = 1, y = 2, z = 2, name = "trinium_research:casing"},
		{x = 1, y = 2, z = 3, name = "trinium_research:casing"},
		{x = 0, y = 2, z = 3, name = "trinium_research:casing"},
		{x = -1, y = 2, z = 3, name = "trinium_research:casing"},
		{x = -1, y = 2, z = 2, name = "trinium_research:casing"},
		{x = -1, y = 2, z = 1, name = "trinium_research:casing"},
		{x = -1, y = 2, z = 0, name = "trinium_research:wall"},
		{x = 0, y = 2, z = 0, name = "trinium_research:wall"},
		{x = 1, y = 2, z = 0, name = "trinium_research:wall"},
		{x = -1, y = 2, z = 4, name = "trinium_research:wall"},
		{x = 0, y = 2, z = 4, name = "trinium_research:wall"},
		{x = 1, y = 2, z = 4, name = "trinium_research:wall"},
		{x = -2, y = 2, z = 1, name = "trinium_research:wall"},
		{x = -2, y = 2, z = 2, name = "trinium_research:wall"},
		{x = -2, y = 2, z = 3, name = "trinium_research:wall"},
		{x = 2, y = 2, z = 1, name = "trinium_research:wall"},
		{x = 2, y = 2, z = 2, name = "trinium_research:wall"},
		{x = 2, y = 2, z = 3, name = "trinium_research:wall"},
		{x = -2, y = 2, z = 0, name = "trinium_research:casing"},
		{x = 2, y = 2, z = 0, name = "trinium_research:casing"},
		{x = -2, y = 2, z = 4, name = "trinium_research:casing"},
		{x = 2, y = 2, z = 4, name = "trinium_research:casing"},

		{x = 0, y = 3, z = 2, name = "default:reflector_glass"},
		{x = 0, y = 3, z = 1, name = "trinium_research:chassis"},
		{x = 1, y = 3, z = 2, name = "trinium_research:chassis"},
		{x = 0, y = 3, z = 3, name = "trinium_research:chassis"},
		{x = -1, y = 3, z = 2, name = "trinium_research:chassis"},
		{x = -1, y = 3, z = 0, name = "trinium_research:casing"},
		{x = 0, y = 3, z = 0, name = "trinium_research:casing"},
		{x = 1, y = 3, z = 0, name = "trinium_research:casing"},
		{x = -1, y = 3, z = 4, name = "trinium_research:casing"},
		{x = 0, y = 3, z = 4, name = "trinium_research:casing"},
		{x = 1, y = 3, z = 4, name = "trinium_research:casing"},
		{x = -2, y = 3, z = 1, name = "trinium_research:casing"},
		{x = -2, y = 3, z = 2, name = "trinium_research:casing"},
		{x = -2, y = 3, z = 3, name = "trinium_research:casing"},
		{x = 2, y = 3, z = 1, name = "trinium_research:casing"},
		{x = 2, y = 3, z = 2, name = "trinium_research:casing"},
		{x = 2, y = 3, z = 3, name = "trinium_research:casing"},
		{x = -2, y = 3, z = 0, name = "trinium_research:casing"},
		{x = 2, y = 3, z = 0, name = "trinium_research:casing"},
		{x = -2, y = 3, z = 4, name = "trinium_research:casing"},
		{x = 2, y = 3, z = 4, name = "trinium_research:casing"},
	},
	after_construct = function(pos, is_constructed)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", is_constructed and infuser_formspec or "")
	end,
}

api.add_multiblock("sheet infuser", infuser_mb)
api.multiblock_rename(infuser_mb)
api.multiblock_rich_info"trinium_research:sheet_infuser"
