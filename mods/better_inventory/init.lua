betterinv = {}
betterinv.tab_position = tonumber(minetest.settings:get("betterinv.tab_position") or "1")

betterinv.tabs = {}
betterinv.tablist = {}
betterinv.contexts = {}
betterinv.selections = {}
betterinv.default = nil
betterinv.prepend = "background[5,5;1,1;trinium_gui_background.png;true]"
function betterinv.register_tab(name, def)
	betterinv.tabs[name] = def
	table.insert(betterinv.tablist, name)
	def.name = name
	if def.default then betterinv.default = name end
end

function betterinv.generate_buttons(size, tabs, filter, selected)
	local str = ""
	if betterinv.tab_position == 4 then str = "tabheader[0,0;betterinv_tabs;" end
	local select = false
	local i = 0
	for j, k in ipairs(betterinv.tablist) do
		local v = betterinv.tabs[k]
		if filter(v) then
			i = i + 1
			if betterinv.tab_position == 0 then
				str = str..("button[%s,0;2,1;betterinv~%s;%s]"):format((i - 1) * 2, k, v.description)
			elseif betterinv.tab_position == 1 then
				str = str..("button[0,%s;2,1;betterinv~%s;%s]"):format((i - 1) * 7/10, k, v.description)
			elseif betterinv.tab_position == 2 then
				str = str..("button[%s,%s;2,1;betterinv~%s;%s]"):format(i - 1, size.y - 1, k, v.description)
			elseif betterinv.tab_position == 3 then
				str = str..("button[%s,%s;2,1;betterinv~%s;%s]"):format(size.x - 2, (i - 1) * 7/10, k, v.description)
			else
				if k == selected then select = i end
				if i > 1 then str = str.."," end
				str = str..v.description
			end
		end
	end
	if betterinv.tab_position == 4 then str = str..";"..select..";true;false]" end
	return str
end

local theme_inv = [[
	listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
	list[current_player;main;0,4.7;8,1;]
	list[current_player;main;0,5.85;8,3;8]
]]

function betterinv.generate_formspec(player, fs, size, bg, inv)
	local p = betterinv.tab_position
	if p == 2 or p == 0 then size.y = size.y + 1
	elseif p == 1 or p == 3 then size.x = size.x + 2
	end

	local x, y = 0, 0
	if p == 0 then y = 1
	elseif p == 1 then x = 2
	end

	local fs1 = ("size[%s,%s]container[%s,%s]%s"):format(size.x, size.y, x, y, bg or "")
	fs1 = fs1..fs
	if inv then fs1 = fs1..theme_inv end
	fs1 = fs1.."container_end[]"
	fs1 = fs1..betterinv.generate_buttons(size, betterinv.tabs, function(tab)
		return not tab.available or tab.available(player)
	end, betterinv.selections[player:get_player_name()])
	return fs1
end

minetest.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	betterinv.contexts[pn] = {}
	for k,v in pairs(betterinv.tabs) do betterinv.contexts[pn][k] = {} end
	betterinv.selections[pn] = betterinv.default
	if betterinv.default then
		player:set_inventory_formspec(betterinv.tabs[betterinv.default].getter(player, betterinv.contexts[pn]))
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then return end
	local pn = player:get_player_name()

	local good = false
	local selection = betterinv.selections[pn]
	local tab = betterinv.tabs[selection]

	if fields.betterinv_tabs then
		local id = tonumber(fields.betterinv_tabs)
		good = betterinv.selections[pn] ~= betterinv.tablist[id]
		if good then
			player:set_inventory_formspec(betterinv.tabs[betterinv.tablist[id]].getter(player, betterinv.contexts[pn][selection]))
			betterinv.selections[pn] = betterinv.tablist[id]
		end
	else
		for k,v in pairs(fields) do
			local ksplit = k:split"~"
			if ksplit[1] == "betterinv" then
				good = true
				player:set_inventory_formspec(betterinv.tabs[ksplit[2]].getter(player, betterinv.contexts[pn][selection]))
				betterinv.selections[pn] = ksplit[2]
			end
		end
	end
	if not good and tab and tab.processor then
		tab.processor(player, betterinv.contexts[pn][selection], fields)
		player:set_inventory_formspec(tab.getter(player, betterinv.contexts[pn][selection]))
	end
end)

if not sfinv then
	sfinv = {}
	function sfinv.register_page(name, def)
		def.getter = function(...)
			return def.get(def, ...)
		end
		if def.on_player_receive_fields then
			def.processor = function(...)
				return def.on_player_receive_fields(def, ...)
			end
		end
		def.description = def.title
		betterinv.register_tab(name, def)
	end
	function sfinv.make_formspec(player, context, fs, inv, size, bg)
		if not size then size = "size[8,8.6]" end
		size = size:split"["[2]
		size = size:split"]"[1]
		size = size:split","

		if not bg then bg = betterinv.prepend end

		return betterinv.generate_formspec(player, fs, {x = tonumber(size[1]), y = tonumber(size[2])}, bg, inv)
	end
	function sfinv.get_or_create_context(player)
		local pn = player:get_player_name()
		return betterinv.contexts[pn][betterinv.selections[pn]]
	end
end
