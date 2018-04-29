local pulse = trinium.pulse_network
local S = pulse.S
local M = trinium.materials.materials

function pulse.add_storage_cell(id, texture, desc, add_types, add_items)
	minetest.register_node(id, {
		stack_max = 16,
		tiles = texture,
		description = desc,
		groups = {cracky = 1, pulsenet_slave = 1},
		paramtype2 = "facedir",
		on_pulsenet_connection = function(pos, ctrlpos)
			local meta = minetest.get_meta(ctrlpos)
			local cs = meta:get_int"capacity_types"
			local items = meta:get_int"capacity_items"
			meta:set_int("capacity_types", cs + add_types)
			meta:set_int("capacity_items", items + add_items)
		end,

		can_dig = function(pos, player)
			local meta = minetest.get_meta(pos)
			local ctrlpos = minetest.deserialize(meta:get_string"controller_pos")
			if not ctrlpos or minetest.get_node(ctrlpos).name ~= "pulse_network:controller" then return true end
			local ctrlmeta = minetest.get_meta(ctrlpos)
			return ctrlmeta:get_int"capacity_types" - add_types >= ctrlmeta:get_int"used_types" and
				ctrlmeta:get_int"capacity_items" - add_items >= ctrlmeta:get_int"used_items"
		end,

		after_dig_node = function(pos, oldnode, oldmeta, digger)
			local ctrlpos = oldmeta.fields.controller_pos
			local dsp = minetest.deserialize(ctrlpos)
			if ctrlpos and minetest.get_node(dsp).name == "pulse_network:controller" then
				local ctrlmeta = minetest.get_meta(dsp)
				local cs = ctrlmeta:get_int"capacity_types"
				local items = ctrlmeta:get_int"capacity_items"
				ctrlmeta:set_int("capacity_types", cs - add_types)
				ctrlmeta:set_int("capacity_items", items - add_items)
			end
		end,
	})
end

-- per tier, type amount is divided by 3, and storage is multiplied by 8
pulse.add_storage_cell("pulse_network:storage_cell", {"pulse_network.storage_cell.png"},
		S"Pulse Network Storage Cell", 27, 5000)
pulse.add_storage_cell("pulse_network:void_storage_cell", {"pulse_network.void_storage_cell.png"},
		S"Void Pulse Network Storage Cell", 9, 40000)
pulse.add_storage_cell("pulse_network:condensed_storage_cell", {"pulse_network.condensed_storage_cell.png"},
		S"Condensed Pulse Network Storage Cell", 3, 320000)
pulse.add_storage_cell("pulse_network:super_storage_cell", {"pulse_network.super_storage_cell.png"},
		S"Ultimate Pulse Network Storage Cell", 1, 2560000)