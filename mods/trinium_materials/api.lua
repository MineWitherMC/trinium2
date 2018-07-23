local mat = trinium.materials
local api = trinium.api

mat.material_types, mat.add_type = api.adder()
mat.material_interactions, mat.add_combination = api.adder()

mat.elements = {}
mat.materials_reg = {}

local function is_complex(formula)
	return type(formula) == "table" and #formula > 0 and (formula[1][2] > 1 or #formula > 1)
end

mat.data_generators, mat.add_data_generator = api.adder()
mat.recipe_generators, mat.add_recipe_generator = api.adder()

function mat.getter(name, kind, amount)
	local x = ("trinium_materials:%s_%s"):format(kind, name)
	if not minetest.registered_items[x] then return false end
	if not amount or amount == 1 then return x end
	return x .. " " .. amount
end

function mat.force_getter(name, kind, amount)
	return ("trinium_materials:%s_%s%s"):format(kind, name, amount and amount ~= 1 and " " .. amount or "")
end

function mat.add(name, def)
	name = def.name or name
	if not def.formula_string and def.formula then
		local fs = ""
		for i = 1, #def.formula do
			local n = mat.materials_reg[def.formula[i][1]]
			if not n then n = mat.elements[def.formula[i][1]] end
			api.assert(n, name, "component", def.formula[i][1])
			local add = n.formula_string or n.formula or ""
			if def.formula[i][2] > 1 and is_complex(n.formula) then
				add = "(" .. add .. ")"
			end
			fs = fs .. add .. (def.formula[i][2] == 1 and "" or def.formula[i][2])
		end
		def.formula_string = fs
	end

	if not def.color_string and def.color then
		def.color_string = api.color_string(def.color)
	elseif not def.color_string and def.formula then
		local formula1 = table.map(def.formula, function(x)
			return {(mat.materials_reg[x[1]] or mat.elements[x[1]]).color or {0, 0, 0}, x[2]}
		end)
		local r, g, b
		r = math.weighted_avg(table.map(formula1, function(x) return {x[1][1], x[2]} end))
		g = math.weighted_avg(table.map(formula1, function(x) return {x[1][2], x[2]} end))
		b = math.weighted_avg(table.map(formula1, function(x) return {x[1][3], x[2]} end))

		def.color_string = api.color_string{r, g, b}
	end

	local def2 = {
		id = name,
		name = def.description,
		color_string = def.color_string,
		color = def.color,
		formula_string = def.formula_string,
		formula = def.formula,
		data = def.data or {},
		types = def.types,
	}
	mat.materials_reg[name] = def2

	local def3 = {
		id = name,
		name = def.description,
		color = def.color_string,
		color_tbl = def.color,
		formula = def.formula_string and "\n" .. minetest.colorize("#CCC", def.formula_string) or "",
		formula_tbl = def.formula,
		data = def.data or {},
		types = def.types,
	}

	if #def.types > 0 then
		for i = 1, #def.types do
			local r = api.assert(mat.material_types[def.types[i]], name, "material type", def.types[i])
			r(def3)
		end
	end

	local object = {}
	function object:generate_recipe(id)
		local reg = api.assert(mat.recipe_generators[id], name, "recipe generator", id)
		api.delayed_call("trinium_materials", reg, self)
		return self
	end

	function object:generate_data(id)
		local reg = api.assert(mat.data_generators[id], name, "data generator", id)
		def2.data[id] = reg(name)
		return self
	end

	function object:generate_interactions()
		for _, v in pairs(mat.material_interactions) do
			if table.every(v.requirements, function(x) return table.exists(def.types, function(a) return a == x end) end) then
				v.apply(name, def2.data or {})
			end
		end
		return self
	end

	function object.get(_, kind, amount)
		return mat.getter(name, kind, amount)
	end

	object.color = def.color_string
	object.name = name

	return object
end

function mat.add_element(name, def)
	mat.elements[name] = def
	local object = {}
	function object.register_material(_, def1)
		def1.formula_string = def.formula
		def1.formula = {}
		def1.color = def.color
		def1.data = setmetatable(def1.data or {}, {__index = def})
		local m1 = mat.add(name, def1)
		m1:generate_interactions()
		return m1
	end
	return object
end
