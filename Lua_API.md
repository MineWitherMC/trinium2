# Trinium API Additions
* More information at <https://gitlab.com/MultiDragon/trinium>
* Last API breakage at 23.07.2018 (1.0-1-1)


## Introduction
Trinium Game has a lot of mechanics and a lot of builtin helpers which allow
modders to perform their work more efficiently. These helpers include math
functions, table helpers, data structures, inventory helpers and so on.

### Introduction on function descriptions
* Functions are described as `return_type func_name(type1 arg1, ...)`.
* There are following types:
	* `int` - any integer;
	* `double` - any integer or fractional number;
	* `bool` - `true` or `false`;
	* `void`, aka `nil` - this argument / return value is ignored;
	* `function` - represented as above, or as `function<type>(args...)` if it is returned;
	* `String`;
	* `Iterator(type1 el1, ...)` - value that can be used in `for i in x` loop;
	* `Object` - any value;
	* `Primitive` - `int`, `double`, `bool` or `String`;
	* `Set(type el)` - table formatted as `[elN] => 1`;
	* `Sequence(type1 el1, ...)` - uses variable output value Lua feature.
		* Also represented as `type1 el1, ...` or `{type1 el1, ...}`.
	* `LSequence(type1 el1)` - sequence with variable number of elements.
		* Also represented as `type1... el1`.
	* Any of these types can be superceded with `[]` to show that it's table of these elements,
	 or with `<>` to show it's list of these elements.
	* Additionally, integer can be substituted inside the `[]` or `<>` to allow
	 fixed-length variables.
* Other from that, there are several objects added by the game:
	* `DataMesh<>(type el)` (list) and `DataMesh[](type el)` (map) - see **DataMesh**;
	* `DataPointer` - `Object[]`, automatically saved when player logs out;
	* `MaterialHandle` - `Object[]`, see **Material System**;
	* `ItemID` - `String` made from `stack:to_string()` by removing amount;
	* `ItemMap` - `int[]` formatted as `[ItemID] => amount`;
	* `ConfiguratorHandle` - `Object[]`, see **HUD Configurator**;
* Also, there are several objects added by the engine:
	* `InvRef`;
	* `InvList`;
	* `ItemStack`;
	* `ItemStackMetaRef`;
	* `PlayerRef`;
	* `vector`.
* Type can be represented as `type1|type2|...` to allow choice.
* If argument is optional, it is described as `[typeN argN]`.


## Generic Additions
These require `trinium_api` as a dependency.

### Algorithms
* `DataMesh(Object<2>) api.advanced_search(Object init, Primitive serialize(Object o),
 Set(Object) vertex(Object o, int depth))`
	* Runs BFS and returns `DataMesh` with search results.
	* `init` is the first vertex added to graph.
	* `vertex` is a function that returns set of connected vertices.
	* Returned DataMesh elements have the format `{vertex, distance}`.
* `DataMesh(Object) api.search(Object init, Primitive serialize(Object o),
 Set(Object) vertex(Object o, int depth))`
 	* Similar to previous function, but has different return type.
* `Iterator(Object...) api.iterator(Object... call(int current))`
	* Returns an iterator to use in a `for` loop.

#### Simple Callback Functions
* `Object api.functions.identity(Object x)`: returns `x`
* `function<Object>() api.functions.const(Object x)`: returns function returning `x`
* `function<bool>(Object) api.functions.equal(Object b)`: returns function checking whether `a=b`
* `void api.functions.empty()`: does nothing
* `Object<0> api.functions.new_object()`: returns new empty object 
* `function<bool>(Object[], Object[]) api.sort_by_param(Object k)`
	* Returns comparison function which compares object by given value.

### Compatibility
* `void api.set_master_prepend(String s)`
	* Sets Formspec prepended string for all players.

### Data Pointers
* `DataPointer api.get_data_pointer(String pn, String id)`
	* Returns mod storage table which is automatically saved on shutdown.
* `DataPointer[] api.get_data_pointers(String id)`
	* Returns a table formatted as `[PlayerName] => DataPointer`.
	* Needed Data Pointers are automatically obtained when needed.

### Fluids
* `void api.register_fluid(String src_name, String flow_name, String src_desc, String flow_desc,
 String color, Object[] def)`
	* A shortcut for registration of simple colored fluid nodes.
	* `def` replaces the default fluid definition table.
	* *Has an alias `register_liquid`.*

### Inventories
* `void api.initialize_inventory(InvRef inv, int[] arr)`
	* Sets inventory list sizes.
* `function<void>(vector) api.initializer(Object[] def)`
	* Returns function doing the following:
		* If `def` contains `formspec` field, set it as formspec for node on given position and remove it.
		* After that, run previous function to set inventory.
* `ItemMap api.inv_to_itemmap(InvList... lists)`
	* Converts inventory lists obtained via `inv:get_list"listname"` to ItemMap.
	* Strips `ItemStackMetaRef` in the process.
* `ItemID api.get_item_identifier(ItemStack stack)`
	* Similar to `stack:to_string()`, but strips the item count.
