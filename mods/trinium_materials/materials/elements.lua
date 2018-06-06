local materials = trinium.materials
local S = materials.S

materials.vanilla_elements = {}
local V = materials.vanilla_elements
materials.materials = {}
local M = materials.materials

-- Elements
do
	V.hydrogen = materials.add_element("hydrogen", {
		formula = "H",
		melting_point = 14,
		color = {0, 0, 150},
	})

	V.carbon = materials.add_element("carbon", {
		formula = "C",
		melting_point = -1,
		color = {16, 16, 16},
	})

	V.nitrogen = materials.add_element("nitrogen", {
		formula = "N",
		melting_point = -1,
		color = {185, 240, 240},
	})

	V.oxygen = materials.add_element("oxygen", {
		formula = "O",
		melting_point = 55,
		color = {185, 185, 240},
	})

	V.fluorine = materials.add_element("fluorine", {
		formula = "F",
		melting_point = 53,
		color = {0, 60, 120},
	})

	V.sodium = materials.add_element("sodium", {
		formula = "Na",
		melting_point = 370,
		color = {0, 0, 150},
	})

	V.aluminium = materials.add_element("aluminium", {
		formula = "Al",
		melting_point = 933,
		color = {128, 200, 240},
	})

	V.silicon = materials.add_element("silicon", {
		formula = "Si",
		melting_point = 1688,
		color = {60, 60, 80},
	})

	V.phosphorus = materials.add_element("phosphorus", {
		formula = "P",
		melting_point = 317,
		color = {250, 250, 235},
	})

	V.sulfur = materials.add_element("sulfur", {
		formula = "S",
		melting_point = 386,
		color = {250, 250, 110},
	})

	V.chlorine = materials.add_element("chlorine", {
		formula = "Cl",
		melting_point = 172,
		color = {0, 120, 145},
	})

	V.potassium = materials.add_element("potassium", {
		formula = "K",
		melting_point = 336,
		color = {225, 225, 225},
	})

	V.calcium = materials.add_element("calcium", {
		formula = "Ca",
		melting_point = 1115,
		color = {255, 245, 245},
	})

	V.titanium = materials.add_element("titanium", {
		formula = "Ti",
		melting_point = 1941,
		color = {220, 160, 240},
	})

	V.chromium = materials.add_element("chromium", {
		formula = "Cr",
		melting_point = 2130,
		color = {255, 230, 230},
	})

	V.iron = materials.add_element("iron", {
		formula = "Fe",
		melting_point = 1811,
		color = {200, 200, 200},
	})

	V.nickel = materials.add_element("nickel", {
		formula = "Ni",
		melting_point = 1728,
		color = {200, 200, 255},
	})

	V.copper = materials.add_element("copper", {
		formula = "Cu",
		melting_point = 1357,
		color = {255, 100, 0},
	})

	V.arsenic = materials.add_element("arsenic", {
		formula = "As",
		melting_point = -1,
		color = {135, 165, 144},
	})

	V.rubidium = materials.add_element("rubidium", {
		formula = "Rb",
		melting_point = 312,
		color = {90, 55, 40},
	})

	V.molybdenum = materials.add_element("molybdenum", {
		formula = "Mo",
		melting_point = 2896,
		color = {180, 180, 220},
	})

	V.silver = materials.add_element("silver", {
		formula = "Ag",
		melting_point = 1234,
		color = {220, 220, 255},
	})

	V.tin = materials.add_element("tin", {
		formula = "Sn",
		melting_point = 504,
		color = {220, 220, 220},
	})

	V.iodine = materials.add_element("iodine", {
		formula = "I",
		melting_point = -1,
		color = {150, 60, 170},
	})

	V.caesium = materials.add_element("caesium", {
		formula = "Cs",
		melting_point = 301,
		color = {150, 240, 235},
	})

	V.rhenium = materials.add_element("rhenium", {
		formula = "Re",
		melting_point = 3459,
		color = {80, 80, 88},
	})

	V.platinum = materials.add_element("platinum", {
		formula = "Pt",
		melting_point = 2041,
		color = {255, 255, 200},
	})

	V.osmium = materials.add_element("osmium", {
		formula = "Os",
		melting_point = 3306,
		color = {50, 50, 255},
	})

	V.bismuth = materials.add_element("bismuth", {
		formula = "Bi",
		melting_point = 545,
		color = {100, 160, 160},
	})

	V.naquadah = materials.add_element("naquadah", {
		formula = "Nq",
		melting_point = 6553,
		color = {16, 45, 16},
	})

	V.extrium = materials.add_element("extrium", {
		formula = "X",
		melting_point = 4200,
		color = {90, 90, 80},
	})
