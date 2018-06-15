local S = pulse_network.S

local function reconnect(item, player, node)
	local meta = item:get_meta()
	meta:set_string("controller_pos", minetest.serialize(node))
	meta:set_string("description", S "Pulse Network Combinator" .. "\n" ..
			S("Connected to (@1, @2, @3)",
					node.x, node.y, node.z))
	cmsg.push_message_player(player, S "Combinator successfully connected to network!")
	return item
end

local function connect(item, player, node, name)
	local meta = item:get_meta()
	local controller_pos = meta:get_string "controller_pos":data()
	if not controller_pos or
			minetest.get_item_group(minetest.get_node(controller_pos).name, "pulsenet_linker") == 0 then
		cmsg.push_message_player(player, S "Combinator got unlinked!")
	elseif vector.distance(node, controller_pos) > 28 then
		cmsg.push_message_player(player, S "Target too far!")
	else
		local meta1 = minetest.get_meta(node)
		if meta1:get_string "controller_pos" ~= "" then
			cmsg.push_message_player(player, S "This device is already connected!")
		else
			meta1:set_string("controller_pos", meta:get_string("controller_pos"))
			local meta2 = minetest.get_meta(controller_pos)
			local cd = meta2:get_string "connected_devices":data()
			table.insert(cd, node)
			meta2:set_string("connected_devices", minetest.serialize(cd))
			if minetest.registered_items[name].on_pulsenet_connection then
				minetest.registered_items[name].on_pulsenet_connection(node, controller_pos)
			end
			pulse_network.trigger_update(controller_pos)
			cmsg.push_message_player(player, S "Device successfully connected to network!")
		end
	end
end

minetest.register_craftitem("pulse_network:combinator", {
	inventory_image = "pulse_network.combinator.png",
	description = S "Pulse Network Combinator",
	stack_max = 1,
	on_place = function(item, player, pointed_thing)
		local node = pointed_thing.under
		local name = minetest.get_node(node).name
		if name == "pulse_network:controller" then
			return reconnect(item, player, node)
		elseif minetest.get_item_group(name, "pulsenet_slave") > 0 then
			return connect(item, player, node, name)
		else
			cmsg.push_message_player(player, S "Incorrect target!")
		end
	end,
})
