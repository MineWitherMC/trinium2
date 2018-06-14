trinium.default = {}
local default = trinium.default
default.S = minetest.get_translator "trinium_default"
local S = default.S
local ss = trinium.sounds

-- Reflector Glass
minetest.register_node("trinium_default:reflector_glass", {
	tiles = {"trinium_default.reflector_glass.png"},
	description = S"Reflection Glass",
	drawtype = "glasslike_framed_optional",
	sunlight_propagades = true,
	paramtype = "light",
	groups = {cracky = 2},
	light_source = 7,
	sounds = ss.default_glass,
})

-- Lamp Frame
minetest.register_node("trinium_default:lamp_frame", {
	tiles = {"trinium_default.lamp_frame_single.png"},
	description = S"Advanced Lamp Frame",
	drawtype = "glasslike",
	groups = {cracky = 3},
	sounds = ss.default_glass,
})

-- Forcillium Lamp
minetest.register_node("trinium_default:forcillium_lamp", {
	tiles = {
		{
			name = "(trinium_default.lamp_core.png^[colorize:#DCEF04C0)^trinium_default.lamp_frame.png",
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

trinium.api.send_init_signal()
