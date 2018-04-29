local S = trinium.mapgen.S

minetest.register_node("trinium_mapgen:wood_log_fir", {
	tiles = {"trinium_mapgen.wood.log.fir.png", "trinium_mapgen.wood.log.fir.png", "trinium_mapgen.wood.bark.fir.png"},
	description = S"Fir Log",
	groups = {wood = 1, choppy = 2},
})

minetest.register_node("trinium_mapgen:wood_leaves_fir", {
	tiles = {"trinium_mapgen.wood.leaves.fir.png"},
	description = S"Fir Needles",
	groups = {snappy = 3, leaves = 8},
	drop = "",
})
minetest.register_alias("trinium:block_fir_log", "trinium_mapgen:wood_log_fir")
minetest.register_alias("trinium:block_fir_leaves", "trinium_mapgen:wood_leaves_fir")

minetest.register_decoration({
	name = "tree_fir",
	deco_type = "schematic",
	place_on = {"trinium_mapgen:dirt_with_grass", "trinium_mapgen:dirt_with_snow", "trinium_mapgen:dirt_with_podzol"},
	sidelen = 8,
	noise_params = {
		offset = 0.0,
		scale = 0.0025,
		spread = {x = 250, y = 250, z = 250},
		seed = 2685,
		octaves = 4,
		persist = 0.7
	},
	biomes = {"taiga", "coniferous_forest"},
	y_max = 31000,
	y_min = 1,
	schematic = minetest.get_modpath"trinium_mapgen".."/schematics/tree_fir.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

minetest.register_node("trinium_mapgen:wood_log_acacia", {
	tiles = {"trinium_mapgen.wood.log.acacia.png", "trinium_mapgen.wood.log.acacia.png", 
			"trinium_mapgen.wood.bark.acacia.png"},
	description = S"Acacia Log",
	groups = {wood = 1, choppy = 2},
})
minetest.register_alias("trinium:block_acacia_log", "trinium_mapgen:wood_log_acacia")
minetest.register_alias("trinium:block_acacia_leaves", "trinium_mapgen:wood_leaves_acacia")

minetest.register_node("trinium_mapgen:wood_leaves_acacia", {
	tiles = {"trinium_mapgen.wood.leaves.acacia.png"},
	description = S"Acacia Leaves",
	groups = {snappy = 3, leaves = 5},
	drop = "",
})

minetest.register_decoration({
	name = "acacia_tree",
	deco_type = "schematic",
	place_on = {"trinium_mapgen:dirt_with_dry_grass"},
	sidelen = 8,
	noise_params = {
		offset = 0.0,
		scale = 0.0025,
		spread = {x = 250, y = 250, z = 250},
		seed = 2686,
		octaves = 4,
		persist = 0.7
	},
	biomes = {"savanna"},
	y_max = 31000,
	y_min = 1,
	schematic = minetest.get_modpath"trinium_mapgen".."/schematics/tree_acacia.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

minetest.register_node("trinium_mapgen:wood_log_maple", {
	tiles = {"trinium_mapgen.wood.log.maple.png", "trinium_mapgen.wood.log.maple.png", 
			"trinium_mapgen.wood.bark.maple.png"},
	description = S"Maple Log",
	groups = {wood = 1, choppy = 2},
})
minetest.register_alias("trinium:block_wood", "trinium_mapgen:wood_log_maple")
minetest.register_alias("trinium:block_maple_log", "trinium_mapgen:wood_log_maple")

minetest.register_node("trinium_mapgen:wood_leaves_maple", {
	tiles = {"trinium_mapgen.wood.leaves.maple.png"},
	description = S"Maple Leaves",
	groups = {snappy = 3, leaves = 4},
	drop = "",
})
minetest.register_alias("trinium:block_leaves", "trinium_mapgen:wood_leaves_maple")
minetest.register_alias("trinium:block_maple_leaves", "trinium_mapgen:wood_leaves_maple")

minetest.register_decoration({
	name = "maple_tree",
	deco_type = "schematic",
	place_on = {"trinium_mapgen:dirt_with_grass"},
	sidelen = 8,
	noise_params = {
		offset = 0.0,
		scale = 0.0025,
		spread = {x = 250, y = 250, z = 250},
		seed = 2687,
		octaves = 4,
		persist = 0.7
	},
	biomes = {"basic_forest", "grassland"},
	y_max = 31000,
	y_min = 1,
	schematic = minetest.get_modpath"trinium_mapgen".."/schematics/tree_maple.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})