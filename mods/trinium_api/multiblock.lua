local api = trinium.api
local recipes = trinium.recipes
local S = api.S

for i = 3, 13, 2 do
	for j = 3, 13 do
		recipes.add_method(("multiblock_%s_%s"):format(i,j), {
			input_amount = i * j,
			output_amount = 1,
			get_input_coords = recipes.coord_getter(i, -1, 0),
			get_output_coords = function()
				return i + 1, (j + 1) / 2
			end,
			formspec_width = i + 2,
			formspec_height = j + 2,
			formspec_name = S "Multiblock",
			formspec_begin = function(data)
				return ("label[0,%s;%s]"):format(j + 1, S("Current Height: @1", data.h))
			end,
		})
	end
end

function api.register_multiblock(name, def)
	if not def.activator and def.map then
		def.activator = function(reg) return reg(def.map) end
	end

	if def.map and def.width < 7 and
			def.width > 0 and
			def.depth_b + def.depth_f < 13 and
			def.depth_b + def.depth_f > 1 then
		for i = (def.height_d == 0 and 0 or -def.height_d), def.height_u do
			local new_map = table.filter(def.map, function(x)
				return x.y == i
			end)
			if i == 0 then
				table.insert(new_map, { x = 0, y = 0, z = 0, name = def.controller })
			end
			local map1, tooltips = {}, {}
			for k = -def.depth_f, def.depth_b do
			for j = -def.width, def.width do
				local res = table.exists(new_map, function(a)
					return a.x == j and a.z == k
				end)
				if res then
					map1[j + def.width + (def.depth_b - k) * (def.width * 2 + 1) + 1] = new_map[res].name
					if new_map[res].desc then
						tooltips[j + def.width + (def.depth_b - k) * (def.width * 2 + 1) + 1] = new_map[res].desc
					end
				end
			end
			end
			recipes.add(("multiblock_%s_%s"):format(def.width * 2 + 1, def.depth_b + def.depth_f + 1),
					map1, {def.controller}, {h = i, input_tooltips = tooltips})
		end
	end

	minetest.register_abm({
		label = name,
		nodenames = def.controller,
		interval = 15,
		chance = 1,
		action = function(pos, node)
			local dir = vector.multiply(minetest.facedir_to_dir(node.param2), -1)
			local x_min, x_max, y_min, y_max, z_min, z_max =
				dir.x == 0 and -def.width or dir.x == 1 and -def.depth_b or -def.depth_f,
				dir.x == 0 and def.width or dir.x == 1 and def.depth_f or def.depth_b,
				-def.height_d,
				def.height_u,
				dir.z == 0 and -def.width or dir.z == 1 and -def.depth_b or -def.depth_f,
				dir.z == 0 and def.width or dir.z == 1 and def.depth_f or def.depth_b

			local rg = {region = {}, counts = {}}

			for x = x_min, x_max do
			for y = y_min, y_max do
			for z = z_min, z_max do
				local crd = vector.add(pos, {x = x, y = y, z = z})
				local nn = minetest.get_node(crd).name
				local depth, r_shift = -x * dir.x + -z * dir.z, z * dir.x - x * dir.z
				table.insert(rg.region, { x = r_shift, y = y, z = depth, name = nn, actual_pos = crd })
				rg.counts[nn] = (rg.counts[nn] or 0) + 1
			end
			end
			end

			setmetatable(rg, {__call = function(reg, def1)
				return table.every(def1, function(d)
					return table.exists(reg.region, function(x)
						return x.x == d.x and x.y == d.y and x.z == d.z and x.name == d.name
					end)
				end)
			end})

			local meta = minetest.get_meta(pos)
			local is_active = def.activator(rg)
			meta:set_int("assembled", is_active and 1 or 0)
			if def.after_construct then
				def.after_construct(pos, is_active, rg)
			end
		end,
	})
end

function api.multiblock_rename(def1)
	local node, def = def1.controller, def1.map
	local tbl = {}
	table.walk(def, function(v)
		if not tbl[v.name] then
			tbl[v.name] = 0
		end
		tbl[v.name] = tbl[v.name] + 1
	end)
	minetest.override_item(node, {
		description = minetest.registered_nodes[node].description .. api.translate_requirements(tbl)
	})
end

function api.multiblock_rich_info(node)
	api.assert(minetest.registered_items[node], minetest.get_current_modname(), "rich info structure", node)
	local groups = table.copy(minetest.registered_items[node].groups)
	groups.rich_info = 1
	local old_rich_info = minetest.registered_items[node].get_rich_info
	minetest.override_item(node, {
		groups = groups,
		get_rich_info = function(pos, player)
			local meta = minetest.get_meta(pos)
			if meta:get_int "assembled" == 1 then
				if old_rich_info then
					return old_rich_info(pos, player)
				end
			else
				return S "Multiblock is not assembled!"
			end
		end,
	})
end