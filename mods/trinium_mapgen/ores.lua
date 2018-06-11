local mapgen = trinium.mapgen

mapgen.register_vein("diamond", {
	ore_list = {"trinium_materials:ore_diamond", "trinium_materials:ore_antracite",
		"trinium_materials:ore_coal", "trinium_materials:ore_graphite"},
	ore_chances = {1, 3, 4, 2},
	density = 90,
	weight = 40,
	min_height = -31000,
	max_height = -50,
})

mapgen.register_vein("polymetallic", {
	ore_list = {"trinium_materials:ore_chalcopyrite", "trinium_materials:ore_galena",
		"trinium_materials:ore_sphalerite"},
	ore_chances = {3, 2, 1},
	density = 70,
	weight = 30,
	min_height = -31000,
	max_height = -50,
})

mapgen.register_vein("pale_ores", {
	ore_list = {"trinium_materials:ore_tetrahedrite", "trinium_materials:ore_freibergite",
		"trinium_materials:ore_tennantite"},
	ore_chances = {5, 2, 2},
	density = 20,
	weight = 20,
	min_height = -31000,
	max_height = -50,
})