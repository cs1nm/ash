extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_finite_liquid_flow()
	_test_water_lava_reaction()
	_test_partial_fill_levels()
	_test_pool_settles_without_jitter()
	await _test_generated_world()
	if failed:
		quit(1)
		return
	print("WORLD_GENERATION_OK")
	quit()


func _test_finite_liquid_flow() -> void:
	var world := _make_test_world(7, 7, 3)
	world[1][3] = 1
	var sim := LiquidSim.new()
	sim.setup(1, 2, 0, 3)
	sim.rebuild(world)
	for step in range(4):
		sim.process(0.11, world, 3, 3, {3: true})
	_require(_count_tile(world, 1) == 1, "Water volume changed while flowing")
	var lowest_water_y := -1
	for y in range(world.size()):
		if int(world[y][3]) == 1:
			lowest_water_y = y
	_require(lowest_water_y >= 4, "Water did not flow down under gravity")


func _test_water_lava_reaction() -> void:
	var world := _make_test_world(5, 5, 3)
	world[2][2] = 1
	world[3][2] = 2
	var sim := LiquidSim.new()
	sim.setup(1, 2, 0, 3)
	sim.rebuild(world)
	sim.process(0.11, world, 2, 2, {3: true})
	_require(int(world[2][2]) == 3 and int(world[3][2]) == 3, "Water and lava did not solidify on contact")


func _test_partial_fill_levels() -> void:
	# A single unit of water splits across the tiles it reaches instead of
	# teleporting whole blocks around, so fill levels must survive a flow.
	var world := _make_test_world(7, 7, 3)
	world[1][3] = 1
	var sim := LiquidSim.new()
	sim.setup(1, 2, 0, 3)
	sim.rebuild(world)
	_require(sim.get_level(3, 1) == sim.LEVEL_MAX, "A fresh liquid tile is not a full block")
	var full_ratio: float = sim.get_fill_ratio(3, 1)
	_require(is_equal_approx(full_ratio, 1.0), "A full block does not report a full ratio")
	for step in range(6):
		sim.process(0.11, world, 3, 3, {3: true})
	var total_level := 0
	for y in range(world.size()):
		for x in range(world[y].size()):
			if int(world[y][x]) == 1:
				total_level += sim.get_level(x, y)
	_require(total_level == sim.LEVEL_MAX, "Liquid volume changed once fill levels were tracked")
	_require(sim.get_level(0, 0) == 0, "An empty tile reports a fill level")


func _test_pool_settles_without_jitter() -> void:
	# The reported bug: surface tiles of a pool traded places forever. With
	# fill levels a resting pool must go completely quiet.
	var width := 12
	var height := 8
	var world := _make_test_world(width, height, 3)
	for x in range(width):
		world[height - 1][x] = 3
	for y in range(height - 4, height - 1):
		for x in range(1, width - 1):
			world[y][x] = 1
	var sim := LiquidSim.new()
	sim.setup(1, 2, 0, 3)
	sim.rebuild(world)
	var water_before := _count_tile(world, 1)
	var quiet_steps := 0
	for step in range(60):
		if sim.process(0.11, world, width / 2, height - 2, {3: true}) == 0:
			quiet_steps += 1
			if quiet_steps >= 3:
				break
		else:
			quiet_steps = 0
	_require(quiet_steps >= 3, "Pool never stopped moving; liquids still jitter")
	_require(_count_tile(world, 1) == water_before, "Settled pool changed its water tile count")


func _test_generated_world() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	_require(game.world.size() == game.WORLD_HEIGHT, "Generated world height is invalid")
	_require(game.world[0].size() == game.WORLD_WIDTH, "Generated world width is invalid")
	var density_ratio := float(game.WORLD_WIDTH) / 560.0
	var chest_count := _count_tile(game.world, game.Tile.CHEST)
	_require(chest_count >= int(16.0 * density_ratio), "Generated world has too few structure and cave chests")
	_require(chest_count <= int(48.0 * density_ratio), "Generated world still has too many chests")
	_test_surface_biomes(game)
	_require(_all_chests_are_grounded(game), "Generated world contains a floating chest")
	_require(_surface_chest_count(game) == 0, "Generated world contains a loose surface chest")
	_test_chest_settling(game)
	_require(_count_tile(game.world, game.Tile.WATER) > 0, "Generated world has no water")
	_require(_count_tile(game.world, game.Tile.LAVA) > 0, "Generated world has no lava")
	_require(_count_tile(game.world, game.Tile.BUBBLE_VENT) > 0, "Flooded cistern landmark was not generated")
	_require(_count_tile(game.world, game.Tile.DRAIN_VALVE) > 0, "Cistern drain landmark was not generated")
	game.queue_free()
	await process_frame


