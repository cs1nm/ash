extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if game.temperature_panel == null or game.temperature_bar == null or game.temperature_value == null:
		push_error("Temperature HUD was not created")
		quit(1)
		return
	if absf(float(game.body_temperature) - game.NORMAL_BODY_TEMPERATURE) > 0.5:
		push_error("New world did not start at normal body temperature")
		quit(1)
		return

	var unprotected_cold: float = game._temperature_target_for_environment(-12.0, 0.0, 0.0)
	var protected_cold: float = game._temperature_target_for_environment(-12.0, 0.45, 0.0)
	if protected_cold <= unprotected_cold:
		push_error("Cold protection does not reduce body cooling")
		quit(1)
		return
	var unprotected_heat: float = game._temperature_target_for_environment(68.0, 0.0, 0.0)
	var protected_heat: float = game._temperature_target_for_environment(68.0, 0.0, 0.58)
	if protected_heat >= unprotected_heat:
		push_error("Heat protection does not reduce body heating")
		quit(1)
		return

	game.equipped_armor = "drowned_armor"
	game.equipped_accessory = "ember_ward"
	if game._temperature_protection("cold_protection") < 0.44 or game._temperature_protection("heat_protection") < 0.57:
		push_error("Equipped temperature protection values are not aggregated")
		quit(1)
		return

	game.body_temperature = 37.0
	if not is_equal_approx(game._temperature_action_multiplier(), 1.0):
		push_error("Safe body temperature applies an action penalty")
		quit(1)
		return
	game.body_temperature = 30.0
	if not is_equal_approx(game._temperature_action_multiplier(), 0.72):
		push_error("Extreme body temperature does not apply the severe action penalty")
		quit(1)
		return

	game.god_mode_enabled = false
	game.health = 100
	game.player_hurt_timer = 0.0
	game.temperature_damage_tick = 0.0
	game.body_temperature = 30.0
	game._update_temperature_consequences(0.1)
	if game.health != 96:
		push_error("Dangerous cold did not cause temperature damage")
		quit(1)
		return
	game.health = 100
	game.player_hurt_timer = 0.0
	game.temperature_damage_tick = 0.0
	game.body_temperature = 44.0
	game._update_temperature_consequences(0.1)
	if game.health != 95:
		push_error("Dangerous heat did not cause temperature damage")
		quit(1)
		return

	game._execute_debug_command("temp 39.5")
	if not is_equal_approx(float(game.body_temperature), 39.5):
		push_error("Temperature debug command did not set body temperature")
		quit(1)
		return

	print("ENVIRONMENT_SMOKE_OK cold=%.1f->%.1f heat=%.1f->%.1f" % [unprotected_cold, protected_cold, unprotected_heat, protected_heat])
	game.queue_free()
	await process_frame
	quit()