* `int api.count_stacks(InvRef inv, String list, [bool disallow_multi_stacks])`
	* Returns count of stacks in given inventory list.
	* In case `disallow_multi_stacks` is present, returns unique stack count.
* `String api.formspec_escape_reverse(String escaped_s)`
	* Reverse function to `minetest.formspec_escape`.

### Math
* `int math.modulate(int num, int divisor)`
	* If `num` is fully divisible by `divisor`, returns `divisor`.
	* Otherwise, returns remainder of dividing `num` by `divisor`.
* `double math.harmonic_distribution(double center, double tolerance, double v, [double amplitude])`
	* If `v` is not between `center - tolerance` and `center + tolerance`, returns 0.
	* Otherwise, returns positive Y coordinate of point with `X = v` on a circle with diameter on points
	 `(center - tolerance, 0)` and `(center + tolerance, 0)`.
	* `amplitude` defaults to `1`.
* `int math.gaussian(int min, int max)`
	* Returns normally distributed random integer between `min` and `max`.
* `int math.weighted_random(double[] arr, [int random_func(int min, int max)])`
	* Returns random key from `arr`. Weight of each key is defined by corresponding value.
	* `random_func` defaults to `math.random`.
* `int math.weighted_avg(double<2>[] arr)`
	* Returns floored weighted mass center of array elements.
	* Element value is first list element, while its weight is its second element.
* `double math.geometrical_avg(double<> arr)`
	* Returns geometric mean of array elements.
* `int math.gcd(int a, int b)`
	* Returns greatest common divisor of given numbers.
	* Returns `nil` in case one of given inputs (or both) is not number.
* `double math.round(double a, double b)`
	* Rounds `a` so the result is fully divisible by `b`.

### Multiblocks
* `void api.add_multiblock(String name, Object[] def)`
	* Registers multiblock. See **Multiblock Definition** for more information.
* `void api.multiblock_rename(Object[] def)`
	* Renames multiblock controller to have needed nodes.
	* `def` is a Multiblock Definition.
* `void api.multiblock_rich_info(String node)`
	* Adds Rich info to given multiblock controller.
	* In case the structure is not assembled, shows a message about that.
	* In case the node already has Rich Info, it is only shown when multiblock is assembled.

### Queueing
Did you ever need to soft-depend on mod, or to create a cyclic dependency? These
 problems are easily solved by queueing!

* `void api.send_init_signal()`
	* Runs all functions that are queued behind mod this function is executed from.
* `function<void>() api.init_wrap(void call(Object... args), Object... args)`
	* Returns a wrapper function which runs given function with given args.
* `void api.delayed_call(String|String<> dependencies, void call(Object... args), Object... args)`
	* Runs `func` with given args after `dep` has sent its init signal.
	* Does nothing if `dep` doesn't send init signal.
	* Does nothing if `dep` is not installed, this can be useful e.g. for soft dependencies.
	* Function is launched instantly if given mod has already sent its signal.
	* `dep` can also be a list of all needed dependencies.

### Random Module
* `String api.roman_number(int num)`
	* Returns `num` in roman notation.
	* Does not work properly in case `num` is too large.
* `double[] api.table_multiply(double[] table, double num)`
	* Returns table obtained from multiplying each array element with `num`.
* `void api.dump(Object[]... o)`
	* Logs all input variables.
* `String api.setting_get(String name, String default)`
	* Returns `name` variable from `minetest.conf`.
	* In case it isn't present, returns `default`, also changing the file.
* `Object[] api.set_defaults(Object[] tbl1, Object[] tbl2)`
	* Returns `tbl1` copy with missing values from `tbl2`.
* `String api.string_capitalization(String s)`
	* Converts all symbols of the string to lowercase, except for the first one,
	 which becomes uppercase, and returns it.
* `String api.string_separation(String s)`
	* Similar to previous one, but also replaces all underscores with spaces.
* `String api.string_superseparation(String s)`
	* Similar to previous one, but also Makes All Words Name Case.
* `String api.translate_requirements(int[] tbl)`
	* Returns string with list of needed items.
	* `tbl` is a table formatted as `[ItemString] => amount`.
* `Object api.get_field(String item, String key)`
	* Returns definition `key` field if `item` is defined, otherwise `nil`.
* `String api.get_description(String item)`
	* If item and its description both exist, returns `item`.
	* Otherwise, returns first line from its description.
* `String... api.get_fs_texture(String... ids)`
	* Returns a sequence of brightened given items textures.
* `String api.process_color(String|int<3> color)`
	* Converts `color` to ColorString format and makes it semi-transparent.
* `String api.color_string(String|int<3> color)`
	* Same thing without transparency.
* `{Object[], function<void>(String, Object)} api.adder()`
	* Returns a table and `add` function for the table. Useful for registration.
* `void api.recolor_facedir(vector pos, int n)`
	* Given a node with `paramtype2 = colorfacedir`, changes its color.
	* `n` is integer between 0 and 7.
	* Node Metadata is unchanged.
