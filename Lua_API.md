# Trinium API Additions
* More information at <https://github.com/MineWitherMC/trinium2>


## Introduction
Trinium Game has a lot of mechanics and a lot of builtin helpers which allow
modders to perform their work more efficiently. These helpers include math
functions, table helpers, data structures, inventory helpers and so on.


## Generic Additions
These require `trinium_api` as a dependency.

### Constants
* `math.ln2` - natural logarithm of 2 to be used in calculations.
* #### Sounds
	All of these tables are in `trinium.sounds` table.
	* `default`
	* `default_stone`
	* `default_dirt`
	* `default_gravel`
	* `default_sand`
	* `default_wood`
	* `default_leaves`
	* `default_glass`
	* `default_water`
	* `default_metal`
	* `default_snow`

### Table Helpers
All of these functions are in `table` table.
* `count(arr)`
* `filter(arr, func(value, key))`
* `exists(arr, func)`
	* Examines `arr` on whether it has such element that `func` returns `true`
	 when runned with this element key and value as arguments.
	* If there is a such element, its key is returned.
	* Otherwise, this function returns `false`.
* `every(arr, func)`
* `walk(arr, func, cond())`
	* Runs `func` on all `arr` elements.
	* `cond` is a continuation condition: if it returns `true`, loop is stopped.
* `iwalk(arr, func, cond)`
	* Same but with integer order on lists.
* `map(arr, func)`
* `remap(arr)`
	* Fixes `arr` numerical keys so `#arr` and similar functions would work.
* `intersect_key_rev(arr1, arr2)`
	* Returns all such elements from `arr1` that element with same key isn't
	 in `arr2`. Still don't remember why do I need this.
* `keys(arr)`
* `asort(arr, func)`
	* Returns iterator of `arr` items sorted by keys.
	* `func` is any comparator function, defaults to lua comparison.
* `sum(arr)`
* `fconcat(arr)`
	* Similar to `concat(arr)`, but works with any keys with random order.
* `tail(arr)`
	* Returns table without first element.
* `mtail(arr, mult)`
	* Similar to `tail(arr)`, but `mult` first elements are stripped instead.
* `random(table)`
	* Selects uniform random element from table.
	* Returns a sequence of 3 things: table element, its key and its number.

### Math Helpers
All of these functions are in `math` table.

* `harmonic_distribution(center, tolerance, current, amplitude)`
	* Returns some value which is between `0` and `amplitude` which is more the
	 closer `current` is to `center`.
	* If `current` is not between `center - tolerance` and `center + tolerance`,
	 returns 0.
	* `amplitude` is `1` by default.
* `lograndom(min, max)`
	* Returns normally distributed integer between `min` and `max`.
* `modulate(num, max)`
	* Alternative to Lua builtin modulo which actually returns `max` instead of
	 `0` when `num` is fully divisible by `max`.
* `weighted_random(arr, func)`
	* Returns random key from `arr`. Weight of each key is defined by corresponding
	 value.
	* `func` is random function which can be called like following:
	 `func(min, max)`. `math.random` by default.
* `weighted_avg(arr)`
	* Returns weighted mass center of `number`s.
	* `arr` is an array of pairs `{number, weight}`.
* `geometrical_avg(arr)`
	* Returns geometric mean of `arr` elements.

### Random functions
All of these functions are in `trinium.api` table.

* `roman_number(num)`
	* Returns `num` in roman notation.
	* Does not work properly in case `num` is too large.
* `table_multiply(table, num)`
	* Returns table obtained from multiplying each `table` element with `num`.
* `get_data_pointer(pn, id)`
	* Returns mod storage table which is automatically saved on shutdown.
* `get_data_pointers(id)`
	* Returns a table formatted as `[PlayerName] => DataPointer`.
	* Data Pointers are automatically obtained when needed.
