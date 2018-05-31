local machines = trinium.machines
local api = trinium.api
local equal = api.functions.equal

function machines.parse_multiblock(def0)
	-- size is {down = 1, up = 1, sides = 1, back = 2, front = 0}
	local function find(x, y, z)
		return table.exists(def0.air_positions, function(r) return r.x == x and r.y == y and r.z == z end)
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
				local maxcount = api.get_field(r.name, "ghatch_max") or math.huge
				local type = api.get_field(r.name, "ghatch_id")
				if not vars.counts[type] then vars.counts[type] = 0 end
				vars.counts[type] = vars.counts[type] + 1
				vars.good = table.exists(def0.hatches, equal(type)) and vars.counts[type] <= maxcount and not find(r.x, r.y, r.z)
				return
			end
			if r.name ~= "air" then vars.good = false return end
			vars.good = find(r.x, r.y, r.z)
		end, func)
		return vars.good and region.counts[def0.casing] >= def0.min_casings
	end

	local function unparse(region)
		table.walk(region.region, function(r)
			if r.name == def0.casing or minetest.get_item_group(r.name, "greggy_hatch") > 0 then
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
		for i = 1, #def0.hatches do hatches[def0.hatches[i]] = {} end
		table.walk(region.region, function(r)
			if r.name == def0.casing then minetest.swap_node(r.actual_pos, {name = r.name, param2 = def0.color}) end
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

	local function unparse_meta(pos)
		unparse(minetest.get_meta(pos):get_string"region":data() or {region = {}})
	end

	-- api.register_multiblock("Greggy stuff - "..controller, def)
	return def, unparse_meta
end
