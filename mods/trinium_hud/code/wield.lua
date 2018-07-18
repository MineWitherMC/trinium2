local wield_descriptions = {}
local huds = {}
local hud = trinium.hud
local api = trinium.api

minetest.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	huds[pn] = player:hud_add {
		hud_elem_type = "text",
		text = "",
		number = 0xFFFFFF,
		position = { x = 0.5, y = 0.9 },
		alignment = { x = 0, y = 0 },
	}
	wield_descriptions[pn] = ""
end)

hud.register_globalstep("wield", {
	period = 0.05,
	callback = function()
		local players = minetest.get_connected_players()
		for i = 1, #players do
			local pn = players[i]:get_player_name()
			local current_wield = players[i]:get_wielded_item()
			local desc = current_wield:get_meta():get_string "description"
			if desc == "" then
				desc = api.get_field(current_wield:get_name(), "description")
			end
			if not desc then desc = "" end
			if desc ~= wield_descriptions[pn] then
				wield_descriptions[pn] = desc
				players[i]:hud_change(huds[pn], "text", desc:split "\n"[1] or "")
			end
		end
	end,
})
