local A = tinker.add_modifier
local S = tinker.S

A("dense", {
	description = minetest.colorize("#CC7500", S"Dense"),
	incompat = {"reinforced"},
	after_use = function(player, itemstack, v, node)
		local meta = itemstack:get_meta()
		local durability, max_durability = meta:get_int"current_durability", meta:get_int"max_durability"
		local tolerance = v * (1 - durability / max_durability) * 0.15
		if math.random() < tolerance then
			meta:set_int("current_durability", durability + 1)
		end
	end,
})

A("reinforced", {
	description = minetest.colorize("#363636", S"Reinforced"),
	incompat = {"dense"},
	after_use = function(player, itemstack, v, node)
		local meta = itemstack:get_meta()
		if math.random() < v * 0.1 then
			meta:set_int("current_durability", meta:get_int"current_durability" + 1)
		end
	end,
})
