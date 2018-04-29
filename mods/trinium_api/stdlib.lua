local api = trinium.api

function table.count(array)
	local a = 0
	for k,v in pairs(array) do
		a = a + 1
	end
	return a
end

function table.filter(array, callable)
	local array, j = table.copy(array)
	for k,v in pairs(array) do
		if not callable(v,k) then
			array[k] = nil
		end
	end
	return array
end

function table.exists(array, callable)
	for k,v in pairs(array) do
		if callable(v,k) then
			return k or true
		end
	end
	return false
end

function table.every(array, callable)
	return not table.exists(array, function(v,k) return not callable(v,k) end)
end

function table.walk(array, callable, cond)
	cond = cond or function() return end
	for k,v in pairs(array) do
		callable(v,k)
		if cond() then break end
	end
end

function table.map(array, callable)
	local array = table.copy(array)
	for k,v in pairs(array) do
		array[k] = callable(v,k)
	end
	return array
end

function table.remap(array)
	local array2 = {}
	for k,v in ipairs(array) do
		table.insert(array2, v)
	end
	return array2
end

function table.intersect_key_rev(arr1, arr2)
	return table.filter(arr1, function(v, k) return not arr2[k] end)
end

function table.keys(t)
	local keys = {}
	for k in pairs(t) do table.insert(keys, k) end
	return keys
end

function table.asort(t, callable)
	callable = callable or function(a, b) return a < b end
	local k = table.keys(t)
	table.sort(k, function(a, b) return callable(t[a], t[b]) end)

	return api.iterator(function(current) return current, k[current], t[k[current]] end), #k, 0
end

function table.sum(t)
	local k = 0
	table.walk(t, function(v) k = k + v end)
	return k
end

function table.fconcat(t, x)
	x = x or ""
	local str = ""
	table.walk(t, function(v) str = str..x..v end)
	return str:sub(x:len())
end

function table.tail(t)
	local function helper(head, ...) return #{...} > 0 and {...} or nil end
	return helper((table.unpack or unpack)(t))
end

function table.mtail(t, mult)
	local k = t
	for i = 1, mult do k = table.tail(k) end
	return k
end

function table.random(tbl)
	api.dump("Table", tbl)
	local k = table.keys(tbl)
	api.dump("Keys", k)
	local el = math.random(1, #k)
	api.dump("Element", el)
	return tbl[k[el]], k[el], el
end

function table.random_map(tbl)
	api.dump("Map", tbl)
	return table.random(table.keys(tbl))
end

function vector.stringify(v)
	return v.x..","..v.y..","..v.z
end

function vector.destringify(v)
	local s = v:split","
	return {x = s[1], y = s[2], z = s[3]}
end

function math.modulate(num, max)
	while num < 1 do num = num + max end
	return (num - 1) % max + 1
end

local mt_register_item_old = minetest.register_item
function minetest.register_item(name, def, ...)
	assert(not def.max_stack, name.." uses max_stack instead of stack_max")
	def.stack_max = def.stack_max or 72
	if def.drop and def.drop ~= "" then
		trinium.recipes.add("drop", {name},
			type(def.drop) == "table" and def.drop.items or {def.drop},
			{max_items = type(def.drop) == "table" and def.drop.max_items or 99}
		)
	end
	return mt_register_item_old(name, def, ...)
end

function string:data()
	return minetest.deserialize(self)
end