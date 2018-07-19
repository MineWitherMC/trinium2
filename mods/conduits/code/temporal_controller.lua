local S = conduits.S
local strings = conduits.strings
local api = trinium.api
local bifrost_dust = trinium.materials.materials.bifrost:get"dust"
local texture = api.get_fs_texture(bifrost_dust)

local times = {S"Day", S"Night"}
local function temporal_controller_fs(mode, time, leftover)
	return ([=[
		size[8,7]
		list[current_player;main;0,3;8,4]
		list[context;catalyst;0,0.5;1,1]
		image[0,1.5;1,1;${bifrost}]
		label[4,0;${current_mode}]
		button[4,0.5;2,1;set_mode~1;${1}]
		button[6,0.5;2,1;set_mode~2;${2}]
		button[4,1.5;2,1;set_mode~3;${3}]
		button[6,1.5;2,1;set_mode~4;${4}]
		label[1.5,0;${current_time}]
		button[1.5,0.5;2,1;set_time~1;${day}]
		button[1.5,1.5;2,1;set_time~2;${night}]
		label[0,0;${leftover}]
		listring[]
	]=]):from_table{
		bifrost = texture,
		current_mode = S("Current mode: @1", mode),
		strings[1], strings[2], strings[3], strings[4],
		current_time = S("Current time: @1", time),
		day = times[1],
		night = times[2],
		leftover = S("@1 left", leftover),
	}
end

minetest.register_node("conduits:temporal_controller", {
	description = S"Temporal Controller",
	sounds = trinium.sounds.default_metal,
	tiles = {"conduits.temporal_controller_top.png", "conduits.temporal_controller_side.png"},
	groups = {cracky = 2, signal_acceptor = 2, rich_info = 1, conduit_insert = 1},

	conduit_insert = function(stack)
		if stack:get_name() == bifrost_dust then
			return "catalyst"
		else
			return false
		end
	end,

	get_rich_info = function(pos)
		local timer = minetest.get_node_timer(pos)
		local msg1 = minetest.get_node(pos).param2 > 0 and S"Signal Enabled" or S"Signal Disabled"
		local msg2 = S("Next operation in @1 seconds", math.round(timer:get_timeout() - timer:get_elapsed(), 0.1))
		return msg1 .. "\n" .. msg2
	end,

	after_place_node = function(pos)
		minetest.get_node_timer(pos):start(10)
		for i = 1, #conduits.neighbours do
			local v1 = vector.add(pos, conduits.neighbours[i])
			local node = minetest.get_node(v1)
			local sigparam = minetest.get_item_group(node.name, "signal_param")
			if sigparam == 3 or (sigparam > 0 and node["param" .. sigparam] > 1) then
				local node2 = minetest.get_node(pos)
				node2.param2 = 1
				minetest.swap_node(pos, node2)
				break
			end
		end

		local meta = minetest.get_meta(pos)
		api.initialize_inventory(meta:get_inventory(), {catalyst = 1})
		meta:set_int("mode", 2)
		meta:set_int("time", 1)
		meta:set_string("formspec", temporal_controller_fs(strings[2], times[1], 0))
	end,

	on_receive_fields = function(pos, _, fields)
		if fields.quit then return end
		local meta = minetest.get_meta(pos)
		for k in pairs(fields) do
			local action, param = unpack(k:split"~")
			if action == "set_mode" then
				meta:set_int("mode", tonumber(param))
			elseif action == "set_time" then
				meta:set_int("time", tonumber(param))
			end
		end

		local fs = temporal_controller_fs(strings[meta:get_int"mode"], times[meta:get_int"time"], meta:get_int"leftover")
		meta:set_string("formspec", fs)
	end,

	allow_metadata_inventory_put = function(_, _, _, stack)
		return stack:get_name() == bifrost_dust and stack:get_count() or 0
	end,

	on_timer = function(pos)
		local timer = minetest.get_node_timer(pos)
		local meta = minetest.get_meta(pos)
		local mode = meta:get_int"mode"
		local param = minetest.get_node(pos).param2
		if (param == 0 and mode == 2) or (param > 0 and mode == 3) or mode == 1 then
			timer:start(5)
			return
		end

		local leftover = meta:get_int"leftover"
		if leftover > 0 then
			leftover = leftover - 1
		else
			local inv = meta:get_inventory()
			local catalyst = inv:get_stack("catalyst", 1)
			if catalyst:is_empty() then
				timer:start(5)
				return
			end
			catalyst:take_item()
			inv:set_stack("catalyst", 1, catalyst)
			leftover = 7
		end
		meta:set_int("leftover", leftover)

		minetest.set_timeofday((2 - meta:get_int"time") * 0.281)

		local fs = temporal_controller_fs(strings[meta:get_int"mode"], times[meta:get_int"time"], leftover)
		meta:set_string("formspec", fs)

		timer:start(30)
	end,
})

minetest.register_node("conduits:time_sensor", {
	description = S"Time Sensor",
	tiles = {"conduits.signal_emitter.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.1, 0.5},
	},
	sounds = trinium.sounds.default_stone,
	groups = {cracky = 2, signal_param = 2, rich_info = 1},
	after_place_node = conduits.rebuild_signals,
	after_dig_node = conduits.rebuild_signals,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(2)
	end,

	on_timer = function(pos)
		local node = minetest.get_node(pos)
		local time = minetest.get_timeofday()
		if time >= 0.281 and time <= 0.781 then
			node.param2 = 255
		else
			node.param2 = 0
		end
		minetest.swap_node(pos, node)
		minetest.get_node_timer(pos):start(2)
		conduits.rebuild_signals(pos)
	end,

	get_rich_info = function(pos)
		local timer = minetest.get_node_timer(pos)
		local msg1 = minetest.get_node(pos).param2 > 0 and S"Signal Enabled" or S"Signal Disabled"
		local msg2 = S("Next operation in @1 seconds", math.round(timer:get_timeout() - timer:get_elapsed(), 0.1))
		return msg1 .. "\n" .. msg2
	end,
})
