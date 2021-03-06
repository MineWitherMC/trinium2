local api = trinium.api
local S = tinker.S

local tool_station_formspec = [[
	size[8,6.5]
	list[context;inputs;1,0;3,2;]
	list[context;output;6,0.5;1,1;]
	list[current_player;main;0,2.5;8,4;]
	listring[context;output]
	listring[current_player;main]
	listring[context;inputs]
	image[4.5,0.5;1,1;trinium_gui.arrow.png]
]]

local function recalculate(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_stack("output", 1, "")
	table.walk(tinker.tools, function(v, k)
		local c, count = v.components, api.count_stacks(inv, "inputs", true)
		if count ~= #c then return end
		if not table.every(c, function(c1)
			return inv:contains_item("inputs", "tinker_phase:part_" .. c1.name)
		end) then return end

		local stack = ItemStack("tinker_phase:tool_" .. k)
		local meta2 = stack:get_meta()

		local durability, level, times, traits = 0, v.level_boost, {}, {}
		local color
		table.walk(c, function(c1)
			if c1.type == 1 then
				local x = inv:remove_item("inputs", "tinker_phase:part_" .. c1.name)
				inv:add_item("inputs", x)
				local data = x:get_meta():get_string("material_data"):data()
				durability = durability + data.base_durability
				if level < data.level then
					level = data.level
				end
				for k1, v1 in pairs(data.traits) do
					traits[k1] = math.max(traits[k1] or 0, v1)
				end

				table.insert(times, data.base_speed)
				color = data.color

				meta2:set_string("material_name", data.description)
			end
		end)
		level = level + v.level_boost
		table.walk(c, function(c1)
			if c1.type == 2 then
				local x = inv:remove_item("inputs", "tinker_phase:part_" .. c1.name)
				inv:add_item("inputs", x)
				local data = x:get_meta():get_string("material_data"):data()
				durability = durability * data.rod_durability
				for k1, v1 in pairs(data.traits) do
					traits[k1] = math.max(traits[k1] or 0, v1)
				end
			end
		end)

		if level < 0 then return end

		traits = table.filter(traits, function(_, k1)
			if tinker.modifiers[k1] and tinker.modifiers[k1].incompat then
				local x = tinker.modifiers[k1].incompat
				return table.every(x, function(v1) return not traits[v1] end)
			end
			return true
		end)
		times = math.geometrical_avg(times)
		local times2 = table.map(v.times, function(v1, k1)
			return {
				times = api.table_multiply(tinker.base[k1], v1 / times),
				uses = 0,
				maxlevel = level,
			}
		end)

		meta2:set_int("max_durability", durability * v.durability_mult)
		meta2:set_int("current_durability", durability * v.durability_mult)
		meta2:set_string("color", "#" .. color)
		meta2:set_tool_capabilities {
			full_punch_interval = 1.0,
			max_drop_level = level,
			groupcaps = times2,
		}
		meta2:set_int("modifiers_left", 3)
		meta2:set_string("modifiers", minetest.serialize(traits))

		for k1, v1 in pairs(traits) do
			if tinker.modifiers[k1] and tinker.modifiers[k1].after_create then
				tinker.modifiers[k1].after_create(v1, meta2)
			end
		end

		meta2:set_string("description", v.update_description(stack))

		inv:set_stack("output", 1, stack)
	end)
end

minetest.register_node("tinker_phase:tool_station", {
	description = S"Tool Station",
	tiles = {"tinker_phase.assembly_table.png", "tinker_phase.table_bottom.png", "tinker_phase.table_side.png"},
	sounds = trinium.sounds.default_wood,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, -0.25, 0.25, -0.25},
			{0.5, -0.5, -0.5, 0.25, 0.25, -0.25},
			{-0.5, -0.5, 0.5, -0.25, 0.25, 0.25},
			{0.5, -0.5, 0.5, 0.25, 0.25, 0.25},
			{-0.5, 0.25, -0.5, 0.5, 0.5, 0.5},
		}
	},
	groups = { choppy = 2 },
	after_place_node = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		api.initialize_inventory(inv, { inputs = 6, output = 1 })
		meta:set_string("formspec", tool_station_formspec)
	end,
	allow_metadata_inventory_put = function(_, list_name, _, stack)
		return list_name == "inputs" and minetest.get_item_group(stack:get_name(), "_tinker_phase_part") ~= 0
				and stack:get_count() or 0
	end,
	allow_metadata_inventory_move = function(_, from_list, _, to_list, _, count)
		return from_list == "inputs" and to_list == "inputs" and count or 0
	end,

	on_metadata_inventory_move = recalculate,
	on_metadata_inventory_put = recalculate,
	on_metadata_inventory_take = function(pos, list_name)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if list_name == "output" then
			for i = 1, 6 do
				local stack = inv:get_stack("inputs", i)
				stack:take_item()
				inv:set_stack("inputs", i, stack)
			end
		end
		recalculate(pos)
	end,
})