func _test_surface_biomes(game: Variant) -> void:
	_require(game.surface_biomes.size() == game.WORLD_WIDTH, "Surface biome map does not cover the full world width")
	var distinct := {}
	var band_runs := 0
	var previous := ""
	for biome_variant in game.surface_biomes:
		var biome := str(biome_variant)
		distinct[biome] = true
		if biome != previous:
			band_runs += 1
			previous = biome
	_require(distinct.size() == 5, "Not every surface biome type was generated")
	_require(band_runs >= 6, "Surface biome bands are too small or too few")
	var spawn_x := int(game.WORLD_WIDTH / 2)
	_require(str(game.surface_biomes[spawn_x]) == "forest", "Spawn column is not inside the forest biome")
	_require(_no_conflicting_biomes_touch(game), "Ash desert and frost wasteland were generated side by side")
	_test_world_edges(game)
	_test_weather(game)
	_test_equipment_slots(game)
	_test_seabed_is_sealed(game)
	_test_sea_creatures(game)
	_test_leviathan_is_unkillable(game)
	_require(_border_metadata_is_sane(game), "Surface biome border metadata does not match the biome map")
	_require(_border_blend_mixes_biomes(game), "Surface biome borders are hard lines instead of blended strips")
	# Biomes own their topsoil below the first row, not only the surface tint.
	_require(_topsoil_matches(game, "ash_desert", game.Tile.ASH_SAND), "Ash desert lacks its ash sand surface")
	_require(_topsoil_matches(game, "ash_desert", game.Tile.ASH_SAND, 3), "Ash desert ash sand is not deep enough")
	_require(_topsoil_matches(game, "frost_wasteland", game.Tile.SNOW_BLOCK), "Frost wasteland lacks its snow surface")
	_require(_topsoil_matches(game, "frost_wasteland", game.Tile.FROZEN_DIRT, 1), "Frost wasteland lacks its frozen dirt topsoil")
	_require(_topsoil_matches(game, "marsh", game.Tile.MUD, 1), "Marsh lacks its mud topsoil")
	_require(_topsoil_matches(game, "ash_ruins", game.Tile.RUBBLE, 1), "Ash ruins lack their rubble topsoil")
	_require(_topsoil_matches(game, "forest", game.Tile.DIRT, 1), "Forest lacks its dirt topsoil")


func _test_leviathan_is_unkillable(game: Variant) -> void:
	# The world-edge leviathan is a wall, not a health bar: five times the
	# player's HP, 20 damage a hit so it never one shots, and immune to damage
	# until the story event unlocks it.
	var template: Dictionary = game._enemy_template("sea_leviathan")
	var levi_hp := int(template.get("max_hp", 0))
	_require(levi_hp == game.MAX_HEALTH * 5, "Leviathan HP is not five times the player's")
	_require(int(template.get("damage", 0)) == 20, "Leviathan does not deal 20 damage")
	var levi_dmg := int(template.get("damage", 0))
	_require(levi_dmg < game.MAX_HEALTH, "Leviathan one shots a full health player")
	_require(bool(template.get("story_invulnerable", false)), "Leviathan is not story invulnerable")
	game.leviathan_story_unlocked = false
	game.enemies.clear()
	game._spawn_enemy("sea_leviathan", Vector2(600, 400))
	var before := int((game.enemies[0] as Dictionary).get("hp", 0))
	game._damage_enemy(0, 999, Vector2.ZERO)
	var after_hit := int((game.enemies[0] as Dictionary).get("hp", 0))
	_require(after_hit == before, "Ordinary weapons hurt the leviathan")
	# After the story event it becomes mortal.
	game.leviathan_story_unlocked = true
	game._damage_enemy(0, 40, Vector2.ZERO)
	var after_story := int((game.enemies[0] as Dictionary).get("hp", 0))
	_require(after_story < before, "Leviathan stays immune after the story unlock")
	game.leviathan_story_unlocked = false
	game.enemies.clear()
	# The animation pack has to be loaded, or it falls back to a colour blob.
	var anims: Dictionary = game.enemy_animation_textures.get("sea_leviathan", {})
	_require(anims.has("idle"), "Sea Leviathan idle animation was not loaded")
	_require(anims.has("attack_1"), "Sea Leviathan bite animation was not loaded")
	_require(anims.size() >= 10, "Sea Leviathan animation pack is incomplete")