* `register_fluid(src_name, flow_name, src_desc, flow_desc, color, def)`
	* A shortcut for registration of simple colored fluid nodes.
	* `def` replaces the default fluid definition table.
	* *Has an alias `register_liquid`.*
* `register_multiblock(name, def)`
	* Registers multiblock. See **Multiblock Definition** for more information.
* `dump(...)`
	* Logs all input variables.
* `setting_get(name, default)`
	* Returns `name` variable from `minetest.conf`.
	* In case it isn't present, returns `default`, also changing the file.
* `advanced_search(init, serialize, vertex)`
	* Runs BFS and returns `DataMesh` with search results.
	* `init` is the first vertice added to graph.
	* `vertex` is a function that should return list of vertices connected to the
	 given one.
	* `serialize` is a function that should return serialized version of vertice
	 (must not return a table).
	* Returned elements have the format `{vertice, distance}`.
* `search(init, serialize, vertex)`
	* Similar to previous function, however, returns elements in `vertice` format.
* `set_defaults(tbl1, tbl2)`
	* Returns `tbl1` copy with missing values from `tbl2`.
* `string_capitalization(s)`
	* Converts all symbols of the string to lowercase, except for the first one,
	 which becomes uppercase, and returns it.
* `string_separation(s)`
	* Similar to previous one, but also replaces all underscores with spaces.
* `string_superseparation(s)`
	* Similar to previous one, but also Makes All Words Name Case.
* `translate_requirements(tbl)`
	* Returns string with list of needed items.
	* `tbl` is a table formatted as `[ItemString] => amount`.
* `multiblock_rename(def)`
	* Renames multiblock controller to have needed nodes.
	* `def` is in Multiblock Definition format.
* `sort_by_param(k)`
	* Returns a function for sorting tables which have `k` key.
* `count_stacks(inv, list, disallow_multistacks)`
	* Returns count of stacks in inventory given list.
	* In case `disallow_multistacks` is present and true, returns unique stack
	 count.
* `iterator(callback)`
	* Returns an iterator to use in a `for` loop.
	* `callback(n)` is function that returns `n`-th element of desired table.
* `get_fs_texture(...)`
	* Returns a sequence of brightened given items textures.
* `get_field(item, key)`
	* Returns definition `key` field if `item` is defined, otherwise `nil`.
* `get_texture(item)`
	* Returns item texture if it is defined, otherwise `nil`.
* `process_color(color)`
	* Converts `color` to colorstring format and makes it semi-transparent.
* `cstring(color)`
	* Same thing without transparency.
* `adder()`
	* Returns a table and `add` function for the table. Useful for registrators.
* `get_item_identifier(stack)`
	* Similar to `stack:to_string()`, but strips the item count.
* `initialize_inventory(inv, arr)`
	* Sets inventory list sizes.
* `initializer(def0)`
	* Returns a function that initializes inventory and optionally `formspec` at
	 given position. Useful for `on_construct`.
* `inv_to_itemmap(list)`
	* Converts inventory list obtained via `inv:get_list"listname"` to item map.
	* Item map is a table formatted as `[ItemString] => amount`.
	* Does not properly work with `metadata`.
* `recolor_facedir(pos, n)`
	* Given a node with `paramtype2 = colorfacedir`, changes its color.
	* `n` is integer between 0 and 7.
* `get_color_facedir(pos)`
	* Given a node with `paramtype2 = colorfacedir`, returns its color.

### Recipe functions
All of these functions are in `trinium.recipes` table.
* `add(method, inputs, outputs, data)`
	* Adds recipe.
	* `data` is a table which required/optional fields are defined by `method`.
* `add_method(name, def)`
	* Adds recipe method. See **Recipe Method Definition** for more information.
* `get_coords(width, dx, dy, n)`
	* Returns a single button coordinate pair.
	* Allows for easy arranging buttons in a rectangle.
	* `dx` and `dy` are used as distance from formspec corner.