* `void api.assert(String condition, String a, String b, String c)`
	* Crashes gracefully if `condition` is not satisfied.

### Recipes
All of these functions are in `trinium.recipes` table.
* `String stringify(int len, String[] arr)`
	* Returns a string composed of `arr`'s elements separated by colons.
	* In case some of fields of `arr` are nil, fills the first `len` with empty
	 strings (leaving non-empty as they are).
* `{String[], String[]} divide(String[] inputs, String[] outputs)`
	* Returns tables obtained via dividing all item amounts in given tables by
	 their greatest common divisor.
	* Example: `divide({"item1 2", "item2 6"}, {"item3 4"})` returns
	 `{"item1 1", "item2 3"}, {"item3 2"}`.
* `int add(String method, String[] inputs, String[] outputs, [Object[] data])`
	* Adds recipe.
	* `data` is a table which required/optional fields are defined by `method`.
	* Some `data` values change various recipe aspects regardless of method:
		* `bool divisible`
			* If `true` recipe is automatically divided by GCD.
			* Also see `divide(inputs, outputs)`.
		* `String[] input_tooltips`
		* `String[] output_tooltips`
	* The recipe can then be obtained via `trinium.recipes.recipe_registry[id]`.
* `void add_method(String name, Object[] def)`
	* Adds recipe method. See **Recipe Method Definition** for more information.
* `{int, int} get_coords(double width, double dx, double dy, int n)`
	* Returns a single button coordinate pair.
	* Allows for easy arranging buttons in a rectangle.
	* `dx` and `dy` are used as distance from formspec corner.
* `function<int, int>(int) coord_getter(double width, double dx, double dy)`
	* Same, with `n` being function argument.
* `bool check_inputs(ItemMap input_map, int[] needed_inputs)`
	* Returns `true` if all `needed_inputs` can be taken from `input_map`.
* `void remove_inputs(InvRef inv, String list, String[] inputs)`
	* Removes a lot of items from inventory in one run.

### Sounds
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
* `int table.count(Object[] arr)`
	* Returns number of `arr` elements.
* `Object[] table.filter(Object[] arr, bool filter(Object value, Object key))`
	* Returns a filtered copy of array with elements not satisfying the filter.
* `Object table.exists(Object[] arr, bool filter(Object value, Object key))`
	* If there is element that satisfies the filter, returns its key.
	* Otherwise, returns `false`.
* `bool table.every(Object[] arr, bool filter(Object value, Object key))`
	* Returns true if all array elements satisfy the filter.
* `void table.walk(Object[] arr, void call(Object value, Object key), [bool condition()])`
	* Runs `func` on all `arr` elements.
	* `condition` is a continuation condition: if it returns `true`, loop is stopped.
* `void table.iwalk(Object<> arr, void call(Object value, Object key), [bool condition()])`
	* Similar to previous one, but works with sorted lists in their order.
* `Object[] table.map(Object[] arr, Object call(Object value, Object key))`
	* Returns a copy of array with values replaced with `call(v, k)`.
* `Object<> table.keys(Object[] arr)`
	* Returns list of array keys.
* `Iterator(int i, Object key, Object value) table.asort(Object[] arr, [bool cmp(Object a, Object b)])`
	* Returns iterator of `arr` items sorted by keys.
	* `cmp` is comparator, defaults to normal comparison.
* `Object<> table.remap(Object[] arr)`
	* Transforms array into sorted list.
* `double table.sum(double[] arr)`
	* Returns sum of `arr` elements.
* `String table.f_concat(String[] arr, [String delim])`
	* Randomly concatenates array.
	* `delim` defaults to empty string.
* `Object<> table.tail(Object<> arr)`
	* Returns array without first element.
	* If given array is empty, returns empty array.
* `Object<> table.multi_tail(Object<> arr, int mult)`
	* Returns array without `mult` first elements.
	* If given array has less than `mult` elements, returns empty array.
* `{Object value, Object key, int i} table.random(Object[] table)`
	* Selects uniformly distributed random element from table.
* `Object<> table.merge(Object<>... tables)`
	* Returns a list of elements of all given tables.

### Miscellaneous
* `String vector.stringify(vector v)`
* `vector vector.destringify(String str)`
* `Object string.data(String self)`
	* Deserializes the string.
* `String string.from_table(String self, Object[] data)`
	* Suppose `self` has variables in form of `${variable_name}`.
	* This function replaces all of them with `data[variable_name]`.
	* Works properly with list and `${1}`/etc.


## Conduits
These require `conduits` as a dependency.

### Methods
* `Set(vector) conduits.get_signal_connections(vector pos)`
	* Returns all signal-based machines straightly connected with node on given position.
* `void conduits.rebuild_signals(vector pos)`
	* Rebuilds params, based on signal emitters in the network.
	* Should be called whenever a node is added/removed from network to change its state.
* `Set(vector) conduits.get_item_connections(vector pos)`
	* Returns all inventories and conduits straightly connected with node on given position.
