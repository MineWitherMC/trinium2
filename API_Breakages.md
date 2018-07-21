# Trinium API Breakages

### 201807-G (20.07.2018)
* `implementing_object = node` now is replaced with `implementing_objects =
 {node}` to add possibility to implement via different machines.
* `functions.returner` is renamed to `functions.identity` to decrease confusion.
* Removed `api.get_texture` due to uselessness.
* `table.random_map` is now replaced with `table.random`. 

### 201807-D (18.07.2018)
* Object returned by `hud.configurator` now has a table argument instead of a
 sequence one.
* `betterinv.XYZ` functions now depend on `betterinv` instead of `sfinv`.

### 17.06.2018
* `nei.func` functions now depend on either `trinium_inventory` or `nei`, but not
 `trinium_player`.
* `betterinv.func` functions now depend on either `trinium_inventory` or `sfinv`,
 but not `better_inventory`, to ensure sfinv mods working under BetterInventory
 without modification.

### 16.06.2018
* Removed `nei.draw_research_recipe` function. Use `nei.draw_recipe_raw` instead.
* Removed `nei.absolute_draw_recipe` function. Use `nei.draw_recipe_raw` instead.
