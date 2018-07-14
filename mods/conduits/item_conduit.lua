local S = conduits.S
local api = trinium.api
local item_buffer_fs = "size[8,8.5]list[context;main;1,0;6,4]list[current_player;main;0,4.5;8,4]listring[]"
local dm = api.DataMesh

-- Item Buffer
minetest.register_node("conduits:item_buffer", {
	tiles = {"conduits.buffer.png"},
	description = S"Item Buffer",
	groups = {cracky = 1, conduit_insert = 1, conduit_extract = 1},
	sounds = trinium.sounds.default_metal,
	after_place_node = api.initializer{main = 24, formspec = item_buffer_fs},
	conduit_insert = function()
		return "main"
	end,
	conduit_extract = {"main"},
})

-- General Functions
function conduits.get_item_connections(pos)
	if minetest.get_item_group(minetest.get_node(pos).name, "conduit_insert") > 0 then return {} end
	local k = {}
	for i = 1, #conduits.neighbours do
		local v1 = vector.add(pos, conduits.neighbours[i])
		local name = minetest.get_node(v1).name
		if name == "conduits:item_conduit" or minetest.get_item_group(name, "conduit_insert") > 0 then
			k[v1] = 1
		end
	end
	return k
end

function conduits.send_items(pos, items)
	local search = api.advanced_search(pos, vector.stringify, conduits.get_item_connections)
	search:map(function(v)
		return {v[1], v[2], minetest.get_node(v[1]).name}
	end):filter(function(v)
		return v[2] > 2 and minetest.get_item_group(v[3], "conduit_insert") > 0
	end):remap():sort(api.sort_by_param(2)):map(function(v)
		return {minetest.get_meta(v[1]):get_inventory(), v[3]}
	end):forEach(true, function(v1)
		local callback = api.get_field(v1[2], "conduit_insert")
		for k, v in pairs(items) do
			local size = math.min(v, api.get_field(k, "stack_max"))
			local z, zs = callback(ItemStack(k .. " " .. size))
			if z then
				if (not zs) and v1[1]:room_for_item(z, k) then
					local ns = v1[1]:add_item(z, k .. " " .. size)
					items[k] = items[k] - size + ns:get_count()
					if items[k] == 0 then items[k] = nil end
					return
				elseif zs then
					local stack = v1[1]:get_stack(z, zs)
					local ns = stack:add_item(k .. " " .. size)
					v1[1]:set_stack(z, zs, stack)
					items[k] = items[k] - size + ns:get_count()
					if items[k] == 0 then items[k] = nil end
					return
				end
			end
		end
	end)
end

-- Conduit, basically utilises nothing except for network calculation time
minetest.register_node("conduits:item_conduit", {
	paramtype = "light",
	description = S"Item Conduit",
	sounds = trinium.sounds.default_stone,
	drawtype = "nodebox",
	node_box = {
		["type"] = "connected",
		fixed = {-3 / 16, -3 / 16, -3 / 16, 3 / 16, 3 / 16, 3 / 16},
		connect_left = {-0.5, -3 / 16, -3 / 16, -3 / 16, 3 / 16, 3 / 16},
		connect_right = {0.5, -3 / 16, -3 / 16, 3 / 16, 3 / 16, 3 / 16},
		connect_top = {-3 / 16, 3 / 16, -3 / 16, 3 / 16, 0.5, 3 / 16},
		connect_bottom = {-3 / 16, -3 / 16, -3 / 16, 3 / 16, -0.5, 3 / 16},
		connect_front = {-3 / 16, -3 / 16, -3 / 16, 3 / 16, 3 / 16, -0.5},
		connect_back = {-3 / 16, -3 / 16, 3 / 16, 3 / 16, 3 / 16, 0.5},
	},
	tiles = {"conduits.item.png"},
	connects_to = {"group:conduit_insert", "conduits:item_pump", "conduits:item_conduit"},
	groups = {cracky = 2},
})

-- Extractor, uses all the CPU
minetest.register_node("conduits:item_pump", {
	paramtype = "light",
	description = S"Item Pump",
	sounds = trinium.sounds.default_metal,
	drawtype = "nodebox",
	node_box = {
		["type"] = "connected",
		fixed = {-3 / 16, -3 / 16, -3 / 16, 3 / 16, 3 / 16, 3 / 16},
		connect_left = {-0.5, -3 / 16, -3 / 16, -3 / 16, 3 / 16, 3 / 16},
		connect_right = {0.5, -3 / 16, -3 / 16, 3 / 16, 3 / 16, 3 / 16},
		connect_top = {-3 / 16, 3 / 16, -3 / 16, 3 / 16, 0.5, 3 / 16},
		connect_bottom = {-3 / 16, -3 / 16, -3 / 16, 3 / 16, -0.5, 3 / 16},
		connect_front = {-3 / 16, -3 / 16, -3 / 16, 3 / 16, 3 / 16, -0.5},
		connect_back = {-3 / 16, -3 / 16, 3 / 16, 3 / 16, 3 / 16, 0.5},
	},
	tiles = {"conduits.item_pump.png"},
	connects_to = {"group:conduit_extract", "group:signal_param", "conduits:item_conduit"},
	groups = {cracky = 2, signal_acceptor = 2, rich_info = 1},
	get_rich_info = function(pos)
		local timer = minetest.get_node_timer(pos)
		local msg1 = minetest.get_node(pos).param2 > 0 and S"Signal Enabled" or S"Signal Disabled"
		local msg2 = S("Next operation in @1 seconds", math.round(timer:get_timeout() - timer:get_elapsed(), 0.1))
		return msg1 .. "\n" .. msg2
	end,

	on_construct = function(pos)
		minetest.get_node_timer(pos):start(10) -- 10 seconds when idle and 1 second when working
	end,

	after_place_node = conduits.rebuild_signals,

	on_timer = function(pos)
		local timer = minetest.get_node_timer(pos)
		if minetest.get_node(pos).param2 == 0 then
			timer:start(10)
			return
		end

		local positions = dm:new()
		for i = 1, #conduits.neighbours do
			local v1 = vector.add(pos, conduits.neighbours[i])
			local name = minetest.get_node(v1).name
			if minetest.get_item_group(name, "conduit_extract") > 0 then
				positions:push(v1)
			end
		end

		local positions1 = dm:new()
		positions:map(function(k)
			local lists = api.get_field(minetest.get_node(k).name, "conduit_extract")
			local inv = minetest.get_meta(k):get_inventory()
			for i = 1, #lists do
				positions1:push({inv, api.inv_to_itemmap(inv:get_list(lists[i])), lists[i]})
			end
		end)

		local action = false
		positions1:forEach(function(e)
			local inv, map = e[1], e[2]
			for k, v in pairs(map) do
				local size = math.min(v, 8)
				local tbl = {[k] = size}
				conduits.send_items(pos, tbl)
				if tbl[k] ~= size then
					inv:remove_item(e[3], k .. " " .. (size - (tbl[k] or 0)))
					action = true
					return
				end
			end
		end)

		timer:start(action and 1 or 10)
	end,
})