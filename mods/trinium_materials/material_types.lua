local materials = trinium.materials
local recipes = trinium.recipes
local S = materials.S

materials.add_type("plate", function(def)
	minetest.register_craftitem(("trinium_materials:plate_%s"):format(def.id), {
		description = S("@1 Plate", def.name) .. def.formula,
		inventory_image = "(trinium_materials.plate.png^[multiply:#" .. def.color .. ")^trinium_materials.plate.overlay.png",
	})
end)

materials.add_type("sheet", function(def)
	minetest.register_craftitem(("trinium_materials:sheet_%s"):format(def.id), {
		description = S("@1 Sheet", def.name) .. def.formula,
		inventory_image = "(trinium_materials.plate.png^[multiply:#" .. def.color .. ")^trinium_materials.plate.overlay.png",
	})
end)

materials.add_type("cell", function(def)
	minetest.register_craftitem(("trinium_materials:cell_%s"):format(def.id), {
		description = S("@1 Cell", def.name) .. def.formula,
		inventory_image = "(trinium_materials.cell.png^[multiply:#" .. def.color .. ")^trinium_materials.cell.overlay.png",
	})
end)

materials.add_type("ingot", function(def)
	minetest.register_craftitem(("trinium_materials:ingot_%s"):format(def.id), {
		description = S("@1 Ingot", def.name) .. def.formula,
		inventory_image = "(trinium_materials.ingot.png^[multiply:#" .. def.color .. ")^trinium_materials.ingot.overlay.png",
	})
end)

materials.add_type("gem", function(def)
	minetest.register_craftitem(("trinium_materials:gem_%s"):format(def.id), {
		description = S("@1", def.name) .. def.formula,
		inventory_image = "trinium_materials.gem.png^[multiply:#" .. def.color,
	})
end)

materials.add_type("dust", function(def)
	minetest.register_craftitem(("trinium_materials:dust_%s"):format(def.id), {
		description = S("@1 Dust", def.name) .. def.formula,
		inventory_image = "(trinium_materials.dust.png^[multiply:#" .. def.color .. ")^trinium_materials.dust.overlay.png",
	})
end)

materials.add_type("water_cell", function(def)
	minetest.register_craftitem(("trinium_materials:cell_%s"):format(def.id), {
		description = S("Water-Mixed @1", def.name) .. def.formula,
		inventory_image = "(trinium_materials.cell.png^[multiply:#" .. def.color .. ")^trinium_materials.cell.overlay.png",
	})
end)

materials.add_type("rod", function(def)
	minetest.register_craftitem(("trinium_materials:rod_%s"):format(def.id), {
		description = S("@1 Rod", def.name) .. def.formula,
		inventory_image = "(trinium_materials.rod.png^[multiply:#" .. def.color .. ")^trinium_materials.rod.overlay.png",
	})
end)

materials.add_type("brick", function(def)
	minetest.register_craftitem(("trinium_materials:brick_%s"):format(def.id), {
		description = S("@1 Brick", def.name) .. def.formula,
		inventory_image = "trinium_materials.ingot.png^[multiply:#" .. def.color,
	})
end)

materials.add_type("ore", function(def)
	local def1 = {
		description = S("@1 Ore", def.name),
		groups = {cracky = def.data.hardness or 2},
		tiles = {"trinium_mapgen.stone.png^(trinium_materials.ore.png^[multiply:#" .. def.color .. ")"},
		sounds = trinium.sounds.default_stone,
	}
	if table.exists(def.types, function(x) return x == "gem" end) then
		def1.drop = "trinium_materials:gem_" .. def.id
	end
	minetest.register_node(("trinium_materials:ore_%s"):format(def.id), def1)
end)

materials.add_type("pulp", function(def)
	minetest.register_craftitem(("trinium_materials:pulp_%s"):format(def.id), {
		description = S("@1 Pulp", def.name) .. def.formula,
		inventory_image = "(trinium_materials.dust.png^[multiply:#" .. def.color .. ")^trinium_materials.dust.overlay.png",
	})
end)

materials.add_type("catalyst", function(def)
	minetest.register_craftitem(("trinium_materials:catalyst_%s"):format(def.id), {
		description = S("@1-based Catalyst", def.name) .. def.formula,
		inventory_image = "trinium_materials.catalyst.png^[multiply:#" .. def.color,
		groups = {chemical_reactor_catalyst = 1},
		stack_max = 1,
	})
end)
