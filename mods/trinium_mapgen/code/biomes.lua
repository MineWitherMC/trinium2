minetest.register_biome{
	name = "tundra",
	node_dust = "trinium_mapgen:snow",
	node_riverbed = "trinium_mapgen:gravel",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 2,
	heat_point = 0,
	humidity_point = 40,
}

minetest.register_biome{
	name = "tundra_beach",
	node_top = "trinium_mapgen:gravel",
	depth_top = 1,
	node_filler = "trinium_mapgen:gravel",
	depth_filler = 2,
	node_riverbed = "trinium_mapgen:gravel",
	depth_riverbed = 2,
	y_max = 1,
	y_min = -3,
	heat_point = 0,
	humidity_point = 40,
}

minetest.register_biome{
	name = "taiga",
	node_dust = "trinium_mapgen:minisnow",
	node_top = "trinium_mapgen:dirt_with_snow",
	depth_top = 1,
	node_filler = "trinium_mapgen:dirt",
	depth_filler = 3,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 2,
	heat_point = 25,
	humidity_point = 70,
}

minetest.register_biome{
	name = "snowy_grassland",
	node_dust = "trinium_mapgen:minisnow",
	node_top = "trinium_mapgen:dirt_with_snow",
	depth_top = 1,
	node_filler = "trinium_mapgen:dirt",
	depth_filler = 1,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 5,
	heat_point = 20,
	humidity_point = 35,
}

minetest.register_biome{
	name = "grassland",
	node_top = "trinium_mapgen:dirt_with_grass",
	depth_top = 1,
	node_filler = "trinium_mapgen:dirt",
	depth_filler = 1,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 6,
	heat_point = 50,
	humidity_point = 35,
}

minetest.register_biome{
	name = "grassland_dunes",
	node_top = "trinium_mapgen:sand",
	depth_top = 1,
	node_filler = "trinium_mapgen:sand",
	depth_filler = 2,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 5,
	y_min = 4,
	heat_point = 50,
	humidity_point = 35,
}

minetest.register_biome{
	name = "coniferous_forest",
	node_top = "trinium_mapgen:dirt_with_podzol",
	depth_top = 1,
	node_filler = "trinium_mapgen:dirt",
	depth_filler = 3,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 6,
	heat_point = 45,
	humidity_point = 70,
}

minetest.register_biome{
	name = "coniferous_forest_dunes",
	node_top = "trinium_mapgen:sand",
	depth_top = 1,
	node_filler = "trinium_mapgen:sand",
	depth_filler = 3,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 5,
	y_min = 4,
	heat_point = 45,
	humidity_point = 70,
}

minetest.register_biome{
	name = "basic_forest",
	node_top = "trinium_mapgen:dirt_with_grass",
	depth_top = 1,
	node_filler = "trinium_mapgen:dirt",
	depth_filler = 3,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 1,
	heat_point = 60,
	humidity_point = 68,
}

minetest.register_biome{
	name = "desert",
	node_top = "trinium_mapgen:sand",
	depth_top = 1,
	node_filler = "trinium_mapgen:sand",
	depth_filler = 1,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 5,
	heat_point = 92,
	humidity_point = 16,
}

minetest.register_biome{
	name = "savanna",
	node_top = "trinium_mapgen:dirt_with_dry_grass",
	depth_top = 1,
	node_filler = "trinium_mapgen:dirt",
	depth_filler = 1,
	node_riverbed = "trinium_mapgen:sand",
	depth_riverbed = 2,
	y_max = 31000,
	y_min = 1,
	heat_point = 89,
	humidity_point = 42,
}

minetest.register_biome{
	name = "underground",
	y_max = -113,
	y_min = -31000,
	heat_point = 50,
	humidity_point = 50,
}
