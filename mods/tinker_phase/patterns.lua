local A = tinker.add_pattern
local S = tinker.S

A("pickaxe_head", {
	description = "@1 Pickaxe Head",
	cost = 3,
	type = 1, -- Additive
})
A("axe_head", {
	description = "@1 Axe Head",
	cost = 3,
	type = 1,
})
A("shovel_head", {
	description = "@1 Shovel Head",
	cost = 2,
	type = 1,
})
A("tool_rod", {
	description = "@1 Tool Rod",
	cost = 2,
	type = 2, -- Multiplicative
})