* `void conduits.send_items_raw(ItemMap items, InvRef inv, String node, vector pos)`
	* Sends given ItemMap to given inventory.
	* `tbl` changes in process and becomes ItemMap with leftover items when the function is done.
* `void conduits.send_items(vector pos, ItemMap tbl)`
	* Sends given ItemMap to inventories via Conduit system.
	* Closer inventories are examined first.
	* `tbl` changes in process and becomes ItemMap with leftover items when the function is done.

### Node Definitions
* Signal Conductors
	* Certain nodes can conduct signals. They must have:
		* Group `signal_param = X` (*Signal Parameter*) with `X` either 1 or 2.
	* Their signal force will be stored in `paramX` field.
* Signal Emitters
	* Certain nodes can "always" emit signals. They must have:
		* Group `signal_emitter = 1`.
	* Other nodes can "sometimes" emit signals. They must have:
		* `paramX = 255`, where X is *Signal Parameter*.
* Signal Acceptors
	* Certain nodes can accept signals. They must have:
		* Group `signal_acceptor = X` with `X` either 1 or 2.
	* Their signal force will be stored in `paramX` field.
* Conduit Item Extraction
	* Certain nodes can push items into Item Pumps. They must have:
		* Group `conduit_extract = 1`;
		* Node definition `String<> conduit_extract` of "extractable" lists.
* Conduit Item Insertion
	* Certain nodes can accept items via conduits. They must have:
		* Group `conduit_insert = 1`;
		* Callback `Object... conduit_insert(ItemStack stack)`.
			* If this callback returns `false`, item is not inserted.
			* If this callback returns `String`, item is put into that list.
			* If this callback returns `{String, int}`, item is put into given list and slot.
			* Regardless of callback, it is automatically checked if item fits into its slot.
		* Optionally, callback `void after_conduit_insert(pos)`.
			* Called after items are inserted into given inventory.


## HUD
These require `trinium_hud` and are stored in `trinium.hud` table.

### Methods
* `void register_globalstep(Object[] def)`
	* Globalstep wrapper. See **Globalstep Wrapper** for more information.
* `ConfiguratorHandle configurator(String id, int x, int y, String desc)`
	* Registers HUD Configuration Tab.
	* See **HUD Configurator** for more information.
	
### Node Definitions
* Rich Info
	* A better way to use `infotext`. Nodes with Rich Info support must have
	 group `rich_info = 1` and a callback `get_rich_info(pos, player)`.
	* The callback can return `nil` in order to hide the Rich Info window.


## Inventory
### BetterInventory
These require `betterinv` as a dependency.
* `void betterinv.register_tab(String name, Object[] def)`
	* Registers an inventory tab.
	* See **Inventory Tab Definition** for more information.
* `String betterinv.generate_buttons(double[] size, bool filter(Object[] def), String selected)`
	* Generates button formspec part or tab header, depending on the mode.
* `String betterinv.generate_formspec(PlayerRef player, String fs, double[] size, string bg, bool show_inv)`
	* Wraps `fs` into a box and adds buttons or tab header, depending on the mode.
* `void betterinv.redraw_for_player(PlayerRef player, [Object[] fields])`
	* Redraws player's inventory. Should not be called from tab callbacks.
	* `fields` defaults to `{}`.
* `void betterinv.disable_tab(String tab)`
	* Makes a tab invisible. Its callbacks still can be fired externally.
* `void betterinv.get_external_context(PlayerRef player, String tab)`
	* Returns requested context.

### NEI
All of these functions are stored in `trinium.nei` table and require `nei`.
* `Object[] draw_recipe_raw(int id)`
	* Draws recipe by Registry ID.
	* Returns a table formatted as `{form = formspec, w = width, h = height}`.
	* Can be directly used for drawing research.
* `{String fs, Object[] size, int id} draw_recipe_wrapped(String item, PlayerRef player, int id, int type)`
	* `type` is integer which changes drawn recipe.
		* `1` draws recipes creating `item`.
		* `2` draws recipes using `item`.
		* `3` draws recipes with `item` as a crafting mechanism.

### Misc
* `void api.try_craft(PlayerRef player)`
	* Requires `nei` as a dependency.
	* Changes player recipe output item.


## TesterGregMachines
These require `trinium_machines` and are stored in `trinium.machines` table.

### Methods
* `void set_default_hatch(String hatch_id, String item)`
	* Sets default hatch.
	* This hatch will be shown in place of `hatch:desired_hatch_type` entries in `addon_map`
	 (however, any hatch can be used in actual multiblock).
* `{mb_def, destruct, i, o, d} machines.add_multiblock(Object[] def)`
	* Registers multiblock with dynamically-positioned hatches, recolored casings
	 and a lot of other nifty features.
	* `mb_def` can be used via `api.add_multiblock(name, mb_def)`.
	* `destruct` must be set as a controller `on_destruct` function.
	* `i`, `o` and `d` can be used via `trinium.recipes.add("greggy_multiblock", i, o, d)`.
	* See **Greggy Multiblock** for more information.

