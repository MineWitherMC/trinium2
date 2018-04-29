local pulse = trinium.pulse_network
local S = pulse.S
local M = trinium.materials.materials
local api = trinium.api

function pulse.import_to_controller(pos)
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
end

minetest.register_node("pulse_network:controller", {
	stack_max = 1,
	tiles = {"pulse_network.controller_side.png", "pulse_network.controller_side.png", "pulse_network.controller_side.png",
			"pulse_network.controller_side.png", "pulse_network.controller_side.png", "pulse_network.controller_front.png"},
	description = S"Pulse Network Controller",
	groups = {cracky = 1},
	paramtype2 = "facedir",
	after_place_node = function(pos, player)
		local meta = minetest.get_meta(pos)
		meta:set_int("capacity_types", 0)
		meta:set_int("used_types", 0)
		meta:set_int("capacity_items", 0)
		meta:set_int("used_items", 0)
		meta:set_string("connected_devices", minetest.serialize{})
		meta:set_string("inventory", minetest.serialize{})
		meta:set_string("inventory_list", minetest.serialize{})
		api.initialize_inventory(meta:get_inventory(), {input = 1})
	end,

	on_metadata_inventory_put = pulse.import_to_controller,
	allow_metadata_inventory_take = function() return 0 end,

	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if itemstack:is_empty() then
			local meta = minetest.get_meta(pos)
			cmsg.push_message_player(clicker,
					S("Used types: @1/@2", meta:get_int"used_types", meta:get_int"capacity_types").."\n"..
					S("Stored items: @1/@2", meta:get_int"used_items", meta:get_int"capacity_items"))
		end
	end,
})

minetest.register_craftitem("pulse_network:combinator", {
	inventory_image = "pulse_network.combinator.png",
	description = S"Pulse Network Combinator",
	stack_max = 1,
	on_place = function(item, player, pointed_thing)
		local node = pointed_thing.under
		local name = minetest.get_node(node).name
		if name == "pulse_network:controller" then
			local meta = item:get_meta()
			meta:set_string("controller_pos", minetest.serialize(pointed_thing.under))
			meta:set_string("description", S"Pulse Network Combinator".."\n"..
					S("Connected to (@1, @2, @3)",
						node.x, node.y, node.z))
			cmsg.push_message_player(player, S"Combinator successfully connected to network!")
			return item
		elseif minetest.get_item_group(name, "pulsenet_slave") > 0 then
			local meta = item:get_meta()
			local controller_pos = minetest.deserialize(meta:get_string"controller_pos")
			if meta:get_string"controller_pos" == "" or
					minetest.get_node(controller_pos).name ~= "pulse_network:controller" then
				cmsg.push_message_player(player, S"Combinator got unlinked!")
			else
				local meta1 = minetest.get_meta(node)
				if meta1:get_string("controller_pos") ~= "" then
					cmsg.push_message_player(player, S"This device is already connected!")
				else
					meta1:set_string("controller_pos", meta:get_string("controller_pos"))
					local meta2 = minetest.get_meta(controller_pos)
					local cd = minetest.deserialize(meta2:get_string"connected_devices")
					table.insert(cd, node)
					if minetest.registered_items[name].on_pulsenet_connection then
						minetest.registered_items[name].on_pulsenet_connection(node, controller_pos)
					end
					for i = 1, #cd do
						local name1 = minetest.get_node(cd[i]).name
						if minetest.registered_items[name1].on_pulsenet_update then
							minetest.registered_items[name1].on_pulsenet_update(cd[i], controller_pos)
						end
					end
					meta2:set_string("connected_devices", minetest.serialize(cd))
					cmsg.push_message_player(player, S"Device successfully connected to network!")
				end
			end
		else
			cmsg.push_message_player(player, S"Incorrect target!")
		end
	end,
})
