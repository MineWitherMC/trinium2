local A = tinker.add_tool
local P = tinker.patterns
local S = tinker.S

A("pickaxe", {
	times = {cracky = 1},
	durability_mult = 1,
	components = {P.pickaxe_head, P.tool_rod},
	level_boost = 0,

	update_description = function(stack)
		local meta = stack:get_meta()
		return tinker.wrap_description(1, {
			current_durability = meta:get_int"current_durability",
			max_durability = meta:get_int"max_durability",
			base = S("@1 Pickaxe", meta:get_string"material_name"),
			modifiers = meta:get_string"modifiers":data()
		})
	end,
})

A("hatchet", {
	times = {choppy = 1},
	durability_mult = 1,
	components = {P.axe_head, P.tool_rod},
	level_boost = 0,

	update_description = function(stack)
		local meta = stack:get_meta()
		return tinker.wrap_description(1, {
			current_durability = meta:get_int"current_durability",
			max_durability = meta:get_int"max_durability",
			base = S("@1 Hatchet", meta:get_string"material_name"),
			modifiers = meta:get_string"modifiers":data()
		})
	end,
})

A("spade", {
	times = {crumbly = 1},
	durability_mult = 1,
	components = {P.shovel_head, P.tool_rod},
	level_boost = 0,

	update_description = function(stack)
		local meta = stack:get_meta()
		return tinker.wrap_description(1, {
			current_durability = meta:get_int"current_durability",
			max_durability = meta:get_int"max_durability",
			base = S("@1 Shovel", meta:get_string"material_name"),
			modifiers = meta:get_string"modifiers":data()
		})
	end,
})
