local S = pulse_network.S
local api = trinium.api
local nei = trinium.nei
local recipes = trinium.recipes

minetest.register_craftitem("pulse_network:blank_pattern", {
	description = S"Blank Pattern",
	inventory_image = "pulse_network.blank_pattern.png",
})

minetest.register_craftitem("pulse_network:encoded_pattern", {
	description = S"Invalid Pattern",
	inventory_image = "pulse_network.encoded_pattern.png",
	groups = {not_in_creative_inventory = 1},
	stack_max = 1,
})

recipes.add("crafting", {"pulse_network:encoded_pattern"}, {"pulse_network:blank_pattern"})

local encoder_formspec = ([=[
	size[8,7.5]
	list[context;blank_patterns;2,1;1,1;]
	image[2,0;1,1;pulse_network.blank_pattern.png^[brighten]
	list[context;encoded_pattern;5,1;1,1;]
	image[5,0;1,1;pulse_network.encoded_pattern.png^[brighten]

	image[3.5,1;1,1;trinium_gui.arrow.png]

	list[context;selected_item;2,2;1,1;]
	button[3,2;3,1;re_encode;%s]
	list[current_player;main;0,3.5;8,4;]
]=]):format(S"Select Recipe")

local encoder_context = {}
local encoder_context2 = {}
minetest.register_node("pulse_network:pattern_encoder", {
	description = S"Pattern Encoder",
	tiles = {"pulse_network.pattern_encoder_top.png", "pulse_network.pattern_encoder_side.png"},
	sounds = trinium.sounds.default_stone,
	groups = {cracky = 2, conduit_insert = 1, conduit_extract = 1},

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", encoder_formspec)
		api.initialize_inventory(meta:get_inventory(), {blank_patterns = 1, encoded_pattern = 1, selected_item = 1})
	end,

	allow_metadata_inventory_move = function(pos, list1, _, list2, _, count)
		if list1 == "blank_patterns" and list2 == "selected_item" then return count end
		if list1 ~= "selected_item" or list2 ~= "blank_patterns" then return 0 end
		local stack = minetest.get_meta(pos):get_inventory():get_stack("selected_item", 1):get_name()
		return stack == "pulse_network:blank_pattern" and count or 0
	end,

	allow_metadata_inventory_put = function(_, list, _, stack)
		if list == "selected_item" then return stack:get_count() end
		if list == "encoded_pattern" then return 0 end
		return stack:get_name() == "pulse_network:blank_pattern" and stack:get_count() or 0
	end,

	conduit_insert = function(stack)
		if stack:get_name() == "pulse_network:blank_pattern" then
			return "blank_patterns"
		else
			return false
		end
	end,

	conduit_extract = {"encoded_pattern"},

	on_receive_fields = function(pos, _, fields, player)
		if not fields.re_encode then return end
		local inv = minetest.get_meta(pos):get_inventory()

		if not inv:get_stack("encoded_pattern", 1):is_empty() then
			cmsg.push_message_player(player, S"Extract Encoded Pattern to continue!")
			return
		end

		local patterns, item = inv:get_stack("blank_patterns", 1), inv:get_stack("selected_item", 1)
		if patterns:is_empty() then
			cmsg.push_message_player(player, S"Insert Blank Pattern to continue!")
			return
		end
		if item:is_empty() then
			cmsg.push_message_player(player, S"Insert any item to continue!")
			return
		end

		local pn = player:get_player_name()
		encoder_context[pn] = pos
		local fs, size, id = nei.draw_recipe_wrapped(item:get_name(), player, 1, 1)
		encoder_context2[pn] = id
		if id and id ~= 0 then fs = fs .. ("button[%s,0;2,1;re_encode_fs;%s]"):format(size.x - 2, S"Encode") end
		minetest.show_formspec(pn, "pulse_network:pattern_encoding", fs)
	end,
})

minetest.register_on_player_receive_fields(function(player, form_name, fields)
	if form_name ~= "pulse_network:pattern_encoding" then
		return
	end
	local pn = player:get_player_name()

	if fields.re_encode_fs and encoder_context2[pn] and encoder_context2[pn] ~= 0 then
		local pos = encoder_context[pn]
		local inv = minetest.get_meta(pos):get_inventory()
		local patterns = inv:get_stack("blank_patterns", 1)
		patterns:take_item()
		inv:set_stack("blank_patterns", 1, patterns)

		local stack = ItemStack"pulse_network:encoded_pattern"
		local sm = stack:get_meta()
		local id = encoder_context2[pn]
		local recipe = recipes.recipe_registry[id]
		sm:set_string("recipe_data", minetest.serialize(table.map(table.filter(recipe, function(_,x)
			return x == "inputs" or x == "outputs"
		end), function(k)
			return table.filter(k, function(z)
				return z:split" "[2] ~= "0"
			end)
		end)))

		local desc_tbl = {S"Encoded Pattern", "", minetest.colorize("#CCCCCC", S"Inputs:")}
		for _,v in pairs(recipe.inputs) do
			local item, count = unpack(v:split" ")
			if count ~= 0 and count ~= "0" then
				if minetest.registered_items[item] then
					item = minetest.registered_items[item].description:split"\n"[1]
				end
				table.insert(desc_tbl, (count or 1) .. " " .. item)
			end
		end
		table.insert(desc_tbl, "")
		table.insert(desc_tbl, minetest.colorize("#CCCCCC", S"Outputs:"))
		for _,v in pairs(recipe.outputs) do
			local item, count = unpack(v:split" ")
			if minetest.registered_items[item] then
				item = minetest.registered_items[item].description:split"\n"[1]
			end
			table.insert(desc_tbl, (count or 1) .. " " .. item)
		end
		sm:set_string("description", table.concat(desc_tbl, "\n"))
		inv:set_stack("encoded_pattern", 1, stack)

		cmsg.push_message_player(player, S"Pattern successfully encoded!")
		minetest.show_formspec(pn, "pulse_network:pattern_encoding", "")
		return
	end

	local fs, size, id = false

	for k, v in pairs(fields) do
		local k_split = k:split"~" -- Module, action, parameters
		local a = k_split[1]
		if a == "change_nei_mode" then
			fs, size, id = nei.draw_recipe_wrapped(k_split[2], player, 1, tonumber(v))
			if id and id ~= 0 then fs = fs .. ("button[%s,0;2,1;re_encode_fs;%s]"):format(size.x - 2, S"Encode") end
			encoder_context2[pn] = id
		elseif a == "view_recipe" then
			local item, num, type = k_split[2], tonumber(k_split[3]), tonumber(k_split[4])
			fs, size, id = nei.draw_recipe_wrapped(item, player, num, type)
			if id and id ~= 0 then fs = fs .. ("button[%s,0;2,1;re_encode_fs;%s]"):format(size.x - 2, S"Encode") end
			encoder_context2[pn] = id
		end
	end

	if fs then
		minetest.show_formspec(pn, "pulse_network:pattern_encoding", fs)
	end
end)