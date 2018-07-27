local api = trinium.api
local S = pulse_network.S

function pulse_network.trigger_update(controller_pos)
	local meta = minetest.get_meta(controller_pos)
	local cd = minetest.deserialize(meta:get_string"connected_devices")
	for i = 1, #cd do
		local name1 = minetest.get_node(cd[i]).name
		if minetest.registered_items[name1].on_pulsenet_update then
			minetest.registered_items[name1].on_pulsenet_update(cd[i], controller_pos)
		end
	end
end

function pulse_network.import_to_controller(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local items = meta:get_string"inventory":data()
	local pending_recipes = meta:get_string"pending_recipes":data()
	local s = inv:get_stack("input", 1)
	if not s:is_empty() then
		local name = s:get_name()
		for i = 1, #pending_recipes do
			if s:is_empty() then break end

			local referrers_parsed = pending_recipes[i].refs
			local action = false
			for _, v in pairs(referrers_parsed) do
				if v[name] then
					local change = math.min(s:get_count(), v[name].needed)
					if change > 0 then
						v[name].needed = v[name].needed - change
						v[name].buffered = v[name].buffered + change
						s:take_item(change)
						inv:set_stack("input", 1, s)
						action = true
					end
				end
			end

			if action then
				meta:set_string("pending_recipes", minetest.serialize(pending_recipes))
				pulse_network.update_pending_recipe(pos, i)
			end
		end
	end

	if not s:is_empty() then
		local CI, UI, CT, UT = meta:get_int"capacity_items", meta:get_int"used_items",
				meta:get_int"capacity_types", meta:get_int"used_types"
		local max_import = CI - UI
		local id = api.get_item_identifier(s)
		local dec = math.min(max_import, s:get_count())
		if items[id] then
			items[id] = items[id] + dec
			s:take_item(dec)
			inv:set_stack("input", 1, s)
			meta:set_int("used_items", UI + dec)
		elseif CT > UT then
			items[id] = dec
			s:take_item(dec)
			inv:set_stack("input", 1, s)
			meta:set_int("used_items", UI + dec)
			meta:set_int("used_types", UT + 1)
		end

		meta:set_string("inventory", minetest.serialize(items))
	end
	pulse_network.trigger_update(pos)
end

function pulse_network.export_from_controller(pos, id, count)
	local meta = minetest.get_meta(pos)
	local items = meta:get_string"inventory":data()
	if not items[id] then return false end
	count = math.min(count, items[id])
	meta:set_int("used_items", meta:get_int"used_items" - count)

	items[id] = items[id] - count
	if items[id] == 0 then
		items[id] = nil
		meta:set_int("used_types", meta:get_int"used_types" - 1)
	end
	meta:set_string("inventory", minetest.serialize(items))
	pulse_network.import_to_controller(pos)

	local tbl = id:split" "
	local additional_info = table.map(table.tail(tbl), function(z) return " "..z end)
	return tbl[1] .. " " .. count .. table.concat(additional_info)
end

function pulse_network.notify_pattern_change(pos, pattern, referrer)
	local meta = minetest.get_meta(pos)
	local patterns = meta:get_string"patterns":data()
	local pattern_data = pattern:get_meta():get_string"recipe_data":data()
	pattern_data.referrer = referrer

	local flagged_for_addition = false
	for _, v1 in pairs(pattern_data.outputs) do
		local v = v1:split" "[1]
		if not patterns[v] then
			patterns[v] = {}
		end

		if not patterns[v][referrer] then
			patterns[v][referrer] = pattern_data
			flagged_for_addition = true
		elseif not flagged_for_addition then
			patterns[v][referrer] = nil
			if table.count(patterns[v]) == 0 then
				patterns[v] = nil
			end
		end
	end

	meta:set_string("patterns", minetest.serialize(patterns))
	pulse_network.trigger_update(pos)
end

local function sequence(storage, patterns)
	return function(object, steps)
		assert(steps <= 25, S"Too complicated pattern sequence!")
		local set = {}

		if object.type == "pattern" then
			--[[
				If we obtained a pattern, we need to buffer all of its components.
			]]--
			for _, v in pairs(object.pattern.inputs) do
				local input_id, input_count = unpack(v:split" ")
				input_count = (tonumber(input_count) or 1) * object.multiplier
				if not storage[input_id] then
					storage[input_id] = 0
				end
				local added_count = math.min(storage[input_id], input_count)
				storage[input_id] = storage[input_id] - added_count
				input_count = input_count - added_count
				if storage[input_id] == 0 then
					storage[input_id] = nil
				end
				local needed_item = {
					type = "item",
					item = input_id,
					buffered = added_count,
					needed = input_count,
					distance = steps,
					parent = object.pattern.referrer,
				}
				set[needed_item] = 1
			end
		else
			--[[
				More interesting case is obtaining item.

				In this case, we should select patterns we could use.
				E.g, if first pattern for X is {Y, 2Z} and second is {T, 5W},
				we need 10 Xs and we have 5 Ys and 10 Ts (and Z/W are free-craftable),
				then we should request 5 Y-based recipes and
				5 T-based recipes.
				If we cannot produce the last recipe possible, it means we have not enough items.

				However, we need to find whether we actually can craft Z
				or we have to request 10 T-based recipes.

				To do that, a probably good way is to binary-search maximum amount of {Y, 2Z} recipes.

				However, I am too lazy ATM and just check the first recipe producing X.
			]]--
			if not patterns[object.item] and object.needed > 0 then
				error(S("Could not craft @1 of @2!", object.needed, api.get_description(object.item)))
			end
			if object.needed == 0 then return {} end
			for _, v in pairs(patterns[object.item]) do
				local outputted_amount = 0
				for _, output in pairs(v.outputs) do
					local id, count = unpack(output:split" ")
					if id == object.item then
						count = tonumber(count) or 1
						outputted_amount = outputted_amount + count
					end
				end
				assert(outputted_amount > 0, S"System error!")

				local needed_recipe_amount = math.ceil(object.needed / outputted_amount)
				local needed_item = {
					type = "pattern",
					pattern = v,
					multiplier = needed_recipe_amount
				}
				set[needed_item] = 1

				break
			end
		end

		return set
	end
end

function pulse_network.request_autocraft(pos, item_id, count)
	local meta = minetest.get_meta(pos)
	if meta:get_int"active_processes" >= meta:get_int"available_processes" then
		return false, S"Insufficient crafting cores!"
	end

	local storage = meta:get_string"inventory":data()
	local patterns = meta:get_string"patterns":data()

	local step_1 = {type = "item", item = item_id, buffered = 0, needed = count, distance = 1, parent = false}
	local a, b = pcall(api.search, step_1, api.functions.new_object, sequence(storage, patterns))
	if a then
		b:push(step_1)
		local memory = count * #b:data()
		if meta:get_int"used_memory" + memory > meta:get_int"available_memory" then
			return false, S"Insufficient crafting memory!"
		end
		return b, memory
	end
	return a, table.concat(table.tail(b:split": "), ": ")
end

function pulse_network.execute_autocraft(pos, item_id, count)
	local meta = minetest.get_meta(pos)
	local storage = meta:get_string"inventory":data()
	local dm, memory = pulse_network.request_autocraft(pos, item_id, count)
	if not dm then return end
	meta:set_int("used_memory", meta:get_int"used_memory" + memory)
	meta:set_int("active_processes", meta:get_int"active_processes" + 1)

	local UI, UT = meta:get_int"used_items", meta:get_int"used_types"

	local referrers_parsed = {}
	dm:forEach(function(obj)
		api.dump(obj)
		if obj.type == "item" then
			local recursive_input_id = obj.item
			local buf = obj.buffered
			if buf > 0 then
				storage[recursive_input_id] = storage[recursive_input_id] - buf
				UI = UI - buf
				if storage[recursive_input_id] == 0 then
					storage[recursive_input_id] = nil
					UT = UT - 1
				end
			end

			if not obj.parent then return end
			if not referrers_parsed[obj.parent] then
				referrers_parsed[obj.parent] = {}
			end

			local old = referrers_parsed[obj.parent][recursive_input_id] or {}
			referrers_parsed[obj.parent][recursive_input_id] = {
				needed = (old.needed or 0) + obj.needed,
				buffered = (old.buffered or 0) + obj.buffered,
			}
		end
	end)
	api.dump(referrers_parsed)

	meta:set_int("used_items", UI)
	meta:set_int("used_types", UT)
	local pending_recipes = meta:get_string"pending_recipes":data()
	table.insert(pending_recipes, {refs = referrers_parsed, memory = memory})
	meta:set_string("pending_recipes", minetest.serialize(pending_recipes))
	meta:set_string("inventory", minetest.serialize(storage))

	pulse_network.trigger_update(pos)
	pulse_network.update_pending_recipe(pos, #pending_recipes)
end

function pulse_network.update_pending_recipe(pos, key)
	local meta = minetest.get_meta(pos)
	local pending_recipes = meta:get_string"pending_recipes":data()
	local processed_recipe = pending_recipes[key]

	for k, v in pairs(processed_recipe.refs) do
		if table.every(v, function(x) return x.needed == 0 end) then
			processed_recipe.refs[k] = nil
			local map = table.map(v, function(x) return x.buffered end)
			pulse_network.send_items_to_referrer(k, map)
		end
	end

	if table.count(processed_recipe.refs) == 0 then
		meta:set_int("used_memory", meta:get_int"used_memory" - processed_recipe.memory)
		meta:set_int("active_processes", meta:get_int"active_processes" - 1)
		table.remove(pending_recipes, key)
	end

	meta:set_string("pending_recipes", minetest.serialize(pending_recipes))
end

function pulse_network.send_items_to_referrer(referrer, itemmap)
	local pos, index = unpack(referrer:split"|")
	pos = vector.destringify(pos)
	local meta = minetest.get_meta(pos)
	local old_items = meta:get_string"autocraft_itemmap":data()
	api.merge_itemmaps(old_items, itemmap)
	meta:set_string("autocraft_itemmap", minetest.serialize(old_items))

	local node = minetest.get_node(pos)
	local callback = api.get_field(node.name, "on_autocraft_insert")
	if callback then
		callback(pos, index)
	end
end