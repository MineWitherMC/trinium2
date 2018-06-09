local materials = trinium.materials
local recipes = trinium.recipes
local S = materials.S


materials.add_type("plate", function(def)
	minetest.register_craftitem(("trinium_materials:plate_%s"):format(def.id), {
		description = S("@1 Plate", def.name)..def.formula,
		inventory_image = "(trinium_materials.plate.png^[multiply:#"..def.color..")^trinium_materials.plate.overlay.png",
	})
end)


materials.add_type("sheet", function(def)
	minetest.register_craftitem(("trinium_materials:sheet_%s"):format(def.id), {
		description = S("@1 Sheet", def.name)..def.formula,
		inventory_image = "(trinium_materials.plate.png^[multiply:#"..def.color..")^trinium_materials.plate.overlay.png",
	})
end)


materials.add_type("cell", function(def)
	minetest.register_craftitem(("trinium_materials:cell_%s"):format(def.id), {
		description = S("@1 Cell", def.name)..def.formula,
		inventory_image = "(trinium_materials.cell.png^[multiply:#"..def.color..")^trinium_materials.cell.overlay.png",
	})
end)


materials.add_type("ingot", function(def)
	minetest.register_craftitem(("trinium_materials:ingot_%s"):format(def.id), {
		description = S("@1 Ingot", def.name)..def.formula,
		inventory_image = "(trinium_materials.ingot.png^[multiply:#"..def.color..")^trinium_materials.ingot.overlay.png",
	})
end)
materials.add_combination("ingot_bending", {
	requirements = {"plate", "ingot"},
	apply = function(name, data)
		recipes.add("metal_former",
			{"trinium_materials:ingot_"..name},
			{"trinium_materials:plate_"..name},
			{["type"] = "bending"})
	end,
})


materials.add_type("gem", function(def)
	minetest.register_craftitem(("trinium_materials:gem_%s"):format(def.id), {
		description = S("@1", def.name)..def.formula,
		inventory_image = "trinium_materials.gem.png^[multiply:#"..def.color,
	})
end)
materials.add_combination("gem_ingot_transform", {
	requirements = {"gem", "ingot"},
	apply = function(name, data)
		recipes.add("molecular_reconstructor",
			{"trinium_materials:ingot_"..name.." 4"},
			{"trinium_materials:gem_"..name.." 3"},
			{["type"] = "compressing", tier = 7, base_sg_per_tick = 12})
		recipes.add("molecular_reconstructor",
			{"trinium_materials:gem_"..name.." 4"},
			{"trinium_materials:ingot_"..name.." 3"},
			{["type"] = "melting", tier = 7, base_sg_per_tick = 12})
	end,
})


materials.add_type("dust", function(def)
	minetest.register_craftitem(("trinium_materials:dust_%s"):format(def.id), {
		description = S("@1 Dust", def.name)..def.formula,
		inventory_image = "(trinium_materials.dust.png^[multiply:#"..def.color..")^trinium_materials.dust.overlay.png",
	})
end)
materials.add_combination("dust_smelting", {
	requirements = {"dust", "ingot"},
	apply = function(name, data)
		recipes.add("grinder",
			{"trinium_materials:ingot_"..name},
			{"trinium_materials:dust_"..name})
		recipes.add("blast_furnace",
			{"trinium_materials:dust_"..name},
			{"trinium_materials:ingot_"..name},
			{melting_point = data.melting_point})
	end,
})
materials.add_combination("dust_implosion", {
	requirements = {"dust", "gem"},
	apply = function(name, data)
		recipes.add("grinder",
			{"trinium_materials:gem_"..name},
			{"trinium_materials:dust_"..name})
		recipes.add("implosion",
			{"trinium_materials:dust_"..name.." 4"},
			{"trinium_materials:gem_"..name.." 3"})
	end,
})


materials.add_type("water_cell", function(def)
	minetest.register_craftitem(("trinium_materials:cell_%s"):format(def.id), {
		description = S("Water-Mixed @1", def.name)..def.formula,
		inventory_image = "(trinium_materials.cell.png^[multiply:#"..def.color..")^trinium_materials.cell.overlay.png",
	})
end)
materials.add_combination("water_mixing", {
	requirements = {"dust", "water_cell"},
	apply = function(name, data)
		recipes.add("mixer",
			{"trinium_materials:dust_"..name, "trinium_materials:cell_empty", [7] = "trinium:block_water_source"},
			{"trinium_materials:cell_"..name},
			{velocity = data.water_mix_velocity})
	end,
})


