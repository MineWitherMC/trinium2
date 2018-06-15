local materials = trinium.materials
local M = materials.materials
local S = materials.S
local V = materials.vanilla_elements

-- Non-organic chemicals and pure elements
do
	M.water = materials.add("water", {
		formula = { { "hydrogen", 2 }, { "oxygen", 1 } },
		types = { "cell" },
		color = { 60, 60, 205 },
		description = S "Water",
	})

	M.steam = materials.add("steam", {
		formula = { { "hydrogen", 2 }, { "oxygen", 1 } },
		types = { "cell" },
		color = { 224, 224, 224 },
		description = S "Steam",
	})

	M.hydrogen = materials.add("m_hydrogen", {
		formula = { { "hydrogen", 2 } },
		types = { "cell" },
		description = S "Hydrogen",
	})

	M.nitrogen = materials.add("m_nitrogen", {
		formula = { { "nitrogen", 2 } },
		types = { "cell" },
		description = S "Nitrogen",
	})

	M.oxygen = materials.add("m_oxygen", {
		formula = { { "oxygen", 2 } },
		types = { "cell" },
		description = S "Oxygen",
	})

	M.sulfur = V.sulfur:register_material {
		description = S "Sulfur",
		types = { "dust" },
	}

	M.ammonia = materials.add("ammonia", {
		formula = { { "nitrogen", 1 }, { "hydrogen", 3 } },
		types = { "cell" },
		description = S "Ammonia",
		color = { 180, 125, 230 },
	})
end

-- Organics
do
	M.methane = materials.add("methane", {
		formula = { { "carbon", 1 }, { "hydrogen", 4 } },
		types = { "cell" },
		color = { 240, 90, 240 },
		description = S "Methane",
	})

	M.ethane = materials.add("ethane", {
		formula = { { "carbon", 2 }, { "hydrogen", 6 } },
		types = { "cell" },
		color = { 170, 170, 235 },
		description = S "Ethane",
	})

	M.ethylene = materials.add("ethylene", {
		formula = { { "carbon", 2 }, { "hydrogen", 4 } },
		types = { "cell" },
		color = { 190, 175, 235 },
		description = S "Ethylene",
	})

	M.propane = materials.add("propane", {
		formula = { { "carbon", 3 }, { "hydrogen", 8 } },
		types = { "cell" },
		color = { 250, 226, 80 },
		description = S "Propane",
	})

	M.propene = materials.add("propene", {
		formula = { { "carbon", 3 }, { "hydrogen", 6 } },
		types = { "cell" },
		color = { 225, 235, 55 },
		description = S "Propene",
	})

	M.butane = materials.add("butane", {
		formula = { { "carbon", 4 }, { "hydrogen", 10 } },
		types = { "cell" },
		color = { 160, 90, 0 },
		description = S "Butane",
	})

	M.butadiene = materials.add("butadiene", {
		formula = { { "carbon", 4 }, { "hydrogen", 6 } },
		types = { "cell" },
		color = { 90, 75, 70 },
		description = S "Butadiene",
	})

	M.pentane = materials.add("pentane", {
		formula = { { "carbon", 5 }, { "hydrogen", 12 } },
		types = { "cell" },
		color = { 0, 110, 160 },
		description = S "Pentane",
	})

	M.isoprene = materials.add("isoprene", {
		formula = { { "carbon", 5 }, { "hydrogen", 8 } },
		types = { "cell" },
		color = { 50, 50, 50 },
		description = S "Isoprene",
	})

	M.octane = materials.add("octane", {
		formula = { { "carbon", 8 }, { "hydrogen", 18 } },
		types = { "cell" },
		color = { 235, 225, 255 },
		description = S "Octane",
	})

	M.benzene = materials.add("benzene", {
		formula = { { "carbon", 6 }, { "hydrogen", 6 } },
		types = { "cell" },
		color = { 70, 75, 90 },
		description = S "Benzene",
	})

	M.toluene = materials.add("toluene", {
		formula = { { "carbon", 7 }, { "hydrogen", 8 } },
		types = { "cell" },
		color = { 90, 85, 50 },
		description = S "Toluene",
	})

	M.xylene = materials.add("xylene", {
		formula = { { "carbon", 8 }, { "hydrogen", 10 } },
		types = { "cell" },
		color = { 115, 85, 135 },
		description = S "Xylene",
	})

	M.ethylbenzene = materials.add("ethylbenzene", {
		formula = { { "carbon", 8 }, { "hydrogen", 10 } },
		types = { "cell" },
		color = { 240, 240, 240 },
		description = S "Ethylbenzene",
	})

	M.styrene = materials.add("styrene", {
		formula = { { "carbon", 8 }, { "hydrogen", 8 } },
		types = { "cell" },
		color = { 250, 230, 240 },
		description = S "Styrene",
	})

	M.acrylonitrile = materials.add("acrylonitrile", {
		formula = { { "carbon", 2 }, { "hydrogen", 3 }, { "carbon", 1 }, { "nitrogen", 1 } },
		types = { "cell" },
		color = { 240, 240, 225 },
		description = S "Acrylonitrile",
	})

	M.abs = materials.add("abs_plastic", {
		formula = { { "styrene", 8 }, { "butadiene", 5 }, { "acrylonitrile", 5 } },
		types = { "cell", "pulp", "ingot", "plate" },
		color = { 255, 225, 180 },
		description = S "ABS Plastic",
	})               :generate_interactions()
end
