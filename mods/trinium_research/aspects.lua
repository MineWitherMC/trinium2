local research = trinium.research
local S = research.S

-- Tier 0
research.add_aspect("aer", {
	texture = "aspect_aer.png",
	name = "Aer\n" .. S "Air",
})
research.add_aspect("aqua", {
	texture = "aspect_aqua.png",
	name = "Aqua\n" .. S "Water",
})
research.add_aspect("ignis", {
	texture = "aspect_ignis.png",
	name = "Ignis\n" .. S "Fire",
})
research.add_aspect("terra", {
	texture = "aspect_terra.png",
	name = "Terra\n" .. S "Earth",
})

-- Tier 1
research.add_aspect("interitum", {
	texture = "aspect_interitum.png",
	name = "Interitum\n" .. S "Entropy",
	req1 = "ignis",
	req2 = "terra",
})
research.add_aspect("lux", {
	texture = "aspect_lux.png",
	name = "Lux\n" .. S "Light",
	req1 = "ignis",
	req2 = "aer",
})
research.add_aspect("motus", {
	texture = "aspect_motus.png",
	name = "Motus\n" .. S "Motion",
	req1 = "terra",
	req2 = "aer",
})
research.add_aspect("ordinatio", {
	texture = "aspect_ordinatio.png",
	name = "Ordinatio\n" .. S "Order",
	req1 = "ignis",
	req2 = "aqua",
})
research.add_aspect("tempestas", {
	texture = "aspect_tempestas.png",
	name = "Tempestas\n" .. S "Weather",
	req1 = "aer",
	req2 = "aqua",
})
research.add_aspect("vita", {
	texture = "aspect_vita.png",
	name = "Vita\n" .. S "Life",
	req1 = "aqua",
	req2 = "terra",
})

-- Tier 2
research.add_aspect("alienis", {
	texture = "aspect_alienis.png",
	name = "Alienis\n" .. S "The Strange",
	req1 = "interitum",
	req2 = "ordinatio",
})
research.add_aspect("celeritas", {
	texture = "aspect_celeritas.png",
	name = "Celeritas\n" .. S "Flight",
	req1 = "motus",
	req2 = "tempestas",
})
research.add_aspect("instrumentum", {
	texture = "aspect_instrumentum.png",
	name = "Instrumentum\n" .. S "Tool",
	req1 = "ordinatio",
	req2 = "motus",
})
research.add_aspect("potentia", {
	texture = "aspect_potentia.png",
	name = "Potentia\n" .. S "Power",
	req1 = "motus",
	req2 = "lux",
})
research.add_aspect("speculum", {
	texture = "aspect_speculum.png",
	name = "Speculum\n" .. S "Crystal",
	req1 = "terra",
	req2 = "ordinatio",
})
research.add_aspect("venenum", {
	texture = "aspect_venenum.png",
	name = "Venenum\n" .. S "Poison",
	req1 = "aqua",
	req2 = "interitum",
})

-- Tier 3
research.add_aspect("firmitatem", {
	texture = "aspect_firmitatem.png",
	name = "Firmitatem\n" .. S "Stability",
	req1 = "terra",
	req2 = "alienis",
})
research.add_aspect("iter", {
	texture = "aspect_iter.png",
	name = "Iter\n" .. S "Travel",
	req1 = "celeritas",
	req2 = "ordinatio",
})
research.add_aspect("meridiem", {
	texture = "aspect_meridiem.png",
	name = "Meridiem\n" .. S "Radiance",
	req1 = "alienis",
	req2 = "lux",
})
research.add_aspect("permutatio", {
	texture = "aspect_permutatio.png",
	name = "Permutatio\n" .. S "Exchange",
	req1 = "alienis",
	req2 = "potentia",
})
research.add_aspect("populus", {
	texture = "aspect_populus.png",
	name = "Populus\n" .. S "Man",
	req1 = "instrumentum",
	req2 = "vita",
})
research.add_aspect("vinculum", {
	texture = "aspect_vinculum.png",
	name = "Vinculum\n" .. S "Trap",
	req1 = "celeritas",
	req2 = "interitum",
})

-- Tier 4
research.add_aspect("caelesta", {
	texture = "aspect_caelesta.png",
	name = "Caelesta\n" .. S "Sky",
	req1 = "aer",
	req2 = "firmitatem",
})
research.add_aspect("canaliculus", {
	texture = "aspect_canaliculus.png",
	name = "Canaliculus\n" .. S "Mechanism",
	req1 = "permutatio",
	req2 = "instrumentum",
})
research.add_aspect("consequat", {
	texture = "aspect_consequat.png",
	name = "Consequat\n" .. S "Craft",
	req1 = "populus",
	req2 = "instrumentum",
})
research.add_aspect("damnum", {
	texture = "aspect_damnum.png",
	name = "Damnum\n" .. S "Weapon",
	req1 = "firmitatem",
	req2 = "interitum",
})
research.add_aspect("herba", {
	texture = "aspect_herba.png",
	name = "Herba\n" .. S "Plant",
	req1 = "vinculum",
	req2 = "vita",
})
research.add_aspect("metallicum", {
	texture = "aspect_metallicum.png",
	name = "Metallicum\n" .. S "Metal",
	req1 = "speculum",
	req2 = "firmitatem",
})
research.add_aspect("sententia", {
	texture = "aspect_sententia.png",
	name = "Sententia\n" .. S "Sense",
	req1 = "populus",
	req2 = "tempestas",
})
research.add_aspect("tempus", {
	texture = "aspect_tempus.png",
	name = "Tempus\n" .. S "Time",
	req1 = "vinculum",
	req2 = "celeritas",
})

-- Tier 5
research.add_aspect("arbor", {
	texture = "aspect_arbor.png",
	name = "Arbor\n" .. S "Tree",
	req1 = "herba",
	req2 = "firmitatem",
})
research.add_aspect("ratus", {
	texture = "aspect_ratus.png",
	name = "Ratus\n" .. S "Cognition",
	req1 = "sententia",
	req2 = "permutatio",
})
research.add_aspect("spiritus", {
	texture = "aspect_spiritus.png",
	name = "Spiritus\n" .. S "Spirit",
	req1 = "vita",
	req2 = "ratus",
})
research.add_aspect("stella", {
	texture = "aspect_stella.png",
	name = "Stella\n" .. S "Star",
	req1 = "meridiem",
	req2 = "caelesta",
})

-- Tier 6
research.add_aspect("manifestatio", {
	texture = "aspect_manifestatio.png",
	name = "Manifestatio\n" .. S "Detection",
	req1 = "speculum",
	req2 = "ratus",
})
research.add_aspect("origo", {
	texture = "aspect_origo.png",
	name = "Origo\n" .. S "Animation",
	req1 = "spiritus",
	req2 = "canaliculus",
})