local S = trinium.machines.S
local api = trinium.api

local types = {"rod", "plate"}
for i = 1, #types do
	local n = types[i]

	minetest.register_craftitem("trinium_machines:press_mold_" .. n, {
		description = S("Metal Press Mold - @1", S(api.string_superseparation(n))),
		inventory_image = "trinium_machines.press_mold." .. n .. ".png",
		stack_max = 1,
	})
end