local S = conduits.S

local function get_controller_fs(code, errors)
	return ([=[
		size[8,9]
		box[0,0;7.8,4;#FFFFCC]
		box[0,4;7.8,4;#FF9999]
		textarea[0.29,-0.05;8.01,4.775;code;;%s]
		textarea[0.29,3.95;8.01,4.775;;;%s]
		button[0,8;8,1;send;%s]
	]=]):format(minetest.formspec_escape(code), minetest.formspec_escape(errors), S"Save & Execute")
end

local function timeout()
	debug.sethook()
	error("Execution timed out")
end

local LIMIT = 10e5
local overheat_msg = "Memory Limit Exceeded"
local no_support = "Node doesn't support signals"
local CALL_LIMIT = 300
local function get_sandbox(node_pos)
	local heat = 0

	return {
		vector = {
			add = function(v1, v2)
				heat = heat + 1
				assert(heat <= LIMIT, overheat_msg)
				return vector.add(v1, v2)
			end,
			multiply = function(v1, v2)
				heat = heat + 5
				assert(heat <= LIMIT, overheat_msg)
				return vector.multiply(v1, v2)
			end,
			turn_left = function(v1)
				heat = heat + 2
				assert(heat <= LIMIT, overheat_msg)
				return {x = -v1.z, y = v1.y, z = v1.x}
			end,
			turn_right = function(v1)
				heat = heat + 2
				assert(heat <= LIMIT, overheat_msg)
				return {x = v1.z, y = v1.y, z = -v1.x}
			end,
		},

		get_meta = function(pos)
			heat = heat + 1000
			assert(heat <= LIMIT, overheat_msg)
			return minetest.get_meta(pos):to_table().fields
		end,

		get_state = function()
			heat = heat + 25
			assert(heat <= LIMIT, overheat_msg)
			return minetest.get_meta(node_pos):get_int"state"
		end,

		set_state = function(new)
			heat = heat + 250
			assert(heat <= LIMIT, overheat_msg)
			return minetest.get_meta(node_pos):set_int("state", new)
		end,

		get_inventory = function(pos)
			heat = heat + 5000
			assert(heat <= LIMIT, overheat_msg)
			return minetest.get_meta(pos):to_table().inventory
		end,

		get_backwards_direction = function(pos)
			heat = heat + 10
			assert(heat <= LIMIT, overheat_msg)
			local node = minetest.get_node(pos).param2
			return minetest.facedir_to_dir(node)
		end,

		set_signal = function(direction, new)
			assert(direction.x^2 + direction.y^2 + direction.z^2 == 1, "Target too far")
			heat = heat + 2500
			assert(heat <= LIMIT, overheat_msg)
			local pos = vector.add(direction, node_pos)
			local node = minetest.get_node(pos)
			local signal_param = minetest.get_item_group(node.name, "signal_param")
			assert(signal_param == 1 or signal_param == 2, no_support)
			local paramstring = "param" .. signal_param
			node[paramstring] = new > 0 and 255 or 0
			minetest.set_node(pos, node)
			debug.sethook()
			conduits.rebuild_signals(pos)
			debug.sethook(timeout, "", CALL_LIMIT)
		end,

		get_signal = function(direction)
			assert(direction.x^2 + direction.y^2 + direction.z^2 == 1, "Target too far")
			heat = heat + 15
			assert(heat <= LIMIT, overheat_msg)
			local pos = vector.add(direction, node_pos)
			local node = minetest.get_node(pos)
			local signal_param = minetest.get_item_group(node.name, "signal_param")
			assert(signal_param == 1 or signal_param == 2, no_support)
			local paramstring = "param" .. signal_param
			return node[paramstring]
		end,

		print_and_die = function(string)
			error(string)
		end,

		dump = function(data)
			heat = heat + 10000
			assert(heat <= LIMIT, overheat_msg)
			debug.sethook()
			local ret = dump(data)
			debug.sethook(timeout, "", CALL_LIMIT)
			return ret
		end,

		to_string = function(stack)
			heat = heat + 200
			assert(heat <= LIMIT, overheat_msg)
			debug.sethook()
			local ret = stack:to_string()
			debug.sethook(timeout, "", CALL_LIMIT)
			return ret
		end,

		make_itemmap = function(tbl)
			heat = heat + 60000
			assert(heat <= LIMIT, overheat_msg)
			debug.sethook()
			local ret = {}
			for i = 1, #tbl do
				local id = api.get_item_identifier(tbl[i])
				if id then
					ret[id] = (ret[id] or 0) + tbl[i]:get_count()
				end
			end
			debug.sethook(timeout, "", CALL_LIMIT)
			return ret
		end,
	}
end

minetest.register_node("conduits:lua_controller", {
	tiles = {"conduits.lua_controller_top.png", "conduits.lua_controller_bottom.png", "conduits.lua_controller_side.png",
	        "conduits.lua_controller_side.png", "conduits.lua_controller_side.png", "conduits.lua_controller_front.png"},
	description = S"Lua Controller",
	sounds = trinium.sounds.default_stone,
	groups = {cracky = 1, signal_acceptor = 1},
	paramtype2 = "facedir",

	on_construct = function(pos)
		minetest.get_meta(pos):set_string("formspec", get_controller_fs("", ""))
	end,

	on_receive_fields = function(pos, _, fields)
		if fields.quit then return end
		local meta = minetest.get_meta(pos)
		meta:set_int("active", 1)
		meta:set_string("formspec", get_controller_fs(fields.code, ""))
		meta:set_string("code", fields.code)

		minetest.get_node_timer(pos):start(0.1)
	end,

	on_timer = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int"active" == 0 then return end

		local code = meta:get_string"code"

		local code2 = ([[
			return function(pos)
				%s
				return true
			end
		]]):format(code)
		local good, output = api.sandbox_call(get_sandbox(pos), code2)
		if good then
			good, output = api.limited_call(CALL_LIMIT, output, pos)
		end
		if not good then
			meta:set_int("active", 0)
			meta:set_string("errors", output)
			meta:set_string("formspec", get_controller_fs(code, output))
			return
		end

		minetest.get_node_timer(pos):start(5)
	end,
})