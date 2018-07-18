local api = trinium.api
local S = conduits.S

function conduits.get_signal_connections(pos)
	if minetest.get_item_group(minetest.get_node(pos).name, "signal_acceptor") > 0 then return {} end
	local k = {}
	for i = 1, #conduits.neighbours do
		local v1 = vector.add(pos, conduits.neighbours[i])
		local name = minetest.get_node(v1).name
		if minetest.get_item_group(name, "signal_param") > 0 or minetest.get_item_group(name, "signal_acceptor") > 0 then
			k[v1] = 1
		end
	end
	return k
end

function conduits.rebuild_signals(pos)
	local search = api.search(pos, vector.stringify, conduits.get_signal_connections)
	search:forEach(function(v)
		local node = minetest.get_node(v)
		local group = minetest.get_item_group(node.name, "signal_param") +
				minetest.get_item_group(node.name, "signal_acceptor")
		if group < 3 and node["param" .. group] ~= 255 then
			node["param" .. group] = 0
			minetest.swap_node(v, node)
		end
	end):push(pos):filter(function(v)
		local node = minetest.get_node(v)
		local group = minetest.get_item_group(node.name, "signal_param")
		return minetest.get_item_group(node.name, "signal_emitter") > 0 or node["param" .. group] == 255
	end):forEach(function(v)
		local s1 = api.advanced_search(v, vector.stringify, conduits.get_signal_connections)
		s1:forEach(function(v1)
			local pos1, steps = v1[1], v1[2]
			local node = minetest.get_node(pos1)
			local group = minetest.get_item_group(node.name, "signal_param") +
					minetest.get_item_group(node.name, "signal_acceptor")
			if group < 3 and node["param" .. group] < 255 - steps then
				node["param" .. group] = 255 - steps
				minetest.swap_node(pos1, node)
			end
		end)
	end)
end

minetest.register_node("conduits:signal_cable", {
	paramtype = "light",
	description = S"Signal Cable",
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
	tiles = {"conduits.signal_cable.png"},
	connects_to = {"group:signal_param", "group:signal_acceptor"},
	groups = {cracky = 2, signal_param = 2, rich_info = 1},
	after_place_node = conduits.rebuild_signals,
	after_dig_node = conduits.rebuild_signals,
	get_rich_info = function(pos)
		return S("Power: @1", minetest.get_node(pos).param2)
	end,
})

minetest.register_node("conduits:signal_emitter", {
	description = S"Signal Emitter",
	tiles = {"conduits.signal_emitter.png"},
	sounds = trinium.sounds.default_stone,
	groups = {cracky = 2, signal_emitter = 1, signal_param = 3},
	after_place_node = conduits.rebuild_signals,
	after_dig_node = conduits.rebuild_signals,
})