* `check_inputs(input_map, needed_inputs)`
	* Returns `true` if all `needed_inputs` can be taken from `input_map`.
	* Also see `inv_to_itemmap`.
* `remove_inputs(inv, list, inputs)`
	* Removes a lot of items from inventory in one run.
* `recipes.stringify(len, arr)`
	* Returns a string composed of `arr`'s elements separated by colons.
	* In case some of fields of `arr` are nil, fills the first `len` with empty
	 strings (leaving non-empty as they are).

### Queueing
Did you ever need to soft-depend on mod, or to create a cyclic dependency? These
 problems are easily solved by queueing!

All of these functions are inside `trinium.api` table.

* `init_wrap(func, ...)`
	* Returns a wrapper function which runs given function with given args.
* `delayed_call(dep, func, ...)`
	* Runs `func` with given args after `dep` has sent its init signal.
	* Doesn't work if `dep` doesn't send init signal.
	* Does nothing if `dep` is not installed, this can be useful e.g. for soft
	 dependencies.
* `send_init_signal()`
	* Runs all functions that are queued behind mod this function is runned from.

### Miscellaneous
* `string:data()`
	* Deserializes the string.
* `vector.stringify(v)`
	* Returns `x,y,z` string.
* `vector.destringify(v)`
	* Opposite to previous function.


## Research System
These require `trinium_research` and are stored in `trinium.research` table.

### Constants
* `lens_data` - table with following elements:
	* `gems` - table formatted as `[material ID] => ItemString`.
	* `metals` - similar to previous one.
	* `shapes` - table formatted as `[material ID] => minTier`, where `minTier` is
	 minimum required upgrade tier for Randomizer to create them.
* `constants`
	* `press_cost` - amount of Rhenium Alloy Randomizer needs per one press.
	* `min_gems` - minimum amount of Gems press can require.
	* `max_gems`
	* `min_metal`
	* `max_metal`
	* `max_tier` - maximum lens tier, unrelated to upgrades!
* `chapters` - table formatted as `[chapter ID] => definition`.
* `researches` - table formatted as `[res. ID] => definition`.
* `researches_by_chapter` - table formatted as `[chapter ID] => {[res. ID] =>
 definition, ...}`.
* `aspects` - table formatted as `[aspect ID] => definition`.
* `aspect_list` - sorted list of `aspect ID` elements.

### Methods
* `add_chapter(name, def)`
	* Adds research chapter. See **Chapter Definition** for more information.
* `add(name, def)`
	* Adds research. See **Research Definition** for more information.
* `add_chapter_req(name, parent)`
* `add_req(name, parent)`
* `check(pn, name)`
	* Returns `true` if and only if player has unlocked requested research.
* `get_tree(name)`
	* Returns list-based `DataMesh` of requirements of given research, recursively.
* `grant(pn, name)`
	* Gives player requested research if its requirements are already completed.
* `force_grant(pn, name)`
	* Gives player requested research recursively.
* `add_aspect(name, def)`
	* Adds aspect. See **Aspect Definition** for more information.
* `random_aspects(pn, num, tbl)`
	* Gives player given number of randomized aspects from given table.
	* Given aspects are not unique and can repeat.


## Tinkering
These require `tinker_phase` and are stored in `tinker` table.

### Constants
* `materials` - table formatted as `[ItemString] => definition`.
* `patterns` - table formatted as `[pattern ID] => definition`.
* `modifiers` - table formatted as `[trait ID] => definition`.
* `tools` - table formatted as `[tool ID] => definition`.
* `base` - table with following elements:
	* `cracky` - speeds of hand-breaking cracky nodes with levels 1, 2 and 3.
	* `crumbly`
	* `choppy`
	* `snappy`

### Methods
* `add_material(itemstring, def)`
	* Adds Tool Material. See **Tool Material Definition** for more information.
* `add_system_material(obj, def)`
	* Similar to previous one, however, `obj` is material handle created by
	 `trinium.materials.new`.
	* Color is set automatically.
