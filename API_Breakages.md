# Trinium API Breakages

### 17.06.2018
* `nei.func` functions now depend on either `trinium_inventory` or `nei`, but not
 `trinium_player`.
* `betterinv.func` functions now depend on either `trinium_inventory` or `sfinv`,
 but not `better_inventory`, to ensure sfinv mods working under BetterInventory
 without modification.

### 16.06.2018
* Removed `nei.draw_research_recipe` function. Use `nei.draw_recipe_raw` instead.
* Removed `nei.absolute_draw_recipe` function. Use `nei.draw_recipe_raw` instead.
