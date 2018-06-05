trinium.recipes = {
	methods = {}, -- unordered map
	usages = {}, -- unordered map of lists
	recipes = {}, -- unordered map of lists
	recipes_by_method = {}, -- unordered_map of lists
	recipe_registry = {}, -- list
}
local recipes = trinium.recipes
local api = trinium.api
local func = api.functions

function recipes.stringify(size, inputs)
	inputs = table.copy(inputs)
	for i = 1, size do
		inputs[i] = inputs[i] or ""
	end
	return table.concat(inputs, ";")
end

function recipes.add(method, inputs, outputs, data)
	local method_table = trinium.recipes.methods[method]
	data = data or {}

	-- Processing inputs (e.g., MC method of creating workbench recipes)
	inputs, outputs, data = method_table.process(inputs, outputs, data)
	if inputs == -1 or outputs == -1 or data == -1 then return end

	-- Redoing all the redirects
	local redirects, method_string = {method = 1}
	while type(method_table.callback(inputs, outputs, data)) == "string" do
		method_string = method
		method = method_table.callback(inputs, outputs, data)
		assert(not redirects[method], "Infinite loop detected!")
		redirects[method] = 1
	end
	data.author_mod = minetest.get_current_modname() or "???"

	assert(method_table.recipe_correct(data),
			"Invalid recipe: "..recipes.stringify(method_table.input_amount, inputs)..
			" for "..method.." by "..data.author_mod)

	-- Registering recipe
	local new_amount = #recipes.recipe_registry + 1
	local outputs_string
	if table.every(outputs, function(k) return type(k) == "string" end) then
		outputs_string = recipes.stringify(method_table.output_amount, outputs)
	end
	recipes.recipe_registry[new_amount] = {
		["type"] = method,
		inputs = inputs,
		outputs = outputs,
		data = data,
		inputs_string = recipes.stringify(method_table.input_amount, inputs),
		outputs_string = outputs_string,
	}

	local k
	local cache = {}
	if not data.secret_recipe and method_table.callback(inputs, outputs, data) then
		for i,v in pairs(inputs) do
			k = v:split" "[1]
			if not cache[k] then
				cache[k] = 1
				recipes.usages[k] = recipes.usages[k] or {}
				table.insert(recipes.usages[k], new_amount)
			end
		end
		cache = {}
		for i,v in pairs(outputs) do
			k = v:split" "[1]
			if not cache[k] then
				cache[k] = 1
				trinium.recipes.recipes[k] = trinium.recipes.recipes[k] or {}
				table.insert(trinium.recipes.recipes[k], new_amount)
			end
		end
		table.insert(trinium.recipes.recipes_by_method[method], new_amount)
	end
end

function recipes.add_method(method, tbl)
	trinium.recipes.methods[method] = api.set_defaults(tbl, {
		callback = func.const(true),
		process = function(a, b, c)
			return a, b, c
		end,
		formspec_begin = func.const"",
		can_perform = func.const(true),
		recipe_correct = func.const(true),
	})

	trinium.recipes.recipes_by_method[method] = {}
end

function recipes.get_coords(width, shiftx, shifty, n)
	return math.modulate(n, width) + shiftx, math.ceil(n / width) + shifty
end

function recipes.coord_getter(width, dx, dy)
	return function(n)
		return recipes.get_coords(width, dx, dy, n)
	end
end

function recipes.check_inputs(input_map, needed_inputs)
	return table.every(needed_inputs, function(r)
		local k = r:split" "
		return input_map[k[1]] and (#k == 1 or (input_map[k[1]] >= tonumber(k[2])))
	end)
end

function recipes.remove_inputs(inventory, list, inputs)
	for k,v in pairs(inputs) do inventory:remove_item(list, v) end
end

recipes.add_method("drop", {
	input_amount = 1,
	output_amount = 9,
	get_input_coords = function(n)
		return 1, 2
	end,
	get_output_coords = function(n)
		return math.modulate(n, 3) + 2.5, math.ceil(n / 3)
	end,
	formspec_width = 7,
	formspec_height = 5,
	formspec_name = api.S"Drop",
	formspec_begin = function(data)
		return ("label[0,4.7;%s]"):format(api.S("Max Drop: @1", data.max_items))
	end,

	process = function(a, outputs, b)
		if type(outputs[1]) == "string" then return a, outputs, b end
		local outputs1 = {}

		table.walk(outputs, function(v, k)
			if type(v) == "string" then
				table.insert(outputs1, v)
			else
				table.walk(v.items, function(v1)
					table.insert(outputs1, v1..(#(v1:split(" ")) == 1 and " 1" or "")..
							" "..math.ceil(10000 / v.rarity) / 100)
				end)
			end
		end)

		return a, #outputs1 > 9 and -1 or outputs1, b
	end,
})