### Node Definition
* Greg Hatches
	* Certain nodes can be made into Greggy Multiblock Hatches. These must have:
		* Group `greggy_hatch = 1`;
		* Node definition `String ghatch_id`;
		* Optionally node definition `int ghatch_max`, maximum number of hatches per multiblock.
			* Defaults to infinity.


## Mapgen Module
These require `trinium_mapgen` and are stored in `trinium.mapgen` table.
* `void register_vein(String name, Object[] def)`
	* Registers Ore vein. Map chunks generally have a single vein per chunk.
	* See **Vein Definition** for more information.


## Material System
These require `trinium_materials` and are stored in `trinium.materials` table.
* `void add_type(String id, void call(Object[] def))`
	* Adds material type.
	* See **Material Type Definition** for more information.
* `void add_combination(String id, Object[] def)`
	* Adds material interaction - action which is performed when a single material
	 has several different material types.
	* See **Material Combinations** for more information.
* `void add_data_generator(String id, Object call(String name))`
	* Adds data generator - function which generates a needed data type.
	* Returned object automatically is set as data element.
* `void add_recipe_generator(String id, void call(MaterialHandle def))`
	* Adds recipe generator - function which generates recipe.
* `String|bool getter(String id, String type, [int amount])`
	* Returns ItemString.
	* `amount` defaults to 1.
	* Returns `false` if this item doesn't exist.
* `String force_getter(String id, String type, [int amount])`
	* Same thing, but never returns `false`.
* `MaterialHandle add(String name, Object[] def)`
	* Adds material.
	* See **Material Definition** for more information.
	* See **Material Handle** for more information.
* `MaterialElementHandle add_element(String name, Object[] def)`
	* Adds material element.
	* See **Material Element Definition** for more information.
	* See **Material Element Handle** for more information.


## Pulse Network
These require `pulse_network` as a dependency.

### Methods
* `void pulse_network.trigger_update(vector ctrlpos)`
	* Sends reload signal to all devices connected to network.
	* Should be called whenever items are put or taken into network, etc.
	* Automatically called by following things:
		* Pulsating Combinator;
		* `import_to_controller`;
		* `execute_autocraft`;
		* `notify_pattern_change`.
* `void pulse_network.import_to_controller(vector ctrlpos)`
	* Sends item from controller internal buffer to network.
	* Automatically calls `trigger_update`.
	* Automatically calls `update_pending_recipe` when needed.
	* Automatically called by `export_from_controller`.
* `String pulse_network.export_from_controller(vector ctrlpos, String id, int count)`
	* Attempts to extract given item from network.
	* Returns ItemString.
* `void pulse_network.notify_pattern_change(vector ctrlpos, ItemStack pattern, String referrer)`
	* Sends controller notification about changed crafting pattern.
	* Should be called whenever patterns are added or removed.
	* `referrer` is a string formatted as `x,y,z|index` (index is optional).
	* Automatically calls `trigger_update`.
* `{bool|DataMesh<>, String|int} pulse_network.request_autocraft(vector ctrlpos, String item_id, int count)`
	* Requests network autocraft.
	* Returns either `false, reason` or `DataMesh<>{{id, count}, distance}, used_memory`.
	* Does NOT initiate the recipe.
* `void pulse_network.execute_autocraft(vector ctrlpos, String item_id, int count)`
	* Initiates the recipe. It *should* be valid (e.g, return no errors when processed via `request_autocraft`).
	* Automatically calls `trigger_update`.
	* Automatically calls `update_pending_recipe`.
* `void pulse_network.update_pending_recipe(vector ctrlpos, int key)`
	* Updates inputs and outputs of given autocraft request.
	* Automatically called by `execute_autocraft`.
	* Automatically called by `import_to_controller` when needed.
* `void pulse_network.add_storage_cell(String id, Object[] texture, String desc, int types, int items)`
	* Adds storage cell.
	* `types` is an integer representing type storage added to network.
	* `items` is an integer representing item storage added to network.
* `void pulse_network.add_crafting_core(String id, Object[] texture, String desc, int processes, int memory)`
	* Adds crafting processor.

### Node Definition
* Network Slaves
	* Certain nodes can be directly connected to network. These must have:
		* Group `pulsenet_slave = 1`;
		* Optionally some of the following callbacks:
			* `void on_pulsenet_connection(vector pos, vector ctrlpos)`;
			* `void on_pulsenet_update(vector pos, vector ctrlpos)`.
* Network Pattern Interfaces
	* Certain Network Slaves can contain Patterns for autocrafting. These must have:
		* `autocraft_buffer` inventory slot with size of at least 16;
		* Optionally some of the following callbacks:
			* `void on_autocraft_insert(vector pos, String index)`.


## Research System
These require `trinium_research` and are stored in `trinium.research` table.
* `void add_chapter(String name, Object[] def)`
	* Adds research chapter. See **Chapter Definition** for more information.
* `void add_chapter_req(String chapter, String research)`
	* Makes given chapter require given research to be unlocked.
