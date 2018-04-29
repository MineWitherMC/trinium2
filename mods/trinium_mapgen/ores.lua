local mapgen = trinium.mapgen

mapgen.register_vein("diamond", {
	ore_list = {"trinium_materials:ore_diamond", "trinium_materials:ore_antracite", 
		"trinium_materials:ore_coal", "trinium_materials:ore_graphite"},
	ore_chances = {1, 3, 4, 2},
	density = 55,
	weight = 10,
	min_height = -31000,
	max_height = -50,
})