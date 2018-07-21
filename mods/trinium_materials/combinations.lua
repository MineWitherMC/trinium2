local materials = trinium.materials
local recipes = trinium.recipes
local api = trinium.api

materials.add_combination("ingot_bending", {
	requirements = {"plate", "ingot"},
	apply = function(name, data)
		api.delayed_call("trinium_machines", recipes.add, "industrial_metal_press",
				{"trinium_machines:press_mold_plate 0", "trinium_materials:ingot_" .. name},
				{"trinium_materials:plate_" .. name},
				{time = data.press_time or 10, pressure = data.press_pressure or 4, pressure_tolerance = 0.5})
	end,
})

--[[materials.add_combination("dust_smelting", {
	requirements = {"dust", "ingot"},
	apply = function(name, data)
		recipes.add("grinder",
				{"trinium_materials:ingot_" .. name},
				{"trinium_materials:dust_" .. name})
		recipes.add("melter",
				{"trinium_materials:dust_" .. name},
				{"trinium_materials:ingot_" .. name},
				{melting_point = data.melting_point})
	end,
})

materials.add_combination("dust_implosion", {
	requirements = {"dust", "gem"},
	apply = function(name)
		recipes.add("grinder",
				{"trinium_materials:gem_" .. name},
				{"trinium_materials:dust_" .. name})
		recipes.add("implosion",
				{"trinium_materials:dust_" .. name .. " 4"},
				{"trinium_materials:gem_" .. name .. " 3"})
	end,
})]]--

materials.add_combination("gem_lathing", {
	requirements = {"rod", "gem", "dust"},
	apply = function(name, data)
		api.delayed_call("trinium_machines", recipes.add, "industrial_metal_press",
				{"trinium_machines:press_mold_rod 0", "trinium_materials:gem_" .. name .. " 2"},
				{"trinium_materials:rod_" .. name .. " 2", "trinium_materials:dust_" .. name},
				{time = (data.press_time or 10) * 0.66, pressure = (data.press_pressure or 4) * 0.66, pressure_tolerance = 0.33})
	end,
})

materials.add_combination("ingot_lathing", {
	requirements = {"rod", "ingot"},
	apply = function(name, data)
		api.delayed_call("trinium_machines", recipes.add, "industrial_metal_press",
				{"trinium_machines:press_mold_rod 0", "trinium_materials:ingot_" .. name},
				{"trinium_materials:rod_" .. name .. " 2"},
				{time = (data.press_time or 10) * 0.5, pressure = (data.press_pressure or 4) * 0.5, pressure_tolerance = 0.25})
	end,
})

--[[materials.add_combination("brick_compression", {
	requirements = {"dust", "brick"},
	apply = function(name)
		recipes.add("crude_compressor",
				{"trinium_materials:dust_" .. name},
				{"trinium_materials:brick_" .. name})
		recipes.add("grinder",
				{"trinium_materials:brick_" .. name},
				{"trinium_materials:dust_" .. name})
	end,
})

materials.add_combination("ore_grinding", {
	requirements = {"ore", "dust"},
	apply = function(name)
		if not minetest.registered_items["trinium_materials:gem_" .. name] then
			recipes.add("grinder",
					{"trinium_materials:ore_" .. name},
					{"trinium_materials:dust_" .. name .. " 3"})
		else
			recipes.add("grinder",
					{"trinium_materials:ore_" .. name},
					{"trinium_materials:dust_" .. name, "trinium:gem_" .. name .. " 2"})
		end
	end,
})]]--