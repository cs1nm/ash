extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	_require(InputMap.has_action("toggle_journal"), "Journal input action was not registered")
	_require(bool(game.known_recipes.get("workbench", false)), "Workbench recipe is not known at world start")
	_require(bool(game.known_recipes.get("wooden_pickaxe", false)), "Basic tool recipe is not known at world start")
	_require(not bool(game.known_recipes.get("ash_sickle", false)), "Advanced recipe is known without discovery")
	game.inventory_open = true
	game._update_hud()
	var visible_recipe_count := 0
	for button in game.recipe_buttons:
		if button.visible:
			visible_recipe_count += 1
	_require(visible_recipe_count == game._known_recipe_indices().size(), "Crafting menu shows unknown recipes")
	game.inventory_open = false

	game._set_journal_open(true)
	await process_frame
	_require(game.journal_open and game.journal_panel.visible and game.journal_backdrop.visible, "Journal did not open")
	_require(game.journal_tab_buttons.size() == 4, "Journal does not contain four sections")
	_require(game.journal_entry_list.get_child_count() > 0, "Journal index was not populated")

	game._observe_enemy("cave_worm")
	var observed: Dictionary = game.bestiary_knowledge.get("cave_worm", {})
	_require(int(observed.get("stage", 0)) == 1, "Observing a creature did not create a bestiary entry")
	for i in range(3):
		game._record_enemy_kill("cave_worm")
	var hunted: Dictionary = game.bestiary_knowledge.get("cave_worm", {})
	_require(int(hunted.get("stage", 0)) == 3 and int(hunted.get("kills", 0)) == 3, "Bestiary kill research did not advance")

	game._record_material_found("copper_ore", 15)
	var material: Dictionary = game.material_knowledge.get("copper_ore", {})
	_require(int(material.get("stage", 0)) == 3, "Material research did not reveal measured properties")

	game._record_alchemy_result("acid_flasks", {"ash": 4, "copper_ore": 2})
	_require(game.alchemy_knowledge.has("acid_flasks"), "Alchemy result was not recorded")
	game._record_recipe_known("ash_sickle")
	_require(bool(game.known_recipes.get("ash_sickle", false)), "Discovered recipe was not added to the journal")

	game._select_journal_tab("Bestiary")
	game._select_journal_entry("cave_worm")
	_require(game.journal_detail_title.text == "Cave Worm", "Bestiary detail page shows the wrong title")
	_require(game.journal_detail_text.text.contains("Common drop"), "Bestiary detail page did not reveal stage-three knowledge")

	game._set_journal_open(false)
	_require(not game.journal_open and not game.journal_panel.visible, "Journal did not close")
	if failed:
		quit(1)
		return
	print("JOURNAL_SMOKE_OK")
	game.queue_free()
	await process_frame
	quit()


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error(message)
