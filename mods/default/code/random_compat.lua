if not minetest.get_modpath"screwdriver" then screwdriver = {} end
if not minetest.get_modpath"farming" then farming = {} end
LIGHT_MAX = 14

default.gui_bg = ""
default.gui_bg_img = ""
default.gui_slots = ""
function default.get_hotbar_bg() return "" end
default.LIGHT_MAX = LIGHT_MAX