* `add_pattern(name, def)`
	* Adds Tool Pattern. See **Tool Pattern Definition** for more information.
* `add_modifier(name, def)`
	* Adds Tool Modifier or Trait. See **Trait Definition** for more information.
* `add_tool(name, def)`
	* Adds Tool Template. See **Tool Definition** for more information.
* `get_color(num)`
	* Returns color the durability string is colored to.
	* `num` is between `0` and `1`.
* `wrap_description(version, def)`
	* Returns tool description. See **Tool Descriptions** for more informations.
	* `version` is definition versions, so older definitions would still work.


## Pulse Network
These require `pulse_network` and are stored in `trinium.pulse_network` table.
* `trigger_update(ctrlpos)`
	* Sends reload signal to all devices connected to network.
	* Should be called whenever items are put or taken into network, etc.
	* Automatically called by Pulsating Combinator and `import_to_controller`.
* `import_to_controller(ctrlpos)`
	* Sends item from controller internal buffer to network, reloading all devices.
* `add_storage_cell(id, texture, desc, types, items)`
	* Adds storage cell.
	* `types` is an integer representing type storage added to network.
	* `items` is an integer representing item storage added to network.


## TesterGregMachines
These require `trinium_machines` and are stored in `trinium.machines` table.

### Constants
* `default_hatches` - table formatted as `[hatch ID] => ItemString`.

### Methods
* `set_default_hatch(hatch_id, item)`
	* Sets default hatch.
	* This hatch will be shown in place of `hatch:desired_hatch_type` entries in
	 `addon_map` (however, any hatch can be used in actual multiblock).
* `machines.register_multiblock(GregDef)`
	* Registers multiblock with dynamically-positioned hatches, recolored casings
	 and a lot of other nifty features.
	* Returns a sequence of `multiblock_def`, `destruct`, `i`, `o` and `data`.
		* `multiblock_def` can be used via `trinium.api.register_multiblock(name,
		 multiblock_def)`.
		* `destruct` has to be set as node `on_destruct` function.
		* Other values can be used via `trinium.recipes.add("greggy_multiblock",
		 i, o, data)`.
	* See **Greggy Multiblock** for more information.


## Mapgen Module
These require `trinium_mapgen` and are stored in `trinium.mapgen` table.
* `register_vein(name, def)`
	* Registers Ore vein. Map chunks generally have a single vein per chunk.
	* See **Vein Definition** for more information.


## Miscellanous
* Better Inventory is fully backwards-compatible with sfinv, so no API here.
* cmsg is fully backwards-compatible with original cmsg, so no API here.
* ### HUD
	These require `trinium_hud` and are stored in `trinium.hud` table.

	#### Constants
	* `steps` - table formatted as `[[globalstep ID] => definition]`.

	#### Methods
	* `register_globalstep`
		* Globalstep wrapper. See **Globalstep Wrapper** for more information.

## Various Objects
### DataMesh
DataMesh: object with chained methods. Created via `trinium.api.DataMesh:new()`.
 Requires `trinium_api` as a dependency.

Existing methods:
* `dm:data()`
	* Returns DataMesh internal table.
* `dm:data(arr)`
	* Sets DataMesh internal table, by reference.
* `dm:filter(func(value, key))`
* `dm:map(func(value, key))`
* `dm:forEach(func(value, key))`
* `dm:exists(func(value, key))`
	* If `func` returns `true` when some of fields is passed, its key is returned.
	* If several fields return `true`, one if them is returned (in table order).
	* Otherwise, returns `false`.
* `dm:serialize()`
* `dm:count()`
* `dm:copy()`
* `dm:push(val)`
	* Inserts variable into internal table.
	* Only works when internal table is a list.
* `dm:unique()`


