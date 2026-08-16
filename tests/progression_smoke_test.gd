extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game: Variant = load("res://Main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	_require(game._enemy_base_tier("wild_slime") == 1, "Wild Slime is not an early-game enemy")
	_require(game._enemy_base_tier("heartwood_boss") == 3, "Heartwood boss tier is incorrect")
	_require(game._enemy_base_tier("stone_beast") == 4, "Stone Beast tier is incorrect")
	_require(game._enemy_base_tier("archive_warden") == 6, "Archive Warden is not the final tier")

	game.equipped_weapon = "wooden_sword"
	game.current_tool = "wooden_pickaxe"
	_require(game._player_progression_tier() == 1, "Starter equipment reports the wrong progression tier")
	var starter_slime_tier: int = game._effective_enemy_tier("wild_slime")

	game.equipped_weapon = "leviathan_fang"
	_require(game._player_progression_tier() == 6, "End-game weapon does not raise player progression")
	var late_slime_tier: int = game._effective_enemy_tier("wild_slime")
	_require(late_slime_tier > starter_slime_tier, "Early enemies do not catch up with player equipment")

	var scaled_slime: Dictionary = game._enemy_template("wild_slime")
	var base_hp := int(scaled_slime.get("max_hp", 0))
	var base_damage := int(scaled_slime.get("damage", 0))
	game._apply_enemy_progression(scaled_slime, "wild_slime")
	_require(int(scaled_slime.get("tier", 0)) == late_slime_tier, "Scaled enemy does not store its tier")
	_require(int(scaled_slime.get("hp", 0)) > base_hp, "Enemy health was not scaled")
	_require(int(scaled_slime.get("damage", 0)) > base_damage, "Enemy damage was not scaled")
	_require(int(scaled_slime.get("base_max_hp", 0)) == base_hp, "Enemy base health was not preserved")

	var weapon_text: String = game._format_item_tooltip("leviathan_fang", 1)
	_require(weapon_text.contains("Damage"), "Weapon tooltip has no damage characteristic")
	_require(weapon_text.contains("Tier 6"), "Weapon tooltip has no equipment tier")
	var armor_text: String = game._format_item_tooltip("stoneblood_chestplate", 1)
	_require(armor_text.contains("Defense"), "Armor tooltip has no defense characteristic")
	_require(armor_text.contains("cold") and armor_text.contains("heat"), "Armor tooltip has no temperature protection")
	var tool_text: String = game._format_item_tooltip("iron_pickaxe", 1)
	_require(tool_text.contains("Power") and tool_text.contains("mining speed"), "Tool tooltip has no mining characteristics")
	var story_text: String = game._format_item_tooltip("ashen_lens", 1)
	_require(story_text.contains("Warden"), "Story item tooltip has no story purpose")

	game.inventory_open = false
	game.full_map_open = false
	game.attack_cooldown = 0.0
	game.equipped_weapon = "harpoon"
	game.projectiles.clear()
	game._try_player_attack_at(game.player_position + Vector2(120, 0), true)
	_require(not game.projectiles.is_empty(), "Harpoon does not create a projectile")
	if not game.projectiles.is_empty():
		var harpoon: Dictionary = game.projectiles[-1]
		_require(str(harpoon.get("kind", "")) == "harpoon", "Harpoon creates the wrong projectile")
		_require(str(harpoon.get("status", "")) == "slow", "Harpoon projectile has no slow effect")

	game.free()
	if failed:
		quit(1)
		return
	print("PROGRESSION_SMOKE_OK")
	quit()


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error(message)
