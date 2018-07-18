local S = default.S
local ss = trinium.sounds

-- Reflector Glass
minetest.register_node("default:reflector_glass", {
	tiles = {"default.reflector_glass.png"},
	description = S"Reflection Glass",
	drawtype = "glasslike_framed_optional",
	sunlight_propagades = true,
	paramtype = "light",
	groups = {cracky = 2},
	light_source = 7,
	sounds = ss.default_glass,
})

-- Normal Glass
minetest.register_node("default:glass", {
	tiles = {"default.glass.png"},
	description = S"Glass",
	drawtype = "glasslike",
	groups = {cracky = 3},
	sounds = ss.default_glass,
})

-- Forcillium Lamp
minetest.register_node("default:forcillium_lamp", {
	tiles = {
		{
			name = "(default.lamp_core.png^[multiply:#DCEF04)^default.lamp_frame.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 32,
				aspect_h = 32,
				length = 2.5,
			},
		}
	},
	description = S"Forcillium Lamp",
	drawtype = "glasslike",
	light_source = 14,
	groups = {cracky = 1, level = 2},
	sounds = ss.default_glass,
})
