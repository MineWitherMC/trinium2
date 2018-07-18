trinium.api.DataMesh = {}
local DataMesh = trinium.api.DataMesh

function DataMesh:new()
	local dm = setmetatable({}, {__index = self})
	dm._data = {}
	return dm
end

function DataMesh:data(b)
	if b then
		self._data = b
		return self
	else
		return self._data
	end
end

function DataMesh:filter(func)
	for k, v in pairs(self._data) do
		if not func(v, k) then
			self._data[k] = nil
		end
	end
	return self
end

function DataMesh:map(func)
	for k, v in pairs(self._data) do
		self._data[k] = func(v, k)
	end
	return self
end

function DataMesh:forEach(sorted, func)
	if not func then
		func = sorted
		sorted = false
	end

	for k, v in (sorted and ipairs or pairs)(self._data) do
		func(v, k)
	end
	return self
end

function DataMesh:remap()
	self._data = table.remap(self._data)
	return self
end

function DataMesh:sort(func)
	table.sort(self._data, func)
	return self
end

function DataMesh:exists(func)
	return table.exists(self._data, func)
end

function DataMesh:serialize()
	return minetest.serialize(self._data)
end

function DataMesh:count()
	return table.count(self._data)
end

function DataMesh:copy()
	local dm = DataMesh:new()
	dm._data = table.copy(self._data)
	return dm
end

function DataMesh:push(val)
	table.insert(self._data, val)
	return self
end

function DataMesh:unique()
	local cache = {}
	for k, v in pairs(self._data) do
		if cache[v] then
			self._data[k] = nil
		else
			cache[v] = true
		end
	end
	return self
end
