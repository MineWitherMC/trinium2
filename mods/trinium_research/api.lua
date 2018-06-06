local research = trinium.research
local S = research.S
local api = trinium.api

research.chapters = {} -- unordered map
research.researches_by_chapter = {} -- unordered map
function research.add_chapter(name, def)
	research.chapters[name] = def
	research.chapters[name].requirements = {}
	research.researches_by_chapter[name] = {}
end
function research.add_chapter_req(chapter, parent)
	research.chapters[chapter].requirements[parent] = 1
end

research.researches = {} -- unordered map
function research.add(name, def)
	research.researches[name] = def
	research.researches[name].requirements = {}
	research.researches_by_chapter[def.chapter][name] = def
end
function research.add_req(child, parent)
	research.researches[child].requirements[parent] = 1
end

research.dp1 = api.get_data_pointers"researches" -- unordered set
research.dp2 = api.get_data_pointers"researches_data" -- unordered map
function research.check(pn, name)
	return research.dp1[pn][name]
end

function research.get_tree(name)
	return api.search(name, api.functions.returner, function(c_res)
		if c_res:find"%." then
			return {c_res:split"."}
		else
			return table.keys(research.researches[c_res].requirements)
		end
	end)
end

function research.grant(pn, name)
	local s = research.get_tree(name):filter(function(k) return not research.check(pn, k) end)
	if s:count() > 0 then
		minetest.chat_send_player(pn, S"Unknown Research!")
	else
		dp1[pn][name] = true
		minetest.chat_send_player(pn, S("Successfully learned @1", name))
	end
end

function research.force_grant(pn, name)
	local s = research.get_tree(name):filter(function(k) return not research.check(pn, k) end):push(name)
	s:forEach(function(r)
		dp1[pn][r] = true
		minetest.chat_send_player(pn, S("Successfully given @1", r))
	end)
end

research.aspects = {} -- unordered map
research.aspect_list = {} -- list
function research.add_aspect(name, def)
	research.aspects[name] = api.set_defaults(def, {req1 = nil, req2 = nil})
	research.aspects[name].id = name
	table.insert(research.aspect_list, name)
	table.sort(research.aspect_list)

	minetest.register_tool("trinium_research:aspect_"..name, {
		description = def.name,
		inventory_image = def.texture,
		groups = {hidden_from_irp = 1},
	})
end

research.lens_data = {}
research.lens_data.gems, research.register_lens_gem = api.adder()
research.lens_data.metals, research.register_lens_metal = api.adder()
research.lens_data.shapes, research.register_lens_shape = api.adder()

research.constants = {
	press_cost = 8,
	min_gems = 6, max_gems = 24,
	min_metal = 2, max_metal = 28,
	max_tier = 7,
}

function research.random_aspects(pn, num, arr)
	if not arr then arr = research.aspect_list end
	for i = 1, num do
		local rand = table.random(arr)
		if not research.dp2[pn].aspects[rand] then research.dp2[pn].aspects[rand] = 5 end
		research.dp2[pn].aspects[rand] = research.dp2[pn].aspects[rand] + 1
	end
end
