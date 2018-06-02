local materials = trinium.materials
local M = materials.materials
local S = materials.S
local V = materials.vanilla_elements

-- Non-organic chemicals and pure elements
do
	M.water = materials.add("water", {
		formula = {{"hydrogen", 2}, {"oxygen", 1}},
		types = {"cell"},
		color = {0, 0, 220},
		description = S"Water",
	})

	M.steam = materials.add("steam", {
		formula = {{"hydrogen", 2}, {"oxygen", 1}},
		types = {"cell"},
		color = {234, 234, 234},
		description = S"Steam",
	})

	M.hydrogen = materials.add("m_hydrogen", {
		formula = {{"hydrogen", 2}},
		types = {"cell"},
		description = S"Hydrogen",
	})

	M.nitrogen = materials.add("m_nitrogen", {
		formula = {{"nitrogen", 2}},
		types = {"cell"},
		description = S"Nitrogen",
	})

	M.oxygen = materials.add("m_oxygen", {
		formula = {{"oxygen", 2}},
		types = {"cell"},
		description = S"Oxygen",
	})

	M.sulfur = V.sulfur:register_material{
		description = S"Sulfur",
		types = {"dust"},
	}

	M.ammonia = materials.add("ammonia", {
		formula = {{"nitrogen", 1}, {"hydrogen", 3}},
		types = {"cell"},
		description = S"Ammonia",
	})

	M.glass = materials.add("glass", {
		formula = {{"silicon", 1}, {"oxygen", 2}},
		types = {"plate", "dust"},
		color = {250, 250, 250},
		description = S"Glass",
	})
end

-- Organics
do
	M.methane = materials.add("methane", {
		formula = {{"carbon", 1}, {"hydrogen", 4}},
		types = {"cell"},
		color = {240, 90, 240},
		description = S"Methane",
	})

	M.ethene = materials.add("ethylene", {
		formula = {{"carbon", 2}, {"hydrogen", 4}},
		types = {"cell"},
		color = {190, 175, 235},
		description = S"Ethylene",
	})

	M.propene = materials.add("propylene", {
		formula = {{"carbon", 3}, {"hydrogen", 6}},
		types = {"cell"},
		color = {235, 235, 55},
		description = S"Propylene",
	})

	M.butane = materials.add("butane", {
		formula = {{"carbon", 4}, {"hydrogen", 10}},
		types = {"cell"},
		color = {160, 90, 0},
		description = S"Butane",
	})

	M.benzene = materials.add("benzene", {
		formula = {{"carbon", 6}, {"hydrogen", 6}},
		types = {"cell"},
		color = {40, 40, 50},
		description = S"Benzene",
	})

	M.toluene = materials.add("toluene", {
		formula = {{"carbon", 7}, {"hydrogen", 8}},
		types = {"cell"},
		color = {90, 85, 50},
		description = S"Toluene",
	})

	M.isooctane = materials.add("octane", {
		formula = {{"carbon", 8}, {"hydrogen", 18}},
		types = {"cell"},
		color = {115, 85, 135},
		description = S"Octane",
	})

	M.ethylbenzene = materials.add("ethylbenzene", {
		formula = {{"carbon", 8}, {"hydrogen", 10}},
		types = {"cell"},
		color = {240, 240, 240},
		description = S"Ethylbenzene",
	})

	M.styrene = materials.add("styrene", {
		formula = {{"carbon", 8}, {"hydrogen", 8}},
		types = {"cell"},
		color = {250, 230, 240},
		description = S"Styrene",
	})

	M.butadiene = materials.add("butadiene", {
		formula = {{"carbon", 4}, {"hydrogen", 6}},
		types = {"cell"},
		color = {50, 40, 40},
		description = S"Divinyl",
	})

	M.acrylonitrile = materials.add("acrylonitrile", {
		formula = {{"carbon", 1}, {"hydrogen", 2}, {"carbon", 1}, {"hydrogen", 1}, {"carbon", 1}, {"nitrogen", 1}},
		types = {"cell"},
		color = {240, 240, 225},
		description = S"Acrylonitrile",
	})

	M.abs = materials.add("abs_plastic", {
		formula = {{"styrene", 8}, {"butadiene", 5}, {"acrylonitrile", 5}},
		types = {"cell", "pulp", "ingot", "plate"},
		color = {50, 50, 50},
		description = S"ABS Plastic",
	}):generate_interactions()
end
