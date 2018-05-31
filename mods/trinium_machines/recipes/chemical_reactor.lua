local A = trinium.recipes.add
local M = trinium.materials.materials

 -- N2 + 3H2 -> 2NH3^
A("chemical_reactor",
	{M.nitrogen:get"cell", M.hydrogen:get("cell", 3)},
	{M.ammonia:get("cell", 2), "trinium_materials:cell_empty 2"},
	{time = 25, pressure = 175, pressure_tolerance = 25, temperature = 850, temperature_tolerance = 20, catalyst = "osmium"})
