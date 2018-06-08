local mat = trinium.materials
local recipes = trinium.recipes
local api = trinium.api

mat.add_recipe_generator("alloysmelting_tower", function(self)
	local name = self.name
	local formula = mat.materials_reg[name].formula
	local inputs = {}
	local count = 0
	local melting = -1
	for i = 1, #formula do
		local x = mat.getter(formula[i][1], "ingot", formula[i][2])
		if not x then
			x = mat.getter(formula[i][1], "brick", formula[i][2])
		end
		if not x then
			x = mat.getter(formula[i][1], "dust", formula[i][2])
		end

		inputs[#inputs + 1] = x

		if mat.materials_reg[formula[i][1]].data.melting_point and
				mat.materials_reg[formula[i][1]].data.melting_point > melting then
			melting = mat.materials_reg[formula[i][1]].data.melting_point
		end
	end
	melting = math.ceil(melting / 50) * 50

	--[[recipes.add("alloysmelting_tower",
		inputs,
		{self:get("ingot", count)},
		{temperature = melting})]]
end)

mat.add_data_generator("melting_point", function(name)
	local formula = mat.materials_reg[name].formula
	formula = table.map(formula, function(v)
		return {mat.materials_reg[v[1]].data.melting_point, v[2]}
	end)
	return math.floor(0.5 + math.weighted_avg(formula))
end)

mat.add_recipe_generator("crude_alloyer", function(self)
	local name = self.name
	local formula = mat.materials_reg[name].formula
	assert(#formula == 2, "Cannot register crude_alloyer for "..name)

	local inputs = {}
	local count = 0
	for i = 1, #formula do
		local x = mat.getter(formula[i][1], "ingot", formula[i][2])
		if not x then
			x = mat.getter(formula[i][1], "brick", formula[i][2])
		end
		if not x then
			x = mat.getter(formula[i][1], "dust", formula[i][2])
		end
		if formula[i][2] > 1 then
			x = x.." "..formula[i][2]
		end
		inputs[#inputs + 1] = x
	end

	--[[recipes.add("crude_alloyer",
		inputs,
		{self:get("ingot", count)})]]
end)

mat.add_recipe_generator("crude_blast_furnace", function(self)
	local name = self.name
	local formula = trinium.api.DataMesh:new():data(mat.materials_reg[name].formula)
			:filter(function(v)
				return mat.getter(v[1], "ingot")
			end)

	local sum = 0
	formula:forEach(function(v) sum = sum + v[2] end)

	api.delayed_call("trinium_machines", recipes.add, "crude_blast_furnace",
		{self:get("dust", sum), mat.fgetter("coal", "gem", 1 + math.floor(sum * 2 / 3))},
		formula:map(function(v) return mat.getter(v[1], "ingot") end):data())
end)
