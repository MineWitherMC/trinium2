local S = trinium.mapgen.S

minetest.register_node("trinium_mapgen:rock", {
	tiles = {"trinium_mapgen.rock.png", "trinium_mapgen.rock.png", "invisible_texture.png"},
	description = S"Rock",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, -0.42, 0.5 },
	},
	groups = { oddly_breakable_by_hand = 3, falling_node = 1, no_silk = 1, hidden_from_irp = 1 },
	drop = "trinium_materials:rock",
	paramtype = "light",
})

minetest.register_node("trinium_mapgen:stick", {
	tiles = {"trinium_mapgen.stick.png", "trinium_mapgen.stick.png", "invisible_texture.png"},
	description = S"Stick",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = { -0.5, -0.5, -0.5, 0.5, -0.42, 0.5 },
	},
	groups = { oddly_breakable_by_hand = 3, falling_node = 1, no_silk = 1, hidden_from_irp = 1 },
	drop = "trinium_materials:stick",
	paramtype = "light",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"trinium_mapgen:dirt_with_grass", "trinium_mapgen:dirt_with_snow", 
			"trinium_mapgen:dirt_with_podzol", "trinium_mapgen:dirt_with_dry_grass"},
	sidelen = 8,
	fill_ratio = 0.0065,
	biomes = {"taiga", "coniferous_forest", "basic_forest", "savanna", "grassland"},
	decoration = "trinium_mapgen:stick",
	height = 1,
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"trinium_mapgen:dirt_with_grass", "trinium_mapgen:dirt_with_snow", 
			"trinium_mapgen:dirt_with_podzol", "trinium_mapgen:dirt_with_dry_grass"},
	sidelen = 8,
	fill_ratio = 0.008,
	biomes = {"taiga", "coniferous_forest", "basic_forest", "savanna", "grassland"},
	decoration = "trinium_mapgen:rock",
	height = 1,
})