local S = pulse_network.S

function pulse_network.add_crafting_core(id, texture, desc, add_processes, add_memory)
	minetest.register_node(id, {
		stack_max = 16,
		tiles = texture,
		sounds = trinium.sounds.default_metal,
		description = desc,
		groups = {cracky = 1, pulsenet_slave = 1},
		on_pulsenet_connection = function(_, ctrlpos)
			local meta = minetest.get_meta(ctrlpos)
			local cp = meta:get_int"available_processes"
			meta:set_int("available_processes", cp + add_processes)
			local cm = meta:get_int"available_memory"
			meta:set_int("available_memory", cm + add_memory)
		end,

		can_dig = function(pos)
			local meta = minetest.get_meta(pos)
			if meta:get_int"network_destruction" == 1 then return true end
			local ctrlpos = minetest.deserialize(meta:get_string"controller_pos")
			if not ctrlpos or minetest.get_node(ctrlpos).name ~= "pulse_network:controller" then return true end
			local ctrl_meta = minetest.get_meta(ctrlpos)
			return ctrl_meta:get_int"available_processes" - add_processes >= ctrl_meta:get_int"active_processes" and
					ctrl_meta:get_int"available_memory" - add_memory >= ctrl_meta:get_int"used_memory"
		end,

		after_dig_node = function(_, _, oldmetadata)
			local ctrlpos = oldmetadata.fields.controller_pos
			if not ctrlpos then return end
			ctrlpos = ctrlpos:data()
			if not ctrlpos then return end
			if ctrlpos and minetest.get_node(ctrlpos).name == "pulse_network:controller" then
				local ctrl_meta = minetest.get_meta(ctrlpos)
				local cp = ctrl_meta:get_int"available_processes"
				ctrl_meta:set_int("available_processes", cp - add_processes)
				local cm = ctrl_meta:get_int"available_memory"
				ctrl_meta:set_int("available_memory", cm - add_memory)
				pulse_network.trigger_update(ctrlpos)
			end
		end,
	})
end

pulse_network.add_crafting_core("pulse_network:crafting_core", {"pulse_network.crafting_core.png"},
	S"Basic Crafting Core", 6, 1200)
pulse_network.add_crafting_core("pulse_network:enhanced_crafting_core", {"pulse_network.enhanced_crafting_core.png"},
	S"Enhanced Crafting Core", 4, 4000)
pulse_network.add_crafting_core("pulse_network:complicated_crafting_core",
	{"pulse_network.complicated_crafting_core.png"}, S"Complicated Crafting Core", 2, 12000)
pulse_network.add_crafting_core("pulse_network:integral_crafting_core", {"pulse_network.integral_crafting_core.png"},
	S"Integral Crafting Core", 1, 60000)
