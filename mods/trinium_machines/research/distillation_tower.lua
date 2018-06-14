local M = trinium.materials.materials
local research = trinium.research
local nei = trinium.nei
local S = research.S
local R = trinium.machines.recipes

research.add("OilDistillation", {
	texture = M.naphtha:get "cell",
	x = 1,
	y = 2,
	name = S "Distillation",
	chapter = "Chemistry2",
	text = {
		S [[The oxygen you added to the raw oil worked perfectly. But what is next?

You think that oil is not powerful enough until it is separated into components, which is what the distillation tower is used for. It should give a handful of each fraction on average - Refinery Gas, Petroleum Ether, Naphtha, Kerosene, Diesel and useless Mazut.

But after a slight research, you realize, that this structure actually DOUBLES the oil!]],
		{ nei.draw_research_recipe(R.oil_dist) }
	},
	requires_lens = {
		requirement = true,
		metal = "Platinum",
		gem = "Diamond",
	},
	map = {
		{ x = 2, y = 1, aspect = "canaliculus" },
		{ x = 1, y = 7, aspect = "permutatio" },
		{ x = 7, y = 2, aspect = "meridiem" },
		{ x = 5, y = 6, aspect = "potentia" },
		{ x = 3, y = 4, aspect = "aqua" },
	},
})
research.add_req("OilDistillation", "OilDesulf")