* `void add(String name, Object[] def)`
	* Adds research. See **Research Definition** for more information.
* `void add_req(String name, String parent)`
	* Makes `name` require `parent` to be unlocked.
* `bool check(String pn, String name)`
	* Returns `true` if player has unlocked requested research.
* `void basic_grant(String pn, String name)`
	* Gives player requested research.
* `DataMesh<>(String) get_tree(String name)`
	* Returns list-based `DataMesh` of requirements of given research,
	 recursively.
* `bool grant(String pn, String name)`
	* Gives player requested research if its requirements are already completed.
	* Returns `true` if the research was actually given.
* `void force_grant(String pn, String name)`
	* Gives player requested research recursively.
* `void add_aspect(String name, Object[] def)`
	* Adds aspect. See **Aspect Definition** for more information.
* `void random_aspects(String pn, int num, [String<> tbl])`
	* Gives player given number of randomized aspects from given table.
	* Given aspects are not unique and can repeat.
	* List of aspects defaults to all aspects.
* `Object[] label_escape(String text, String description, Object[] aspects)`
	* Returns object that can be used in registering research.
	* This object will create a page bought for aspects and only having given text.

## Tinkering
These require `tinker_phase` as a dependency.
* `void tinker.add_material(String item, Object[] def)`
	* Adds Tool Material. See **Tool Material Definition** for more information.
* `void tinker.add_system_material(MaterialHandle obj, Object[] def)`
	* Similar to previous one, however, `obj` is material handle created by `trinium.materials.new`.
	* Color is set automatically.
* `void tinker.add_pattern(String name, Object[] def)`
	* Adds Tool Pattern. See **Tool Pattern Definition** for more information.
* `void tinker.add_modifier(String name, Object[] def)`
	* Adds Tool Modifier or Trait. See **Trait Definition** for more information.
* `void tinker.add_tool(String name, Object[] def)`
	* Adds Tool Template. See **Tool Definition** for more information.
* `String tinker.get_color(double num)`
	* Returns color the durability string is colored to.
	* `num` is between `0` and `1`.
* `String wrap_description(int version, Object[] def)`
	* Returns tool description. See **Tool Descriptions** for more information.
	* `version` is definition versions, so older definitions would still work.


## Various Objects
### DataMesh
DataMesh: object with chained methods. Created via `trinium.api.DataMesh:new()` from `trinium_api`.

Existing methods:
* `Object[] dm:data()`
	* Returns DataMesh internal table.
* `DataMesh[] dm:data(arr)`
	* Sets DataMesh internal table, by reference.
* `DataMesh[] dm:filter(bool filter(Object value, Object key))`
* `DataMesh[] dm:map(Object call(Object value, Object key))`
* `DataMesh[] dm:forEach([bool sorted], void call(Object value, Object key))`
	* `sorted` defaults to `false`.
	* If `sorted` is `true`, uses `ipairs` instead of `pairs`.
* `DataMesh<> dm:remap()`
* `DataMesh<> dm:sort([bool cmp(Object a, Object b)])`
* `Object dm:exists(bool filter(Object value, Object key))`
* `String dm:serialize()`
* `int dm:count()`
* `DataMesh[] dm:copy()`
* `DataMesh<> dm:push(Object val)`
	* Inserts variable into internal table.
	* Only works when internal table is a list.
* `DataMesh[] dm:unique()`

### HUD Configurator (`trinium_hud`)
HUD Configuration Window. Created via `trinium.hud.configurator(...)`.
 
Existing methods:
* `void conf:add(String id, Object[] def)`
	* Adds Configurator element. See **Configurator Element Definition** for more
	 information.

### Material Handle (`trinium_materials`)
Created via `trinium.materials.add(...)`.

Existing methods:
* `MaterialHandle material:generate_recipe(String id)`
* `MaterialHandle material:generate_data(String id)`
* `MaterialHandle material:generate_interactions()`
* `String material:get(kind, amount)`

### Material Element Handle (`trinium_materials`)
Created via `trinium.materials.add_element(...)`.

Existing methods:
* `MaterialHandle material:register_material(Object[] overrides)`
	* See **Material Definition** for more information.


## Various Definitions
### Multiblock Definition
Multiblock definition is a table with following elements:
* `String controller` - parsed node, must have `paramtype2` of `facedir` or `colorfacedir`.
* `int width` - processed distance to the left and right from controller.
* `int depth_b` - processed distance behind of controller.
* `int depth_f` - processed distance in front of controller.
* `int height_d` - processed distance to the bottom from controller.
* `int height_u` - processed distance to the top from controller.
* `[Object[]<> map]` - parsed node list in format `{int x, int y, int z, String name}`.
	* `x` represents shift to the right or left.
	* `x` is negative if node is at the left of controller.
	* `y` represents vertical shift.
	* `y` is negative if node is below the controller.
	* `z` represents front-back shift.
	* `z` is negative if node is in front of controller.
	* In most cases, adding `map` causes multiblock recipe to be created.
	* `map` is not checked in case `activator` is set.
