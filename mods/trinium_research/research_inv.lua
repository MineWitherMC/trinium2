local research = trinium.research
local S = research.S
local api = trinium.api
local M = trinium.materials.materials

minetest.register_on_joinplayer(function(player)
	local data = research.dp2[player:get_player_name()]
	data.aspects = data.aspects or {}
	data.ink = data.ink or 0
	data.paper = data.paper or 0
	data.warp = data.warp or 0
end)

local function get_book_fs(pn)
	local buttons = ""
	for k,v in pairs(research.chapters) do
		if table.every(v.requirements, function(b,a) return research.check(pn, a) end) then
			buttons = buttons..([=[
				item_image_button[%s,%s;1,1;%s;open_chapter~%s;]
				tooltip[open_chapter~%s;%s]
			]=]):format(v.x, v.y, v.texture, k, k, v.name)
		end
	end
	return buttons
end

local function cut_coordinates(x1, x2, y1, y2)
	if y1 == y2 then return math.min(math.max(x1, x2), 8), math.max(math.min(x1, x2), -0.5), y1, y1 end
	if x1 == x2 then return x1, x1, math.min(math.max(y1, y2), 8), math.max(math.min(y1, y2), -0.5) end
	--[[
		define line (x1,y1) => (x2,y2) as y = kx + b
		then, kx1 + b = y1 and kx2 + b = y2
		k(x2-x1) = (y2-y1)
		k = (y2-y1)/(x2-x1)
		b = y1 - kx1 = (x2y1 - x1y2)/(x2-x1)
	]]--
	local k, b = (y2 - y1) / (x2 - x1), (x2 * y1 - x1 * y2) / (x2 - x1)
	-- then, intersect y = kx + b with line x = -0.5, then y = -0.5k + b
	if x1 < -0.5 then x1 = -0.5; y1 = -0.5 * k + b end
	if x2 < -0.5 then x2 = -0.5; y2 = -0.5 * k + b end
	-- then, with x = 8, then y = 8k + b
	if x1 > 8 then x1 = 8; y1 = 8 * k + b end
	if x2 > 8 then x2 = 8; y2 = 8 * k + b end
	-- then, with y = -0.5, then x = -(b+0.5)/k
	if y1 < -0.5 then y1 = -0.5; x1 = -(b + 0.5) / k end
	if y2 < -0.5 then y2 = -0.5; x2 = -(b + 0.5) / k end
	-- finally, with y = 8, then x = (8-b)/k
	if y1 > 8 then y1 = 8; x1 = (8 - b) / k end
	if y2 > 8 then y2 = 8; x2 = (8 - b) / k end

	return x1, x2, y1, y2
end

local function draw_connection(x1, y1, x2, y2)
	-- some strange thing
	if x1 == x2 and y1 == y2 then return "" end

	-- both outside of screen
	if ((x1 < 0 or x1 > 7) and (x2 < 0 or x2 > 7)) or
			((y1 < 0 or y1 > 7) and (y2 < 0 or y2 > 7)) then return "" end
	x1, x2, y1, y2 = cut_coordinates(x1, x2, y1, y2)
	if x1 == x2 then
		if y1 > y2 then y1, y2 = y2, y1 end
		return ("background[%s,%s;1,%s;trinium_research_gui.connector_vertical.png]"):format(x1, y1 + 0.5, y2 - y1)
	elseif y1 == y2 then
		if x1 > x2 then x1, x2 = x2, x1 end
		return ("background[%s,%s;%s,1;trinium_research_gui.connector_horizontal.png]"):format(x1 + 0.5, y1, x2 - x1)
	elseif (x1 > x2) == (y1 > y2) then
		if x1 > x2 then x1, x2, y1, y2 = x2, x1, y2, y1 end
		return ("background[%s,%s;%s,%s;trinium_research_gui.connector_normal.png]")
			:format(x1 + 0.5, y1 + 0.5, x2 - x1, y2 - y1)
	else
		if x1 > x2 then
			x1, x2 = x2, x1
			y1, y2 = y2, y1
		end
		return ("background[%s,%s;%s,%s;trinium_research_gui.connector_reverse.png]")
			:format(x1 + 0.5, y2 + 0.5, x2 - x1, y1 - y2)
	end
end

