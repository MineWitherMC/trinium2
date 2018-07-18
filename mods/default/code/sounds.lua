local sounds = trinium.sounds
local api = trinium.api

local function getter(tbl)
	return function(tbl2)
		return api.set_defaults(tbl2, tbl)
	end
end

default.node_sound_defaults = getter(sounds.default)
default.node_sound_stone_defaults = getter(sounds.default_stone)
default.node_sound_dirt_defaults = getter(sounds.default_dirt)
default.node_sound_sand_defaults = getter(sounds.default_sand)
default.node_sound_gravel_defaults = getter(sounds.default_gravel)
default.node_sound_wood_defaults = getter(sounds.default_wood)
default.node_sound_leaves_defaults = getter(sounds.default_leaves)
default.node_sound_glass_defaults = getter(sounds.default_glass)
default.node_sound_metal_defaults = getter(sounds.default_metal)
default.node_sound_water_defaults = getter(sounds.default_water)
default.node_sound_snow_defaults = getter(sounds.default_snow)