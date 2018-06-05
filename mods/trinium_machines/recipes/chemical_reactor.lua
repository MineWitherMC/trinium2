local A = trinium.recipes.add
local M = trinium.materials.materials

 -- N2 + 3H2 -> 2NH3^
A("chemical_reactor",
	{M.nitrogen:get"cell", M.hydrogen:get("cell", 3)},
	{M.ammonia:get("cell", 2), "trinium_materials:cell_empty 2"},
	{time = 25, pressure = 175, temperature = 850, catalyst = "osmium",
		pressure_tolerance = 25, temperature_tolerance = 20})

-- 2(C3H6) + 2NH3 + 3O2 -> 2(CH2CHCN) + 6H2O
A("chemical_reactor",
	{M.propene:get("cell", 2), M.ammonia:get("cell", 2), M.oxygen:get("cell", 3), "trinium_materials:cell_empty"},
	{M.acrylonitrile:get("cell", 2), M.water:get("cell", 6)},
	{time = 8, temperature = 587, temperature_tolerance = 16, catalyst = "bismuth_molybdenum"})

-- C4H10 Steam-Cracking -> C4H6^ + 2H2^
A("chemical_reactor",
	{M.butane:get"cell", M.steam:get("cell", 2)},
	{M.butadiene:get"cell", M.hydrogen:get("cell", 2)},
	{time = 0.5, temperature = 1225, temperature_tolerance = 10})

-- C7H8 + H2 -> C6H6 + CH4^
A("chemical_reactor",
	{M.toluene:get"cell", M.hydrogen:get"cell"},
	{M.benzene:get"cell", M.methane:get"cell"},
	{time = 28, temperature = 550, temperature_tolerance = 60, catalyst = "chromium_trioxide",
		pressure = 50, pressure_tolerance = 8})

-- С6H6 + C2H4 -> C8H10
A("chemical_reactor",
	{M.benzene:get"cell", M.ethene:get"cell"},
	{M.ethylbenzene:get"cell", "trinium_materials:cell_empty"},
	{time = 55})

-- C8H10 -> C8H8 + H2^
A("chemical_reactor",
	{M.ethylbenzene:get"cell", "trinium_materials:cell_empty"},
	{M.styrene:get"cell", M.hydrogen:get"cell"},
	{time = 55, catalyst = "iron_trioxide", temperature = 785, temperature_tolerance = 10})

-- 2H2S + O2 -> 2S + 2H2O turned into Oil Desulfurization
A("chemical_reactor",
	{M.oil:get("cell", 14), M.oxygen:get"cell", "trinium_materials:cell_empty"},
	{M.sulfur:get("dust", 2), M.water:get("cell", 2), M.desulf:get("cell", 14)},
	{time = 80, temperature = 370, temperature_tolerance = 10})
