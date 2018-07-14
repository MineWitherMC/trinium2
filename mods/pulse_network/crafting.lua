local A = trinium.recipes.add
local M = trinium.materials.materials
local R = pulse_network.recipes
local S = pulse_network.S

minetest.register_craftitem("pulse_network:wireless_plating", {
	description = S"Wireless Plating",
	inventory_image = "pulse_network.wireless_plate.png"
})

R.wireless_plating = A("precision_assembler",
		{M.pulsating_alloy:get"plate", M.diamond:get("gem", 4), "trinium_materials:stardust 3"},
		{"pulse_network:wireless_plating"},
		{time = 80, pressure = 450, pressure_tolerance = 25, temperature = 865, temperature_tolerance = 45})
