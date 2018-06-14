local A = tinker.add_system_material
local M = trinium.materials.materials
local S = trinium.materials.S

A(M.iron, {
	base_durability = 275,
	base_speed = 6,
	level = 2,
	rod_durability = 1.25,
	traits = {magnetic = 1},
	description = S"Iron",
})

A(M.bronze, {
	base_durability = 200,
	base_speed = 5.5,
	level = 1,
	rod_durability = 1.4,
	traits = {dense = 1},
	description = S"Bronze",
})

A(M.titanium, {
	base_durability = 700,
	base_speed = 9.6,
	level = 3,
	rod_durability = 1.85,
	traits = {active = 1, reinforced = 1},
	description = S"Titanium",
})

A(M.rhenium_alloy, {
	base_durability = 1450,
	base_speed = 7.6,
	level = 2,
	rod_durability = 0.45,
	traits = {reinforced = 1},
	description = S"Rhenium Alloy",
})

A(M.forcillium, {
	base_durability = 180,
	base_speed = 14,
	level = 1,
	rod_durability = 6,
	traits = {active = 2, electric = 1},
	description = S"Forcillium",
})

A(M.imbued_forcillium, {
	base_durability = 280,
	base_speed = 17,
	level = 3,
	rod_durability = 5,
	traits = {active = 2, electric = 2},
	description = S"Imbued Forcillium",
})

A(M.endium, {
	base_durability = 600,
	base_speed = 10,
	level = 2,
	rod_durability = 1.8,
	traits = {alien = 1},
	description = S"Endium",
})
