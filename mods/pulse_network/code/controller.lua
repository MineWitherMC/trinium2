local S = pulse_network.S
local api = trinium.api

minetest.register_node("pulse_network:controller", {
	stack_max = 1,
	tiles = {"pulse_network.controller_side.png", "pulse_network.controller_side.png", "pulse_network.controller_side.png",
			"pulse_network.controller_side.png", "pulse_network.controller_side.png", "pulse_network.controller_front.png"},
	description = S"Pulse Network Controller",
	groups = {cracky = 1, pulsenet_linker = 1, rich_info = 1},
	sounds = trinium.sounds.default_metal,
	paramtype2 = "facedir",
	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("capacity_types", 0)
		meta:set_int("used_types", 0)
		meta:set_int("capacity_items", 0)
		meta:set_int("used_items", 0)
		meta:set_int("active_processes", 0)
		meta:set_int("available_processes", 0)
		meta:set_int("used_memory", 0)
		meta:set_int("available_memory", 0)
		meta:set_string("connected_devices", minetest.serialize{})
		meta:set_string("inventory", minetest.serialize{})
		meta:set_string("patterns", minetest.serialize{})
		meta:set_string("pending_recipes", minetest.serialize{})
		meta:set_string("pending_outputs", minetest.serialize{})
		api.initialize_inventory(meta:get_inventory(), {input = 1})

		minetest.get_node_timer(pos):start(5)
	end,

	on_metadata_inventory_put = pulse_network.import_to_controller,
	allow_metadata_inventory_take = function() return 0 end,

	get_rich_info = function(pos)
		local meta = minetest.get_meta(pos)
		return S("Types: @1/@2", meta:get_int"used_types", meta:get_int"capacity_types") .. "\n" ..
				S("Items: @1/@2", meta:get_int"used_items", meta:get_int"capacity_items") .. "\n" ..
				S("Crafting memory: @1/@2", meta:get_int"used_memory", meta:get_int"available_memory") .. "\n" ..
				S("Crafting processes: @1/@2", meta:get_int"active_processes", meta:get_int"available_processes")
	end,

	after_dig_node = function(_, _, oldmetadata)
		local connected = oldmetadata.fields.connected_devices:data()
		table.walk(connected, function(r)
			minetest.get_meta(r):set_int("network_destruction", 1)
			minetest.dig_node(r)
		end)
	end,

	on_timer = function(pos)
		local meta = minetest.get_meta(pos)
		local outputs = meta:get_string"pending_outputs":data()
		if #outputs == 0 then
			minetest.get_node_timer(pos):start(5)
			return
		end

		local inventory = meta:get_string"inventory":data()
		local CI, UI, CT, UT = meta:get_int"capacity_items", meta:get_int"used_items",
				meta:get_int"capacity_types", meta:get_int"used_types"

		local item, count = unpack(outputs[1])
		if not inventory[item] and CT == UT then return end
		count = math.min(count, CI - UI)
		if count == 0 then return end
		if not inventory[item] then
			inventory[item] = count
			UT = UT + 1
			meta:set_int("used_types", UT)
		else
			inventory[item] = inventory[item] + count
		end
		outputs[1][2] = outputs[1][2] - count

		UI = UI + count
		meta:set_int("used_items", UI)
		meta:set_string("inventory", minetest.serialize(inventory))
		if outputs[1][2] == 0 then
			table.remove(outputs, 1)
		end
		meta:set_string("pending_outputs", minetest.serialize(outputs))
		minetest.get_node_timer(pos):start(5)

		pulse_network.trigger_update(pos)
	end,
})
