if not minetest.get_modpath"screwdriver" then screwdriver = {} end
if not minetest.get_modpath"farming" then farming = {} end
LIGHT_MAX = 14

default.gui_bg = ""
default.gui_bg_img = ""
default.gui_slots = ""
function default.get_hotbar_bg() return "" end
default.LIGHT_MAX = LIGHT_MAX

trinium.api.set_master_prepend[=[
	bgcolor[#111B;true]
	background[5,5;1,1;trinium_gui_background.png;true]
	listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
]=]

local function update_drop(name, drop)
	if drop and drop ~= "" then
		trinium.recipes.add("drop", {name},
				type(drop) == "table" and drop.items or {drop},
				{max_items = type(drop) == "table" and drop.max_items or 99})
	end
end

minetest.nodedef_default.stack_max = 72
minetest.craftitemdef_default.stack_max = 72

minetest.after(0, function()
	for item, v in pairs(minetest.registered_items) do
		update_drop(item, v.drop)
	end
end)