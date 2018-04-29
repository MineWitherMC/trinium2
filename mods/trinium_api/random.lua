local api = trinium.api
local DataMesh = api.DataMesh

function api.dump(...)
	local string, add = ""
	for _,x in ipairs{...} do
		add = minetest.serialize(x)
		if add:sub(1, 7) == "return " then
			add = add:sub(8)
		end
		if type(x) == "string" then
			add = add:sub(2, -2)
		end
		add = add:gsub('loadstring%(".-"%)', '<function>')
		string = string..add.."  "
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

trinium.ln2 = math.log(2)
function api.lograndom(a1, b1) -- more similar to normal
	if b1 then
		local lr, lr1 = 0, 0
		local a, b = a1 - 1, b1 + 1
		repeat
			lr = (api.lograndom() + 1) / 5.7 -- this probably has values from 0...1
			if lr < 0 then lr = 0 end; if lr > 1 then lr = 1 end
			lr1 = math.floor(a + (b - a) * lr)
		until lr1 > a and lr1 < b
		return lr1
	end
	return 2 + 0.33 * math.log(1 / math.random() - 1) / trinium.ln2
end

-- Inventory
function api.initialize_inventory(inv, def)
	for k,v in pairs(def) do
		inv:set_size(k,v)
	end
end

-- Palettes
function api.recolor_facedir(pos, n) -- n from 0 to 7
	local node = minetest.get_node(pos)
	node.param2 = (node.param2 % 32) + (n * 32)
	minetest.set_node(pos, node)
end
function api.get_color_facedir(pos) -- n from 0 to 7
	local node = minetest.get_node(pos)
	return math.floor(node.param2 / 32)
end

-- BFS
function api.advanced_search(begin, serialize, vertex)
	local dm = DataMesh:new()
	local dd = dm._data
	local used = {}
	local operation = {[begin] = 1}
	local underoperation
	local step = 0
	local finished = false
	repeat
		finished = true
		underoperation = {}
		step = step + 1
		for v in pairs(operation) do
			if not used[serialize(v)] then
				used[serialize(v)] = 1
				if step > 1 then
					table.insert(dd, {v, step})
				end
				finished = false
				for v1 in pairs(vertex(v)) do
					underoperation[v1] = 1
				end
			end
		end

		operation = table.copy(underoperation)
	until finished
	return dm
end

function api.search(begin, serialize, vertex)
	return api.advanced_search(begin, serialize, vertex):map(function(r) return r[1] end)
end

function api.set_defaults(tbl, reserved_tbl)
	for k,v in pairs(reserved_tbl) do
		if not tbl[k] then
			tbl[k] = v
		end
	end
	return tbl
end

function api.roman_number(a)
	local one = {"", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"}
	local ten = {"", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"}
	local hun = {"", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"}
	local k = a % 1000
	local str = ("M"):rep(math.floor(a / 1000))

	str = str..hun[(k - k % 100)/100 + 1]
	str = str..ten[(k % 100 - k % 10)/10 + 1]
	str = str..one[k % 10 + 1]
	return str
end

function api.string_capitalization(str)
	return str:sub(1,1):upper()..str:sub(2):lower()
end

function api.string_separation(str)
	return api.string_capitalization(str):gsub("_", " ")
end

function api.formspec_restore(str)
	return str:gsub("\\\\", "\\"):gsub("\\%[", "["):gsub("\\%]", "]"):gsub("\\,", ","):gsub("\\;", ";")
end

function api.translate_requirements(tbl)
	local tbl1 = {}
	for c, k, v in table.asort(tbl, function(a, b) return a > b end) do
		tbl1[#tbl1 + 1] = "\n"..minetest.colorize("#CCC", v.." "..((minetest.registered_nodes[k] or {}).description or "???"))
	end
	return table.concat(tbl1, "")
end

function api.multiblock_rename(def1)
	local node, def = def1.controller, def1.map
	local tbl = {}
	table.walk(def, function(v)
		if not tbl[v.name] then tbl[v.name] = 0 end
		tbl[v.name] = tbl[v.name] + 1
	end)
	minetest.override_item(node, {
		description = minetest.registered_nodes[node].description..api.translate_requirements(tbl)
	})
end

function api.get_item_identifier(stack)
	local s = stack:to_string():split(" ")
	return s[1]..(s[3] and " "..table.concat(table.mtail(s, 2), " ") or "")
end

function api.sort_by_param(param)
	return function(a, b)
		return a[param] < b[param]
	end
end

-- {{amount1, weight1}, {amount2, weight2}, ...}
function api.weighted_avg(t)
	local t1 = table.map(t, function(v) return v[1] * v[2] end)
	local t2 = table.map(t, function(v) return v[2] end)
	return table.sum(t1) / table.sum(t2)
end

function api.validate(array, def)
	for k,v in pairs(def) do
		if type(array[k]) ~= v then
			return nil, "Invalid type for "..k..": "..v.." expected, "..type(array[k]).." given"
		end
	end
	return array
end

function api.weighted_random(mas, func)
	func = func or math.random
	local j = table.sum(mas)
	local k = func(1, j)
	local i = 1
	while k > mas[i] do
		k = k - mas[i]
		i = i + 1
	end
	return i
end

function api.iterator(callback)
	return function(max, current)
		if max == current then return end
		current = current + 1
		return callback(current)
	end
end

function api.get_texture(item)
	return minetest.registered_items[item].inventory_image
end

function api.get_fs_texture(...)
	local textures = {}
	for k,v in pairs{...} do
		table.insert(textures, table.concat{"(", api.get_texture(v), ")^[brighten"})
	end
	return (table.unpack or unpack)(textures)
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
