local M = trinium.materials.materials
local research = trinium.research
local nei = trinium.nei
local S = research.S
local R = trinium.machines.recipes

research.add("OilDesulf", {
	texture = M.desulf:get"cell",
	x = 0,
	y = 0,
	name = S"Desulfurization",
	chapter = "Chemistry2",
	text = {
		S[[You found some interesting dark brown liquid a long time ago. It looked like it contained a lot of power at the beginning, but it was poisonous and power couldn't be used due to this.

But you've just discovered the way to purify it from useless and dangerous brimstone hydride. You think it is possible to capture it using oxygen, which should burn the former, resulting in pure brimstone if temperature is low enough, which will then precitipate...]],
		{nei.draw_recipe_raw(R.desulf)},
		research.label_escape(
				S[[You think that for oil researches a diamond lens will be useful - no material has such complicated carbon structure...

Also, platinum will work, too. A very inert metal, probably a good catalyst, definitely good for holding active materials, you realise you'll need it too.]],
				S"Further Oil Researching", {ratus = 8, manifestatio = 11, consequat = 5})
	},
	map = {
		{x = 2, y = 1, aspect = "instrumentum"},
		{x = 1, y = 7, aspect = "ratus"},
		{x = 7, y = 2, aspect = "potentia"},
		{x = 5, y = 6, aspect = "terra"},
	},
})

research.add("SteamCracking", {
	texture = M.propene:get"cell",
	x = 1,
	y = 4,
	name = S"Steam Cracking",
	chapter = "Chemistry2",
	text = {
		S[[Usage of the lighter fractions - Refinery Gas, Petroleum Ether, and probably Naphtha - is difficult because they hold little to no energy, and cannot be used to create anything else.

However, it only looks like that on first glance. You managed to find a way to heat these fluids to incredible temperature of almost 1200 Kelvins with steam, separating them into compounds and extracting hydrogen from those in process, only leaving precious unsaturated hydrocarbons!

Unfortunately, the hydrogen is lost in process, however, this is already a huge jump forward!]],
		{nei.draw_recipe_raw(R.sc_gas)},
		{nei.draw_recipe_raw(R.sc_ether)},
		{nei.draw_recipe_raw(R.sc_naphtha)},
	},
	requires_lens = {
		requirement = true,
		metal = "Platinum",
		gem = "Diamond",
	},
	map = {
		{x = 2, y = 1, aspect = "ordinatio"},
		{x = 1, y = 7, aspect = "potentia"},
		{x = 7, y = 2, aspect = "ignis"},
		{x = 5, y = 6, aspect = "ratus"},
		{x = 3, y = 4, aspect = "aqua"},
	},
})
research.add_req("SteamCracking", "OilDistillation")

research.add("HydrogenCracking", {
	texture = M.xylene:get"cell",
	x = 3,
	y = 1,
	name = S"Hydro-Cracking",
	chapter = "Chemistry2",
	text = {
		S[[After using Oil for a bit, you realized that even distillation tower doesn't give enough products to get enough fuel using a single Pumpjack, and started finding alternate ways to process this precious hydrocarbon mix.

And several sleepless nights were worth it. You found a way to hydrate most fractions at very high temperatures, leaving mostly saturated hydrocarbons, which are an excellent choice to be used as fuel! Furthermore, oil seems to be multiplied again!

This project will definitely solve your fueling issues.]],
		{nei.draw_recipe_raw(R.hc_gas)},
		{nei.draw_recipe_raw(R.hc_ether)},
		{nei.draw_recipe_raw(R.hc_naphtha)},
		{nei.draw_recipe_raw(R.hc_kerosene)},
		{nei.draw_recipe_raw(R.hc_diesel)},
	},
	requires_lens = {
		requirement = true,
		metal = "Platinum",
		gem = "Diamond",
	},
	map = {
		{x = 2, y = 1, aspect = "interitum"},
		{x = 1, y = 7, aspect = "potentia"},
		{x = 7, y = 2, aspect = "ignis"},
		{x = 5, y = 6, aspect = "ratus"},
		{x = 3, y = 4, aspect = "tempestas"},
	},
})
research.add_req("HydrogenCracking", "OilDistillation")

research.add("HydrocarbonDehydration", {
	texture = M.butadiene:get"cell",
	x = 5,
	y = 2,
	name = S"Hydrocarbon Dehydration",
	chapter = "Chemistry2",
	text = {
		S[[Some of the hydrocarbons you obtained from cracking are useful, for instance, octane and toluene. They both can be used in creation of a very strong fuel, premium gasoline, even stronger than natural diesel. Furthermore, former probably can be used to create some kind of explosives.

But what can be done with, e.g., butane, absolutely useless gas, obtained in huge quantities when hydro-cracking Naphtha?..

You found an answer. It can be cracked with usage of steam and high temperature to form butadiene, which is definitely useful.]],
		{nei.draw_recipe_raw(R.butane_cracking)},
		{w = 8, h = 8, name = "Styrene Production",
		  requirements = {Ethylbenzene = 1}, locked = true,
		  required_aspects = {potentia = 12, interitum = 15, aqua = 18, sententia = 24, ratus = 21},
		  text = S[[After some more researching, you found a similar way to produce Styrene.]]},
		{nei.draw_recipe_raw(R.styrene), w = 8, h = 8, name = "Styrene Production",
		  requirements = {["HydrocarbonDehydration-3"] = 1}},
	},
	requires_lens = {
		requirement = true,
		metal = "Platinum",
		gem = "Diamond",
	},
	map = {
		{x = 2, y = 1, aspect = "interitum"},
		{x = 1, y = 7, aspect = "motus"},
		{x = 7, y = 2, aspect = "ignis"},
		{x = 5, y = 6, aspect = "instrumentum"},
		{x = 3, y = 4, aspect = "potentia"},
	},
})
research.add_req("HydrocarbonDehydration", "HydrogenCracking")

research.add("Ethylbenzene", {
	texture = M.ethylbenzene:get"cell",
	x = 3,
	y = 3,
	name = S"Ethylbenzene Production",
	chapter = "Chemistry2",
	text = {
		S[[(WIP Text)]],
		{nei.draw_recipe_raw(R.ethylbenzene)},
	},
	requires_lens = {
		requirement = true,
		metal = "Platinum",
		gem = "Diamond",
	},
	map = {
		{x = 2, y = 1, aspect = "permutatio"},
		{x = 1, y = 7, aspect = "ordinatio"},
		{x = 7, y = 2, aspect = "potentia"},
		{x = 5, y = 6, aspect = "venenum"},
		{x = 3, y = 4, aspect = "sententia"},
	},
})
research.add_req("Ethylbenzene", "SteamCracking")
research.add_req("Ethylbenzene", "HydrogenCracking")

research.add("Ammonia", {
	texture = M.ammonia:get"cell",
	x = 3,
	y = 8,
	name = S"Ammonia from Air",
	chapter = "Chemistry2",
	text = {
		S[[You were tired of using Nitrate ores whenever you need Nitrogen, because they're rare and mostly used up so you just had a handful of them.

You suddenly found a way to break the Nitrogen triple bond, giving you the unique possibility to extract Nitrogen out of air! This sounds very cheap and useful, and you hope you'll find more uses for resulting material, Ammonia... However, it requires very high pressures, very high temperature, etcetera, however, it doesn't stop you...]],
		{nei.draw_recipe_raw(R.ammonia)},
	},
	requires_lens = {
		requirement = true,
		metal = "Osmium",
		gem = "Diamond",
	},
	map = {
		{x = 7, y = 7, aspect = "venenum"},
		{x = 4, y = 1, aspect = "vita"},
		{x = 1, y = 7, aspect = "meridiem"},
	},
	warp = 2,
})

research.add("Acrylonitrile", {
	texture = M.acrylonitrile:get"cell",
	x = 3,
	y = 5,
	name = S"Acrylonitrile",
	chapter = "Chemistry2",
	text = {
		S[[(WIP Text)]],
		{nei.draw_recipe_raw(R.acrylonitrile)},
	},
	requires_lens = {
		requirement = true,
		metal = "Bismuth",
		gem = "Diamond",
	},
	map = {
		{x = 2, y = 1, aspect = "permutatio"},
		{x = 1, y = 7, aspect = "venenum"},
		{x = 7, y = 2, aspect = "firmitatem"},
		{x = 5, y = 6, aspect = "vita"},
		{x = 3, y = 4, aspect = "vinculum"},
	},
})
research.add_req("Acrylonitrile", "SteamCracking")
research.add_req("Acrylonitrile", "Ammonia")

research.add("ABS", {
	texture = M.abs:get"ingot",
	x = 5,
	y = 4,
	name = S"Nitrile-Butadiene-Styrene Polymer",
	chapter = "Chemistry2",
	text = {
		S[["I've suddenly found the ideal proportions for this reaction... X of acrylonitrile, Y of butadiene and a lot of styrene..." - it is a page from an old diary of some chemist. Nothing more was saved from the destructive nature of world. Yeah, X and Y weren't saved, too.

But it was enough for you, and after some trial and error you found these proportions.

It is 8 parts of styrene, 4 parts of butadiene and 5 parts of acrylonitrile.

This compound will definitely be very useful in your further progressions.]],
		--{nei.draw_research_recipe(R.abs)},
	},
	requires_lens = {
		requirement = true,
		band_material = "Platinum",
		core = "Diamond",
	},
	map = {
		{x = 2, y = 1, aspect = "metallicum"},
		{x = 7, y = 2, aspect = "speculum"},
		{x = 6, y = 7, aspect = "sententia"},
		{x = 1, y = 6, aspect = "ratus"},
		{x = 4, y = 4, aspect = "firmitatem"},
	},
	important = 1,
})
research.add_req("ABS", "Acrylonitrile")
research.add_req("ABS", "HydrocarbonDehydration-3")
research.add_req("ABS", "HydrocarbonDehydration")
research.add_req("ABS", "Ethylbenzene")