## Various Definitions
### Multiblock Definition
Multiblock definition is a table with following elements:
* `controller` - parsed node, which must have `paramtype2` of `facedir`.
* `width` - integer, processed distance to the left and right from controller.
* `depth_b` - integer, processed distance behind of controller.
* `depth_f` - integer, processed distance in front of controller.
* `height_d` - integer, processed distance to the bottom from controller.
* `height_u` - integer, processed distance to the top from controller.
* `map` - parsed node list in format `{x = dx, y = dy, z = dz, name = name}`.
	* `dx` is an integer and represents sideward shift.
	* `dx` is negative if node is at the left of controller.
	* `dy` is an integer and represents vertical shift.
	* `dy` is negative if node is below the controller.
	* `dz` is an integer and represents front-back shift.
	* `dz` is negative if node is in front of controller.
	* `name` is needed node name.
	* In most cases, adding `map` causes multiblock recipe to be created.
	* `map` is not required and can be substituted with `activator`.
	* `map` is not checked in case `activator` is set.
* `activator` - function of `region`. Returns whether multiblock is correct.
	* `region.region` is a obtained node list in format `{x = dx, y = dy, z = dz,
	 actual_pos = vec, name = name}`.
		* `dx`, `dy` and `dz` have the same format as `map` ones.
		* `actual_pos` is a vector from `{x=0, y=0, z=0}` to obtained node.
	* `region.counts` is a table formatted as `[ItemString] => amount`.
	* `region(map)` checks whether all `map` requirements are satisfied.
* `after_construct` - function of `pos`, `region` and `is_active`. Can be abscent.

### Recipe Method Definition
Recipe Method definition is a table with following elements:
#### Required
* `input_amount` - integer.
* `output_amount` - integer.
* `get_input_coords` - function of input slot. Should return coords in format
 `x, y`.
* `get_output_coords` - function of output slot, similar to previous one.
* `formspec_width` - float.
* `formspec_height` - float.
* `formspec_name` - string, inserted at the top left of formspec.
#### Optional (Callbacks)
* `callback` - function of `inputs`, `outputs` and `data`.
	* If this returns string, the recipe method is changed.
	* Otherwise the recipe is processed further.
	* Should **never** create an infinite loop.
	* No redirects by default.
* `process` - function of `inputs`, `outputs` and `data`.
	* Should return processed `inputs`, `outputs` and `data`.
	* If this returns `-1` as any of return values, recipe is not created.
	* Returns given variables as-is by default.
* `formspec_begin` - function of `data`.
	* Should return formspec elements to add to recipe.
	* Returns empty string by default.
* `can_perform` - function of `player` and `data`.
	* Should return whether player can perform the recipe.
	* Always true by default.
* `recipe_correct` - function of `data`.
	* Should return whether recipe is correctly composed.
	* If this function returns `false`, minetest instance is terminated.
	* Always true by default.

### Aspect Definition (`trinium_research`)
Aspect Definition is a table with following elements:
* `texture` - TextureString.
* `name` - string, description of aspect item.
	* Should contain aspect latin name on first line and localized name on second.
* `req1` - string, ID of 1st component.
	* Defaults to abscence of 1st component (e.g., Base Aspect).
* `req2` - string.

### Tool Material Definition (`tinker_phase`)
Tool Material Definition is a table with following elements:
* `color` - ColorString, can be abscent if `add_system_material` is used.
* `base_durability` - integer.
* `base_speed` - float, relative to hand speed (`tinker.base`).
* `level` - integer.
	* Note that tinkered tools durability doesn't depend on `level`.
* `rod_durability` - float, durability multiplier.
* `traits` - table formatted as `[trait ID] => level`.
	* Tool trait level is calculated as maximum of all levels with same ID.
* `description` - localized string.

### Tool Pattern Definition (`tinker_phase`)
Tool Pattern Definition is a table with following elements:
* `description` - string with **exactly one** `@1` translation element.
	* This element will be substituted with material description.