local function get_book_chapter_fs(chapter_id, pn, cx, cy)
	local buttons, texture = ("button[7,8;1,1;open_book;%s]"):format(S"Back")
	if research.chapters[chapter_id].create_map then
		buttons = buttons..("button[5,8;2,1;research~get_map;%s]tooltip[research~get_map;%s]")
				:format(buttons, S "Get Chapter Map", S "This chapter uses Secret researches discovered via Sheet Infuser")
	end
	if not research.researches_by_chapter[chapter_id] then
		return
	end
	local frc = table.filter(research.researches_by_chapter[chapter_id], function(v)
		return v.x - cx >= 0 and v.x - cx <= 7 and v.y - cy >= 0 and v.y - cy <= 7
	end)

	local enable
	for k, v in pairs(research.researches_by_chapter[chapter_id]) do
		local desc = v.name
		if v.warp then
			desc = desc .. "\n" .. minetest.colorize("#663399", S("Forbidden Knowledge: Level @1", v.warp))
		end
		enable = false
		if research.dp1[pn][k] or v.pre_unlock then
			-- Research available
			for v1 in pairs(v.requirements) do
				if research.researches_by_chapter[chapter_id][v1] then
					local v2 = research.researches[v1]
					buttons = buttons..draw_connection(v.x - cx, v.y - cy, v2.x - cx, v2.y - cy)
				end
			end

			if frc[k] then
				buttons = buttons..([=[
					item_image_button[%s,%s;1,1;%s;open_research~%s;]
					tooltip[open_research~%s;%s]
				]=]):format(v.x - cx, v.y - cy, v.texture, k, k, desc)
				enable = true
			end
		elseif table.every(v.requirements, function(_, a) return not research.researches[a] or
				research.researches[a].pre_unlock or research.check(pn, a) end) and not v.hidden then
			-- Obtainable research sheet
			for v1 in pairs(v.requirements) do
				if research.researches_by_chapter[chapter_id][v1] then
					local v2 = research.researches[v1]
					buttons = buttons..draw_connection(v.x - cx, v.y - cy, v2.x - cx, v2.y - cy)
				end
			end

			if frc[k] then
				texture = v.texture:gsub(":", "__")
				buttons = buttons..([=[
						background[%s,%s;1,1;trinium_research_gui.glowing.png]
						item_image_button[%s,%s;1,1;%s;get_sheet~%s;]
						tooltip[get_sheet~%s;%s]
					]=]):format(v.x - cx, v.y - cy, v.x - cx, v.y - cy, v.texture, k, k, desc)
				enable = true
			end
		end

		if enable and v.important then
			buttons = buttons..([=[
				background[%s,%s;1.5,1.5;trinium_research_gui.important.png]
			]=]):format(v.x - cx - 0.25, v.y - cy - 0.25)
		end
	end
	return buttons
end

