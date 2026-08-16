extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	game.health = 100000

	var slime_states := ["idle", "move", "hurt", "death", "attack_1", "attack_2", "ichor_projectile", "ichor_impact"]
	for state in slime_states:
		if not game.enemy_animation_textures.get("wild_slime", {}).has(state):
			push_error("Missing Wild Slime animation: %s" % state)
			quit(1)
			return
	if not is_equal_approx(game._enemy_attack_windup("wild_slime", 1, 0.0), 0.5):
		push_error("Wild Slime attack_1 hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("wild_slime", 2, 0.0), 8.0 / 12.0):
		push_error("Wild Slime attack_2 projectile frame is not synchronized")
		quit(1)
		return

	var mossling_states := ["idle", "move", "hurt", "death", "attack_1", "attack_2", "root_impact"]
	for state in mossling_states:
		if not game.enemy_animation_textures.get("mossling", {}).has(state):
			push_error("Missing Mossling animation: %s" % state)
			quit(1)
			return
	if not is_equal_approx(game._enemy_attack_windup("mossling", 1, 0.0), 7.0 / 14.0):
		push_error("Mossling attack_1 hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("mossling", 2, 0.0), 10.0 / 14.0):
		push_error("Mossling attack_2 hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(float(game.enemy_sprite_ground_anchors.get("mossling", 0.0)), 89.0):
		push_error("Mossling ground anchor does not match animation metadata")
		quit(1)
		return

	var root_states := ["idle", "move", "hurt", "death", "attack_1", "attack_2", "attack_3", "whip_impact", "burrow_dust"]
	for state in root_states:
		if not game.enemy_animation_textures.get("root_crawler", {}).has(state):
			push_error("Missing Root Crawler animation: %s" % state)
			quit(1)
			return
	if not is_equal_approx(game._enemy_attack_windup("root_crawler", 1, 0.0), 7.0 / 14.0):
		push_error("Root Crawler attack_1 hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("root_crawler", 2, 0.0), 11.0 / 14.0):
		push_error("Root Crawler attack_2 hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("root_crawler", 3, 0.0), 1.0):
		push_error("Root Crawler attack_3 hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(float(game.enemy_sprite_ground_anchors.get("root_crawler", 0.0)), 89.0):
		push_error("Root Crawler ground anchor does not match animation metadata")
		quit(1)
		return
	if not is_equal_approx(game._enemy_sprite_scale("root_crawler"), 0.48):
		push_error("Root Crawler sprite scale changed unexpectedly")
		quit(1)
		return
	var root_hitbox_test: Dictionary = game._enemy_template("root_crawler")
	root_hitbox_test["pos"] = Vector2(200, 120)
	var root_hitbox: Rect2 = game._enemy_hitbox_rect(root_hitbox_test)
	var root_physics_size: Vector2 = root_hitbox_test["size"]
	var root_physics_rect := Rect2(root_hitbox_test["pos"] - root_physics_size * 0.5, root_physics_size)
	var tail_test_point := Vector2(226, 116)
	if root_hitbox.size != Vector2(58, 22) or not root_hitbox.has_point(tail_test_point):
		push_error("Root Crawler combat hitbox does not cover the visible body")
		quit(1)
		return
	if root_physics_rect.has_point(tail_test_point):
		push_error("Root Crawler combat hitbox test point still overlaps only the physics core")
		quit(1)
		return
	root_hitbox_test["burrow_hidden"] = true
	if game._enemy_can_be_hit(root_hitbox_test):
		push_error("Root Crawler can still be hit while burrowing")
		quit(1)
		return

	var cave_worm_states := ["idle", "move", "hurt", "death", "attack_1", "attack_2", "attack_3", "bite_impact", "roll_dust", "burrow_dust"]
	for state in cave_worm_states:
		if not game.enemy_animation_textures.get("cave_worm", {}).has(state):
			push_error("Missing Cave Worm animation: %s" % state)
			quit(1)
			return
	if not is_equal_approx(game._enemy_attack_windup("cave_worm", 1, 0.0), 7.0 / 14.0):
		push_error("Cave Worm bite hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("cave_worm", 2, 0.0), 10.0 / 14.0):
		push_error("Cave Worm roll hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("cave_worm", 3, 0.0), 1.0):
		push_error("Cave Worm burrow hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(float(game.enemy_sprite_ground_anchors.get("cave_worm", 0.0)), 89.0):
		push_error("Cave Worm ground anchor does not match animation metadata")
		quit(1)
		return
	if not is_equal_approx(game._enemy_sprite_scale("cave_worm"), 0.56):
		push_error("Cave Worm sprite scale changed unexpectedly")
		quit(1)
		return
	var cave_worm_hitbox_test: Dictionary = game._enemy_template("cave_worm")
	cave_worm_hitbox_test["type"] = "cave_worm"
	cave_worm_hitbox_test["pos"] = Vector2(200, 120)
	cave_worm_hitbox_test["anim_state"] = "idle"
	var cave_worm_hitbox: Rect2 = game._enemy_hitbox_rect(cave_worm_hitbox_test)
	var cave_worm_physics_size: Vector2 = cave_worm_hitbox_test["size"]
	var cave_worm_physics_rect := Rect2(cave_worm_hitbox_test["pos"] - cave_worm_physics_size * 0.5, cave_worm_physics_size)
	var worm_tail_test_point := Vector2(229, 114)
	if cave_worm_hitbox.size != Vector2(62, 24) or not cave_worm_hitbox.has_point(worm_tail_test_point):
		push_error("Cave Worm combat hitbox does not cover the visible body")
		quit(1)
		return
	if cave_worm_physics_rect.has_point(worm_tail_test_point):
		push_error("Cave Worm body hitbox test point still overlaps only the physics core")
		quit(1)
		return
	cave_worm_hitbox_test["anim_state"] = "attack_2"
	var cave_worm_roll_hitbox: Rect2 = game._enemy_hitbox_rect(cave_worm_hitbox_test)
	if cave_worm_roll_hitbox.size != Vector2(36, 36) or cave_worm_roll_hitbox.get_center() != Vector2(200, 108):
		push_error("Cave Worm roll hitbox does not match the wheel pose")
		quit(1)
		return
	cave_worm_hitbox_test["burrow_hidden"] = true
	if game._enemy_can_be_hit(cave_worm_hitbox_test):
		push_error("Cave Worm can still be hit while burrowing")
		quit(1)
		return

	var bat_states := [
		"idle", "move", "hang_idle", "wake_up", "hurt", "attack_1", "attack_2",
		"attack_3", "dive_loop", "dive_recover", "death", "death_fall", "death_impact"
	]
	for state in bat_states:
		if not game.enemy_animation_textures.get("bat", {}).has(state):
			push_error("Missing Bat animation: %s" % state)
			quit(1)
			return
	if game._enemy_attack_count("bat") != 3:
		push_error("Bat does not expose bite, sonic pulse and dive attacks")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("bat", 1, 0.0), 4.0 / 14.0):
		push_error("Bat bite hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("bat", 2, 0.0), 5.0 / 12.0):
		push_error("Bat sonic release frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("bat", 3, 0.0), 3.0 / 12.0):
		push_error("Bat dive start frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_sprite_scale("bat"), 0.44):
		push_error("Bat sprite scale changed unexpectedly")
		quit(1)
		return
	var bat_hitbox_test: Dictionary = game._enemy_template("bat")
	bat_hitbox_test["type"] = "bat"
	bat_hitbox_test["pos"] = Vector2(200, 120)
	var bat_hitbox: Rect2 = game._enemy_hitbox_rect(bat_hitbox_test)
	if bat_hitbox.size != Vector2(42, 28):
		push_error("Bat combat hitbox does not cover the authored wingspan")
		quit(1)
		return
	bat_hitbox_test["attack_index"] = 3
	game.player_position = Vector2(245, 145)
	game._execute_enemy_attack(bat_hitbox_test, bat_hitbox_test["pos"], 1, 52.0, 145.0)
	if str(bat_hitbox_test.get("dive_phase", "")) != "loop" or float(bat_hitbox_test.get("dive_timer", 0.0)) <= 0.0:
		push_error("Bat dive did not enter its active loop")
		quit(1)
		return

	var spore_bat_states := [
		"idle", "move", "alert", "hurt", "stunned", "attack_1", "attack_2",
		"spore_cloud", "spore_trail", "death", "death_impact"
	]
	for state in spore_bat_states:
		if not game.enemy_animation_textures.get("spore_bat", {}).has(state):
			push_error("Missing Spore Bat animation: %s" % state)
			quit(1)
			return
	if game._enemy_attack_count("spore_bat") != 2:
		push_error("Spore Bat attack count does not match the authored bite and burst")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("spore_bat", 1, 0.0), 4.0 / 14.0):
		push_error("Spore Bat bite hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("spore_bat", 2, 0.0), 5.0 / 12.0):
		push_error("Spore Bat burst frame is not synchronized")
		quit(1)
		return
	var spore_hitbox_test: Dictionary = game._enemy_template("spore_bat")
	spore_hitbox_test["type"] = "spore_bat"
	spore_hitbox_test["pos"] = Vector2(200, 120)
	if game._enemy_hitbox_rect(spore_hitbox_test).size != Vector2(42, 24):
		push_error("Spore Bat hitbox does not match the authored body")
		quit(1)
		return

	var cave_husk_states := [
		"idle", "move", "alert", "hurt", "stunned",
		"attack_1", "reach_vfx", "attack_2", "rock_projectile", "rock_impact",
		"attack_3", "slam_vfx", "death", "death_vfx"
	]
	for state in cave_husk_states:
		if not game.enemy_animation_textures.get("cave_husk", {}).has(state):
			push_error("Missing Cave Husk animation: %s" % state)
			quit(1)
			return
	if not is_equal_approx(game._enemy_attack_windup("cave_husk", 3, 0.0), 5.0 / 8.2):
		push_error("Cave Husk slam impact frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("cave_husk", 1, 0.0), 4.0 / 9.4):
		push_error("Cave Husk reach hit frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("cave_husk", 2, 0.0), 5.0 / 9.7):
		push_error("Cave Husk rock release frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(float(game.enemy_sprite_ground_anchors.get("cave_husk", 0.0)), 89.0):
		push_error("Cave Husk ground anchor does not match animation metadata")
		quit(1)
		return
	for authored_attack_state in ["attack_1", "attack_2", "attack_3"]:
		if game._enemy_animation_visual_state("cave_husk", authored_attack_state) != authored_attack_state:
			push_error("Cave Husk authored attack must not use the idle fallback: %s" % authored_attack_state)
			quit(1)
			return
	var throw_spec: Dictionary = game._enemy_animation_spec("cave_husk", "attack_2")
	var throw_frames: Array = throw_spec.get("projectile_frames", [])
	var throw_spawn: Array = throw_spec.get("projectile_spawn", [])
	if throw_frames.size() != 1 or int(throw_frames[0]) != 5 or throw_spawn.size() != 2 or int(throw_spawn[0]) != 112 or int(throw_spawn[1]) != 46:
		push_error("Cave Husk rock release metadata is incorrect")
		quit(1)
		return
	if not is_equal_approx(game._enemy_animation_ground_clearance("cave_husk"), 1.0):
		push_error("Cave Husk ground clearance is missing")
		quit(1)
		return
	var cave_husk_hitbox_test: Dictionary = game._enemy_template("cave_husk")
	cave_husk_hitbox_test["type"] = "cave_husk"
	cave_husk_hitbox_test["pos"] = Vector2(200, 120)
	if game._enemy_hitbox_rect(cave_husk_hitbox_test).size != Vector2(72, 42):
		push_error("Cave Husk hitbox does not cover the authored silhouette")
		quit(1)
		return

	var beetle_states := [
		"idle", "move", "alert", "hurt", "stunned",
		"attack_1", "attack_2", "dust_vfx", "attack_3",
		"poison_projectile", "poison_impact", "death"
	]
	for state in beetle_states:
		if not game.enemy_animation_textures.get("mushroom_beetle", {}).has(state):
			push_error("Missing Mushroom Beetle animation: %s" % state)
			quit(1)
			return
	if not is_equal_approx(game._enemy_attack_windup("mushroom_beetle", 1, 0.0), 4.0 / 14.0):
		push_error("Mushroom Beetle bite frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("mushroom_beetle", 2, 0.0), 6.0 / 12.0):
		push_error("Mushroom Beetle charge frame is not synchronized")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("mushroom_beetle", 3, 0.0), 5.0 / 12.0):
		push_error("Mushroom Beetle projectile frame is not synchronized")
		quit(1)
		return
	var beetle_hitbox_test: Dictionary = game._enemy_template("mushroom_beetle")
	beetle_hitbox_test["type"] = "mushroom_beetle"
	beetle_hitbox_test["pos"] = Vector2(200, 120)
	if game._enemy_hitbox_rect(beetle_hitbox_test).size != Vector2(56, 28):
		push_error("Mushroom Beetle hitbox does not cover the authored silhouette")
		quit(1)
		return

	var phantom_states := [
		"idle", "move", "alert", "hurt", "stunned",
		"attack_1", "slash_vfx", "attack_2", "dash_vfx",
		"attack_3", "ember_projectile", "ember_impact", "death"
	]
	for state in phantom_states:
		if not game.enemy_animation_textures.get("ash_phantom", {}).has(state):
			push_error("Missing Ash Phantom animation: %s" % state)
			quit(1)
			return
	if game._enemy_attack_kind("ash_phantom", 1) != "claw" or game._enemy_attack_kind("ash_phantom", 2) != "phase_dash" or game._enemy_attack_kind("ash_phantom", 3) != "projectile":
		push_error("Ash Phantom attacks do not match the authored package")
		quit(1)
		return
	if not is_equal_approx(game._enemy_attack_windup("ash_phantom", 3, 0.0), 5.0 / 12.0):
		push_error("Ash Phantom projectile frame is not synchronized")
		quit(1)
		return

	var new_pack_states := {
		"ash_wisp": ["idle", "move", "alert", "hurt", "attack_1", "ember_projectile", "ember_impact", "attack_2", "burst_vfx", "death"],
		"ash_sentinel": ["idle", "move", "alert", "hurt", "stunned", "attack_1", "attack_2", "slam_vfx", "ground_cracks", "attack_3", "sentinel_projectile", "projectile_impact", "attack_4", "death"],
		"drowned_guard": ["idle", "move", "alert", "hurt", "stunned", "attack_1", "attack_2", "harpoon_projectile", "harpoon_impact", "attack_3", "wave_projectile", "wave_impact", "attack_4", "death"],
		"ember_rootling": ["idle", "move", "alert", "hurt", "stunned", "attack_1", "attack_2", "ember_seed", "seed_impact", "attack_3", "root_burst_vfx", "death"],
		"glass_wraith": ["idle", "move", "alert", "hurt", "stunned", "attack_1", "shard_projectile", "shard_impact", "attack_2", "teleport_vfx", "slash_vfx", "attack_3", "laser_beam", "attack_4", "cage_vfx", "death"],
		"night_ember": ["idle", "move", "alert", "hurt", "attack_1", "flame_trail", "attack_2", "fire_projectile", "fire_impact", "attack_3", "burst_vfx", "death"],
		"ruin_drone": ["idle", "move", "alert", "hurt", "stunned", "attack_1", "drone_bolt", "bolt_impact", "attack_2", "laser_beam", "attack_3", "pulse_vfx", "death", "death_vfx"],
		"stone_beast": ["idle", "move", "alert", "hurt", "stunned", "attack_1", "attack_2", "dust_trail", "attack_3", "shockwave_vfx", "attack_4", "falling_rock", "rock_impact", "attack_5", "spikes_vfx", "attack_6", "death", "death_dust"]
	}
	for packed_enemy_type in new_pack_states:
		for state in new_pack_states[packed_enemy_type]:
			if not game.enemy_animation_textures.get(packed_enemy_type, {}).has(state):
				push_error("Missing %s animation: %s" % [packed_enemy_type, state])
				quit(1)
				return
	var authored_windups := {
		"ash_wisp": {1: 5.0 / 13.0, 2: 6.0 / 12.0},
		"ash_sentinel": {1: 6.0 / 12.0, 2: 7.0 / 11.0, 3: 6.0 / 12.0},
		"drowned_guard": {1: 6.0 / 12.0, 2: 7.0 / 12.0, 3: 7.0 / 11.0},
		"ember_rootling": {1: 5.0 / 13.0, 2: 6.0 / 12.0, 3: 7.0 / 11.0},
		"glass_wraith": {1: 7.0 / 13.0, 2: 6.0 / 14.0, 3: 7.0 / 12.0, 4: 8.0 / 11.0},
		"night_ember": {1: 5.0 / 15.0, 2: 6.0 / 13.0, 3: 7.0 / 12.0},
		"ruin_drone": {1: 6.0 / 13.0, 2: 8.0 / 12.0, 3: 7.0 / 12.0},
		"stone_beast": {1: 7.0 / 11.0, 2: 8.0 / 12.0, 3: 8.0 / 11.0, 4: 9.0 / 10.0, 5: 8.0 / 11.0}
	}
	for packed_enemy_type in authored_windups:
		for attack_index in authored_windups[packed_enemy_type]:
			var expected_windup: float = authored_windups[packed_enemy_type][attack_index]
			if not is_equal_approx(game._enemy_attack_windup(packed_enemy_type, attack_index, 0.0), expected_windup):
				push_error("%s attack_%d event frame is not synchronized" % [packed_enemy_type, attack_index])
				quit(1)
				return
	for grounded_pack in ["ash_sentinel", "drowned_guard", "ember_rootling", "stone_beast"]:
		if not is_equal_approx(game._enemy_animation_ground_clearance(grounded_pack), 1.0):
			push_error("%s ground clearance is missing" % grounded_pack)
			quit(1)
			return

	var enemy_types := [
		"wild_slime", "mossling", "root_crawler", "cave_worm", "bat", "cave_husk",
		"spore_bat", "mushroom_beetle", "ash_phantom", "ash_wisp", "ash_sentinel",
		"ruin_drone", "drowned_guard", "ember_rootling", "night_ember", "glass_wraith",
		"stone_beast", "heartwood_boss"
	]
	var ground_enemy_types := [
		"wild_slime", "mossling", "root_crawler", "cave_worm", "cave_husk",
		"mushroom_beetle", "ash_sentinel", "drowned_guard", "ember_rootling",
		"stone_beast", "heartwood_boss"
	]
	for ground_enemy_type in ground_enemy_types:
		var movement_profile: Dictionary = game._enemy_movement_profile(ground_enemy_type)
		if ground_enemy_type != "wild_slime" and str(movement_profile.get("locomotion", "")) == "hop":
			push_error("Non-slime enemy still uses hopping locomotion: %s" % ground_enemy_type)
			quit(1)
			return
	for obstacle_jumper in ["mossling", "root_crawler", "cave_worm", "cave_husk", "mushroom_beetle", "ash_sentinel", "drowned_guard", "ember_rootling"]:
		if not bool(game._enemy_movement_profile(obstacle_jumper).get("navigation_jump", false)):
			push_error("Ground enemy cannot clear a blocking obstacle: %s" % obstacle_jumper)
			quit(1)
			return
	if bool(game._enemy_movement_profile("wild_slime").get("navigation_jump", true)):
		push_error("Wild Slime must use its own hop instead of duplicate navigation jumps")
		quit(1)
		return
	if game._enemy_template("root_crawler").get("size", Vector2.ZERO) != Vector2(22, 12):
		push_error("Root Crawler physics core became too wide for cave terrain")
		quit(1)
		return
	if game._enemy_template("cave_worm").get("size", Vector2.ZERO) != Vector2(34, 12):
		push_error("Cave Worm physics core became too wide for cave terrain")
		quit(1)
		return
	if game._enemy_template("cave_husk").get("size", Vector2.ZERO) != Vector2(18, 22):
		push_error("Cave Husk physics core became too wide for cave terrain")
		quit(1)
		return
	var mossling_charge: Dictionary = game._enemy_template("mossling")
	mossling_charge["type"] = "mossling"
	mossling_charge["attack_index"] = 2
	if not is_zero_approx((game._execute_enemy_attack(mossling_charge, Vector2.ZERO, 1, 999.0, 20.0) as Vector2).y):
		push_error("Mossling ground charge still jumps")
		quit(1)
		return
	var slime_leap: Dictionary = game._enemy_template("wild_slime")
	slime_leap["type"] = "wild_slime"
	slime_leap["attack_index"] = 1
	var slime_leap_velocity := absf(float((game._execute_enemy_attack(slime_leap, Vector2.ZERO, 1, 999.0, 20.0) as Vector2).y))
	var slime_leap_height: float = slime_leap_velocity * slime_leap_velocity / (2.0 * float(game.GRAVITY))
	if slime_leap_height < game.TILE_SIZE + 4.0:
		push_error("Wild Slime leap is too low to clear one tile")
		quit(1)
		return
	var attacks_checked := 0
	for enemy_type in enemy_types:
		var enemy: Dictionary = game._enemy_template(enemy_type)
		enemy["type"] = enemy_type
		enemy["pos"] = game.player_position + Vector2(36, -12)
		enemy["vel"] = Vector2.ZERO
		enemy["facing"] = -1
		enemy["statuses"] = {}
		for attack_index in range(1, game._enemy_attack_count(enemy_type) + 1):
			enemy["attack_index"] = attack_index
			game._execute_enemy_attack(enemy, enemy["pos"], -1, 24.0, 160.0)
			attacks_checked += 1
		game.enemy_projectiles.clear()
		game.enemy_impact_effects.clear()
		game.enemies.clear()

	var mossling: Dictionary = game._enemy_template("mossling")
	mossling["type"] = "mossling"
	mossling["attack_index"] = 1
	mossling["pos"] = game.player_position + Vector2(36, -6)
	mossling["vel"] = Vector2.ZERO
	game._execute_enemy_attack(mossling, mossling["pos"], -1, 24.0, 160.0)
	if game.enemy_impact_effects.is_empty():
		push_error("Mossling root impact was not created")
		quit(1)
		return
	var mossling_impact: Dictionary = game.enemy_impact_effects[0]
	if str(mossling_impact.get("enemy_type", "")) != "mossling" or str(mossling_impact.get("state", "")) != "root_impact":
		push_error("Mossling root impact uses incorrect animation data")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	var slime: Dictionary = game._enemy_template("wild_slime")
	slime["type"] = "wild_slime"
	slime["attack_index"] = 2
	slime["pos"] = game.player_position + Vector2(80, 0)
	slime["vel"] = Vector2.ZERO
	game._execute_enemy_attack(slime, slime["pos"], -1, 80.0, 160.0)
	if game.enemy_projectiles.is_empty() or str(game.enemy_projectiles[0].get("special", "")) != "wild_ichor":
		push_error("Wild Slime ichor projectile was not created")
		quit(1)
		return
	for projectile in game.enemy_projectiles:
		projectile["life"] = 0.0
	game._update_enemy_projectiles(1.0 / 60.0)
	if game.enemy_impact_effects.is_empty():
		push_error("Wild Slime ichor impact was not created")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	var cave_husk_throw: Dictionary = game._enemy_template("cave_husk")
	cave_husk_throw["type"] = "cave_husk"
	cave_husk_throw["attack_index"] = 2
	cave_husk_throw["pos"] = game.player_position + Vector2(90, 0)
	cave_husk_throw["vel"] = Vector2.ZERO
	cave_husk_throw["facing"] = -1
	game._execute_enemy_attack(cave_husk_throw, cave_husk_throw["pos"], -1, 90.0, 92.0)
	if game.enemy_projectiles.is_empty() or str(game.enemy_projectiles[0].get("special", "")) != "cave_husk_rock":
		push_error("Cave Husk rock projectile was not created")
		quit(1)
		return
	if (game.enemy_projectiles[0].get("vel", Vector2.ZERO) as Vector2).y >= 0.0:
		push_error("Cave Husk rock projectile has no authored throw arc")
		quit(1)
		return
	game.enemy_projectiles[0]["life"] = 0.0
	game._update_enemy_projectiles(1.0 / 60.0)
	if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("state", "")) != "rock_impact":
		push_error("Cave Husk rock impact was not created")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	var beetle_throw: Dictionary = game._enemy_template("mushroom_beetle")
	beetle_throw["type"] = "mushroom_beetle"
	beetle_throw["attack_index"] = 3
	beetle_throw["pos"] = game.player_position + Vector2(82, 0)
	beetle_throw["facing"] = -1
	game._execute_enemy_attack(beetle_throw, beetle_throw["pos"], -1, 82.0, 92.0)
	if game.enemy_projectiles.is_empty() or str(game.enemy_projectiles[0].get("special", "")) != "mushroom_poison":
		push_error("Mushroom Beetle poison projectile was not created")
		quit(1)
		return
	game.enemy_projectiles[0]["life"] = 0.0
	game._update_enemy_projectiles(1.0 / 60.0)
	if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("state", "")) != "poison_impact":
		push_error("Mushroom Beetle poison impact was not created")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	var phantom_bolt: Dictionary = game._enemy_template("ash_phantom")
	phantom_bolt["type"] = "ash_phantom"
	phantom_bolt["attack_index"] = 3
	phantom_bolt["pos"] = game.player_position + Vector2(86, -12)
	phantom_bolt["facing"] = -1
	game._execute_enemy_attack(phantom_bolt, phantom_bolt["pos"], -1, 86.0, 150.0)
	if game.enemy_projectiles.is_empty() or str(game.enemy_projectiles[0].get("special", "")) != "ash_phantom_ember":
		push_error("Ash Phantom ember projectile was not created")
		quit(1)
		return
	game.enemy_projectiles[0]["life"] = 0.0
	game._update_enemy_projectiles(1.0 / 60.0)
	if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("state", "")) != "ember_impact":
		push_error("Ash Phantom ember impact was not created")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	var authored_projectiles := [
		{"type": "ash_wisp", "attack": 1, "special": "ash_wisp_ember", "impact": "ember_impact"},
		{"type": "ash_sentinel", "attack": 3, "special": "sentinel_ash", "impact": "projectile_impact"},
		{"type": "drowned_guard", "attack": 2, "special": "drowned_harpoon", "impact": "harpoon_impact"},
		{"type": "drowned_guard", "attack": 3, "special": "drowned_wave", "impact": "wave_impact"},
		{"type": "ember_rootling", "attack": 2, "special": "ember_seed", "impact": "seed_impact"},
		{"type": "glass_wraith", "attack": 1, "special": "glass_shard", "impact": "shard_impact"},
		{"type": "night_ember", "attack": 2, "special": "night_fire", "impact": "fire_impact"},
		{"type": "ruin_drone", "attack": 1, "special": "ruin_bolt", "impact": "bolt_impact"},
		{"type": "stone_beast", "attack": 4, "special": "stone_falling_rock", "impact": "rock_impact"}
	]
	for projectile_case in authored_projectiles:
		game.enemy_projectiles.clear()
		game.enemy_impact_effects.clear()
		var projectile_enemy_type := str(projectile_case["type"])
		var projectile_enemy: Dictionary = game._enemy_template(projectile_enemy_type)
		projectile_enemy["type"] = projectile_enemy_type
		projectile_enemy["attack_index"] = int(projectile_case["attack"])
		projectile_enemy["pos"] = game.player_position + Vector2(90, -12)
		projectile_enemy["facing"] = -1
		game._execute_enemy_attack(projectile_enemy, projectile_enemy["pos"], -1, 90.0, 180.0)
		if game.enemy_projectiles.is_empty() or str(game.enemy_projectiles[0].get("special", "")) != str(projectile_case["special"]):
			push_error("%s authored projectile was not created" % projectile_enemy_type)
			quit(1)
			return
		for projectile in game.enemy_projectiles:
			projectile["life"] = 0.0
		game._update_enemy_projectiles(1.0 / 60.0)
		if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("state", "")) != str(projectile_case["impact"]):
			push_error("%s authored projectile impact was not created" % projectile_enemy_type)
			quit(1)
			return
	game.enemy_projectiles.clear()
	game.enemy_impact_effects.clear()

	var authored_vfx_attacks := [
		{"type": "ash_wisp", "attack": 2, "states": ["burst_vfx"]},
		{"type": "ash_sentinel", "attack": 2, "states": ["ground_cracks", "slam_vfx"]},
		{"type": "ember_rootling", "attack": 3, "states": ["root_burst_vfx"]},
		{"type": "glass_wraith", "attack": 2, "states": ["teleport_vfx", "slash_vfx"]},
		{"type": "glass_wraith", "attack": 3, "states": ["laser_beam"]},
		{"type": "glass_wraith", "attack": 4, "states": ["cage_vfx"]},
		{"type": "night_ember", "attack": 1, "states": ["flame_trail"]},
		{"type": "night_ember", "attack": 3, "states": ["burst_vfx"]},
		{"type": "ruin_drone", "attack": 2, "states": ["laser_beam"]},
		{"type": "ruin_drone", "attack": 3, "states": ["pulse_vfx"]},
		{"type": "stone_beast", "attack": 2, "states": ["dust_trail"]},
		{"type": "stone_beast", "attack": 3, "states": ["shockwave_vfx"]},
		{"type": "stone_beast", "attack": 5, "states": ["spikes_vfx"]}
	]
	for vfx_case in authored_vfx_attacks:
		game.enemy_impact_effects.clear()
		var vfx_enemy_type := str(vfx_case["type"])
		var vfx_enemy: Dictionary = game._enemy_template(vfx_enemy_type)
		vfx_enemy["type"] = vfx_enemy_type
		vfx_enemy["attack_index"] = int(vfx_case["attack"])
		vfx_enemy["pos"] = game.player_position + Vector2(48, -8)
		vfx_enemy["facing"] = -1
		game._execute_enemy_attack(vfx_enemy, vfx_enemy["pos"], -1, 48.0, 180.0)
		for required_vfx_state in vfx_case["states"]:
			var found_vfx := false
			for effect in game.enemy_impact_effects:
				if str(effect.get("state", "")) == str(required_vfx_state):
					found_vfx = true
					break
			if not found_vfx:
				push_error("%s attack_%d did not create %s" % [vfx_enemy_type, int(vfx_case["attack"]), required_vfx_state])
				quit(1)
				return
	game.enemy_impact_effects.clear()

	var root_crawler: Dictionary = game._enemy_template("root_crawler")
	root_crawler["type"] = "root_crawler"
	root_crawler["attack_index"] = 2
	root_crawler["pos"] = game.player_position + Vector2(40, 0)
	root_crawler["vel"] = Vector2.ZERO
	root_crawler["facing"] = -1
	root_crawler["statuses"] = {}
	game._execute_enemy_attack(root_crawler, root_crawler["pos"], -1, 40.0, 52.0)
	if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("state", "")) != "whip_impact":
		push_error("Root Crawler whip impact was not created")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	root_crawler["attack_index"] = 3
	root_crawler["attack_total"] = 1.0
	root_crawler["burrow_origin"] = root_crawler["pos"]
	root_crawler["burrow_target"] = root_crawler["pos"] + Vector2(-32, 0)
	root_crawler["burrow_hidden"] = false
	root_crawler["burrow_dust_started"] = false
	var burrow_midpoint: Vector2 = game._update_root_crawler_burrow_windup(root_crawler, root_crawler["pos"], 0.35)
	if not bool(root_crawler.get("burrow_hidden", false)) or burrow_midpoint == root_crawler["pos"]:
		push_error("Root Crawler did not enter hidden burrow travel")
		quit(1)
		return
	if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("state", "")) != "burrow_dust":
		push_error("Root Crawler entry dust was not created")
		quit(1)
		return
	var burrow_target: Vector2 = game._update_root_crawler_burrow_windup(root_crawler, burrow_midpoint, 0.0)
	game._execute_enemy_attack(root_crawler, burrow_target, -1, burrow_target.distance_to(game.player_position), 72.0)
	if bool(root_crawler.get("burrow_hidden", true)):
		push_error("Root Crawler stayed hidden after emerging")
		quit(1)
		return
	if game.enemy_impact_effects.size() < 2 or str(game.enemy_impact_effects[-1].get("state", "")) != "burrow_dust":
		push_error("Root Crawler emergence dust was not created")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	var cave_worm: Dictionary = game._enemy_template("cave_worm")
	cave_worm["type"] = "cave_worm"
	cave_worm["pos"] = game.player_position + Vector2(42, 0)
	cave_worm["vel"] = Vector2.ZERO
	cave_worm["facing"] = -1
	cave_worm["statuses"] = {}
	cave_worm["attack_index"] = 1
	game._execute_enemy_attack(cave_worm, cave_worm["pos"], -1, 42.0, 48.0)
	if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("state", "")) != "bite_impact":
		push_error("Cave Worm bite impact was not created")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	cave_worm["attack_index"] = 2
	cave_worm["attack_total"] = 10.0 / 14.0
	cave_worm["roll_direction"] = -1
	cave_worm["roll_active"] = false
	cave_worm["roll_dust_started"] = false
	cave_worm["roll_time"] = 0.0
	game._update_cave_worm_roll_windup(cave_worm, cave_worm["pos"], 0.0)
	if not bool(cave_worm.get("roll_active", false)):
		push_error("Cave Worm did not enter the wheel phase")
		quit(1)
		return
	if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("state", "")) != "roll_dust":
		push_error("Cave Worm roll dust was not created")
		quit(1)
		return
	game._execute_enemy_attack(cave_worm, cave_worm["pos"], -1, 42.0, 48.0)
	if float(cave_worm.get("roll_time", 0.0)) <= 0.0:
		push_error("Cave Worm roll recovery did not preserve the wheel phase")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	cave_worm["attack_index"] = 3
	cave_worm["attack_total"] = 1.0
	cave_worm["burrow_origin"] = cave_worm["pos"]
	cave_worm["burrow_target"] = cave_worm["pos"] + Vector2(-36, 0)
	cave_worm["burrow_hidden"] = false
	cave_worm["burrow_dust_started"] = false
	var worm_burrow_midpoint: Vector2 = game._update_enemy_burrow_windup(cave_worm, cave_worm["pos"], 0.35)
	if not bool(cave_worm.get("burrow_hidden", false)) or worm_burrow_midpoint == cave_worm["pos"]:
		push_error("Cave Worm did not enter hidden burrow travel")
		quit(1)
		return
	if game._enemy_can_be_hit(cave_worm):
		push_error("Cave Worm remains targetable during hidden burrow travel")
		quit(1)
		return
	if game.enemy_impact_effects.is_empty() or str(game.enemy_impact_effects[0].get("enemy_type", "")) != "cave_worm" or str(game.enemy_impact_effects[0].get("state", "")) != "burrow_dust":
		push_error("Cave Worm entry dust uses incorrect animation data")
		quit(1)
		return
	var worm_burrow_target: Vector2 = game._update_enemy_burrow_windup(cave_worm, worm_burrow_midpoint, 0.0)
	game._execute_enemy_attack(cave_worm, worm_burrow_target, -1, worm_burrow_target.distance_to(game.player_position), 72.0)
	if bool(cave_worm.get("burrow_hidden", true)):
		push_error("Cave Worm stayed hidden after emerging")
		quit(1)
		return
	if game.enemy_impact_effects.size() < 2 or str(game.enemy_impact_effects[-1].get("enemy_type", "")) != "cave_worm" or str(game.enemy_impact_effects[-1].get("state", "")) != "burrow_dust":
		push_error("Cave Worm emergence dust uses incorrect animation data")
		quit(1)
		return
	game.enemy_impact_effects.clear()

	var recovery_size := Vector2(16, 13)
	var blocked_x := clampi(floori(game.player_position.x / game.TILE_SIZE) + 4, 2, game.WORLD_WIDTH - 3)
	var blocked_tile := Vector2i(blocked_x, int(game.surface_heights[blocked_x]) + 1)
	var blocked_position := Vector2(
		blocked_tile.x * game.TILE_SIZE + game.TILE_SIZE * 0.5,
		blocked_tile.y * game.TILE_SIZE + game.TILE_SIZE * 0.5
	)
	var recovered_position: Vector2 = game._recover_enemy_position(blocked_position, recovery_size, game.player_position)
	if not game._enemy_position_valid(recovered_position, recovery_size):
		push_error("Enemy recovery failed to find a safe position")
		quit(1)
		return

	var arena_x := int(game.WORLD_WIDTH / 2)
	var arena_floor_tile := int(game.surface_heights[arena_x])
	for tile_x in range(arena_x - 12, arena_x + 13):
		game.surface_heights[tile_x] = arena_floor_tile
		for tile_y in range(arena_floor_tile - 8, arena_floor_tile):
			game._set_tile(tile_x, tile_y, game.Tile.AIR)
		game._set_tile(tile_x, arena_floor_tile, game.Tile.GRASS)
	var arena_ground_y := float(arena_floor_tile * game.TILE_SIZE)
	var snap_test_size := Vector2(18, 22)
	var snap_test_pos := Vector2(
		float(arena_x * game.TILE_SIZE) + game.TILE_SIZE * 0.5,
		arena_ground_y - snap_test_size.y * 0.5 - 5.0
	)
	var snapped_test_pos: Vector2 = game._enemy_snap_to_ground(snap_test_pos, snap_test_size, 6.0)
	if not is_equal_approx(snapped_test_pos.y, arena_ground_y - snap_test_size.y * 0.5):
		push_error("Ground enemies do not snap cleanly onto terrain")
		quit(1)
		return
	var step_tile_x := arena_x + 4
	for tile_x in range(step_tile_x, step_tile_x + 4):
		game._set_tile(tile_x, arena_floor_tile - 1, game.Tile.DIRT)
	var step_size: Vector2 = game._enemy_template("mossling")["size"]
	var step_pos := Vector2(
		float((step_tile_x - 2) * game.TILE_SIZE) + game.TILE_SIZE * 0.5,
		arena_ground_y - step_size.y * 0.5
	)
	for _step_frame in range(64):
		step_pos = game._move_enemy(step_pos, Vector2(1.0, 0.0), step_size)
	if step_pos.x < float(step_tile_x * game.TILE_SIZE) + game.TILE_SIZE or step_pos.y > arena_ground_y - game.TILE_SIZE - step_size.y * 0.5 + 0.1:
		push_error("Ground enemy cannot climb a one-tile step: pos=%s target_y=%.2f" % [step_pos, arena_ground_y - game.TILE_SIZE - step_size.y * 0.5])
		quit(1)
		return
	for tile_x in range(step_tile_x, step_tile_x + 4):
		game._set_tile(tile_x, arena_floor_tile - 1, game.Tile.AIR)
	var drop_tile_x := arena_x + 4
	game._set_tile(drop_tile_x, arena_floor_tile, game.Tile.AIR)
	var drop_size: Vector2 = game._enemy_template("cave_husk")["size"]
	var drop_pos := Vector2(
		float((drop_tile_x - 2) * game.TILE_SIZE) + game.TILE_SIZE * 0.5,
		arena_ground_y - drop_size.y * 0.5
	)
	var drop_velocity := Vector2(62.0, 0.0)
	for _drop_frame in range(90):
		drop_velocity.y += game.GRAVITY / 60.0
		drop_pos = game._move_enemy(drop_pos, drop_velocity / 60.0, drop_size)
		if game._enemy_on_floor(drop_pos, drop_size) and drop_velocity.y > 0.0:
			drop_velocity.y = 0.0
	if drop_pos.x <= float((drop_tile_x + 1) * game.TILE_SIZE):
		push_error("Ground enemy refuses to descend through a one-tile dip")
		quit(1)
		return
	game._set_tile(drop_tile_x, arena_floor_tile, game.Tile.GRASS)
	var roll_spawn_size: Vector2 = game._enemy_template("cave_worm")["size"]
	var roll_spawn_pos := Vector2(float(arena_x * game.TILE_SIZE) + game.TILE_SIZE * 0.5, arena_ground_y - roll_spawn_size.y * 0.5)
	game._spawn_enemy("cave_worm", roll_spawn_pos)
	var rolling_worm: Dictionary = game.enemies[-1]
	rolling_worm["attack_index"] = 2
	rolling_worm["attack_windup"] = 0.0
	rolling_worm["attack_cooldown"] = 10.0
	rolling_worm["attack_flash"] = 0.40
	rolling_worm["roll_active"] = true
	rolling_worm["roll_direction"] = 1
	rolling_worm["roll_time"] = 0.40
	rolling_worm["anim_state"] = "attack_2"
	game.enemies[-1] = rolling_worm
	var roll_start_x := roll_spawn_pos.x
	game._update_enemy_ai(1.0 / 60.0)
	rolling_worm = game.enemies[-1]
	if float((rolling_worm["vel"] as Vector2).x) < 240.0 or float((rolling_worm["pos"] as Vector2).x) <= roll_start_x:
		push_error("Cave Worm roll velocity was cancelled by normal movement")
		quit(1)
		return
	game.enemies.clear()
	for enemy_type in enemy_types:
		var template: Dictionary = game._enemy_template(enemy_type)
		var flying := bool(template.get("flying", false))
		var spawn_size: Vector2 = template.get("size", Vector2(16, 16))
		var spawn_pos := Vector2(
			float(arena_x * game.TILE_SIZE) + game.TILE_SIZE * 0.5,
			arena_ground_y - (80.0 if flying else spawn_size.y * 0.5)
		)
		if not game._enemy_position_valid(spawn_pos, spawn_size):
			push_error("Could not find valid smoke-test spawn: %s" % enemy_type)
			quit(1)
			return
		game._spawn_enemy(enemy_type, spawn_pos)
	for frame in range(600):
		game._update_enemy_ai(1.0 / 60.0)
		for enemy in game.enemies:
			if not game._enemy_position_valid(enemy["pos"], enemy["size"]):
				push_error("Enemy left valid world space: %s" % str(enemy.get("type", "unknown")))
				quit(1)
				return

	for enemy_type in enemy_types:
		var profile: Dictionary = game._enemy_perception_profile(enemy_type)
		for required_key in ["vision_range", "vision_angle", "hearing", "light_sensitivity", "memory_time", "search_time", "alert_radius"]:
			if not profile.has(required_key):
				push_error("Missing perception setting %s for %s" % [required_key, enemy_type])
				quit(1)
				return

	game.enemies.clear()
	game.perception_noise_events.clear()
	var perception_ground_y := arena_ground_y
	var listener_pos := Vector2(float((arena_x - 4) * game.TILE_SIZE) + 8.0, perception_ground_y - 8.0)
	game.player_position = Vector2(float((arena_x + 8) * game.TILE_SIZE) + 8.0, perception_ground_y - game.PLAYER_SIZE.y * 0.5)
	game._spawn_enemy("bat", listener_pos + Vector2(0, -42))
	var listener: Dictionary = game.enemies[-1]
	game._emit_noise(listener["pos"] + Vector2(72, 0), 120.0, "smoke_noise", 1.0)
	var heard: Dictionary = game._strongest_heard_noise(listener, listener["pos"], game._enemy_perception_profile("bat"))
	if heard.is_empty() or str(heard.get("kind", "")) != "smoke_noise":
		push_error("Hearing did not detect a nearby noise event")
		quit(1)
		return
	if not is_equal_approx(float(game.ENEMY_HEARING_RADIUS_MULTIPLIER), 3.0):
		push_error("Enemy hearing radius multiplier is not tripled")
		quit(1)
		return
	var distant_listener: Dictionary = game._enemy_template("mossling")
	distant_listener["type"] = "mossling"
	distant_listener["last_noise_id"] = game.next_noise_event_id - 1
	var distant_listener_pos := Vector2(float((arena_x - 8) * game.TILE_SIZE) + 8.0, perception_ground_y - 6.0)
	game._emit_noise(distant_listener_pos + Vector2(200.0, 0.0), 78.0, "distant_footstep", 0.72)
	var distant_heard: Dictionary = game._strongest_heard_noise(distant_listener, distant_listener_pos, game._enemy_perception_profile("mossling"))
	if distant_heard.is_empty() or str(distant_heard.get("kind", "")) != "distant_footstep":
		push_error("Tripled hearing radius did not detect a distant player footstep")
		quit(1)
		return
	game._emit_noise(listener["pos"] + Vector2(54, 0), 120.0, "investigate_noise", 1.0)
	var hearing_result: Dictionary = game._update_enemy_perception(listener, listener["pos"], 0.1)
	if str(hearing_result.get("state", "")) != game.PERCEPTION_INVESTIGATE:
		push_error("Heard noise did not move the enemy into investigate state")
		quit(1)
		return

	game.enemies.clear()
	var ally_a_pos := Vector2(float((arena_x - 3) * game.TILE_SIZE) + 8.0, perception_ground_y - 7.0)
	var ally_b_pos := Vector2(float((arena_x - 1) * game.TILE_SIZE) + 8.0, perception_ground_y - 7.0)
	game._spawn_enemy("mossling", ally_a_pos)
	game._spawn_enemy("mossling", ally_b_pos)
	var alert_source: Dictionary = game.enemies[0]
	game._force_enemy_combat(alert_source, game.player_position, true)
	if str(game.enemies[1].get("perception_state", "")) != game.PERCEPTION_INVESTIGATE:
		push_error("Enemy alert did not notify a nearby ally")
		quit(1)
		return

	if not is_equal_approx(float(game.ENEMY_VISION_RANGE_MULTIPLIER), 2.0):
		push_error("Enemy vision range multiplier is not doubled")
		quit(1)
		return
	var doubled_vision_enemy: Dictionary = game._enemy_template("mossling")
	doubled_vision_enemy["type"] = "mossling"
	doubled_vision_enemy["facing"] = 1
	doubled_vision_enemy["size"] = Vector2(18, 12)
	doubled_vision_enemy["pos"] = Vector2(float((arena_x - 5) * game.TILE_SIZE) + 8.0, perception_ground_y - 6.0)
	game.player_position = Vector2(float((arena_x + 5) * game.TILE_SIZE) + 8.0, perception_ground_y - game.PLAYER_SIZE.y * 0.5)
	var doubled_vision_profile := {
		"vision_range": 100.0,
		"vision_angle": 120.0,
		"light_sensitivity": 0.0,
		"instant_range": 20.0
	}
	if not game._enemy_can_see_player(doubled_vision_enemy, doubled_vision_enemy["pos"], doubled_vision_profile):
		push_error("Doubled enemy vision did not detect a target beyond the former range")
		quit(1)
		return

	var vision_enemy: Dictionary = game._enemy_template("ruin_drone")
	vision_enemy["type"] = "ruin_drone"
	vision_enemy["pos"] = Vector2(float((arena_x - 5) * game.TILE_SIZE) + 8.0, perception_ground_y - 34.0)
	vision_enemy["facing"] = 1
	vision_enemy["size"] = Vector2(16, 16)
	game.player_position = Vector2(float((arena_x + 4) * game.TILE_SIZE) + 8.0, perception_ground_y - game.PLAYER_SIZE.y * 0.5)
	game._collect_visible_light_sources()
	if not game._enemy_can_see_player(vision_enemy, vision_enemy["pos"], game._enemy_perception_profile("ruin_drone")):
		push_error("Enemy vision failed across a clear arena")
		quit(1)
		return
	vision_enemy["perception_state"] = game.PERCEPTION_SUSPICIOUS
	vision_enemy["suspicion"] = 0.99
	vision_enemy["memory_timer"] = 0.0
	vision_enemy["last_noise_id"] = game.next_noise_event_id
	var combat_result: Dictionary = game._update_enemy_perception(vision_enemy, vision_enemy["pos"], 0.1)
	if str(combat_result.get("state", "")) != game.PERCEPTION_COMBAT:
		push_error("Direct vision did not escalate suspicion into combat")
		quit(1)
		return
	for wall_y in range(arena_floor_tile - 4, arena_floor_tile):
		game._set_tile(arena_x, wall_y, game.Tile.STONE)
	if game._enemy_can_see_player(vision_enemy, vision_enemy["pos"], game._enemy_perception_profile("ruin_drone")):
		push_error("Enemy vision ignored a solid wall")
		quit(1)
		return
	vision_enemy["perception_state"] = game.PERCEPTION_COMBAT
	vision_enemy["memory_timer"] = 0.0
	var search_result: Dictionary = game._update_enemy_perception(vision_enemy, vision_enemy["pos"], 0.1)
	if str(search_result.get("state", "")) != game.PERCEPTION_SEARCH:
		push_error("Enemy did not search after losing its last known target")
		quit(1)
		return
	for wall_y in range(arena_floor_tile - 4, arena_floor_tile):
		game._set_tile(arena_x, wall_y, game.Tile.AIR)

	game.hotbar[game.selected_slot] = "stone"
	game._collect_visible_light_sources()
	var dark_visibility: float = game._player_visibility_light()
	game.inventory["torch"] = 1
	game.hotbar[game.selected_slot] = "torch"
	var torch_visibility: float = game._player_visibility_light()
	if torch_visibility <= dark_visibility or not is_equal_approx(torch_visibility, 1.0):
		push_error("Held torch did not increase player visibility")
		quit(1)
		return

	print("ENEMY_SMOKE_OK creatures=%d attacks=%d" % [enemy_types.size(), attacks_checked])
	game.queue_free()
	await process_frame
	quit()
