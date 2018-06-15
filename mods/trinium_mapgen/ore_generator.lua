local veins_by_breakpoints, vein_breakpoints_s, vein_breakpoint_w
local vein_breakpoints, registered_veins = {}, {}

local mapgen = trinium.mapgen
function mapgen.register_vein(name, params)
	for i = 1, #params.ore_list do
		params.ore_list[i] = minetest.get_content_id(params.ore_list[i])
		assert(params.ore_list[i] ~= 127, "No such block exists!")
	end

	vein_breakpoints[params.min_height] = vein_breakpoints[params.min_height] or 1
	vein_breakpoints[params.max_height] = vein_breakpoints[params.max_height] or 1
	registered_veins[name] = params
	registered_veins[name].name = name
	registered_veins[name].ore_chances_multiplier = table.sum(params.ore_chances)
end

local stone_cid = minetest.get_content_id(trinium.DEBUG_MODE and "air" or "trinium_mapgen:stone")
assert(stone_cid ~= 127)

local data = {}
local perlin_map = {}
minetest.register_on_generated(function(min_pos, _, seed)
	local rand = PcgRandom(seed)
	local vb, vbs, wb = veins_by_breakpoints, vein_breakpoints_s, vein_breakpoint_w
	if not vb or not vbs or not wb then
		local n
		vb, wb, n = {}, {}, {}
		for i in pairs(vein_breakpoints) do
			n[#n + 1] = i
		end
		table.sort(n)
		for i = 2, #n do
			vb[n[i] .. "_" .. n[i - 1]] = {}
			wb[n[i] .. "_" .. n[i - 1]] = 0
		end
		for k, v in pairs(registered_veins) do
			for i = 2, #n do
				if v.max_height >= n[i] and v.min_height <= n[i - 1] then
					vb[n[i] .. "_" .. n[i - 1]][k] = v.weight
					wb[n[i] .. "_" .. n[i - 1]] = wb[n[i] .. "_" .. n[i - 1]] + v.weight
				end
			end
		end

		vbs = n
	end

	if rand:next(1, 1000000) / 1000000 > 0.92 then return end

	local xs, ys, zs = rand:next(34, 66), rand:next(9, 12), rand:next(34, 66)
	local dx, dy, dz = rand:next(0, 80 - xs), rand:next(0, 80 - ys), rand:next(0, 80 - zs)
	local xc, yc, zc = min_pos.x + dx, min_pos.y + dy, min_pos.z + dz
	local j, vein_name, weight, vein

	for i = 2, #vbs do
		j = 0
		if yc >= vbs[i - 1] and yc <= vbs[i] then
			weight = rand:next(1, wb[vbs[i] .. "_" .. vbs[i - 1]])
			for y, w in pairs(vb[vbs[i] .. "_" .. vbs[i - 1]]) do
				j = j + w
				if j >= weight then
					vein = y
					break
				end
			end

			break
		end
	end

	if not vein then return end -- something went wrong
	local v = registered_veins[vein]

	local vm, emin, emax = minetest.get_mapgen_object "voxelmanip"
	local area = VoxelArea:new { MinEdge = emin, MaxEdge = emax }
	vm:get_data(data)
	local choice, x, y, w
	local noise_params = {
		offset = 5 / 6 * (v.density - 50),
		scale = 50,
		spread = { x = 1, y = 1.2, z = 1 },
		seed = seed + 232,
		octaves = 1,
		persist = 0.5,
	}
	local vec, corner = vector.new(xs, ys, zs), vector.new(xc, yc, zc)

	PerlinNoiseMap(noise_params, vec):get3dMap_flat(corner, perlin_map)

	local perlin_key = 1
	local count = 0
	for i in area:iter(xc, yc, zc, xc + xs - 1, yc + ys - 1, zc + zs - 1) do
		if data[i] == stone_cid and perlin_map[perlin_key] > 0 then
			count = count + 1
			x, y, w = 0, 0, v.ore_chances_multiplier
			choice = rand:next(1, w)
			while x < choice and y < #v.ore_chances do
				y = y + 1
				x = x + v.ore_chances[y]
			end
			data[i] = v.ore_list[y]
		end
		perlin_key = perlin_key + 1
	end

	if trinium.DEBUG_MODE then
		trinium.api.dump("Generated", vein, "vein with density =", count / (xs * ys * zs))
	end

	vm:set_data(data)
	vm:set_lighting { day = 0, night = 0 }
	vm:calc_lighting()
	vm:write_to_map()
end)
