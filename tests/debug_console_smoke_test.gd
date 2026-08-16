extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	game._execute_debug_command("give wood 7")
	assert(int(game.inventory.get("wood", 0)) >= 19)
	game._execute_debug_command("give_all 2")
	assert(int(game.inventory.get("heartwood_core", 0)) >= 2)

	game.debug_memory_node_index = -1
	for expected_index in range(game.memory_nodes.size()):
		game._execute_debug_command("nodes")
		assert(game.debug_memory_node_index == expected_index)
		var visited_node: Dictionary = game.memory_nodes[expected_index]
		var visited_tile: Vector2i = visited_node.get("tile_pos", Vector2i.ZERO)
		assert(absf(game.player_position.x / game.TILE_SIZE - (float(visited_tile.x) + 0.5)) < 0.01)
	game._execute_debug_command("node ash")
	var ash_node_index := -1
	for index in range(game.memory_nodes.size()):
		if str((game.memory_nodes[index] as Dictionary).get("kind", "")) == "ash":
			ash_node_index = index
			break
	assert(ash_node_index >= 0 and game.debug_memory_node_index == ash_node_index)
	game._execute_debug_command("archive")
	var archive_console_tile: Vector2i = game.archive_site.get("console_tile", Vector2i.ZERO)
	assert(absf(game.player_position.x / game.TILE_SIZE - (float(archive_console_tile.x) - 2.5)) < 0.01)

	game.inventory_open = true
	game._update_hud()
	var initial_known_count: int = game._known_recipe_indices().size()
	var initial_visible_count := 0
	for button in game.recipe_buttons:
		if button.visible:
			initial_visible_count += 1
	assert(initial_known_count < game.recipes.size())
	assert(initial_visible_count == initial_known_count)
	var ash_recipe_index := -1
	for i in range(game.recipes.size()):
		if str(game.recipes[i].get("id", "")) == "ash_sickle":
			ash_recipe_index = i
			break
	assert(ash_recipe_index >= 0)
	game.selected_recipe_index = ash_recipe_index
	assert(str(game._selected_recipe().get("id", "")) != "ash_sickle")
	game._execute_debug_command("learn all")
	assert(game._known_recipe_indices().size() == game.recipes.size())
	game._update_hud()
	var learned_visible_count := 0
	for button in game.recipe_buttons:
		if button.visible:
			learned_visible_count += 1
	assert(learned_visible_count == game.recipes.size())
	game.inventory_open = false

	game._execute_debug_command("spawn wild_slime 2")
	assert(game.enemies.size() >= 2)
	game._execute_debug_command("killall")
	assert(game.enemies.is_empty())

	game._execute_debug_command("noclip on")
	assert(game.noclip_unlocked and game.noclip_enabled)
	var start_x: float = game.player_position.x
	game.physical_move_right_held = true
	game._update_player(0.5)
	game.physical_move_right_held = false
	assert(game.player_position.x > start_x)
	game._execute_debug_command("noclip off")
	assert(not game.noclip_enabled)
	var space_press := InputEventKey.new()
	space_press.keycode = KEY_SPACE
	space_press.physical_keycode = KEY_SPACE
	space_press.pressed = true
	game._input(space_press)
	game._input(space_press)
	assert(game.noclip_enabled)
	game._set_noclip_enabled(false)

	game._execute_debug_command("god on")
	game.health = 1
	game._damage_player(999)
	assert(game.health == game.MAX_HEALTH)
	game._execute_debug_command("god off")
	game._execute_debug_command("perception on")
	assert(game.perception_debug_enabled)
	game._execute_debug_command("noise 140")
	assert(not game.perception_noise_events.is_empty())
	assert(is_equal_approx(float(game.perception_noise_events[-1].get("radius", 0.0)), 140.0))
	await process_frame
	game._execute_debug_command("perception off")
	assert(not game.perception_debug_enabled)
	game._set_debug_console_open(true)
	assert(game.debug_console_open and game.debug_console_panel.visible)
	game._set_debug_console_open(false)

	print("DEBUG_CONSOLE_OK")
	game.queue_free()
	await process_frame
	quit()
