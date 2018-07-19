local S = pulse_network.S
local api = trinium.api

function pulse_network.trigger_update(controller_pos)
	local meta = minetest.get_meta(controller_pos)
	local cd = minetest.deserialize(meta:get_string"connected_devices")
	for i = 1, #cd do
		local name1 = minetest.get_node(cd[i]).name
		if minetest.registered_items[name1].on_pulsenet_update then
			minetest.registered_items[name1].on_pulsenet_update(cd[i], controller_pos)
		end
	end
end

function pulse_network.import_to_controller(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local items = meta:get_string"inventory":data()
	local s = inv:get_stack("input", 1)
	if not s:is_empty() then
		local CI, UI, CT, UT = meta:get_int"capacity_items", meta:get_int"used_items",
				meta:get_int"capacity_types", meta:get_int"used_types"
		local max_import = CI - UI
		local id = api.get_item_identifier(s)
		local dec = math.min(max_import, s:get_count())
		if items[id] then
			items[id] = items[id] + dec
			s:take_item(dec)
			inv:set_stack("input", 1, s)
			meta:set_int("used_items", UI + dec)
		elseif CT > UT then
			items[id] = dec
			s:take_item(dec)
			inv:set_stack("input", 1, s)
			meta:set_int("used_items", UI + dec)
			meta:set_int("used_types", UT + 1)

			local items_list = meta:get_string"inventory_list":data()
			table.insert(items_list, id)
			meta:set_string("inventory_list", minetest.serialize(items_list))
		end

		meta:set_string("inventory", minetest.serialize(items))
	end
	pulse_network.trigger_update(pos)
end

function pulse_network.export_from_controller(pos, id, count, id2)
	local meta = minetest.get_meta(pos)
	local items = meta:get_string"inventory":data()
	if not items[id] then return false end
	count = math.min(count, items[id])
	meta:set_int("used_items", meta:get_int"used_items" - count)

	items[id] = items[id] - count
	if items[id] == 0 then
		items[id] = nil
		meta:set_int("used_types", meta:get_int"used_types" - 1)
		local new_list
		if not id2 then
			local old_list = meta:get_string"inventory_list":data()
			new_list = {}
			for i = 1, #old_list do
				if old_list[i] ~= id then
					table.insert(new_list, id)
				end
			end
		else
			new_list = meta:get_string"inventory_list":data()
			table.remove(new_list, id2)
		end
		meta:set_string("inventory_list", minetest.serialize(new_list))
	end
	meta:set_string("inventory", minetest.serialize(items))
	pulse_network.import_to_controller(pos)

	local tbl = id:split" "
	local additional_info = table.map(table.tail(tbl), function(z) return " "..z end)
	return tbl[1] .. " " .. count .. table.concat(additional_info)
end

minetest.register_node("pulse_network:controller", {
	stack_max = 1,
	tiles = {"pulse_network.controller_side.png", "pulse_network.controller_side.png", "pulse_network.controller_side.png",
			"pulse_network.controller_side.png", "pulse_network.controller_side.png", "pulse_network.controller_front.png"},
	description = S"Pulse Network Controller",
	groups = {cracky = 1, pulsenet_linker = 1, rich_info = 1},
	sounds = trinium.sounds.default_metal,
	paramtype2 ="facedir",
	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("capacity_types", 0)
		meta:set_int("used_types", 0)
		meta:set_int("capacity_items", 0)
		meta:set_int("used_items", 0)
		meta:set_string("connected_devices", minetest.serialize {})
		meta:set_string("inventory", minetest.serialize {})
		meta:set_string("inventory_list", minetest.serialize {})
		api.initialize_inventory(meta:get_inventory(), {input = 1})
	end,

	on_metadata_inventory_put = pulse_network.import_to_controller,
	allow_metadata_inventory_take = function() return 0 end,

	get_rich_info = function(pos)
		local meta = minetest.get_meta(pos)
		return S("Types: @1/@2", meta:get_int"used_types", meta:get_int"capacity_types") .."\n" ..
				S("Items: @1/@2", meta:get_int"used_items", meta:get_int"capacity_items")
	end,

	after_dig_node = function(_, _, oldmetadata)
		local connected = oldmetadata.fields.connected_devices:data()
		table.walk(connected, function(r) minetest.dig_node(r) end)
	end,
})