* `[bool activator(Object[] region)]`
	* `region` is formatted as `{Object[][] region, ItemMap counts}`.
	* `region.region` is a node list in format `{int x, int y, int z, vector actual_pos, String name}`.
	* `region(map)` can check whether all `map` requirements are satisfied.
* `[void after_construct(vector pos, Object[] region, bool is_active)]`
	* Called after multiblock tick is done.
	* Defaults to empty function.

### Recipe Method Definition
Recipe Method definition is a table with following elements:
#### Required
* `int input_amount`
* `int output_amount`
* `{double, double} get_input_coords(int n)`
* `{double, double} get_output_coords(int n)`
* `double formspec_width`
* `double formspec_height`
* `String formspec_name`

#### Optional
* `String|void callback(String[] inputs, String[] outputs, Object[] data)`
	* If this returns string, the recipe method is changed and callback is re-run again on the new method.
	* Otherwise the recipe is processed further.
* `{String[] i, String[] o, Object[] d} process(String[] i, String[] o, Object[] data)`
	* Should return processed `inputs`, `outputs` and `data`.
	* If this returns `-1` as any of return values, recipe is not created.
* `String formspec_begin(Object[] data)`
	* Should return formspec elements to add to recipe.
* `bool can_perform(PlayerRef player, Object[] data)`
	* Should return whether player can perform the recipe.
* `bool recipe_correct(Object[] data)`
	* Should return whether recipe is correctly composed.
	* If this function returns `false`, minetest instance is terminated.

### Globalstep Wrapper (`trinium_hud`)
Globalstep Definition is a table with following elements:
* `double period` - time in seconds between runs.
* `void callback(double dtime)`
* `[bool consistent]` - boolean.
	* If `true`, new function run won't happen before old one stops.
	* Defaults to `false`.

### Configurator Element Definition (`trinium_hud`)
Configurator Element Definition is a table with following elements:
* `String label`
* `void callback(PlayerRef player, String value)`
	* Should change needed configuration field.
* `int y`
* `String get_current(PlayerRef player)`

### Inventory Tab Definition (`better_inventory`)
Inventory Tab Definition is a table with following elements:
* `String description`
* `String getter(PlayerRef player, Object[] context)`
* `[void processor(PlayerRef player, Object[] context, Object[] fields)]`
	* `fields` can be empty.
* `[bool available(PlayerRef player)]`

### Greggy Multiblock (`trinium_machines`)
Greggy Multiblock Definition is a table with following elements:
* `String controller` - node with `paramtype2` either `colorfacedir` or `facedir`.
* `String casing` - node with `paramtype2` either `color` or default.
* `int[] size` - `{int front, int back, int up, int down, int sides}`.
* `int min_casings` - if selected region has less `casing` blocks than this value,
 multiblock is not assembled.
* `Object[][] addon_map` - table.
	* Same format as `map` within **Multiblock Definition**, however, casings and hatches are not needed.
	* Checked in order to complete multiblock.
	* Forcing specific hatch at specific position can be done with `name = hatch:desired_hatch_type`.
* `int color`
	* All casing and hatch `param2` in calculated regions are set to this value.
	* Recommended to have all casings and hatches with `paramtype2 = color` and the same palette.
* `String<> hatches` - list of hatches possible for the machine.

### Vein Definition (`trinium_mapgen`)
Vein Definition is a table with following elements:
* `ItemString<> ore_list`
* `integer<> ore_chances`
	* This must be of the same length as `ore_list`.
	* Each number sets relative rarity of corresponding ore in vein.
* `integer density`
	* Percentage of ore blocks per vein.
	* 100 generally means no stone will be left, whereas 0 means very little ores will be spawned.
* `int weight`
	* The more this variable is, the more common the vein is.
	* General recommendation is 5-10 for very rare veins, 20-30 for rare,
	 40-60 for common and 70-100 for abundant/very common.
* `int min_height`
* `int max_height`

### Material Type Definition (`trinium_materials`)
Material Type is a `function<void>(Object[] def)` function.

The `def` here is a table with following elements:
* `String id`
* `String name`
* `String color`
* `int<3> color_tbl`
* `String formula`
* `String<> formula_tbl`
* `Object[] data`
* `String<> types`

### Material Definition (`trinium_materials`)
Material Definition is a table with following elements:
* `Object<2><> formula`
	* In each pair, first element is material name while second one is its quantity.
* `String<> types`
* `int<3> color`
* `String description`
* `[Object[] data]`

### Material Combinations (`trinium_materials`)
Different actions can be runned when material has several subitems. It is done using Material Combinations.

Combination Definition is a table with following elements:
* `String<> requirements`
	* List of all needed subitems.
* `void apply(String name, Object[] data)`
	
### Chapter Definition (`trinium_research`)
Chapter Definition is a table with following elements:
* `String texture`
* `int x` - horizontal coordinate.
	* Can only be from 0 to 7 due to limitations of Formspec API.
