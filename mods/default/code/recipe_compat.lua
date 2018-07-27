minetest.after(0, function()
	for item in pairs(minetest.registered_items) do
		local recipes = minetest.get_all_craft_recipes(item)
		if item ~= "" and recipes then
			for _, recipe in pairs(recipes) do
				if recipe.method == "normal" then
					-- todo: add replacements
					if recipe.width == 0 then
						table.sort(recipe.items)
					end

					trinium.recipes.add("crafting", recipe.items, {recipe.output}, {shapeless = recipe.width == 0})
				elseif recipe.method == "cooking" then
					-- trinium.recipes.add("furnace", recipe.items, {recipe.output}, {time = 8})
				end
				pcall(minetest.clear_craft, recipe)
			end
		end
	end
end)