local api = trinium.api
local S = tinker.S

local tool_station_formspec = [[
	size[8,6.5]
	list[context;inputs;1,0;3,2;]
	list[context;output;6,0.5;1,1;]
	list[current_player;main;0,2.5;8,4;]
	listring[]
]]

local function recalculate(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_stack("output", 1, "")
	table.walk(tinker.tools, function(v, k)
		local c, count = v.components, api.count_stacks(inv, "inputs", true)
		if count ~= #c then return end
		if not table.every(c, function(c1)
			return inv:contains_item("inputs", "tinker_phase:part_"..c1.name)
		end) then return end

		local stack = ItemStack("tinker_phase:tool_"..k)
		local meta2 = stack:get_meta()

		local durability, level, times, color, traits = 0, 0, {}, "FFFFFF", {}
		table.walk(c, function(c1)
			if c1.type == 1 then
				local x = inv:remove_item("inputs", "tinker_phase:part_"..c1.name)
				inv:add_item("inputs", x)
				local data = x:get_meta():get_string("material_data"):data()
				durability = durability + data.base_durability
				if level < data.level then
					level = data.level
				end
				for k,v in pairs(data.traits) do
					traits[k] = math.max(traits[k] or 0, v)
				end

				table.insert(times, data.base_speed)
				color = data.color

				meta2:set_string("material_name", data.description)
			end
		end)
		level = level + v.level_boost
		table.walk(c, function(c1)
			if c1.type == 2 then
				local x = inv:remove_item("inputs", "tinker_phase:part_"..c1.name)
				inv:add_item("inputs", x)
				local data = x:get_meta():get_string("material_data"):data()
				durability = durability * data.rod_durability
				for k,v in pairs(data.traits) do
					traits[k] = math.max(traits[k] or 0, v)
				end
			end
		end)

		traits = table.filter(traits, function(v, k)
			if tinker.modifiers[k] and tinker.modifiers[k].incompat then
				local x = tinker.modifiers[k].incompat
				return table.every(x, function(v1) return not traits[v1] end)
			end
			return true
		end)
		times = math.geometrical_avg(times)
		local times2 = table.map(v.times, function(v1, k1)
			return {
				times = math.table_multiply(tinker.base[k1], v1 / times),
				uses = 0,
				maxlevel = level,
			}
		end)

		meta2:set_int("max_durability", durability)
		meta2:set_int("current_durability", durability)
		meta2:set_string("color", "#"..color)
		meta2:set_tool_capabilities{
			full_punch_interval = 1.0,
			max_drop_level = level,
			groupcaps = times2,
		}
		meta2:set_int("modifiers_left", 3)
		meta2:set_string("modifiers", minetest.serialize(traits))

		for k,v in pairs(traits) do
			if tinker.modifiers[k] and tinker.modifiers[k].after_create then
				tinker.modifiers[k].after_create(k, v, meta2)
			end
		end

		meta2:set_string("description", v.update_description(stack))

		inv:set_stack("output", 1, stack)
	end)
end

minetest.register_node("tinker_phase:tool_station", {
	description = S"Tool Station",
	tiles = {"tinker_phase.assembly_table.png", "tinker_phase.table_bottom.png", "tinker_phase.table_side.png"},
	drawtype = "nodebox",
	node_box = {
		["type"] = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, -0.25, 0.25, -0.25},
			{0.5, -0.5, -0.5, 0.25, 0.25, -0.25},
			{-0.5, -0.5, 0.5, -0.25, 0.25, 0.25},
			{0.5, -0.5, 0.5, 0.25, 0.25, 0.25},
			{-0.5, 0.25, -0.5, 0.5, 0.5, 0.5},
		}
	},
	groups = {choppy = 2},
	after_place_node = function(pos, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		api.initialize_inventory(inv, {inputs = 6, output = 1})
		meta:set_string("formspec", tool_station_formspec)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return listname == "inputs" and minetest.get_item_group(stack:get_name(), "_tinkerphase_part") ~= 0
			and stack:get_count() or 0
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		return from_list == "inputs" and to_list == "inputs" and count or 0
	end,

	on_metadata_inventory_move = recalculate,
	on_metadata_inventory_put = recalculate,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "output" then
			for i = 1, 6 do
				local stack = inv:get_stack("inputs", i)
				stack:take_item()
				inv:set_stack("inputs", i, stack)
			end
		end
		recalculate(pos)
	end,
})
