local mat = trinium.materials
local recipes = trinium.recipes
mat.add_recipe_generator("alloysmelting_tower", function(name)
	local formula = mat.materials_reg[name].formula
	local inputs = {}
	local count = 0
	local melting = -1
	for i = 1, #formula do
		local x
		if table.exists(mat.materials_reg[formula[i][1]].types, function(v) return v == "ingot" end) then
			x = "trinium_materials:ingot_"..mat.materials_reg[formula[i][1]].id
			count = count + formula[i][2]
		elseif table.exists(mat.materials_reg[formula[i][1]].types, function(v) return v == "brick" end) then
			x = "trinium_materials:brick_"..mat.materials_reg[formula[i][1]].id
			count = count + formula[i][2]
		else
			x = "trinium_materials:dust_"..mat.materials_reg[formula[i][1]].id
		end
		if formula[i][2] > 1 then
			x = x.." "..formula[i][2]
		end
		inputs[#inputs + 1] = x

		if mat.materials_reg[formula[i][1]].data.melting_point and
				mat.materials_reg[formula[i][1]].data.melting_point > melting then
			melting = mat.materials_reg[formula[i][1]].data.melting_point
		end
	end
	melting = math.ceil(melting / 50) * 50

	recipes.add("alloysmelting_tower",
		inputs,
		{"trinium_materials:ingot_"..name.." "..count},
		{temperature = melting})
end)

mat.add_data_generator("melting_point", function(name)
	local formula = mat.materials_reg[name].formula
	formula = table.map(formula, function(v)
		return {mat.materials_reg[v[1]].data.melting_point, v[2]}
	end)
	return math.floor(0.5 + math.weighted_avg(formula))
end)

mat.add_recipe_generator("crude_alloyer", function(name)
	local formula = mat.materials_reg[name].formula
	assert(#formula <= 2, "Cannot register crude_alloyer for "..name)

	local inputs = {}
	local count = 0
	for i = 1, #formula do
		local x
		if table.exists(mat.materials_reg[formula[i][1]].types, function(v) return v == "ingot" end) then
			x = "trinium_materials:ingot_"..mat.materials_reg[formula[i][1]].id
			count = count + formula[i][2]
		elseif table.exists(mat.materials_reg[formula[i][1]].types, function(v) return v == "brick" end) then
			x = "trinium_materials:brick_"..mat.materials_reg[formula[i][1]].id
			count = count + formula[i][2]
		else
			x = "trinium_materials:dust_"..mat.materials_reg[formula[i][1]].id
		end
		if formula[i][2] > 1 then
			x = x.." "..formula[i][2]
		end
		inputs[#inputs + 1] = x
	end

	recipes.add("crude_alloyer",
		inputs,
		{"trinium_materials:ingot_"..name.." "..count})
end)
