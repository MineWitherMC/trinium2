local research = trinium.research
local S = research.S
local api = trinium.api

local function get_table_formspec(mode, pn, real_research, aspect_key)
	aspect_key = aspect_key or 0
	if mode == 1 or mode == "1" then
		return ([=[
			size[11.5,9]
			list[context;aspect_panel;0,2;4,6;%s]
			button[1,8;1,1;research_table~up;↑]
			button[2,8;1,1;research_table~down;↓]
			%s
			list[context;research_notes;0,0.25;1,1;]
			list[context;lens;1,0.25;1,1;]
			list[context;trash;10.5,0.25;1,1;]
			image[9.5,0.25;1,1;trinium_gui.trash.png]
			textarea[2.25,0;7.25,2;;;%s]
			tabheader[0,0;research_table~change_fs;%s,%s;1;true;false]
		]=]):format(aspect_key, real_research and "list[context;map;4.5,2;7,7;]" or "",
				S("Ink: @1@nPaper: @2@nWarp: @3",
						research.dp2[pn].ink, research.dp2[pn].paper, research.dp2[pn].warp),
				S "Map", S "Inventory")
	elseif mode == 2 or mode == "2" then
		return ([=[
			size[12.5,7]
			list[context;aspect_panel;0,0;4,6;%s]
			button[1,6;1,1;research_table~up;↑]
			button[2,6;1,1;research_table~down;↓]
			list[context;aspect_inputs;7,0.5;1,2;]
			button[8,1;1,1;research_table~add_aspects;+]
			list[context;r2m;10,1.5;1,1;]
			image[10,0.4;1,1;trinium_gui.trash.png]
			list[context;research_notes;4.5,1.5;1,1;]
			image[4.5,0.4;1,1;trinium_research.uncompleted_notes.png^[brighten]
			list[context;lens;5.5,1.5;1,1;]
			image[5.5,0.4;1,1;trinium_research.lens.png^[brighten]
			list[current_player;main;4.5,3;8,4;]
			tabheader[0,0;research_table~change_fs;%s,%s;2;true;false]
		]=]):format(aspect_key, S "Map", S "Inventory")
	end
end

local function is_correct_research(inv)
	local research_notes, lens = inv:get_stack("research_notes", 1), inv:get_stack("lens", 1)
	if research_notes:is_empty() then return false end
	if research_notes:get_name() == "trinium_research:notes_1" then return true end
	local lens_req = research.researches[research_notes:get_meta():get_string("research_id")].requires_lens
	if lens:is_empty() and lens_req and lens_req.requirement then return false end
	if not lens_req or not lens_req.requirement then return true end
	lens = lens:get_meta()
	return (not lens_req.shape or lens:get_string "shape" == lens_req.shape) and
			(not lens_req.tier or lens:get_int "tier" >= lens_req.tier) and
			(not lens_req.gem or lens:get_string "gem" == lens_req.gem) and
			(not lens_req.metal or lens:get_string "metal" == lens_req.metal)
end

local function recalculate_aspects(pn, inv)
	for i = 1, #research.aspect_list do
		local aspect_name = research.aspect_list[i]
		local cur_amount, name = research.dp2[pn].aspects[aspect_name] or 0, "trinium_research:aspect_" .. aspect_name
		local writer = ItemStack(name)
		writer:set_wear(math.max(65535 - cur_amount * 16, 1))
		if cur_amount == 0 then
			inv:set_stack("aspect_panel", i, "")
		else
			inv:set_stack("aspect_panel", i, writer)
		end
	end
end

local function can_connect(inv, index1, index2)
	if index1 < 1 or index1 > 49 or index2 < 1 or index2 > 49 then return false end
	local an1 = inv:get_stack("map", index1):get_name():split "_"[3]
	local an2 = inv:get_stack("map", index2):get_name():split "_"[3]
	if an1 == "" or an2 == "" or not an1 or not an2 then return end
	local ad1 = research.aspects[an1]
	local ad2 = research.aspects[an2]
	return ad1.req1 == an2 or ad1.req2 == an2 or ad2.req1 == an1 or ad2.req2 == an1
end

local function recalculate_light(meta, pn)
	local inv = meta:get_inventory()
	local research_notes = inv:get_stack("research_notes", 1)
	local rn_meta = research_notes:get_meta()
	local enlightened = api.search(rn_meta:get_int "begin", api.functions.returner, function(n)
		local output = {}
		if n > 7 and can_connect(inv, n, n - 7) then output[n - 7] = 1 end
		if n <= 42 and can_connect(inv, n, n + 7) then output[n + 7] = 1 end
		if n % 7 ~= 1 and can_connect(inv, n, n - 1) then output[n - 1] = 1 end
		if n % 7 ~= 0 and can_connect(inv, n, n + 1) then output[n + 1] = 1 end
		return output
	end)                   :push(rn_meta:get_int "begin")
	local list_of_endpoints = rn_meta:get_string "endpoints":data()
	local ended = enlightened:copy():filter(function(k)
		return table.exists(list_of_endpoints, api.functions.equal(k))
	end)
	return ended:count() == #list_of_endpoints, enlightened:data()
end

local function update_formspec(pos)
	local meta = minetest.get_meta(pos)
	local mode = meta:get_int("current_mode")
	local pn = meta:get_string("owner")
	local real_res = is_correct_research(meta:get_inventory())
	local aspect_key = meta:get_int("aspect_key")
	local fs_base = get_table_formspec(mode, pn, real_res, aspect_key)
	meta:set_string("formspec", fs_base)
end

minetest.register_node("trinium_research:table", {
	stack_max = 1,
	tiles = { "trinium_research.chassis.png" },
	description = S "Research Table",
	groups = { cracky = 2 },
	paramtype2 = "facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{ -0.45, -0.5, -0.45, 0.45, -0.4, 0.45 }, -- platform
			{ -0.1, -0.4, 0.2, 0.1, 0.455, 0.4 }, -- tube
			{ -0.075, 0.45, -0.1, 0.075, 0.455, 0.2 }, -- connector
			{ -0.15, 0.38, -0.4, 0.15, 0.455, -0.1 }, -- lens
			{ -0.075, 0.34, -0.325, 0.075, 0.38, -0.175 }, -- lens bottom
		}
	},
	sounds = trinium.sounds.default_stone,

	after_place_node = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pn = player:get_player_name()
		api.initialize_inventory(inv,
				{ map = 49, aspect_panel = 4 * math.ceil(#research.aspect_list / 4),
				  research_notes = 1, lens = 1,
				  trash = 1, aspect_inputs = 2, r2m = 1 })
		meta:set_string("current_mode", 2)
		meta:set_string("owner", pn)
		meta:set_int("aspect_key", 0)

		recalculate_aspects(pn, inv)
	end,

	allow_metadata_inventory_move = function(pos, list1, index1, list2, index2, stack_size, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pn = player:get_player_name()
		local notes = inv:get_stack("research_notes", 1)
		local notes_meta = notes:get_meta()
		if (list1 == "map" and list2 == "trash") then
			local ep = notes_meta:get_string("endpoints"):data()
			if not ep then return 0 end
			return index1 ~= notes_meta:get_int("begin") and not table.exists(ep, api.functions.equal(index1)) and 1 or 0
		end
		if list2 == "r2m" then
			return stack_size
		end
		if not (list1 == "aspect_panel" and (list2 == "map" or list2 == "aspect_inputs")) then return 0 end
		if list2 == "map" and research.dp2[pn].ink <= 0 then return 0 end
		return inv:get_stack(list2, index2):get_count() > 0 and 0 or 1
	end,

	allow_metadata_inventory_put = function(_, list, _, stack)
		local name, size = stack:get_name(), stack:get_count()
		return ((list == "research_notes" and name == "trinium_research:notes_2") or
				(list == "lens" and name == "trinium_research:lens")) and 1 or 0
	end,

	allow_metadata_inventory_take = function(_, list, _, stack)
		local name, size = stack:get_name(), stack:get_count()
		return (list == "research_notes" or list == "lens") and size or 0
	end,

	on_receive_fields = function(pos, _, fields, player)
		if fields.quit then return end
		local pn = player:get_player_name()
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		for k, v in pairs(fields) do
			local k_split = k:split "~"
			if k_split[1] == "research_table" then
				local a = k_split[2]
				if a == "change_fs" then
					local tnb = tonumber(v)
					meta:set_string("current_mode", tnb)
					update_formspec(pos)
				elseif a == "down" then
					local key = meta:get_int "aspect_key"
					key = math.min(key + 4, math.ceil(#research.aspect_list / 4) * 4 - 24)
					meta:set_int("aspect_key", key)
					update_formspec(pos)
				elseif a == "up" then
					local key = meta:get_int "aspect_key"
					key = math.max(key - 4, 0)
					meta:set_int("aspect_key", key)
					update_formspec(pos)
				elseif a == "add_aspects" then
					local a1, a2 = inv:get_stack("aspect_inputs", 1):get_name():split "_"[3],
					inv:get_stack("aspect_inputs", 2):get_name():split "_"[3]
					if not a1 or a1 == "" or not a2 or a2 == "" then return end

					if research.dp2[pn].aspects[a1] < 0 or research.dp2[pn].aspects[a1] < 0 then return end
					if research.dp2[pn].aspects[a1] == 0 then
						inv:set_stack("aspect_inputs", 1, "")
					else
						research.dp2[pn].aspects[a1] = research.dp2[pn].aspects[a1] - 1
					end
					if research.dp2[pn].aspects[a2] == 0 then
						inv:set_stack("aspect_inputs", 2, "")
					else
						research.dp2[pn].aspects[a2] = research.dp2[pn].aspects[a2] - 1
					end

					local new_aspect = table.exists(research.aspects, function(v)
						return (v.req1 == a1 and v.req2 == a2) or (v.req2 == a1 and v.req1 == a2)
					end)
					if new_aspect then
						research.dp2[pn].aspects[new_aspect] = (research.dp2[pn].aspects[new_aspect] or 5) + 1
						minetest.sound_play("experience", {
							to_player = pn,
							gain = 3.0
						})
					end

					recalculate_aspects(pn, inv)
				end
			end
		end
	end,

	on_rightclick = function(pos, _, player)
		if minetest.get_meta(pos):get_int "assembled" == 1 then
			recalculate_aspects(player:get_player_name(), minetest.get_meta(pos):get_inventory())
		end
	end,

	after_dig_node = function(pos, _, oldmetadata, digger)
		local sh, l = oldmetadata.inventory.research_notes[1], oldmetadata.inventory.lens[1]
		if not sh:is_empty() then
			minetest.item_drop(sh, digger, pos)
		end
		if not l:is_empty() then
			minetest.item_drop(l, digger, pos)
		end
	end,

	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_string "owner" == player:get_player_name()
	end,

	on_metadata_inventory_move = function(pos, _, index1, list2, index2, _, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pn = player:get_player_name()
		if list2 == "trash" then
			inv:set_stack("trash", 1, "")
			local is_done, arr = recalculate_light(meta, pn) -- is done is always false
			meta:set_string("additions", minetest.serialize(arr))
			update_formspec(pos)
		elseif list2 == "r2m" then
			local a = inv:get_stack("r2m", 1):get_name():split "_"[3]
			research.dp2[pn].aspects[a] = research.dp2[pn].aspects[a] + 1
			inv:set_stack("r2m", 1, "")
		elseif list2 == "map" then
			research.dp2[pn].aspects[research.aspect_list[index1]] = research.dp2[pn].aspects[research.aspect_list[index1]] - 1
			research.dp2[pn].ink = research.dp2[pn].ink - 1
			local s = inv:get_stack(list2, index2)
			s:set_wear(0)
			inv:set_stack(list2, index2, s)
			recalculate_aspects(pn, inv)
			local is_done, arr = recalculate_light(meta, pn) -- is done is NOT always false
			meta:set_string("additions", minetest.serialize(arr))
			if is_done then
				local stack = ItemStack("trinium_research:notes_1")
				local notes_meta = stack:get_meta()
				local old_stack = inv:get_stack("research_notes", 1)
				local old_meta = old_stack:get_meta()
				local id = old_meta:get_string "research_id"

				notes_meta:set_string("description", S("Discovery - @1", research.researches[id].name))
				notes_meta:set_string("research_id", id)
				inv:set_stack("research_notes", 1, stack)
			end
			update_formspec(pos)
		elseif list2 == "aspect_inputs" then
			local asp = research.aspect_list[index1]
			research.dp2[pn].aspects[asp] = research.dp2[pn].aspects[asp] - 1
			inv:set_stack(list2, index2, "trinium_research:aspect_" .. asp)
		end

		recalculate_aspects(pn, inv)
	end,

	on_metadata_inventory_take = function(pos, list_name)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if list_name == "research_notes" then
			for i = 1, 49 do
				inv:set_stack("map", i, "")
			end
		end
	end,

	on_metadata_inventory_put = function(pos, list_name, index, stack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if list_name == "research_notes" then
			local stack_meta = stack:get_meta()
			local res_map = table.copy(research.researches[stack_meta:get_string "research_id"].map)
			stack_meta:set_int("begin", res_map[1].x + 7 * (res_map[1].y - 1))
			table.walk(res_map, function(v, k)
				local coords = v.x + 7 * (v.y - 1)
				inv:set_stack("map", coords, "trinium_research:aspect_" .. v.aspect)
			end)

			table.remove(res_map, 1)
			local res_map2 = table.map(res_map, function(r)
				return r.x + 7 * (r.y - 1)
			end)
			stack_meta:set_string("endpoints", minetest.serialize(res_map2))
			inv:set_stack(list_name, index, stack)
		end
	end,
})

api.register_multiblock("research table", {
	width = 0,
	height_d = 2,
	height_u = 0,
	depth_b = 0,
	depth_f = 1,
	controller = "trinium_research:table",
	activator = function(rg)
		local ctrl = table.exists(rg.region, function(x)
			return x.x == 0 and x.y == -2 and x.z == -1 and x.name == "trinium_research:node_controller"
		end)
		return ctrl and minetest.get_meta(rg.region[ctrl].actual_pos):get_int "assembled" == 1
	end,
	after_construct = function(pos, is_constructed)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local r = meta:get_string "current_mode"
		if r ~= "1" and r ~= "2" then
			meta:set_string("current_mode", 2)
		end
		local fs = ""
		if is_constructed then
			fs = get_table_formspec(r, meta:get_string "owner", is_correct_research(inv), meta:get_int "aspect_key" or 0)
		end
		meta:set_string("formspec", fs)
	end,
})
api.multiblock_rich_info "trinium_research:table"