trinium.sounds = {}
local sounds = trinium.sounds
local api = trinium.api

sounds.default = {
	footstep = {name = "", gain = 1.0},
	dug = {name = "trinium.dug_node", gain = 0.25},
	place = {name = "trinium.place_node_hard", gain = 1.0},
}

sounds.default_stone = api.set_defaults({
	footstep = {name = "trinium.hard_footstep", gain = 0.3},
	dug = {name = "trinium.hard_footstep", gain = 1.0},
}, sounds.default)

sounds.default_dirt = api.set_defaults({
	footstep = {name = "trinium.dirt_footstep", gain = 0.4},
	dug = {name = "trinium.dirt_footstep", gain = 1.0},
	place = {name = "trinium.place_node_soft", gain = 1.0},
}, sounds.default)

sounds.default_sand = api.set_defaults({
	footstep = {name = "trinium.sand_footstep", gain = 0.12},
	dug = {name = "trinium.sand_footstep", gain = 0.24},
	place = {name = "trinium.place_node_soft", gain = 1.0},
}, sounds.default)

sounds.default_gravel = api.set_defaults({
	footstep = {name = "trinium.gravel_footstep", gain = 0.4},
	dug = {name = "trinium.gravel_footstep", gain = 1.0},
	place = {name = "trinium.place_node_soft", gain = 1.0},
}, sounds.default)

sounds.default_wood = api.set_defaults({
	footstep = {name = "trinium.wood_footstep", gain = 0.3},
	dug = {name = "trinium.wood_footstep", gain = 1.0},
}, sounds.default)

sounds.default_leaves = api.set_defaults({
	footstep = {name = "trinium.grass_footstep", gain = 0.45},
	dug = {name = "trinium.grass_footstep", gain = 0.7},
	place = {name = "trinium.place_node_soft", gain = 1.0},
}, sounds.default)

sounds.default_glass = api.set_defaults({
	footstep = {name = "trinium.glass_footstep", gain = 0.3},
	dig = {name = "trinium.glass_footstep", gain = 0.5},
	dug = {name = "trinium.glass_broken", gain = 1.0},
}, sounds.default)

sounds.default_water = api.set_defaults({
	footstep = {name = "trinium.water_footstep", gain = 0.2},
}, sounds.default)

sounds.default_metal = api.set_defaults({
	footstep = {name = "trinium.metal_footstep", gain = 0.4},
	dig = {name = "trinium.metal_digging", gain = 0.5},
	dug = {name = "trinium.metal_broken", gain = 0.5},
	place = {name = "trinium.metal_placed", gain = 0.5},
}, sounds.default)

sounds.default_snow = api.set_defaults({
	footstep = {name = "trinium.snow_footstep", gain = 0.2},
	dig = {name = "trinium.snow_footstep", gain = 0.3},
	dug = {name = "trinium.snow_footstep", gain = 0.3},
	place = {name = "trinium.place_node_soft", gain = 1.0},
}, sounds.default)
