local S = pulse_network.S
local api = trinium.api

local function generate_buttons(ctrlpos, index, search)
	local meta = minetest.get_meta(ctrlpos)
	local str = ""
	local inv = meta:get_string"inventory":data()
	local inv_list = meta:get_string"inventory_list":data()
	local acquired = 0

	for c, k, v in table.asort(inv, function(a, b) return inv[a] > inv[b] or (inv[a] == inv[b] and a > b) end) do
		-- k is item, v is amount
		if c > index + 40 then break end
		if c > index and (k:lower():find(search:lower()) or
				minetest.registered_items[k].description:lower():find(search:lower())) then
			acquired = acquired + 1
			local key = table.exists(inv_list, api.functions.equal(k))
			str = str .. ([=[
				item_image_button[%s,%s;1,1;%s;take_items~%s;%s]
			]=]):format(math.modulate(acquired, 8) - 1, math.ceil(acquired / 8) - 1, k:split" "[1], key, v)
			local s = ItemStack(("%s 1 %s"):format(
					k:split(" ")[1],
					table.concat(table.tail(k:split" "), " ")
			)):get_meta():get_string("description")
			if s ~= "" then
				str = str .. ([=[
					tooltip[take_items~%s;%s]
				]=]):format(key, s)
			end
		end
	end
	local max = math.min(meta:get_int"capacity_types" - index, 40)
	if acquired < max then
		for i = acquired + 1, max do
			str = str .. ([=[
				item_image_button[%s,%s;1,1;;;]
			]=]):format(math.modulate(i, 8) - 1, math.ceil(i / 8) - 1)
		end
	end
	return str
end

local function get_terminal_formspec(ctrlpos, index, search_string)
	local meta = minetest.get_meta(ctrlpos)
	local CI, UI, CT, UT = meta:get_int"capacity_items", meta:get_int"used_items",
	meta:get_int"capacity_types", meta:get_int"used_types"
	return ([[
		size[8,12]
		list[context;input;0,5.5;1,1]
		button[1,5.5;1,1;up;↑]
		button[2,5.5;1,1;down;↓]
		list[current_player;main;0,7;8,4;]
		listring[]
		field[0.25,11.33;6,1;search;;${search_string}]
		button[7,11;1,1;empty_search;X]
		button[6,11;1,1;send_search;>>]
		field_close_on_enter[search;false]
		${buttons}
		textarea[3.25,5.5;5,1.2;;;${network_info}]
	]]):from_table{
		search_string = search_string,
		buttons = generate_buttons(ctrlpos, index, search_string),
		network_info = S("Types: @1/@2", UT, CT) .. "\n" .. S("Items: @1/@2", UI, CI),
	}
end

minetest.register_node("pulse_network:terminal", {
	stack_max = 16,
	tiles = {"pulse_network.terminal_top.png", "pulse_network.terminal_bottom.png", "pulse_network.terminal_right.png",
	          "pulse_network.terminal_left.png", "pulse_network.terminal_back.png", "pulse_network.terminal_front.png"},
	description = S"Pulse Network Terminal",
	sounds = trinium.sounds.default_metal,
	groups = {cracky = 1, pulsenet_slave = 1},
	paramtype2 = "facedir",
	on_pulsenet_connection = function(pos, ctrlpos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_terminal_formspec(ctrlpos, 0, ""))
		meta:set_int("index", 0)
		api.initialize_inventory(meta:get_inventory(), {input = 1})
	end,

	on_pulsenet_update = function(pos, ctrlpos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", get_terminal_formspec(ctrlpos, meta:get_int"index", meta:get_string"search"))
	end,

	on_metadata_inventory_put = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local ctrlpos = meta:get_string"controller_pos":data()
		local ctrl_meta = minetest.get_meta(ctrlpos)
		local ctrl_inv = ctrl_meta:get_inventory()
		if not ctrl_inv:get_stack("input", 1):is_empty() then
			return
		end
		ctrl_inv:set_stack("input", 1, inv:get_stack("input", 1))
		inv:set_stack("input", 1, "")
		pulse_network.import_to_controller(ctrlpos)
		meta:set_string("formspec", get_terminal_formspec(ctrlpos, meta:get_int"index", meta:get_string"search"))
	end,

	on_receive_fields = function(pos, _, fields, player)
		if fields.quit then return end
		if fields.key_enter then
			fields.send_search = 1
		end
		local meta = minetest.get_meta(pos)
		local ctrlpos = minetest.deserialize(meta:get_string"controller_pos")
		local ctrl_meta = minetest.get_meta(ctrlpos)
		for k in pairs(fields) do
			local k_split = k:split"~"
			local a = k_split[1]
			if a == "down" then
				local key = meta:get_int"index"
				key = math.min(key + 8, math.ceil(ctrl_meta:get_int"capacity_types" / 8) * 8 - 40)
				meta:set_int("index", key)
				meta:set_string("formspec", get_terminal_formspec(ctrlpos, key, meta:get_string"search"))
			elseif a == "up" then
				local key = meta:get_int"index"
				key = math.max(key - 8, 0)
				meta:set_int("index", key)
				meta:set_string("formspec", get_terminal_formspec(ctrlpos, key, meta:get_string"search"))
			elseif a == "empty_search" then
				meta:set_string("search", "")
				meta:set_string("formspec", get_terminal_formspec(ctrlpos, meta:get_int"index", ""))
			elseif a == "send_search" then
				meta:set_string("search", fields.search)
				meta:set_string("formspec",
						get_terminal_formspec(ctrlpos, meta:get_int"index", fields.search))
			elseif a == "take_items" then
				local inv_list = ctrl_meta:get_string"inventory_list":data()
				local id = inv_list[tonumber(k_split[2])]
				local inv = ctrl_meta:get_string"inventory":data()
				local k_split2 = id:split" "
				local tester = ItemStack(k_split2[1])
				if not tester:is_known() then
					inv[id] = nil

					ctrl_meta:set_string("inventory", minetest.serialize(inv))
					pulse_network.import_to_controller(ctrlpos)
					meta:set_string("formspec", get_terminal_formspec(ctrlpos, meta:get_int"index", meta:get_string"search"))
				else
					local ss = minetest.registered_items[k_split2[1]].stack_max
					local item = pulse_network.export_from_controller(ctrlpos, id, ss, tonumber(k_split[2]))
					if item then
						player:get_inventory():add_item("main", item)
					end
				end
			end
		end
	end,
})
