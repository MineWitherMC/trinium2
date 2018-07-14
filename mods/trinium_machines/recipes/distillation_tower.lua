local A = trinium.recipes.add
local M = trinium.materials.materials
local R = trinium.machines.recipes

R.oil_dist = A("distillation_tower",
		{M.desulf:get"cell"},
		{M.frac_gas:get"cell", M.frac_ether:get"cell", M.naphtha:get"cell",
		  M.kerosene:get"cell", M.diesel:get"cell", M.mazut:get"cell"},
		{pressure = 1, pressure_tolerance = 0.1, temperatures = {-1, 375, 400, 450, 480, 585}, recovery = 2})
