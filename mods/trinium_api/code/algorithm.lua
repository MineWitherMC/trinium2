local api = trinium.api
local DataMesh = api.DataMesh

function api.advanced_search(begin, serialize, vertex)
	local dm = DataMesh:new()
	local dd = dm._data
	local used = {}
	local operation = {[begin] = 1}
	local under_operation
	local step = 0
	local finished
	repeat
		finished = true
		under_operation = {}
		step = step + 1
		for v in pairs(operation) do
			if not used[serialize(v)] then
				used[serialize(v)] = 1
				if step > 1 then
					table.insert(dd, {v, step})
				end
				finished = false
				for v1 in pairs(vertex(v, step)) do
					under_operation[v1] = 1
				end
			end
		end

		operation = table.copy(under_operation)
	until finished
	return dm
end

function api.search(begin, serialize, vertex)
	return api.advanced_search(begin, serialize, vertex):map(function(r) return r[1] end)
end

function api.sort_by_param(param, x)
	if not x then
		return function(a, b)
			return a[param] < b[param]
		end
	else
		return function(a, b)
			return a[param] > b[param]
		end
	end
end

function api.exposed_var()
	local tbl = {good = true}
	return tbl, function() return not tbl.good end
end

function api.iterator(callback)
	return function(max, current)
		if max == current then return end
		current = current + 1
		return callback(current)
	end
end

api.functions = {} -- table of functions
local func = api.functions

function func.identity(a)
	return a
end

function func.const(a)
	return function()
		return a
	end
end

function func.equal(a)
	return function(b)
		return a == b
	end
end

function func.empty() end

function func.new_object()
	return {}
end