func _test_weather(game: Variant) -> void:
	# Weather is global, but what it does depends on depth and biome.
	game._start_weather(game.WEATHER_CLEAR, 60.0)
	game.weather_intensity = 0.0
	_require(is_zero_approx(game._weather_strength()), "Clear weather still has strength")
	_require(is_zero_approx(game._weather_temperature_shift()), "Clear weather shifts temperature")

	# Put the player on the surface so the weather is fully felt.
	var spawn_x := int(game.WORLD_WIDTH / 2)
	var surface_y := int(game.surface_heights[spawn_x])
	game.player_position = Vector2(spawn_x * game.TILE_SIZE, (surface_y - 2) * game.TILE_SIZE)
	game._start_weather(game.WEATHER_BLIZZARD, 60.0)
	game.weather_intensity = 1.0
	_require(game._weather_strength() > 0.9, "Surface blizzard is not at full strength")
	_require(game._weather_temperature_shift() < -5.0, "Blizzard does not make it colder")
	_require(game._weather_visibility_penalty() > 0.5, "Blizzard does not reduce visibility")

	# Ash storms heat the air instead of cooling it.
	game._start_weather(game.WEATHER_ASHFALL, 60.0)
	game.weather_intensity = 1.0
	_require(game._weather_temperature_shift() > 5.0, "Ash storm does not make it hotter")

	# Storms mask footsteps, fog carries them.
	game._start_weather(game.WEATHER_STORM, 60.0)
	game.weather_intensity = 1.0
	_require(game._weather_noise_mask() < 1.0, "A storm does not mask footsteps")
	game._start_weather(game.WEATHER_FOG, 60.0)
	game.weather_intensity = 1.0
	_require(game._weather_noise_mask() > 1.0, "Fog does not carry sound further")

	# Deep underground nothing of the surface is felt at all.
	game._start_weather(game.WEATHER_BLIZZARD, 60.0)
	game.weather_intensity = 1.0
	game.player_position = Vector2(spawn_x * game.TILE_SIZE,
		(surface_y + game.WEATHER_DEPTH_SILENT + 4) * game.TILE_SIZE)
	_require(is_zero_approx(game._weather_strength()), "Weather still reaches deep underground")
	var deep_shift: float = game._weather_temperature_shift()
	var deep_vis: float = game._weather_visibility_penalty()
	_require(is_zero_approx(deep_shift), "Weather changes temperature underground")
	_require(is_zero_approx(deep_vis), "Weather blinds the player underground")
	game.player_position = Vector2(spawn_x * game.TILE_SIZE, (surface_y - 2) * game.TILE_SIZE)
	game._start_weather(game.WEATHER_CLEAR, 60.0)
	game.weather_intensity = 0.0


