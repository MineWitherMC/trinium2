local machines = trinium.machines
local api = trinium.api
local equal = api.functions.equal
local recipes = trinium.recipes
local S = machines.S

machines.default_hatches, machines.set_default_hatch = api.adder()

function machines.parse_multiblock(def0)
	-- size is {down = 1, up = 1, sides = 1, back = 2, front = 0}
	local function find(x, y, z)
		local key = table.exists(def0.addon_map, function(r) return r.x == x and r.y == y and r.z == z end)
		if not key then return false end
		return def0.addon_map[key].name
	end

	local def = {controller = def0.controller,
	              width = def0.size.sides,
	              depth_f = def0.size.front, depth_b = def0.size.back,
	              height_d = def0.size.down, height_u = def0.size.up}

	function def.activator(region)
		local vars, func = api.exposed_var()
		vars.counts = {}
		table.walk(region.region, function(r)
			if r.x == 0 and r.y == 0 and r.z == 0 then return end
			if r.name == def0.casing then
				vars.good = not find(r.x, r.y, r.z)
				return
			end
			if minetest.get_item_group(r.name, "greggy_hatch") > 0 then
				local max_count = api.get_field(r.name, "ghatch_max") or math.huge
				local type = api.get_field(r.name, "ghatch_id")
				if not vars.counts[type] then vars.counts[type] = 0 end
				vars.counts[type] = vars.counts[type] + 1
				local finder = find(r.x, r.y, r.z)
				if not finder then
					vars.good = table.exists(def0.hatches, equal(type)) and
							vars.counts[type] <= max_count
				else
					vars.good = finder:split":"[1] == "hatch" and finder:split":"[2] == type
				end
				return
			end
			vars.good = find(r.x, r.y, r.z) == r.name
		end, func)
		return vars.good and region.counts[def0.casing] >= def0.min_casings
	end

	local function destroy(region)
		table.walk(region.region, function(r)
			if r.name ~= minetest.get_node(r.actual_pos).name then return end
			if r.name == def0.casing or minetest.get_item_group(r.name, "greggy_hatch") > 0 then
				local color = api.get_field(r.name, "place_param2") or 0
				minetest.swap_node(r.actual_pos, {name = r.name, param2 = color})
			end
		end)
	end

	function def.after_construct(pos, is_constructed, region)
		local meta = minetest.get_meta(pos)
		if not is_constructed then
			destroy(region)
			meta:from_table()
			minetest.get_node_timer(pos):stop()
			return
		end
		local hatches = {}
		for i = 1, #def0.hatches do hatches[def0.hatches[i]] = {} end
		if def0.fake_hatches then for i = 1, #def0.fake_hatches do hatches[def0.fake_hatches[i]] = {} end end
		table.walk(region.region, function(r)
			if r.name == def0.casing then
				minetest.swap_node(r.actual_pos, {name = r.name, param2 = def0.color})
			end

			if minetest.get_item_group(r.name, "greggy_hatch") == 0 then return end
			minetest.swap_node(r.actual_pos, {name = r.name, param2 = def0.color})
			local f = api.get_field(r.name, "ghatch_id")
			table.insert(hatches[f], r.actual_pos)
		end)
		meta:set_string("hatches", minetest.serialize(hatches))
		meta:set_string("region", minetest.serialize(region))
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(5)
		end
	end

	def.map = {}
	for i = -def.width, def.width do
		for j = -def.height_d, def.height_u do
			for k = -def.depth_f, def.depth_b do
				if (i ~= 0 or j ~= 0 or k ~= 0) and (not find(i, j, k)) then
					table.insert(def.map, {x = i, y = j, z = k, name = def0.casing})
				end
			end
		end
	end
	for i = 1, #def0.addon_map do
		if def0.addon_map[i].name ~= "air" then
			local item = def0.addon_map[i]
			local item_split = item.name:split":"
			if item_split[1] ~= "hatch" then
				table.insert(def.map, item)
			else
				local s = item_split[2]:split"."
				local desc = api.string_superseparation(s[2]) .. " " .. api.string_superseparation(s[1])
				table.insert(def.map, {x = item.x, y = item.y, z = item.z,
				                        name = machines.default_hatches[item_split[2]], desc = S("Any Hatch - @1", desc)})
			end
		end
	end

	local function destroy_meta(pos)
		destroy(minetest.get_meta(pos):get_string"region":data() or {region = {}})
	end

	return def, destroy_meta,
			{def0.casing}, {def0.controller}, {min_casings = def0.min_casings, hatches = def0.hatches}
end

recipes.add_method("greggy_multiblock", {
	input_amount = 1,
	output_amount = 1,
	get_input_coords = function()
		return 0, 1
	end,
	get_output_coords = function()
		return 4, 1
	end,
	formspec_width = 5,
	formspec_height = 5,
	formspec_name = S"GT Multiblock",
	formspec_begin = function(data)
		local hatches = table.map(data.hatches, function(h)
			local s = h:split"."
			return S(api.string_superseparation(s[2]) .. " " .. api.string_superseparation(s[1]))
		end)
		return ("textarea[0.25,2;4.5,3;;;%s]"):format(
				S("Minimum Casings: @1@n@nAllowed hatches:@n@2", data.min_casings, table.concat(hatches, "\n"))
		)
	end,
})
