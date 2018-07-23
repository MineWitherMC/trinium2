function math.modulate(num, max)
	while num < 1 do num = num + max end
	return (num - 1) % max + 1
end

function math.harmonic_distribution(center, tolerance, current, amplitude)
	amplitude = amplitude or 1
	if current < center - tolerance or current > center + tolerance then return 0 end
	return math.sqrt(1 - ((current - center) / tolerance) ^ 2) * amplitude
end

math.ln2 = math.log(2)
local randomizer = PcgRandom(math.random() * 10 ^ 8)
function math.gaussian(a, b)
	return randomizer:rand_normal_dist(a, b)
end

function math.weighted_random(arr, func)
	func = func or math.random
	local j = table.sum(arr)
	local k = func(1, j)
	local i = 1
	while k > arr[i] do
		k = k - arr[i]
		i = i + 1
	end
	return i
end

-- {{amount1, weight1}, {amount2, weight2}, ...}
function math.weighted_avg(t)
	local t1 = table.map(t, function(v) return v[1] * v[2] end)
	local t2 = table.map(t, function(v) return v[2] end)
	return math.floor(table.sum(t1) / table.sum(t2))
end

function math.geometrical_avg(tbl)
	local sum = 0
	table.walk(tbl, function(r) sum = sum + math.log(r) end)
	return math.exp(sum / #tbl)
end

function math.gcd(a, b)
	if not a or not b then return end
	while a > 0 and b > 0 do
		if a > b then
			a = a % b
		else
			b = b % a
		end
	end
	return a + b
end

function math.round(num, level)
	return math.floor(num / level + 0.5) * level
end