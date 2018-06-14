local A = trinium.recipes.add
local M = trinium.materials.materials
local R = trinium.machines.recipes

 -- N2 + 3H2 -> 2NH3^
R.ammonia = A("chemical_reactor",
	{M.nitrogen:get"cell", M.hydrogen:get("cell", 3)},
	{M.ammonia:get("cell", 2), "trinium_materials:cell_empty 2"},
	{time = 25, pressure = 175, temperature = 850, catalyst = "osmium",
		pressure_tolerance = 25, temperature_tolerance = 20})

-- 2(C3H6) + 2NH3 + 3O2 -> 2C3H3N + 6H2O
R.acrylonitrile = A("chemical_reactor",
	{M.propene:get("cell", 2), M.ammonia:get("cell", 2), M.oxygen:get("cell", 3), "trinium_materials:cell_empty"},
	{M.acrylonitrile:get("cell", 2), M.water:get("cell", 6)},
	{time = 8, temperature = 587, temperature_tolerance = 16, catalyst = "bismuth_molybdenum"})

-- C4H10 Steam-Cracking -> C4H6^ + 2H2^
R.butane_cracking = A("chemical_reactor",
	{M.butane:get"cell", M.steam:get("cell", 2)},
	{M.butadiene:get"cell", M.hydrogen:get("cell", 2)},
	{time = 0.5, temperature = 1225, temperature_tolerance = 10})

-- C7H8 + H2 -> C6H6 + CH4^
R.toluene_hydration = A("chemical_reactor",
	{M.toluene:get"cell", M.hydrogen:get"cell"},
	{M.benzene:get"cell", M.methane:get"cell"},
	{time = 28, temperature = 550, temperature_tolerance = 60, catalyst = "chromium_trioxide",
		pressure = 50, pressure_tolerance = 8})

-- С6H6 + C2H4 -> C8H10
R.ethylbenzene = A("chemical_reactor",
	{M.benzene:get"cell", M.ethylene:get"cell"},
	{M.ethylbenzene:get"cell", "trinium_materials:cell_empty"},
	{time = 55})

-- C8H10 -> C8H8 + H2^
R.styrene = A("chemical_reactor",
	{M.ethylbenzene:get"cell", "trinium_materials:cell_empty"},
	{M.styrene:get"cell", M.hydrogen:get"cell"},
	{time = 55, catalyst = "iron_trioxide", temperature = 785, temperature_tolerance = 10})

-- 2H2S + O2 -> 2S + 2H2O turned into Oil Desulfurization
R.desulf = A("chemical_reactor",
	{M.oil:get("cell", 14), M.oxygen:get"cell", "trinium_materials:cell_empty"},
	{M.sulfur:get("dust", 2), M.water:get("cell", 2), M.desulf:get("cell", 14)},
	{time = 80, temperature = 370, temperature_tolerance = 10})

-- Various Hydro-cracking
R.hc_gas = A("chemical_reactor",
	{M.frac_gas:get("cell", 12), M.hydrogen:get"cell", "trinium_materials:cell_empty 5"},
	{M.methane:get("cell", 11), M.ethane:get("cell", 7)},
	{time = 10, temperature = 900, temperature_tolerance = 100, pressure = 100, pressure_tolerance = 20})

R.hc_ether = A("chemical_reactor",
	{M.frac_ether:get("cell", 12), M.hydrogen:get"cell", "trinium_materials:cell_empty 5"},
	{M.ethane:get("cell", 11), M.propane:get("cell", 5), M.butane:get("cell", 2)},
	{time = 10, temperature = 900, temperature_tolerance = 100, pressure = 100, pressure_tolerance = 20})

R.hc_naphtha = A("chemical_reactor",
	{M.naphtha:get("cell", 12), M.hydrogen:get"cell", "trinium_materials:cell_empty 5"},
	{M.butane:get("cell", 9), M.benzene:get("cell", 5), M.pentane:get("cell", 4)},
	{time = 10, temperature = 900, temperature_tolerance = 100, pressure = 100, pressure_tolerance = 20})

R.hc_kerosene = A("chemical_reactor",
	{M.kerosene:get("cell", 12), M.hydrogen:get"cell", "trinium_materials:cell_empty 5"},
	{M.benzene:get("cell", 14), M.toluene:get("cell", 3), M.octane:get"cell"},
	{time = 10, temperature = 900, temperature_tolerance = 100, pressure = 100, pressure_tolerance = 20})

R.hc_diesel = A("chemical_reactor",
	{M.diesel:get("cell", 12), M.hydrogen:get"cell", "trinium_materials:cell_empty 5"},
	{M.toluene:get("cell", 10), M.xylene:get("cell", 6), M.octane:get("cell", 2)},
	{time = 10, temperature = 900, temperature_tolerance = 100, pressure = 100, pressure_tolerance = 20})

-- Various Steam-Cracking
R.sc_gas = A("chemical_reactor",
	{M.frac_gas:get("cell", 12), M.steam:get"cell"},
	{M.methane:get("cell", 7), M.ethylene:get("cell", 3), M.propene:get("cell", 2), "trinium_materials:cell_empty"},
	{time = 0.5, temperature = 1150, temperature_tolerance = 10})

R.sc_ether = A("chemical_reactor",
	{M.frac_ether:get("cell", 12), M.steam:get"cell"},
	{M.ethylene:get("cell", 7), M.propene:get("cell", 4), M.butadiene:get"cell", "trinium_materials:cell_empty"},
	{time = 0.5, temperature = 1250, temperature_tolerance = 10})

R.sc_naphtha = A("chemical_reactor",
	{M.naphtha:get("cell", 12), M.steam:get"cell"},
	{M.toluene:get("cell", 9), M.isoprene:get("cell", 2), M.butadiene:get"cell", "trinium_materials:cell_empty"},
	{time = 0.5, temperature = 1325, temperature_tolerance = 10})
