extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	for i in range(4):
		await process_frame

	game._set_pause_menu_open(true)
	if not paused or not game.pause_menu_open or not game.pause_menu_view.visible:
		push_error("Pause menu did not pause the game")
		paused = false
		quit(1)
		return

	game._set_pause_menu_open(false)
	if paused or game.pause_menu_open or game.pause_menu_view.visible:
		push_error("Pause menu did not resume the game")
		paused = false
		quit(1)
		return

	print("PAUSE_MENU_OK")
	game.queue_free()
	await process_frame
	quit()
