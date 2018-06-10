local research = trinium.research
local api = trinium.api
local S = research.S

local compressor_formspec = ([=[
	size[8,9]
	list[context;lens;4,2.5;1,1;]
	image[3,2.5;1,1;trinium_research.lens.png^[brighten]
	list[context;gem;0,0;2,2;]
	image[0.5,2;1,1;trinium_materials.gem.png^[brighten]
	list[context;metal;6,0;2,2;]
	image[6.5,2;1,1;(trinium_materials.ingot.png^trinium_materials.ingot.overlay.png)^[brighten]
	list[context;press;4,0.5;1,1;]
	image[3,0.5;1,1;trinium_research.press.png^[brighten]
	list[context;upgrade;4,3.5;1,1;]
	image[3,3.5;1,1;trinium_research.upgrade2.png^[brighten]
	list[current_player;main;0,5;8,4;]
	button[0,3.5;2,1;assemble_lens;%s]
]=]):format(S"Assemble Lens")

minetest.register_node("trinium_research:lens_curver", {
	stack_max = 1,
	tiles = {"trinium_research.chassis.png"},
	description = S"Lens Curver",
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
		}
	},
	sounds = trinium.sounds.default_stone,

	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		api.initialize_inventory(inv, {lens = 1, gem = 4, metal = 4, press = 1, upgrade = 1})
	end,

	allow_metadata_inventory_move = function(_, list1, _, list2, _, stacksize)
		return list1 == list2 and stacksize or 0
	end,

	allow_metadata_inventory_put = function(pos, list, _, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local n = stack:get_name()
		local m
		if list == "metal" then
			if not table.exists(research.lens_data.metals, function(x) return x == n end) then return 0 end
			for i = 1,4 do
				m = inv:get_stack("metal", i):get_name()
				if m ~= n and m ~= "" then return 0 end
			end
			return stack:get_count()
		elseif list == "gem" then
			if not table.exists(research.lens_data.gems, function(x) return x == n end) then return 0 end
			for i = 1,4 do
				m = inv:get_stack("gem", i):get_name()
				if m ~= n and m ~= "" then return 0 end
			end
			return stack:get_count()
		elseif list == "press" then
			return stack:get_name() == "trinium_research:press" and 1 or 0
		elseif list == "upgrade" then
			return minetest.get_item_group(stack:get_name(), "lens_upgrade") ~= 0 and stack:get_count() or 0
		else
			return 0
		end
	end,

	on_receive_fields = function(pos, _, fields, player)
		if not fields.assemble_lens then return end

		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local lens, press, upgrade = inv:get_stack("lens", 1), inv:get_stack("press", 1), inv:get_stack("upgrade", 1)
		if not lens:is_empty() then
			cmsg.push_message_player(player, S"Extract Lens to continue!")
			return
		end
		if press:is_empty() then
			cmsg.push_message_player(player, S"Press is abscent!")
			return
		end
		local pressmeta = press:get_meta()
		local base_tier = pressmeta:get_int"tier"
		local umult = math.max(minetest.get_item_group(upgrade:get_name(), "lens_upgrade") + 1 - base_tier, 1)
		local actual_tier = math.min(5, base_tier + minetest.get_item_group(upgrade:get_name(), "lens_upgrade"))

		local req_gem, req_metal, shape =
				pressmeta:get_int"gem" * umult,
				pressmeta:get_int"metal" * umult,
				pressmeta:get_string"shape"
		local stored_gem, stored_metal = 0, 0
		local metatbl = meta:to_table().inventory
		table.walk(metatbl.gem, function(x) stored_gem = stored_gem + ItemStack(x):get_count() end)
		table.walk(metatbl.metal, function(x) stored_metal = stored_metal + ItemStack(x):get_count() end)
		if stored_gem < req_gem or stored_metal < req_metal then
			cmsg.push_message_player(player, S"Insufficient Resources!")
			return
		end
		local item_gem, item_metal

		table.walk(metatbl.gem, function(x, k)
			local st = ItemStack(x)
			local ct = st:get_count()
			if ct >= req_gem then item_gem = st:get_name() end
			if ct <= req_gem then
				req_gem = req_gem - ct
				inv:set_stack("gem", k, "")
			else
				st:take_item(req_gem)
				req_gem = 0
				inv:set_stack("gem", k, st)
			end
		end, function() return req_gem == 0 end)

		table.walk(metatbl.metal, function(x, k)
			local st = ItemStack(x)
			local ct = st:get_count()
			if ct >= req_gem then item_metal = st:get_name() end
			if ct <= req_metal then
				req_metal = req_metal - ct
				inv:set_stack("metal", k, "")
			else
				st:take_item(req_metal)
				req_metal = 0
				inv:set_stack("metal", k, st)
			end
		end, function() return req_metal == 0 end)

		local item_gem1 = minetest.registered_items[item_gem].description:split"\n"[1]
		local item_metal1 = minetest.registered_items[item_metal].description:split"\n"[1]

		local item_gem2 = table.exists(research.lens_data.gems, function(x) return x == item_gem end)
		local item_metal2 = table.exists(research.lens_data.metals, function(x) return x == item_metal end)

		local lens = ItemStack"trinium_research:lens"
		local lensmeta = lens:get_meta()
		lensmeta:set_string("gem", item_gem2)
		lensmeta:set_string("metal", item_metal2)
		lensmeta:set_int("tier", actual_tier)
		lensmeta:set_string("shape", shape)
		lensmeta:set_string("description",
				S("Research Lens@nGem Material: @1@nMetal Material: @2@nShape: @3@nTier: @4",
						item_gem1, item_metal1,
						S(api.string_capitalization(shape)), actual_tier))
		upgrade:take_item()
		inv:set_stack("upgrade", 1, upgrade)
		inv:set_stack("lens", 1, lens)
	end,
	on_rightclick = function(pos, _, player)
		if minetest.get_meta(pos):get_int("assembled") == 0 then
			cmsg.push_message_player(player, S"Multiblock is not assembled!")
		end
	end,
})

local lens_curver_mb = {
	width = 1,
	height_d = 1,
	height_u = 1,
	depth_b = 6,
	depth_f = 0,
	controller = "trinium_research:lens_curver",
	map = {
		{x = -1, z = 1, y = -1, name = "trinium_research:casing"},
		{x = -1, z = 0, y = -1, name = "trinium_research:casing"},
		{x = 1, z = 1, y = -1, name = "trinium_research:casing"},
		{x = 1, z = 0, y = -1, name = "trinium_research:casing"},
		{x = 0, z = 1, y = -1, name = "trinium_research:chassis"},
		{x = 0, z = 0, y = -1, name = "trinium_research:chassis"},

		{x = -1, z = 1, y = 0, name = "trinium_research:casing"},
		{x = -1, z = 0, y = 0, name = "trinium_research:casing"},
		{x = 1, z = 1, y = 0, name = "trinium_research:casing"},
		{x = 1, z = 0, y = 0, name = "trinium_research:casing"},
		{x = 0, z = 1, y = 0, name = "trinium_research:chassis"},

		{x = -1, z = 1, y = 1, name = "trinium_research:chassis"},
		{x = -1, z = 0, y = 1, name = "trinium_research:chassis"},
		{x = 1, z = 1, y = 1, name = "trinium_research:chassis"},
		{x = 1, z = 0, y = 1, name = "trinium_research:chassis"},
		{x = 0, z = 1, y = 1, name = "trinium_research:chassis"},
		{x = 0, z = 0, y = 1, name = "trinium_research:chassis"},

		{x = 0, z = 6, y = 0, name = "trinium_research:node_controller"},
	},
	after_construct = function(pos, is_constructed)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", is_constructed and compressor_formspec or "")
	end,
}

lens_curver_mb.activator = function(rg)
	if not rg(lens_curver_mb.map) then return end
	local ctrl = table.exists(rg.region, function(x) return x.x == 0 and x.y == 0 and x.z == 6 end)
	return ctrl and minetest.get_meta(rg.region[ctrl].actual_pos):get_int("assembled") == 1
end

api.register_multiblock("lens curver", lens_curver_mb)