-- Returns text, size
local function get_book_research_fs(pn, context)
	local split = context.book:split"~"
	local res, key = split[2], tonumber(split[3])
	local def = research.researches[res]
	local text = def.text[key]

	if type(text) == "string" then
		text = { form = "textarea[0.25,1;7.75,7;;;" .. text .. "]", w = 8, h = 8, locked = false }
	end
	if type(text[1]) == "table" then
		for k,v in pairs(text[1]) do
			if not text[k] then
				text[k] = v
			end
		end
	end
	if text.text and not text.form then
		text.form = "textarea[0.25,1;7.75,7;;;" .. (text.text) .. "]"
	end

	if text.requirements and not table.every(text.requirements, function(v, k) return research.check(pn, k) end) then
		-- has requirement
		return ([=[
			label[0,8.2;%s]
			button[6,0.25;1,0.5;turn_backward;<]
			button[7,0.25;1,0.5;turn_forward;>]
			textarea[0,1;8,7;;;%s]
			button[7,8;1,1;open_chapter~%s;%s]
		]=]):format(S("@1 - page @2/@3", def.name, key, #def.text), S"This page is not found yet", def.chapter, S"Back"),
				"size[8,8.6]"
	elseif text.locked and not research.check(pn, res .. "-" .. key) then
		local good = true
		local r = 0
		local reqs = table.f_concat(table.map(text.required_aspects, function(v, k)
			if not research.dp2[pn].aspects[k] then
				research.dp2[pn].aspects[k] = 0
			end
			local amount = research.dp2[pn].aspects[k]
			local color = amount >= v and "#00CC00" or "#CC0000"
			if amount < v then good = false end
			r = r + 1

			return ("label[0,%s;%s]"):format(
					(2 + r) / 3,
					minetest.colorize(color,
							S("@1 aspect (@2 needed, @3 available)", api.string_capitalization(k), v, amount))
			)
		end))
		return ([=[
			label[0,8.2;%s]
			button[6,0.25;1,0.5;turn_backward;<]
			button[7,0.25;1,0.5;turn_forward;>]
			%s
			button[7,8;1,1;open_chapter~%s;%s]
			button[0,7;8,1;%s;%s]
		]=]):format(S("@1 - page @2/@3", def.name, key, #def.text),
				reqs, def.chapter, S"Back", good and "unlock" or "", S"Unlock"), "size[8,8.6]"
	else
		local w, h = math.max(text.w, 8), math.max(text.h, 8) + 0.6
		return ([=[
			label[0,%s;%s]
			button[%s,0.25;1,0.5;turn_backward;<]
			button[%s,0.25;1,0.5;turn_forward;>]
			%s
			button[%s,%s;1,1;open_chapter~%s;%s]
		]=]):format(h - 0.4, S("@1 - page @2/@3", def.name, key, #def.text),
				w - 2, w - 1, text.form, w - 1, h - 0.6, def.chapter, S"Back"), ("size[%s,%s]"):format(w, h)
	end
end

local function get_book_bg(pn)
	local w = research.dp1[pn]
	return ("background[0,0;1,1;trinium_research_gui.background_%s.png;true]")
		:format(w.CognFission and 4 or w.CognVoid and 3 or w.CognWarp and 2 or 1)
end

local function get_book_chapter_bg(chapter_id)
	local w = research.chapters[chapter_id]
	return ("background[0,0;1,1;trinium_research_gui.background_%s.png;true]"):format(w.tier)
end

local book = {description = S"Research Book"}
function book.getter(player, context)
	local pn = player:get_player_name()
	context.book = context.book or "default_bg"
	context.book_y = context.book_y or 0
	local split = context.book:split"~"
	if split[1] == "default_bg" then
		return sfinv.make_formspec(player, context, get_book_fs(pn), false, false, get_book_bg(pn))
	elseif split[1] == "chapter" then
		local fs = get_book_chapter_fs(split[2], pn, 0, context.book_y)
		return sfinv.make_formspec(player, context, fs, false, false, get_book_chapter_bg(split[2]))
	elseif split[1] == "research" then -- research~SomeTestResearch~3 (3rd page)
		local fs, s = get_book_research_fs(pn, context)
		return sfinv.make_formspec(player, context, fs, false, s)
	end
end

function book.processor(player, context, fields)
	if fields.quit then return end
	local pn = player:get_player_name()
	local inv = player:get_inventory()

	for k,v in pairs(fields) do
		if k == "key_up" then
			context.book_y = context.book_y - 1
		elseif k == "key_down" and context.book:split"~"[1] == "chapter" then
			context.book_y = context.book_y + 1
		else
			local k_split = k:split "~" -- Module, action, parameters
			local a = k_split[1]
			if a == "open_chapter" then
				context.book = "chapter~" .. k_split[2]
			elseif a == "open_book" then
				context.book = "default_bg"
				context.book_y = 0
			elseif a == "open_research" then
				context.book = ("research~%s~1"):format(k_split[2])
			elseif a == "turn_forward" then
				local cs = context.book:split("~")
				local res = research.researches[cs[2]]
				cs[3] = tonumber(cs[3])
				context.book = ("research~%s~%s"):format(cs[2], math.min(cs[3] + 1, #res.text))
			elseif a == "turn_backward" then
				local cs = context.book:split("~")
				cs[3] = tonumber(cs[3])
				context.book = ("research~%s~%s"):format(cs[2], math.max(cs[3] - 1, 1))
			elseif a == "unlock" then
				local cs = context.book:split("~")
				local res = research.researches[cs[2]]

				cs[3] = tonumber(cs[3])
				table.walk(res.text[cs[3]].required_aspects, function(v, k)
					research.dp2[pn].aspects[k] = research.dp2[pn].aspects[k] - v
				end)

				research.dp1[pn][cs[2].."-"..cs[3]] = 1
			elseif a == "get_sheet" then
				local stack = ItemStack("trinium_research:notes_2")
				local meta = stack:get_meta()
				local res = research.researches[k_split[2]]
				meta:set_string("description", S("Research Notes - @1", res.name))
				meta:set_string("research_id", k_split[2])

				if inv:contains_item("main", stack, true) then
					cmsg.push_message_player(player, S"You already have these research notes!")
					return
				elseif research.dp2[pn].ink < 3 then
					cmsg.push_message_player(player, S"Insufficient Ink!")
					return
				elseif research.dp2[pn].paper < 1 then
					cmsg.push_message_player(player, S"Insufficient Paper!")
					return
				end

				research.dp2[pn].ink = research.dp2[pn].ink - 3
				research.dp2[pn].paper = research.dp2[pn].paper - 1
				inv:add_item("main", stack)
			elseif a == "get_map" then
				local stack = ItemStack("trinium_research:notes_3")
				local meta = stack:get_meta()
				local cs = context.book:split("~")
				local res = research.researches[cs[2]]
				meta:set_string("description", S("Research Map - @1", research.chapters[res.chapter].name))
				meta:set_string("chapter_id", cs[2])

				if inv:contains_item("main", stack, true) then
					cmsg.push_message_player(player, S"You already have this research map!")
					return
				elseif research.dp2[pn].ink < 500 then
					cmsg.push_message_player(player, S"Insufficient Ink!")
					return
				end

				if not inv:contains_item("main", M.diamond:get("dust", 16)) then
					cmsg.push_message_player(player, S"Insufficient Diamond Dust!")
					return
				end

				inv:remove_item("main", M.diamond:get("dust", 16))
				research.dp2[pn].ink = research.dp2[pn].ink - 500

				inv:add_item("main", stack)
			end
		end
	end
end

betterinv.register_tab("research_book", book)
