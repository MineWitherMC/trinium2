local S = trinium.mapgen.S
local api = trinium.api
local ss = trinium.sounds

-- Cobble
minetest.register_node("trinium_mapgen:cobble", {
	tiles = {"trinium_mapgen.cobble.png"},
	description = S"Cobblestone",
	groups = {stone = 1, cracky = 3},
	sounds = ss.default_stone,
})
-- Basic Stone
minetest.register_node("trinium_mapgen:stone", {
	tiles = {"trinium_mapgen.stone.png"},
	description = S"Stone",
	groups = {stone = 1, cracky = 3},
	drop = "trinium_mapgen:cobble",
	sounds = ss.default_stone,
})

if trinium.DEBUG_MODE then
	minetest.register_alias("mapgen_stone", "air")
else
	minetest.register_alias("mapgen_stone", "trinium_mapgen:stone")
end

-- Dirt
minetest.register_node("trinium_mapgen:dirt", {
	tiles = {"trinium_mapgen.dirt.png"},
	description = S"Dirt",
	groups = {soil = 1, crumbly = 3},
	sounds = ss.default_dirt,
})
minetest.register_alias("mapgen_dirt", "trinium_mapgen:dirt")

-- Sand
minetest.register_node("trinium_mapgen:sand", {
	tiles = {"trinium_mapgen.sand.png"},
	description = S"Sand",
	groups = {crumbly = 3, falling_node = 1},
	sounds = ss.default_sand,
})
minetest.register_alias("mapgen_sand", "trinium_mapgen:sand")

-- Dirt+Grass
minetest.register_node("trinium_mapgen:dirt_with_grass", {
	tiles = {"trinium_mapgen.grass.normal.png", "trinium_mapgen.dirt.png",
	          "trinium_mapgen.dirt.png^trinium_mapgen.grass.normal.overlay.png"},
	description = S"Dirt with Grass",
	groups = {soil = 1, crumbly = 3, grass = 1},
	drop = "trinium_mapgen:dirt",
	sounds = api.set_defaults({
		footstep = {name = "trinium.grass_footstep", gain = 0.25},
	}, ss.default_dirt),
})

-- Dirt+Snow
minetest.register_node("trinium_mapgen:dirt_with_snow", {
	tiles = {"trinium_mapgen.grass.snow.png", "trinium_mapgen.dirt.png",
	          "trinium_mapgen.dirt.png^trinium_mapgen.grass.snow.overlay.png"},
	description = S"Dirt with Snow",
	groups = {soil = 1, crumbly = 3, grass = 1},
	drop = "trinium_mapgen:dirt",
	sounds = ss.default_snow,
})

-- Dirt+Podzol
minetest.register_node("trinium_mapgen:dirt_with_podzol", {
	tiles = {"trinium_mapgen.grass.podzol.png", "trinium_mapgen.dirt.png",
	          "trinium_mapgen.dirt.png^trinium_mapgen.grass.podzol.overlay.png"},
	description = S"Dirt with Podzol",
	groups = {soil = 1, crumbly = 3, grass = 1},
	drop = "trinium_mapgen:dirt",
	sounds = api.set_defaults({
		footstep = {name = "trinium.grass_footstep", gain = 0.35},
	}, ss.default_dirt),
})

-- Dirt+Dry grass
minetest.register_node("trinium_mapgen:dirt_with_dry_grass", {
	tiles = {"trinium_mapgen.grass.dry.png", "trinium_mapgen.dirt.png",
	          "trinium_mapgen.dirt.png^trinium_mapgen.grass.dry.overlay.png"},
	description = S"Dirt with Dry Grass",
	groups = {soil = 1, crumbly = 3, grass = 1},
	drop = "trinium_mapgen:dirt",
	sounds = api.set_defaults({
		footstep = {name = "trinium.grass_footstep", gain = 0.35},
	}, ss.default_dirt),
})

-- Snow
minetest.register_node("trinium_mapgen:snow", {
	tiles = {"trinium_mapgen.snow.png"},
	description = S"Snow",
	groups = {soil = 1, crumbly = 3},
	sounds = ss.default_snow,
})