* `int y` - vertical coordinate.
	* Can only be from 0 to 7 due to limitations of Research API.
* `String name`
* `int tier` - integer from 1 to 4.
	* Currently only changes chapter background.
	
### Research Definition (`trinium_research`)
Research Definition is a table with following elements:
* `String texture` - ItemString.
* `int x` - horizontal coordinate.
	* Can only be from 0 to 7 due to limitations of Formspec API.
* `int y` - vertical coordinate.
* `String name` - localized string.
* `String chapter` - string, Chapter ID.
* `Object<> text` - list of pages.
	* Each page is either a localized string or a associative table.
	* Localized string makes page appear as text with wordwraps.
	* Associative table variant should have following elements:
		* `double w` - page width. 
			* Defaults to `8`, making it smaller has no effect.
		* `double h` - page height. 
			* Defaults to `8.6`, making it smaller has no effect.
		* `Set(String) requirements` - set of research IDs.
			* This page will be hidden in case some of requirements are not researched.
		* `bool locked` - if `true`, the page must be bought for aspects.
			* Defaults to `false`.
			* If the research also has requirements,
			 it cannot be bought until the requirements are satisfied.
		* `int[] required_aspects` - table formatted as `[aspect] => amount`.
			* Only has effect if `locked` is true.
		* `String text`
	* Also see `trinium.research.label_escape`.
	* Also see `trinium.nei.draw_recipe_raw`.
* `[bool pre_unlock]` - defaults to `false`.
* `[Object[] requires_lens]` - table with following elements:
	* `bool requirement`
	* `String metal`
	* `String gem`
	* `String shape`
	* `int tier`
	* In case some of the elements are not present, the corresponding lens trait is ignored.
	* Only has effect when `pre_unlock` is `false`.
* `Object[]<> map`
	* List elements are tables with following elements:
		* `int x` - integer from 1 to 7, horizontal coordinate.
		* `int y` - integer from 1 to 7, vertical coordinate.
		* `String aspect` - string, aspect ID.
	* Only has effect when `pre_unlock` is `false`.
* `[int warp]` - non-negative integer.
	* `0` by default.
	* Only has effect when `pre_unlock` is `false`.
		
### Aspect Definition (`trinium_research`)
Aspect Definition is a table with following elements:
* `String texture`
* `String name`
	* Should contain aspect latin name on first line and localized name on second.
* `String req1` - ID of 1st component.
* `String req2` - ID of 2nd component.

### Tool Material Definition (`tinker_phase`)
Tool Material Definition is a table with following elements:
* `String color` - can be `nil` if `add_system_material` is used.
* `int base_durability`
* `double base_speed` - multiplier to hand speed (`tinker.base`).
* `int level`
	* Note that tinkered tools durability doesn't depend on `level`.
* `double rod_durability` - durability multiplier.
* `int[] traits` - table formatted as `[trait ID] => level`.
	* Tool trait level is calculated as maximum of all levels with same ID.
* `String description`

### Tool Pattern Definition (`tinker_phase`)
Tool Pattern Definition is a table with following elements:
* `String description` - string with **exactly one** `@1` translation element.
	* This element will be substituted with material description.
* `int cost`
* `int type` - either `1` or `2`.
	* If this is `1`, the part material `base_durability` is averaged with other
	 parts of type 1, and this part is also used to calculate tool speed.
	* Common examples include pickaxe/axe/whatever blades.
	* If this is `2`, the part material `rod_durability` is averaged with other
	 parts of type 2, and this part is not used to calculate tool speed.
	* Common examples include tool rods.
* Texture file must be called `tinker_phase.part.<id>.png`.

### Tool Definition (`tinker_phase`)
Tool Definition is a table with following elements:
* `double[] times` - table formatted as `[group] => time`.
* `double durability_mult` - float.
* `Object<> components` - list of elements from `tinker.patterns`.
	* The tool is assembled when all these elements are put into table and nothing more.
	* Should be unique.
* `int level_boost`
	* Increases tool maximum harvest level.
	* Can decrease it, when negative.
	* Tool won't assemble if calculated level is below 0.
* `update_description` - function of `stack`.

#### Tool Descriptions
* Whenever a tool changes it description (e.g, when its durability is changed),
 it calls `update_description` callback from tool definition on itself.
* Best way to get the description (unless you want something really fancy)
 is calling `wrap_description` function.

##### `wrap_description` definition table
* API v1 fields:
	* `int current_durability`
	* `int max_durability`
	* `String base` - actual item description.
	* `int[] modifiers` - table formatted as `[trait ID] => level`.
	* **v1 is by far the newest API version.**

### Trait Definition (`tinker_phase`)
Trait Definition is a table with following elements:

#### Required
* `String description`
* `String<> incompat` - list of trait IDs this trait doesn't work with.

#### Callbacks
* `void after_use(PlayerRef player, ItemStack stack, int level, Object[] node)`
	* Called after tool with this trait digs any block.
* `void after_create(int level, ItemStackMetaRef meta)`
	* Called after tool with this trait is created.