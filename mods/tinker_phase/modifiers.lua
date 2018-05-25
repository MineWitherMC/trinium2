local A = tinker.add_modifier
local S = tinker.S

A("dense", {
	description = minetest.colorize("#CC7500", S"Dense"),
	incompat = {"reinforced"},
	after_use = function(itemstack, v, pos)
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
	after_use = function(itemstack, v, pos)
		local meta = itemstack:get_meta()
		if math.random() < v * 0.1 then
			meta:set_int("current_durability", meta:get_int"current_durability" + 1)
		end
	end,
})

A("active", {
	description = minetest.colorize("#FFDD00", S"Active"),
	incompat = {},
	--[[after_use = function(itemstack, v, pos)
		local pos1 = vector.add(pos, {x = 0, y = -1, z = 0})
		if math.random() < v * 0.05 and minetest.get_node(pos1).name == "trinium_mapgen:sand" then
			minetest.set_node(pos1, "trinium_default:reflection_glass")
		end
	end,]]--
})
