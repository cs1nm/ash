extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	for i in range(4):
		await process_frame
	game._observe_enemy("cave_worm")
	for i in range(3):
		game._record_enemy_kill("cave_worm")
	game._record_material_found("copper_ore", 15)
	game._record_alchemy_result("acid_flasks", {"ash": 4, "copper_ore": 2})
	var capture_mode := OS.get_environment("ASHENROOT_CAPTURE_MODE")
	if capture_mode == "inventory":
		game.inventory_open = true
		game._update_hud()
	elif capture_mode == "map":
		game._set_full_map_open(true)
	elif capture_mode == "pause":
		game._set_pause_menu_open(true)
	elif capture_mode == "settings":
		game._set_pause_menu_open(true)
		game.pause_menu_view._show_settings()
	elif capture_mode != "gameplay":
		game._set_journal_open(true)
		game._select_journal_tab("Bestiary")
		game._select_journal_entry("cave_worm")
	for i in range(3):
		await process_frame
	var capture_path := OS.get_environment("ASHENROOT_CAPTURE_PATH")
	if capture_path == "":
		capture_path = ProjectSettings.globalize_path("user://journal_preview.png")
	var image := root.get_texture().get_image()
	var error := image.save_png(capture_path)
	if error != OK:
		push_error("Could not save UI capture: %s" % error_string(error))
		quit(1)
		return
	print("UI_CAPTURE_OK %s" % capture_path)
	game.queue_free()
	await process_frame
	quit()
