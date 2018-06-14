local research = trinium.research

--[[ Lens ]]--
research.register_lens_shape("hexagon", 1)
research.register_lens_shape("square", 1)
research.register_lens_shape("diamond", 1)
research.register_lens_shape("triangle", 1)
research.register_lens_shape("circle", 2)
research.register_lens_shape("pentagon", 2)
research.register_lens_shape("star_hexagon", 2)
research.register_lens_shape("octagon", 2)
research.register_lens_shape("heptagon", 3)
research.register_lens_shape("reuleaux_triangle", 3)

research.register_lens_gem("Forcillium", "trinium_materials:gem_forcillium")
research.register_lens_gem("ImbuedForcillium", "trinium_materials:gem_imbued_forcillium")
research.register_lens_gem("Diamond", "trinium_materials:gem_diamond")

research.register_lens_metal("Forcillium", "trinium_materials:ingot_forcillium")
research.register_lens_metal("TiRe", "trinium_materials:ingot_rhenium_alloy")
research.register_lens_metal("Platinum", "trinium_materials:ingot_platinum")
research.register_lens_metal("Bismuth", "trinium_materials:ingot_bismuth")
research.register_lens_metal("Osmium", "trinium_materials:ingot_osmium")
