local api = trinium.api

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
	local a = api.string_capitalization(str):gsub("_", " ")
	return a
end

function api.string_superseparation(str)
	local a = api.string_separation(str):gsub("%W%l", string.upper)
	return a
end

function api.translate_requirements(tbl)
	local tbl1 = {}
	for _, k, v in table.asort(tbl, function(a, b) return tbl[a] > tbl[b] end) do
		tbl1[#tbl1 + 1] = "\n" ..
				minetest.colorize("#CCC", v .. " " .. ((minetest.registered_nodes[k] or {}).description or "???"))
	end
	return table.concat(tbl1, "")
end

function api.get_field(item, fn)
	item = minetest.registered_items[item]
	if not item then return nil end
	return item[fn]
end

function api.get_description(item)
	return (api.get_field(item, "description") or item):split"\n"[1]
end

function api.get_texture(item)
	return api.get_field(item, "inventory_image")
end

function api.get_fs_texture(...)
	local textures = {}
	for _, v in ipairs{...} do
		table.insert(textures, table.concat{"(", api.get_field(v, "inventory_image"), ")^[brighten"})
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