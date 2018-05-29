local machines = trinium.machines
local api = trinium.api
function machines.parse_multiblock(def0)
	local controller, casing, size, min_casings, air_positions, color = def0.controller, def0.casing, def0.size, def0.min_casings,
			def0.air_positions, def0.color
	-- size is {down = 1, up = 1, sides = 1, back = 2, front = 0}
	local function find(x, y, z)
		return table.exists(air_positions, function(r) return r.x == x and r.y == y and r.z == z end)
	end

	local def = {controller = controller, width = size.sides, depth_f = size.front, depth_b = size.back, height_d = size.down,
	 		height_u = size.up}

	function def.activator(region)
		local vars, func = api.exposed_var()
		table.walk(region.region, function(r)
			if r.x == 0 and r.y == 0 and r.z == 0 then return end
			if r.name == casing then
				vars.good = not find(r.x, r.y, r.z)
				return
			end
			if minetest.get_item_group(r.name, "greggy_hatch") > 0 then
				local maxcount = api.get_field(r.name, "ghatch_max") or math.huge
				vars.good = (not find(r.x, r.y, r.z)) and region.counts[r.name] <= maxcount
				return
			end
			if r.name ~= "air" then vars.good = false return end
			vars.good = find(r.x, r.y, r.z)
		end, func)
		return vars.good and region.counts[casing] >= min_casings
	end

	local function unparse(region)
		table.walk(region.region, function(r)
			if r.name == casing or minetest.get_item_group(r.name, "greggy_hatch") > 0 then
				local color = api.get_field(r.name, "place_param2") or 0
				minetest.swap_node(r.actual_pos, {name = r.name, param2 = color})
			end
		end)
	end

	function def.after_construct(pos, is_constructed, region)
		local meta = minetest.get_meta(pos)
		if not is_constructed then
			unparse(region)
			meta:from_table()
			minetest.get_node_timer(pos):stop()
			return
		end
		local hatches = {}
		table.walk(region.region, function(r)
			if r.name == casing then minetest.swap_node(r.actual_pos, {name = r.name, param2 = color}) end
			if minetest.get_item_group(r.name, "greggy_hatch") == 0 then return end
			minetest.swap_node(r.actual_pos, {name = r.name, param2 = color})
			local f = api.get_field(r.name, "ghatch_id")
			if not hatches[f] then hatches[f] = {} end
			table.insert(hatches[f], {x = r.x, y = r.y, z = r.z})
		end)
		meta:set_string("hatches", minetest.serialize(hatches))
		meta:set_string("region", minetest.serialize(region))
	end

	local function unparse_meta(pos)
		unparse(minetest.get_meta(pos):get_string"region":data() or {region = {}})
	end

	-- api.register_multiblock("Greggy stuff - "..controller, def)
	return def, unparse_meta
end