func _test_equipment_slots(game: Variant) -> void:
	# Armour is four pieces, and every worn piece has to count toward defense.
	game.equipped_helmet = ""
	game.equipped_armor = ""
	game.equipped_legs = ""
	game.equipped_boots = ""
	game.equipped_accessory = ""
	_require(game._total_defense() == 0, "Bare player already has defense")
	for material in ["copper", "iron", "stoneblood"]:
		var pieces := {
			"helmet": "%s_helmet" % material,
			"chest": "%s_chestplate" % material,
			"legs": "%s_greaves" % material,
			"boots": "%s_boots" % material,
		}
		var expected := 0
		for slot_name in pieces:
			var gear_id := str(pieces[slot_name])
			_require(game.gear_stats.has(gear_id), "Missing armour piece %s" % gear_id)
			var gear: Dictionary = game.gear_stats[gear_id]
			_require(str(gear.get("slot", "")) == slot_name, "%s sits in the wrong slot" % gear_id)
			_require(game.item_names.has(gear_id), "%s has no display name" % gear_id)
			expected += int(gear.get("defense", 0))
			game._equip_item_id(gear_id)
		_require(game._total_defense() == expected, "%s set defense does not add up" % material)
	# Each material must be a real upgrade over the last.
	game.equipped_helmet = "copper_helmet"
	game.equipped_armor = "copper_chestplate"
	game.equipped_legs = "copper_greaves"
	game.equipped_boots = "copper_boots"
	var copper_total := int(game._total_defense())
	game.equipped_helmet = "iron_helmet"
	game.equipped_armor = "iron_chestplate"
	game.equipped_legs = "iron_greaves"
	game.equipped_boots = "iron_boots"
	var iron_total := int(game._total_defense())
	game.equipped_helmet = "stoneblood_helmet"
	game.equipped_armor = "stoneblood_chestplate"
	game.equipped_legs = "stoneblood_greaves"
	game.equipped_boots = "stoneblood_boots"
	var stone_total := int(game._total_defense())
	_require(copper_total < iron_total, "Iron armour is not better than copper")
	_require(iron_total < stone_total, "Stoneblood armour is not better than iron")
	# Selecting a hotbar slot must wield the weapon in it, with no equip step.
	game.hotbar[0] = "copper_sword"
	game.selected_slot = 0
	game._update_selection_from_hotbar()
	_require(str(game.equipped_weapon) == "copper_sword", "Hotbar did not wield the sword")
	game.hotbar[1] = "wooden_bow"
	game.selected_slot = 1
	game._update_selection_from_hotbar()
	_require(str(game.equipped_weapon) == "wooden_bow", "Switching hotbar slots did not swap weapon")
	# A tool in a slot must not leave a stale weapon wielded by mistake.
	game.hotbar[2] = "wooden_pickaxe"
	game.selected_slot = 2
	game._update_selection_from_hotbar()
	_require(str(game.current_tool) == "wooden_pickaxe", "Hotbar did not select the tool")


func _test_seabed_is_sealed(game: Variant) -> void:
	# A single cave breaching the sea floor drains the whole dead sea, so the
	# seabed has to be solid everywhere the water sits.
	var checked := 0
	var leaks := 0
	for x in range(game.WORLD_WIDTH):
		var sea_level: int = game._edge_sea_level_at(x)
		if sea_level < 0:
			continue
		checked += 1
		var surface_y := int(game.surface_heights[x])
		# Every tile from the waterline down to the bed must be water or solid,
		# never an open cave that the sea could pour into.
		for y in range(sea_level, surface_y + 1):
			var tile := int(game.world[y][x])
			if tile == game.Tile.AIR:
				leaks += 1
				break
		# The floor itself and the rock under it must be solid.
		for depth in range(1, 5):
			if not game._is_solid(x, surface_y + depth):
				leaks += 1
				break
	_require(checked > 20, "No sea columns were found to check")
	_require(leaks == 0, "The dead sea floor has holes and would drain")
	# The protection helper must agree with where the water actually is.
	for x in range(0, 40):
		if game._edge_sea_level_at(x) >= 0:
			_require(game._is_protected_seabed(x, int(game.surface_heights[x])),
				"A sea column is not protected from carving")


