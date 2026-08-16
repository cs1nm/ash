extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	_test_generated_tree_size(game)
	_test_single_tree_felling(game)
	if failed:
		quit(1)
		return
	print("TREE_SMOKE_OK")
	game.queue_free()
	await process_frame
	quit()


func _test_generated_tree_size(game: Variant) -> void:
	var bounds := {}
	for key_variant in game.tree_tile_owners.keys():
		var key := str(key_variant)
		var tree_id := int(game.tree_tile_owners[key])
		var parts := key.split(",")
		if parts.size() != 2:
			continue
		var pos := Vector2i(int(parts[0]), int(parts[1]))
		if not bounds.has(tree_id):
			bounds[tree_id] = Rect2i(pos, Vector2i.ONE)
		else:
			var rect: Rect2i = bounds[tree_id]
			rect = rect.expand(pos)
			rect = rect.expand(pos + Vector2i.ONE)
			bounds[tree_id] = rect
	_require(not bounds.is_empty(), "Generated world contains no owned trees")
	for rect_variant in bounds.values():
		var rect: Rect2i = rect_variant
		_require(rect.size.x <= 16 and rect.size.y <= 20, "Generated tree exceeds the compact size limits")


func _test_single_tree_felling(game: Variant) -> void:
	var base_a := Vector2i(10, 22)
	var base_b := Vector2i(15, 22)
	for y in range(12, 24):
		for x in range(5, 21):
			game._set_tile(x, y, game.Tile.AIR)
	for x in range(5, 21):
		game._set_tile(x, 23, game.Tile.STONE)

	var tree_a: int = int(game._allocate_tree_id())
	var tree_b: int = int(game._allocate_tree_id())
	var tree_a_tiles := [
		base_a, base_a + Vector2i(0, -1), base_a + Vector2i(0, -2),
		base_a + Vector2i(1, -3), base_a + Vector2i(2, -3),
		base_a + Vector2i(1, -4), base_a + Vector2i(2, -4)
	]
	var tree_b_tiles := [
		base_b, base_b + Vector2i(0, -1), base_b + Vector2i(0, -2),
		base_b + Vector2i(-1, -3), base_b + Vector2i(-2, -3),
		base_b + Vector2i(-1, -4), base_b + Vector2i(-2, -4)
	]
	for pos in tree_a_tiles:
		game._set_tree_tile(pos.x, pos.y, game.Tile.WOOD, tree_a)
	for pos in tree_b_tiles:
		game._set_tree_tile(pos.x, pos.y, game.Tile.WOOD, tree_b)

	var leaves_a := [Vector2i(12, 17), Vector2i(12, 16), Vector2i(13, 16)]
	var leaves_b := [Vector2i(13, 17), Vector2i(14, 17), Vector2i(14, 16)]
	for pos in leaves_a:
		game._set_tree_tile(pos.x, pos.y, game.Tile.LEAVES, tree_a)
	for pos in leaves_b:
		game._set_tree_tile(pos.x, pos.y, game.Tile.LEAVES, tree_b)

	var normal_wood_hardness := float(game.tile_hardness[game.Tile.WOOD])
	_require(game._mining_hardness(game.Tile.WOOD, base_a) >= normal_wood_hardness * 2.0, "Tree base is not significantly harder to chop")
	game._fell_tree_from(base_a)
	for pos in tree_a_tiles + leaves_a:
		_require(game._get_tile(pos.x, pos.y) == game.Tile.AIR, "Selected tree left owned blocks behind")
	for pos in tree_b_tiles:
		_require(game._get_tile(pos.x, pos.y) == game.Tile.WOOD, "Felling one tree damaged the neighboring trunk or branch")
	for pos in leaves_b:
		_require(game._get_tile(pos.x, pos.y) == game.Tile.LEAVES, "Felling one tree damaged neighboring leaves")


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error(message)
