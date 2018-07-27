local S = pulse_network.S
local api = trinium.api
local interface_formspec = [=[
	size[9,6.5]
	image[4,1;1,1;pulse_network.encoded_pattern.png^[brighten]
	list[context;patterns;0,1;4,1;]
	list[context;patterns;5,1;4,1;4]
	list[context;output_filter;0.5,0;8,1;]
	list[current_player;main;0.5,2.5;8,4;]
	listring[context;output_filter]
	listring[current_player;main]
	listring[context;patterns]
	listring[current_player;main]
]=]
local interface_inv = {patterns = 8, input = 1, output = 8, output_filter = 8, autocraft_buffer = 16}

local function on_metadata_inventory_change(pos, list, index, stack)
	if list ~= "patterns" then return end
	local meta = minetest.get_meta(pos)
	local ctrlpos = meta:get_string"controller_pos":data()
	pulse_network.notify_pattern_change(ctrlpos, stack, vector.stringify(pos) .. "|" .. index)
end

local neighbours = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{y = 1, x = 0, z = 0},
	{y = -1, x = 0, z = 0},
	{z = 1, x = 0, y = 0},
	{z = -1, x = 0, y = 0},
}

minetest.register_node("pulse_network:interface", {
	stack_max = 16,
	tiles = {"pulse_network.interface.png"},
	sounds = trinium.sounds.default_metal,
	description = S"Pulse Network Interface",
	groups = {cracky = 1, pulsenet_slave = 1, conduit_insert = 1, conduit_extract = 1, rich_info = 1},
	conduit_extract = {"output"},

	get_rich_info = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local tbl = {S"Buffered Items:"}
		local action = false
		for i = 1, 8 do
			local stack = inv:get_stack("output", i)
			if not stack:is_empty() then
				local name = stack:get_name()
				table.insert(tbl, stack:get_count() .. " " .. api.get_description(name))
				action = true
			end
		end
		if action then return table.concat(tbl, "\n") end
	end,

	on_pulsenet_connection = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", interface_formspec)
		meta:set_string("autocraft_itemmap", minetest.serialize{})
		api.initialize_inventory(meta:get_inventory(), interface_inv)
		minetest.get_node_timer(pos):start(1)
	end,

	allow_metadata_inventory_put = function(_, list, _, stack)
		return (list == "output_filter" or stack:get_name() == "pulse_network:encoded_pattern") and stack:get_count() or 0
	end,

	on_metadata_inventory_put = on_metadata_inventory_change,
	on_metadata_inventory_take = on_metadata_inventory_change,

	conduit_insert = function()
		return "input"
	end,

	after_conduit_insert = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local ctrlpos = meta:get_string"controller_pos":data()
		local ctrl_meta = minetest.get_meta(ctrlpos)
		local ctrl_inv = ctrl_meta:get_inventory()
		if not ctrl_inv:get_stack("input", 1):is_empty() then
			return
		end
		ctrl_inv:set_stack("input", 1, inv:get_stack("input", 1))
		inv:set_stack("input", 1, "")
		pulse_network.import_to_controller(ctrlpos)
	end,

	on_timer = function(pos, elapsed)
		elapsed = elapsed % 10
		local meta = minetest.get_meta(pos)
		if elapsed == 0 then
			local inv = meta:get_inventory()
			local ctrlpos = meta:get_string"controller_pos":data()

			for i = 1, 8 do
				if inv:get_stack("output", i):is_empty() then
					local s1 = inv:get_stack("output_filter", i)
					if not s1:is_empty() and s1:is_known() then
						local id, c = api.get_item_identifier(s1), s1:get_count()
						local extracted_stack = pulse_network.export_from_controller(ctrlpos, id, c)
						if extracted_stack then inv:set_stack("output", i, extracted_stack) end
					end
				end
			end
		end

		local map = meta:get_string"autocraft_itemmap":data()
		for i = 1, #neighbours do
			local vec = vector.add(pos, neighbours[i])
			local inv = minetest.get_meta(vec):get_inventory()
			local name = minetest.get_node(vec).name
			if minetest.get_item_group(name, "conduit_insert") > 0 then
				conduits.send_items_raw(map, inv, name, vec)
			end
		end
		meta:set_string("autocraft_itemmap", minetest.serialize(map))

		minetest.get_node_timer(pos):set(elapsed + 1, elapsed)
	end,

	can_dig = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_int"network_destruction" == 1 then return true end
		local inv = meta:get_inventory()
		for i = 1, 8 do
			if not inv:get_stack("patterns", i):is_empty() then
				return false
			end
		end
		return true
	end,
})