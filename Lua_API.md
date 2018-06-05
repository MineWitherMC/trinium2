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
	* Returns a table which keys are players and values are data pointers.
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
	* `tbl` is a table with keys being itemstrings and values being their amounts.
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
	* Item map is a table which has itemnames as keys and their amounts as tables.
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

### Miscellaneous
* `string:data()`
	* Deserializes the string.
* `vector.stringify(v)`
	* Returns `x,y,z` string.
* `vector.destringify(v)`
	* Opposite to previous function.

## Various Objects
### DataMesh
DataMesh: object with chained methods. Created via `trinium.api.DataMesh:new()`.

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

### Multiblock Definition
Multiblock definition is a table with following keys:
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
	* `region.counts` is a table whose keys are nodenames and values are their
	 counts in parsed region.
	* `region(map)` checks whether all `map` requirements are satisfied.
* `after_construct` - function of `pos`, `region` and `is_active`. Can be abscent.

### Recipe Method Definition
Recipe Method definition is a table with following keys:
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
* `inputs` - function of `inputs`.
	* Should process inputs.
	* If this returns `-1`, recipe is not created.
	* Returns `inputs` as-is by default.
* `outputs` - function of `outputs`, similar to `inputs`.
* `data` - function of `data`, similar to `inputs`.
* `formspec_begin` - function of `data`.
	* Should return formspec elements to add to recipe.
	* Returns empty string by default.
* `can_perform` - function of `player` and `data`.
	* Should return whether player can perform the recipe.
	* Always true by default.