end

-- Pseudo-Materials
do
	materials.add("iodine_acid_ion", {
		formula = {{"iodine", 1}, {"oxygen", 6}},
		types = {},
	})

	materials.add("hydroxide_ion", {
		formula = {{"oxygen", 1}, {"hydrogen", 1}},
		types = {},
	})

	materials.add("phosphoric_acid_ion", {
		formula = {{"phosphorus", 1}, {"oxygen", 4}},
		types = {},
	})

	materials.add("forcillium_induced_ion", {
		formula = {{"iron", 1}, {"extrium", 1}, {"caesium", 2}, {"rubidium", 1}},
		types = {},
	})

	materials.add("fluixine_ring", {
		formula = {{"carbon", 12}, {"hydrogen", 12}},
		types = {},
	})
	materials.add("fluixine_ion", {
		formula = {{"carbon", 12}, {"hydrogen", 11}},
		types = {},
	})
	materials.add("fluixine2_ion", {
		formula = {{"carbon", 12}, {"hydrogen", 10}},
		types = {},
	})
end

-- Items that are in materials namespace are also here
do
	minetest.register_craftitem("trinium_materials:cell_empty", {
		description = S"Empty Cell",
		inventory_image = "(trinium_materials.cell.png^[colorize:#404040B0)^trinium_materials.cell.overlay.png"
	})

	minetest.register_craftitem("trinium_materials:stardust", {
		description = S"Stardust"..minetest.colorize("#CCC", "\nHe2X"),
		inventory_image = "(trinium_materials.dust.png^[colorize:#AAD200B0)^trinium_materials.dust.overlay.png"
	})

	minetest.register_craftitem("trinium_materials:brick", {
		description = S"Brick",
		inventory_image = "trinium_materials.ingot.png^[colorize:#483526B0"
	})

	minetest.register_craftitem("trinium_materials:clay", {
		description = S"Clay",
		inventory_image = "trinium_materials.clay.png"
	})

	minetest.register_craftitem("trinium_materials:rock", {
		inventory_image = "trinium_mapgen.rock.png",
		description = S"Rock",
	})

	minetest.register_craftitem("trinium_materials:stick", {
		inventory_image = "trinium_mapgen.stick.png",
		description = S"Stick",
	})
end

-- Finally, materials W/ no formula
do
	M.paper = materials.add("paper", {
		types = {"sheet"},
		color = {224, 224, 224},
		description = S"Paper",
	})

	M.carton = materials.add("carton", {
		types = {"sheet"},
		color = {160, 112, 64},
		description = S"Carton",
	})

	M.parchment = materials.add("parchment", {
		types = {"sheet"},
		color = {226, 190, 190},
		description = S"Parchment",
	})

	M.ink = materials.add("ink", {
		types = {"cell"},
		color = {0, 0, 0},
		description = S"Ink",
	})

	M.oil = materials.add("oil_raw", {
		types = {"cell"},
		color = {24, 24, 12},
		description = S"Raw Oil",
	})

	M.desulf = materials.add("oil_desulfurized", {
		types = {"cell"},
		color = {12, 12, 12},
		description = S"Desulfurized Oil",
	})

	M.frac_gas = materials.add("fraction_gas", {
		types = {"cell"},
		color = {240, 250, 250},
		description = S"Refinery Gas",
	})

	M.frac_ether = materials.add("fraction_ether", {
		types = {"cell"},
		color = {185, 220, 105},
		description = S"Petroleum Ether",
	})

	M.naphtha = materials.add("fraction_naphtha", {
		types = {"cell"},
		color = {250, 250, 80},
		description = S"Naphtha",
	})

	M.kerosene = materials.add("fraction_kerosene", {
		types = {"cell"},
		color = {250, 250, 140},
		description = S"Natural Kerosene",
	})

	M.diesel = materials.add("fraction_diesel", {
		types = {"cell"},
		color = {128, 128, 64},
		description = S"Natural Diesel",
	})

	M.mazut = materials.add("fraction_mazut", {
		types = {"cell"},
		color = {35, 30, 5},
		description = S"Mazut",
	})
end