materials.add_type("rod", function(def)
	minetest.register_craftitem(("trinium_materials:rod_%s"):format(def.id), {
		description = S("@1 Rod", def.name)..def.formula,
		inventory_image = "(trinium_materials.rod.png^[multiply:#"..def.color..")^trinium_materials.rod.overlay.png",
	})
end)
materials.add_combination("gem_lathing", {
	requirements = {"rod", "gem"},
	apply = function(name, data)
		recipes.add("metal_former",
			{"trinium_materials:gem_"..name},
			{"trinium_materials:rod_"..name.." 2"},
			{["type"] = "lathing"})
	end,
})
materials.add_combination("ingot_lathing", {
	requirements = {"rod", "ingot"},
	apply = function(name, data)
		recipes.add("metal_former",
			{"trinium_materials:ingot_"..name},
			{"trinium_materials:rod_"..name.." 2"},
			{["type"] = "lathing"})
	end,
})


materials.add_type("ring", function(def)
	minetest.register_craftitem(("trinium_materials:ring_%s"):format(def.id), {
		description = S("@1 Ring", def.name)..def.formula,
		inventory_image = "(trinium_materials.ring.png^[multiply:#"..def.color..")^trinium_materials.ring.overlay.png",
	})
end)
materials.add_combination("rod_hammering", {
	requirements = {"rod", "ring"},
	apply = function(name, data)
		recipes.add("metal_former",
			{"trinium_materials:rod_"..name},
			{"trinium_materials:ring_"..name.." 2"},
			{["type"] = "hammering"})
	end,
})


materials.add_type("brick", function(def)
	minetest.register_craftitem(("trinium_materials:brick_%s"):format(def.id), {
		description = S("@1 Brick", def.name)..def.formula,
		inventory_image = "trinium_materials.ingot.png^[multiply:#"..def.color,
	})
end)
materials.add_combination("brick_compression", {
	requirements = {"dust", "brick"},
	apply = function(name, data)
		recipes.add("crude_compressor",
			{"trinium_materials:dust_"..name},
			{"trinium_materials:brick_"..name})
		recipes.add("grinder",
			{"trinium_materials:brick_"..name},
			{"trinium_materials:dust_"..name})
	end,
})


materials.add_type("ore", function(def)
	local def1 = {
		description = S("@1 Ore", def.name),
		groups = {cracky = def.data.hardness or 2},
		tiles = {"trinium_mapgen.stone.png^(trinium_materials.ore.png^[multiply:#"..def.color..")"},
		sounds = trinium.sounds.default_stone,
	}
	if table.exists(def.types, function(x) return x == "gem" end) then
		def1.drop = "trinium_materials:gem_"..def.id
	end
	minetest.register_node(("trinium_materials:ore_%s"):format(def.id), def1)
end)
materials.add_combination("ore_grinding", {
	requirements = {"ore", "dust"},
	apply = function(name, data)
		if not minetest.registered_items["trinium_materials:gem_"..name] then
			recipes.add("grinder",
				{"trinium_materials:ore_"..name},
				{"trinium_materials:dust_"..name.." 3"})
		else
			recipes.add("grinder",
				{"trinium_materials:ore_"..name},
				{"trinium_materials:dust_"..name, "trinium:gem_"..name.." 2"})
		end
	end,
})


materials.add_type("pulp", function(def)
	minetest.register_craftitem(("trinium_materials:pulp_%s"):format(def.id), {
		description = S("@1 Pulp", def.name)..def.formula,
		inventory_image = "(trinium_materials.dust.png^[multiply:#"..def.color..")^trinium_materials.dust.overlay.png",
	})
end)


materials.add_type("catalyst", function(def)
	minetest.register_craftitem(("trinium_materials:catalyst_%s"):format(def.id), {
		description = S("@1-based Catalyst", def.name)..def.formula,
		inventory_image = "trinium_materials.catalyst.png^[multiply:#"..def.color,
		groups = {chemical_reactor_catalyst = 1},
		stack_max = 1,
	})
end)


materials.add_type("foil", function(def)
	minetest.register_craftitem(("trinium_materials:foil_%s"):format(def.id), {
		description = S("@1 Foil", def.name)..def.formula,
		inventory_image = "trinium_materials.foil.png^[multiply:#"..def.color:sub(0, 6).."80",
	})
end)
materials.add_combination("plate_bending", {
	requirements = {"plate", "foil"},
	apply = function(name, data)
		recipes.add("metal_former",
			{"trinium_materials:plate_"..name},
			{"trinium_materials:foil_"..name.." 4"},
			{["type"] = "bending"})
	end,
})


materials.add_type("wire", function(def)
	minetest.register_craftitem(("trinium_materials:wire_%s"):format(def.id), {
		description = S("Fine @1 Wire", def.name)..def.formula,
		inventory_image = "(trinium_materials.wire.png^[multiply:#"..def.color..")^trinium_materials.wire.overlay.png",
	})
end)
materials.add_combination("wire_extruding", {
	requirements = {"ingot", "wire"},
	apply = function(name, data)
		recipes.add("metal_former",
			{"trinium_materials:ingot_"..name},
			{"trinium_materials:wire_"..name.." 4"},
			{["type"] = "extruding"})
	end,
})
