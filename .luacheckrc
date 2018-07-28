-- allow_defined_top = true

read_globals = {
	"DIR_DELIM",
	"minetest", "core", "vector",
	"dump", "dump2", "unpack", "setfenv", "loadstring",
	"VoxelManip", "VoxelArea", "PerlinNoiseMap", "PseudoRandom", "PcgRandom", "ItemStack", "Settings", "Raycast",
	
	table = { 
		fields = {
			"copy", "insert_all", "sign",
			"count", "filter", "exists", "every", "walk", "iwalk", "map", "keys", "asort", "remap", "sum",
			"f_concat", "tail", "multi_tail", "random", "merge"
		}
	},
	math = {
		fields = {
			"hypot",
			"ln2",
			"modulate", "harmonic_distribution", "gaussian", "weighted_random", "weighted_avg", "geometrical_avg",
			"roman_number", "table_multiply", "gcd", "round"
		}
	},
	string = {
		fields = {
			"split", "trim",
			"data", "from_table"
		}
	}
}

globals = {
	"trinium", "api",
	"conduits",
	"pulse_network",
	"cmsg",
	"tinker",
	"betterinv"
}

files["mods/trinium_api/code/math.lua"].globals = {"math"}
files["mods/trinium_inventory/betterinv/init.lua"].globals = {"sfinv"}
files["mods/default/*"].globals = {"LIGHT_MAX", "screwdriver", "farming", "default"}
files["mods/trinium_api/code/stdlib.lua"].globals = {"table", "vector", "string"}
files["mods/trinium_player/creative.lua"].globals = {"minetest"}
files["mods/default/code/random_compat.lua"].globals = {"minetest"}
files["mods/trinium_machines/research/*"].max_line_length = false