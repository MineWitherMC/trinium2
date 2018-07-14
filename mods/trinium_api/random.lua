local api = trinium.api
local DataMesh = api.DataMesh

function api.dump(...)
	local string = ""
	local add
	for _, x in ipairs(table.remap{...}) do
		add = dump(x)
		if type(x) == "string" then
			add = add:sub(2, -2)
		end
		string = string .. add .. "  "
	end
	minetest.log("warning", string:sub(1, -3))
end

function api.setting_get(name, default)
	local s = minetest.settings:get(name)
	if not s then
		minetest.settings:set(name, default)
		s = default
	end
	return s
end

-- Inventory
function api.initialize_inventory(inv, def)
	for k, v in pairs(def) do
		inv:set_size(k, v)
	end
end

function api.initializer(def0)
	return function(pos)
		local def = table.copy(def0)
		local meta = minetest.get_meta(pos)
		if def.formspec then
			meta:set_string("formspec", def.formspec)
			def.formspec = nil
		end
		api.initialize_inventory(meta:get_inventory(), def)
	end
end

function api.inv_to_itemmap(...)
	local map, inv = {}, {...}
	for _, v in pairs(inv) do
		for _, v1 in pairs(v) do
			local name, count = v1:get_name(), v1:get_count()
			if not map[name] then map[name] = 0 end
			map[name] = map[name] + count
		end
	end
	map[""] = nil
	return map
end

-- BFS
function api.advanced_search(begin, serialize, vertex)
	local dm = DataMesh:new()
	local dd = dm._data
	local used = {}
	local operation = {[begin] = 1}
	local under_operation
	local step = 0
	local finished
	repeat
		finished = true
		under_operation = {}
		step = step + 1
		for v in pairs(operation) do
			if not used[serialize(v)] then
				used[serialize(v)] = 1
				if step > 1 then
					table.insert(dd, {v, step})
				end
				finished = false
				for v1 in pairs(vertex(v)) do
					under_operation[v1] = 1
				end
			end
		end

		operation = table.copy(under_operation)
	until finished
	return dm
end

function api.search(begin, serialize, vertex)
	return api.advanced_search(begin, serialize, vertex):map(function(r) return r[1] end)
end

function api.set_defaults(tbl, reserved_tbl)
	tbl = tbl or {}
	if not reserved_tbl then return tbl end
	for k, v in pairs(reserved_tbl) do
		if not tbl[k] then
			tbl[k] = v
		end
	end
	return tbl
end

function api.string_capitalization(str)
	return str:sub(1, 1):upper() .. str:sub(2):lower()
end

function api.string_separation(str)
	return api.string_capitalization(str):gsub("_", " ")
end

function api.string_superseparation(str)
	return api.string_separation(str):gsub("%W%l", string.upper)
end

function api.translate_requirements(tbl)
	local tbl1 = {}
	for _, k, v in table.asort(tbl, function(a, b) return tbl[a] > tbl[b] end) do
		tbl1[#tbl1 + 1] = "\n" ..
				minetest.colorize("#CCC", v .. " " .. ((minetest.registered_nodes[k] or {}).description or "???"))
	end
	return table.concat(tbl1, "")
end

function api.get_item_identifier(stack)
	local s = stack:to_string():split(" ")
	return s[1] .. (s[3] and " " .. table.concat(table.multi_tail(s, 2), " ") or "")
end

function api.sort_by_param(param)
	return function(a, b)
		return a[param] < b[param]
	end
end

function api.exposed_var()
	local tbl = {good = true}
	return tbl, function() return not tbl.good end
end

function api.count_stacks(inv, list, disallow_multi_stacks)
	local dm = DataMesh:new():data(inv:get_list(list)):filter(function(v)
		return not v:is_empty()
	end)
	if not disallow_multi_stacks then
		dm = dm:map(function(v)
			return v:get_name()
		end)   :unique()
	end
	return dm:count()
end

function api.iterator(callback)
	return function(max, current)
		if max == current then return end
		current = current + 1
		return callback(current)
	end
end

function api.get_field(item, fn)
	item = minetest.registered_items[item]
	if not item then return nil end
	return item[fn]
end

function api.get_texture(item)
	return api.get_field(item, "inventory_image")
end

function api.get_fs_texture(...)
	local textures = {}
	for _, v in pairs {...} do
		table.insert(textures, table.concat {"(", api.get_texture(v), ")^[brighten"})
	end
	return unpack(textures)
end

function api.process_color(color)
	if type(color) == "string" then return color end
	color = ("%xB0"):format(color[1] * 256 * 256 + color[2] * 256 + color[3])
	color = ("0"):rep(8 - #color) .. color
	return color
end

function api.color_string(color)
	return api.process_color(color):sub(1, 6)
end

function api.adder()
	local x = {}
	return x, function(name, def) x[name] = def end
end

function api.recolor_facedir(pos, n)
	-- n from 0 to 7
	local node = minetest.get_node(pos)
	node.param2 = (node.param2 % 32) + (n * 32)
	minetest.swap_node(pos, node)
end

function api.assert(x, y, z, t)
	return assert(x, "\n" .. y .. " requested nonexistent " .. z .. " " .. t)
end

function api.save_to_worldfile(name, str)
	name = minetest.get_worldpath() .. "/" .. name
	local handler = assert(io.open(name, "w"))
	handler:write(str)
	handler:close()
	error("Done!")
end

api.functions = {} -- table of functions
local func = api.functions

function func.returner(a)
	return a
end

function func.const(a)
	return function()
		return a
	end
end

function func.equal(a)
	return function(b)
		return a == b
	end
end

function func.empty() end