func _test_sea_creatures(game: Variant) -> void:
	# Sea creatures must be a real reason to fear deep water: harmless at the
	# beach, increasingly likely further out, and unable to leave the water.
	for enemy_type in ["brine_lurker", "drowned_leviathan"]:
		var template: Dictionary = game._enemy_template(enemy_type)
		_require(bool(template.get("flying", false)), "%s cannot swim freely" % enemy_type)
		_require(game._is_sea_creature(enemy_type), "%s is not treated as a sea creature" % enemy_type)
		var drop := str(template.get("drop", ""))
		_require(game.item_names.has(drop), "%s drops an unnamed item" % enemy_type)
		_require(game._enemy_habitat(enemy_type).contains("sea"), "%s has no sea habitat" % enemy_type)
	# Threat has to be zero on dry land and rise towards the rim.
	var spawn_x := int(game.WORLD_WIDTH / 2)
	var dry_y: int = (int(game.surface_heights[spawn_x]) - 2) * game.TILE_SIZE
	game.player_position = Vector2(spawn_x * game.TILE_SIZE, dry_y)
	_require(is_zero_approx(game._sea_threat_level()), "Dry land reports a sea threat")
	# Deep water near the rim must be the most dangerous place.
	var deep_threat := 0.0
	var shallow_threat := 0.0
	for y in range(game.WORLD_HEIGHT):
		if int(game.world[y][3]) == game.Tile.WATER:
			game.player_position = Vector2(3 * game.TILE_SIZE, (y + 1) * game.TILE_SIZE)
			deep_threat = maxf(deep_threat, float(game._sea_threat_level()))
		if int(game.world[y][95]) == game.Tile.WATER:
			game.player_position = Vector2(95 * game.TILE_SIZE, (y + 1) * game.TILE_SIZE)
			shallow_threat = maxf(shallow_threat, float(game._sea_threat_level()))
	_require(deep_threat > 0.8, "Water at the rim is not treated as dangerous")
	_require(deep_threat > shallow_threat, "Sea threat does not grow towards the world edge")
	# A creature dragged into the air must snap back into the water, not fly.
	# This is what stopped sea creatures chasing a noclipping player upward.
	var air_pos := Vector2(3 * game.TILE_SIZE, 2 * game.TILE_SIZE)
	var water_y := -1
	for y in range(game.WORLD_HEIGHT):
		if int(game.world[y][3]) == game.Tile.WATER:
			water_y = y
			break
	if water_y > 4:
		var flyer := {"type": "brine_lurker", "hp": 30, "beached_time": 0.0}
		var snapped: Vector2 = game._constrain_sea_creature(flyer, air_pos, Vector2(24, 13), 0.05)
		_require(snapped.y > air_pos.y, "A sea creature stayed up in the air")
		_require(snapped.y >= float(water_y) * game.TILE_SIZE, "A sea creature did not reach the water")

	# A creature stranded out of water must not hover in the air forever.
	var beached := {"type": "brine_lurker", "hp": 30, "beached_time": 0.0}
	var dry_pos := Vector2(spawn_x * game.TILE_SIZE, 4 * game.TILE_SIZE)
	var moved: Vector2 = game._constrain_sea_creature(beached, dry_pos, Vector2(24, 13), 0.2)
	_require(moved.y > dry_pos.y, "A beached sea creature does not sink back down")
	for step in range(20):
		moved = game._constrain_sea_creature(beached, moved, Vector2(24, 13), 0.2)
	_require(int(beached.get("hp", 1)) <= 0, "A sea creature survives forever out of water")


func _test_world_edges(game: Variant) -> void:
	# The map has to end in a shoreline and open water rather than a wall of
	# land the player simply bumps into.
	var rim_height := int(game.surface_heights[0])
	var inland_height := int(game.surface_heights[game.WORLD_WIDTH / 2])
	_require(rim_height > inland_height + 20, "World edge does not slope down into a basin")
	var right_rim := int(game.surface_heights[game.WORLD_WIDTH - 1])
	_require(right_rim > inland_height + 20, "Right world edge does not slope down into a basin")
	var edge_water := 0
	for y in range(game.WORLD_HEIGHT):
		if int(game.world[y][2]) == game.Tile.WATER:
			edge_water += 1
	_require(edge_water > 10, "World edge has no dead sea covering it")
	# The sea must stay on the margin instead of flooding the spawn region.
	var spawn_x := int(game.WORLD_WIDTH / 2)
	var spawn_surface := int(game.surface_heights[spawn_x])
	var above_spawn := int(game.world[spawn_surface - 1][spawn_x])
	_require(above_spawn != game.Tile.WATER, "Dead sea flooded the spawn area")
	# No dry rock may stick out of the sea where the bed sits above the water.
	for x in range(0, 60):
		var sea_level: int = game._edge_sea_level_at(x)
		if sea_level < 0:
			continue
		_require(int(game.surface_heights[x]) > sea_level, "A sea column has its bed above the waterline")


func _no_conflicting_biomes_touch(game: Variant) -> bool:
	# Climate opposites never share a border, so no column of one may sit next
	# to a column of the other once the blend strips are accounted for.
	var previous := ""
	var run_biomes: Array[String] = []
	for biome_variant in game.surface_biomes:
		var biome := str(biome_variant)
		if biome != previous:
			run_biomes.append(biome)
			previous = biome
	for i in range(1, run_biomes.size()):
		if game._biomes_conflict(run_biomes[i - 1], run_biomes[i]):
			return false
	return true


