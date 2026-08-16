extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	var template: Dictionary = game._enemy_template("archive_warden")
	_require(str(template.get("name", "")) == "Archive Warden", "Archive Warden template is missing")
	_require(int(template.get("max_hp", 0)) == 620, "Archive Warden HP is incorrect")
	_require(game._enemy_attack_count("archive_warden") == 4, "Archive Warden does not have four attacks")

	var expected_states := [
		"spawn", "idle", "move", "hurt", "stunned", "phase_2",
		"attack_1", "attack_2", "attack_3", "attack_4", "death"
	]
	var animations: Dictionary = game.enemy_animation_textures.get("archive_warden", {})
	for state in expected_states:
		_require(animations.has(state), "Archive Warden animation is missing: %s" % state)
	for vfx_state in ["memory_beam_vfx", "memory_pulse_vfx", "memory_projectile", "warden_death_vfx"]:
		_require(animations.has(vfx_state), "Archive Warden VFX is missing: %s" % vfx_state)

	var story_items := [
		"cracked_memory_core", "fungal_memory_shard", "sunken_memory_shard",
		"ash_memory_shard", "ashen_lens", "archive_sigil"
	]
	for item_id in story_items:
		_require(game.item_icon_cache.has(item_id), "Story item icon is missing: %s" % item_id)

	_require(not bool(game.known_recipes.get("ashen_lens", false)), "Ashen Lens recipe starts unlocked")
	_require(game.memory_nodes.size() == 3, "World did not generate exactly three memory nodes")
	var generated_kinds: Array[String] = []
	for node_variant in game.memory_nodes:
		var generated_node: Dictionary = node_variant
		generated_kinds.append(str(generated_node.get("kind", "")))
	_require(generated_kinds.has("fungal"), "Fungal memory node was not generated")
	_require(generated_kinds.has("sunken"), "Sunken memory node was not generated")
	_require(generated_kinds.has("ash"), "Ash memory node was not generated")
	for node_kind in ["fungal", "sunken", "ash"]:
		var node_textures: Dictionary = game.memory_node_textures.get(node_kind, {})
		for state in ["dormant", "activate", "active"]:
			_require(node_textures.has(state), "%s memory node texture is missing: %s" % [node_kind, state])

	game.inventory.erase("cracked_memory_core")
	game._activate_memory_node(0)
	_require(
		str((game.memory_nodes[0] as Dictionary).get("state", "")) == "dormant",
		"Memory node activated without a cracked memory core"
	)
	game.inventory["cracked_memory_core"] = 1
	for node_index in range(game.memory_nodes.size()):
		game._activate_memory_node(node_index)
		game._update_memory_nodes(1.0)
	for node_variant in game.memory_nodes:
		var active_node: Dictionary = node_variant
		_require(str(active_node.get("state", "")) == "active", "Memory node did not finish activating")
	for shard_id in ["fungal_memory_shard", "sunken_memory_shard", "ash_memory_shard"]:
		_require(int(game.inventory.get(shard_id, 0)) >= 1, "Memory node did not grant %s" % shard_id)
	_require(bool(game.known_recipes.get("ashen_lens", false)), "Memory nodes did not unlock the Ashen Lens")

	var serialized_nodes: Array = game._serialize_memory_nodes()
	game.memory_nodes.clear()
	game._restore_memory_nodes(serialized_nodes)
	_require(game.memory_nodes.size() == 3, "Memory node save data did not restore all nodes")
	_require(game._serialize_memory_nodes() == serialized_nodes, "Memory node save data changed after restoration")

	for texture_id in [
		"console_idle", "console_activate", "gate_closed",
		"gate_opening", "gate_open", "hologram"
	]:
		_require(game.archive_object_textures.get(texture_id, null) != null, "Archive object texture is missing: %s" % texture_id)
	_require(not game.archive_site.is_empty(), "Archive site was not generated")
	_require(str(game.archive_site.get("console_state", "")) == "idle", "Archive Console starts active")
	_require(str(game.archive_site.get("gate_state", "")) == "closed", "Archive Gate starts open")
	_require(game._archive_gate_collision_rect().has_area(), "Closed Archive Gate has no collision")

	game.enemies.clear()
	game.archive_warden_spawned = false
	game.archive_warden_defeated = false
	game.inventory["ashen_lens"] = 1
	var archive_console_tile: Vector2i = game.archive_site.get("console_tile", Vector2i.ZERO)
	game.player_position = game._archive_object_world_position(archive_console_tile) + Vector2(-80.0, -20.0)
	game._update_archive_warden_encounter()
	_require(game._count_enemies_of_type("archive_warden") == 1, "Archive Warden did not awaken near the Archive Console")
	_require(game.archive_warden_spawned, "Archive Warden spawn state was not recorded")
	game.enemies.clear()

	game.inventory.erase("ashen_lens")
	game.inventory.erase("archive_sigil")
	game._activate_archive_console()
	_require(str(game.archive_site.get("console_state", "")) == "idle", "Archive Console activated without an Ashen Lens")
	game.inventory["ashen_lens"] = 1
	game._activate_archive_console()
	_require(str(game.archive_site.get("console_state", "")) == "idle", "Archive Console activated without an Archive Sigil")
	game.inventory["archive_sigil"] = 1
	game._activate_archive_console()
	_require(str(game.archive_site.get("console_state", "")) == "activating", "Archive Console activation did not start")
	_require(int(game.inventory.get("ashen_lens", 0)) == 0, "Archive Console did not consume the Ashen Lens")
	_require(int(game.inventory.get("archive_sigil", 0)) == 0, "Archive Console did not consume the Archive Sigil")
	game._update_archive_site(1.2)
	_require(str(game.archive_site.get("console_state", "")) == "active", "Archive Console did not finish activating")
	_require(str(game.archive_site.get("gate_state", "")) == "opening", "Archive Gate opening did not start")
	game._update_archive_site(1.3)
	_require(str(game.archive_site.get("gate_state", "")) == "open", "Archive Gate did not finish opening")
	_require(not game._archive_gate_collision_rect().has_area(), "Open Archive Gate still has collision")

	var serialized_archive: Dictionary = game._serialize_archive_site()
	game.archive_site.clear()
	game._restore_archive_site(serialized_archive)
	_require(game._serialize_archive_site() == serialized_archive, "Archive site save data changed after restoration")

	var expected_kinds := ["memory_blade", "memory_beam", "memory_summon", "memory_pulse"]
	for index in range(expected_kinds.size()):
		_require(
			game._enemy_attack_kind("archive_warden", index + 1) == expected_kinds[index],
			"Archive Warden attack %d has the wrong behavior" % (index + 1)
		)

	for boss_type in ["stone_beast", "heartwood_boss"]:
		game.enemies.clear()
		game._spawn_enemy(boss_type, game.player_position + Vector2(80.0, -8.0))
		(game.enemies[0] as Dictionary)["vel"] = Vector2.ZERO
		game._damage_enemy(0, 1, Vector2.RIGHT)
		var boss_velocity: Vector2 = (game.enemies[0] as Dictionary).get("vel", Vector2.ZERO)
		_require(absf(boss_velocity.x) <= 20.0, "%s still receives excessive knockback" % boss_type)

	game.enemies.clear()
	game.enemy_projectiles.clear()
	var spawn_pos: Vector2 = game.player_position + Vector2(80.0, -8.0)
	game._spawn_enemy("archive_warden", spawn_pos)
	_require(game.enemies.size() == 1, "Archive Warden did not spawn")
	var warden: Dictionary = game.enemies[0]
	_require(float(warden.get("spawn_timer", 0.0)) > 1.0, "Spawn animation duration was not applied")
	_require(str(warden.get("anim_state", "")) == "spawn", "Spawn animation did not start")

	warden["attack_index"] = 2
	game._execute_enemy_attack(warden, spawn_pos, 1, 80.0, 185.0)
	_require(game.enemy_projectiles.size() == 1, "Memory beam did not create a projectile")
	_require(
		str((game.enemy_projectiles[0] as Dictionary).get("special", "")) == "archive_memory",
		"Memory beam projectile has the wrong type"
	)

	game.enemies.clear()
	warden["attack_index"] = 3
	game._execute_enemy_attack(warden, spawn_pos, 1, 100.0, 185.0)
	_require(game._count_enemies_of_type("ruin_drone") == 2, "Archive Warden did not summon two Ruin Drones")

	game.enemies.clear()
	game.dropped_items.clear()
	game._spawn_enemy("archive_warden", spawn_pos)
	game._kill_enemy(0)
	_require(game.archive_warden_defeated, "Archive Warden defeat state was not recorded")
	var dropped_archive_sigil := false
	for item_variant in game.dropped_items:
		var dropped_item: Dictionary = item_variant
		if str(dropped_item.get("id", "")) == "archive_sigil":
			dropped_archive_sigil = true
			break
	_require(dropped_archive_sigil, "Archive Warden did not drop the Archive Sigil")

	game.free()
	if failed:
		quit(1)
		return
	print("ARCHIVE_WARDEN_OK")
	quit()


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error(message)