-- Snow Layer
minetest.register_node("trinium_mapgen:minisnow", {
	tiles = {"trinium_mapgen.snow.png"},
	description = S"Snow Layer",
	groups = {soil = 1, crumbly = 3},
	paramtype = "light",
	drawtype = "nodebox",
	buildable_to = true,
	node_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}},
	},
	sounds = ss.default_snow,
})

minetest.register_abm({
	label = "grass destruction",
	nodenames = {"group:grass"},
	interval = 1,
	chance = 256,
	catch_up = false,
	action = function(pos)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		local name = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[name]
		if name ~= "ignore" and nodedef and not nodedef.sunlight_propagates
				and nodedef.paramtype ~= "light"
				and nodedef.liquidtype == "none" then
			minetest.set_node(pos, {name = "trinium_mapgen:dirt"})
		end
	end,
})

minetest.register_abm({
	label = "grass spread",
	nodenames = {"trinium_mapgen:dirt"},
	neighbors = {"air"},
	interval = 4,
	chance = 256,
	catch_up = false,
	action = function(pos)
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		if (minetest.get_node_light(above) or 0) < 12 then return end
		local name = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[name]
		if name == "ignore" or not nodedef or nodedef.sunlight_propagates or
				nodedef.paramtype == "light" or
				nodedef.liquidtype ~= "none" then
			local biome = minetest.get_biome_name(minetest.get_biome_data(pos).biome)
			local node1 = minetest.registered_biomes[biome]
			if not node1 or not node1.node_top then
				node1 = "trinium_mapgen:dirt_with_grass"
			else
				node1 = node1.node_top
			end
			if node1 == "trinium_mapgen:sand" then node1 = "trinium_mapgen:dirt_with_dry_grass" end
			if node1 == "trinium_mapgen:gravel" then node1 = "trinium_mapgen:dirt_with_snow" end
			minetest.set_node(pos, {name = node1})
		end
	end,
})

-- Gravel
minetest.register_node("trinium_mapgen:gravel", {
	tiles = {"trinium_mapgen.gravel.png"},
	description = S"Gravel",
	groups = {crumbly = 2, falling_node = 1},
	sounds = ss.default_gravel,
})
minetest.register_alias("mapgen_gravel", "trinium_mapgen:gravel")

-- Water
api.register_fluid("trinium_mapgen:water_source", "trinium_mapgen:water_flowing",
		S"Water", S"Flowing Water",
		"0000DC", {
			alpha = 160,
			liquid_viscosity = 1,
		})

if not trinium.DEBUG_MODE then
	minetest.register_alias("mapgen_water_source", "trinium_mapgen:water_source")
end

-- River Water
api.register_fluid("trinium_mapgen:river_water_source", "trinium_mapgen:river_water_flowing",
		S"River Water", S"Flowing River Water",
		"3399EC", {
			alpha = 160,
			liquid_viscosity = 1,
			liquid_range = 3,
		})

if not trinium.DEBUG_MODE then
	minetest.register_alias("mapgen_river_water_source", "trinium_mapgen:river_water_source")
end

-- Clay
minetest.register_node("trinium_mapgen:clay", {
	tiles = {"trinium_mapgen.clay.png"},
	description = S"Clay",
	groups = {crumbly = 2},
	drop = {
		-- max_items = 3,
		items = {
			{items = {"trinium_materials:clay 3"}, rarity = 1},
			{items = {"trinium_materials:clay"}, rarity = 2},
			{items = {"trinium_materials:clay"}, rarity = 4},
		},
	},
	sounds = ss.default_sand,
})
minetest.register_ore{
	ore_type = "blob",
	ore = "trinium_mapgen:clay",
	wherein = "trinium_mapgen:stone",
	clust_scarcity = 135,
	clust_num_ores = 7,
	clust_size = 4,
	y_min = -200,
	y_max = 64,
	flags = "",
	noise_threshold = 0.5,
	noise_params = {
		offset = 0,
		scale = 1,
		spread = {x = 100, y = 100, z = 100},
		seed = 226,
		octaves = 3,
		persist = 0.7
	},
}