* `cost` - integer, material cost for the pattern.
* `type` - integer, either `1` or `2`.
	* If this is `1`, the part material `base_durability` is averaged with other
	 parts of type 1, and this part is also used to calculate tool speed.
	* Common examples include pickaxe/axe/whatever blades.
	* If this is `2`, the part material `rod_durability` is averaged with other
	 parts of type 2, and this part is not used to calculate tool speed.
	* Common examples include tool rods.
* Texture file must be called `tinker_phase.part.<id>.png`.

### Trait Definition (`tinker_phase`)
Trait Definition is a table with following elements:

#### Required
* `description` - localized string, probably colorized.
* `incompat` - list of trait IDs this trait doesn't work with.
#### Callbacks
* `after_use` - function of `player`, `stack`, `trait_level` and `node`.
	* Called after tool with this trait digs any block.
* `after_create` - function of `trait_level` and `meta`.
	* Called after tool with this trait is created.

### Tool Definition (`tinker_phase`)
Tool Definition is a table with following elements:
* `times` - table formatted as `[group] => time`.
	* `time` is a float, the higher it is - the slower this group nodes are dug.
* `durability_mult` - float.
	* The final tool durability is multiplied by this value.
* `components` - list of elements from `tinker.patterns`.
	* The tool is assembled when all these elements are put into table and nothing
	 more.
	* Should be unique.
* `level_boost` - integer.
	* Increases tool maximum harvest level.
	* Can decrease it, when negative.
	* Tool won't assemble if calculated level is below 0.
* `update_description` - function of `stack`.
#### Tool Descriptions
* Whenever a tool changes it description (e.g, when its durability is changed),
 it calls `update_description` callback from tool definition on itself.
* Best way to get the description (unless you want something really fancy) is
 calling `wrap_description` function.
##### `wrap_description` definition table
* API v1 fields:
	* `current_durability` - integer.
	* `max_durability` - integer.
	* `base` - actual item description, localized string.
	* `modifiers` - table formatted as `[trait ID] => level`.
	* **v1 is by far the newest API version.**

### Greggy Multiblock (`trinium_machines`)
Greggy Multiblock Definition is a table with following elements:
* `controller` - ItemString.
	* Must be a node with `paramtype2` either `colorfacedir` or `facedir`.
* `casing` - ItemString.
	* Must be a node with `paramtype2` either `color` or abscent.
* `size` - `{front = int, back = int, up = int, down = int, sides = int}`.
* `min_casings` - integer.
	* if selected region has less `casing` blocks than this value, multiblock is
	 not assembled.
* `addon_map` - table.
	* Same format as `map` within **Multiblock Definition**, however, casings and
	 hatches are not needed.
	* Checked in order to complete multiblock.
	* Forcing specific hatch at specific position can be done with `name =
 	 hatch:desired_hatch_type`.
* `color` - integer.
	* All casing and hatch `param2` in calculated regions are set to this value.
	* Recommended to have all casings and hatches with `paramtype2 = color` and
	 the same palette.
* `hatches` - list of hatches possible for the machine.

### Vein Definition (`trinium_mapgen`)
Vein Definition is a table with following elements:
* `ore_list` - list of ItemStrings.
* `ore_chances` - list of integers.
	* This must be of the same length as `ore_list`.
	* Each number sets relative rarity of corresponding ore in vein.
* `density` - integer from 0 to 100.
	* Percentage of ore blocks per vein. 100 means no stone will be left, whereas
	 0 means no ores will be spawned.
* `weight` - positive integer.
	* The more this variable is, the more common the vein is.
	* General recommendation is 5-10 for very rare veins, 20-30 for rare, 40-60
	 for common and 70-100 for abundant/very common.
* `min_height` - integer.
* `max_height` - integer.

### Globalstep Wrapper (`trinium_hud`)
Globalstep Definition is a table with following elements:
* `period` - float, time in seconds between runs.
* `callback` - function of `dtime`.
* `consistent` - boolean.
	* If `true`, new function run won't happen before old one stops.
	* `false` by default.