func _border_metadata_is_sane(game: Variant) -> bool:
	if game.border_distances.size() != game.WORLD_WIDTH:
		return false
	if game.border_neighbors.size() != game.WORLD_WIDTH:
		return false
	for x in range(game.WORLD_WIDTH):
		var distance := int(game.border_distances[x])
		if distance >= game.SURFACE_BORDER_BLEND:
			continue
		var neighbor := str(game.border_neighbors[x])
		# Inside a blend strip there is always a different biome on the far
		# side of the seam.
		if neighbor.is_empty() or neighbor == str(game.surface_biomes[x]):
			return false
	return true


func _border_blend_mixes_biomes(game: Variant) -> bool:
	# At least one seam has to show foreign topsoil pockets on its own side,
	# otherwise the transition never actually blended.
	for x in range(game.WORLD_WIDTH):
		if int(game.border_distances[x]) >= game.SURFACE_BORDER_BLEND:
			continue
		var column_biome := str(game.surface_biomes[x])
		var surface_y := int(game.surface_heights[x])
		for y in range(surface_y, mini(game.WORLD_HEIGHT, surface_y + 6)):
			if str(game._blended_biome_at(x, y, column_biome)) != column_biome:
				return true
	return false


func _topsoil_matches(game: Variant, biome: String, expected_tile: int, depth: int = 0) -> bool:
	var checked := 0
	for x in range(game.WORLD_WIDTH):
		if str(game.surface_biomes[x]) != biome:
			continue
		# Border strips deliberately mix in the neighbouring biome's blocks, so
		# only columns well inside a band prove the base topsoil rule.
		if int(game.border_distances[x]) < game.SURFACE_BORDER_BLEND:
			continue
		var surface_y := int(game.surface_heights[x])
		var surface_tile := int(game.world[surface_y][x])
		# Skip pond, moss rim and otherwise disturbed columns; this checks the
		# generator's base terrain rule, not later decorative passes.
		if surface_tile != game.Tile.GRASS and surface_tile != game.Tile.SNOW_BLOCK and surface_tile != game.Tile.ASH_SAND:
			continue
		if int(game.world[surface_y + depth][x]) != expected_tile:
			return false
		checked += 1
		if checked >= 12:
			break
	return checked > 0


func _all_chests_are_grounded(game: Variant) -> bool:
	for y in range(game.WORLD_HEIGHT - 1):
		for x in range(game.WORLD_WIDTH):
			if int(game.world[y][x]) == game.Tile.CHEST and not game._is_solid(x, y + 1):
				return false
	return true


func _surface_chest_count(game: Variant) -> int:
	var count := 0
	for x in range(game.WORLD_WIDTH):
		var surface_y := int(game.surface_heights[x])
		for y in range(maxi(0, surface_y - 4), mini(game.WORLD_HEIGHT, surface_y + 8)):
			if int(game.world[y][x]) == game.Tile.CHEST:
				count += 1
	return count


func _test_chest_settling(game: Variant) -> void:
	var chest_pos := Vector2i(3, 3)
	var landing_pos := chest_pos + Vector2i(0, 1)
	game._set_tile(chest_pos.x, chest_pos.y, game.Tile.CHEST)
	game._set_tile(landing_pos.x, landing_pos.y, game.Tile.AIR)
	game._set_tile(landing_pos.x, landing_pos.y + 1, game.Tile.STONE)
	var old_key: String = game._tile_key(chest_pos)
	var new_key: String = game._tile_key(landing_pos)
	game.chest_loot[old_key] = {"torch": 2}
	game._settle_unsupported_chest(chest_pos)
	_require(int(game.world[landing_pos.y][landing_pos.x]) == game.Tile.CHEST, "Unsupported chest did not settle onto the floor")
	_require(not game.chest_loot.has(old_key) and int(game.chest_loot.get(new_key, {}).get("torch", 0)) == 2, "Settled chest lost its stored loot")


func _make_test_world(width: int, height: int, solid_tile: int) -> Array:
	var world: Array = []
	for y in range(height):
		var row: Array[int] = []
		for x in range(width):
			row.append(solid_tile if y == height - 1 else 0)
		world.append(row)
	return world


func _count_tile(world: Array, target_tile: int) -> int:
	var count := 0
	for row in world:
		for tile in row:
			if int(tile) == target_tile:
				count += 1
	return count


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error(message)
