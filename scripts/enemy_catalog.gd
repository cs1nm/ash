extends RefCounted
class_name EnemyCatalog

const PERCEPTION_PROFILES := {
	"wild_slime": {"vision_range": 150.0, "vision_angle": 105.0, "hearing": 0.75, "light_sensitivity": 1.0, "suspicion_rate": 1.15, "memory_time": 3.0, "search_time": 4.0, "alert_radius": 105.0},
	"mossling": {"vision_range": 175.0, "vision_angle": 125.0, "hearing": 1.0, "light_sensitivity": 0.85, "suspicion_rate": 1.35, "memory_time": 4.0, "search_time": 5.0, "alert_radius": 135.0},
	"root_crawler": {"vision_range": 145.0, "vision_angle": 95.0, "hearing": 1.35, "light_sensitivity": 0.45, "suspicion_rate": 1.10, "memory_time": 5.5, "search_time": 7.0, "alert_radius": 145.0},
	"cave_worm": {"vision_range": 105.0, "vision_angle": 80.0, "hearing": 1.65, "light_sensitivity": 0.15, "suspicion_rate": 1.25, "memory_time": 6.0, "search_time": 7.5, "alert_radius": 140.0},
	"bat": {"vision_range": 135.0, "vision_angle": 210.0, "hearing": 1.75, "light_sensitivity": 0.20, "suspicion_rate": 1.55, "memory_time": 4.5, "search_time": 6.0, "alert_radius": 170.0},
	"cave_husk": {"vision_range": 165.0, "vision_angle": 115.0, "hearing": 1.05, "light_sensitivity": 0.75, "suspicion_rate": 1.30, "memory_time": 5.0, "search_time": 6.0, "alert_radius": 145.0},
	"spore_bat": {"vision_range": 155.0, "vision_angle": 220.0, "hearing": 1.65, "light_sensitivity": 0.25, "suspicion_rate": 1.65, "memory_time": 5.0, "search_time": 6.5, "alert_radius": 185.0},
	"mushroom_beetle": {"vision_range": 145.0, "vision_angle": 100.0, "hearing": 1.20, "light_sensitivity": 0.45, "suspicion_rate": 1.20, "memory_time": 5.0, "search_time": 6.0, "alert_radius": 135.0},
	"ash_phantom": {"vision_range": 215.0, "vision_angle": 240.0, "hearing": 0.85, "light_sensitivity": 0.55, "suspicion_rate": 1.65, "memory_time": 7.0, "search_time": 8.0, "alert_radius": 190.0},
	"ash_wisp": {"vision_range": 185.0, "vision_angle": 260.0, "hearing": 0.95, "light_sensitivity": 0.35, "suspicion_rate": 1.55, "memory_time": 5.0, "search_time": 6.0, "alert_radius": 165.0},
	"ruin_drone": {"vision_range": 245.0, "vision_angle": 150.0, "hearing": 0.80, "light_sensitivity": 0.90, "suspicion_rate": 1.85, "memory_time": 8.0, "search_time": 9.0, "alert_radius": 225.0},
	"ash_sentinel": {"vision_range": 225.0, "vision_angle": 125.0, "hearing": 1.10, "light_sensitivity": 0.75, "suspicion_rate": 1.60, "memory_time": 8.0, "search_time": 9.0, "alert_radius": 210.0},
	"drowned_guard": {"vision_range": 185.0, "vision_angle": 120.0, "hearing": 1.30, "light_sensitivity": 0.50, "suspicion_rate": 1.45, "memory_time": 7.0, "search_time": 8.0, "alert_radius": 190.0},
	"ember_rootling": {"vision_range": 190.0, "vision_angle": 115.0, "hearing": 1.20, "light_sensitivity": 0.30, "suspicion_rate": 1.50, "memory_time": 6.5, "search_time": 7.0, "alert_radius": 180.0},
	"glass_wraith": {"vision_range": 260.0, "vision_angle": 280.0, "hearing": 0.95, "light_sensitivity": 0.10, "suspicion_rate": 1.90, "memory_time": 9.0, "search_time": 10.0, "alert_radius": 230.0},
	"night_ember": {"vision_range": 210.0, "vision_angle": 250.0, "hearing": 1.10, "light_sensitivity": 0.15, "suspicion_rate": 1.75, "memory_time": 6.0, "search_time": 7.0, "alert_radius": 185.0},
	"sea_leviathan": {"vision_range": 420.0, "vision_angle": 330.0, "hearing": 2.10, "light_sensitivity": 0.05, "suspicion_rate": 2.60, "memory_time": 14.0, "search_time": 12.0, "alert_radius": 420.0},
	"brine_lurker": {"vision_range": 175.0, "vision_angle": 300.0, "hearing": 1.60, "light_sensitivity": 0.10, "suspicion_rate": 1.95, "memory_time": 7.0, "search_time": 8.0, "alert_radius": 240.0},
	"drowned_leviathan": {"vision_range": 240.0, "vision_angle": 320.0, "hearing": 1.80, "light_sensitivity": 0.05, "suspicion_rate": 2.20, "memory_time": 11.0, "search_time": 10.0, "alert_radius": 300.0},
	"stone_beast": {"vision_range": 290.0, "vision_angle": 170.0, "hearing": 1.45, "light_sensitivity": 0.20, "suspicion_rate": 2.40, "memory_time": 12.0, "search_time": 10.0, "alert_radius": 260.0},
	"heartwood_boss": {"vision_range": 320.0, "vision_angle": 220.0, "hearing": 1.50, "light_sensitivity": 0.10, "suspicion_rate": 2.60, "memory_time": 14.0, "search_time": 12.0, "alert_radius": 280.0},
	"archive_warden": {"vision_range": 330.0, "vision_angle": 185.0, "hearing": 1.60, "light_sensitivity": 0.15, "suspicion_rate": 2.70, "memory_time": 15.0, "search_time": 12.0, "alert_radius": 300.0}
}

const SPRITE_SPECS := {
	"wild_slime": {"frame": Vector2i(40, 32), "idle_row": 0, "idle_frames": 4, "move_row": 1, "move_frames": 4, "fps": 7.0, "scale": 0.58},
	"mossling": {"frame": Vector2i(48, 32), "idle_row": 0, "idle_frames": 4, "move_row": 1, "move_frames": 8, "fps": 8.0, "scale": 0.58},
	"root_crawler": {"frame": Vector2i(64, 32), "idle_row": 0, "idle_frames": 4, "move_row": 1, "move_frames": 8, "fps": 9.0, "scale": 0.58},
	"cave_worm": {"frame": Vector2i(80, 32), "idle_row": 0, "idle_frames": 4, "move_row": 1, "move_frames": 8, "fps": 8.0, "scale": 0.58},
	"bat": {"frame": Vector2i(48, 32), "idle_row": 0, "idle_frames": 6, "move_row": 0, "move_frames": 6, "fps": 11.0, "scale": 0.58},
	"cave_husk": {"frame": Vector2i(48, 64), "idle_row": 0, "idle_frames": 4, "move_row": 1, "move_frames": 8, "fps": 7.0, "scale": 0.58},
	"spore_bat": {"frame": Vector2i(48, 32), "idle_row": 0, "idle_frames": 6, "move_row": 0, "move_frames": 6, "fps": 10.0, "scale": 0.58},
	"mushroom_beetle": {"frame": Vector2i(48, 32), "idle_row": 0, "idle_frames": 4, "move_row": 1, "move_frames": 8, "fps": 8.0, "scale": 0.58},
	"ash_phantom": {"frame": Vector2i(40, 40), "idle_row": 0, "idle_frames": 23, "move_row": 0, "move_frames": 23, "fps": 13.0, "scale": 0.72},
	"ash_wisp": {"frame": Vector2i(40, 40), "idle_row": 0, "idle_frames": 6, "move_row": 0, "move_frames": 6, "fps": 10.0, "scale": 0.58},
	"ruin_drone": {"frame": Vector2i(48, 48), "idle_row": 0, "idle_frames": 6, "move_row": 0, "move_frames": 6, "fps": 9.0, "scale": 0.58},
	"ash_sentinel": {"frame": Vector2i(64, 64), "idle_row": 0, "idle_frames": 8, "move_row": 1, "move_frames": 8, "fps": 7.0, "scale": 0.58},
	"drowned_guard": {"frame": Vector2i(64, 64), "idle_row": 0, "idle_frames": 8, "move_row": 1, "move_frames": 8, "fps": 7.0, "scale": 0.58},
	"ember_rootling": {"frame": Vector2i(64, 48), "idle_row": 0, "idle_frames": 8, "move_row": 1, "move_frames": 8, "fps": 8.0, "scale": 0.58},
	"glass_wraith": {"frame": Vector2i(48, 64), "idle_row": 0, "idle_frames": 8, "move_row": 1, "move_frames": 8, "fps": 9.0, "scale": 0.58},
	"night_ember": {"frame": Vector2i(40, 40), "idle_row": 0, "idle_frames": 6, "move_row": 0, "move_frames": 6, "fps": 11.0, "scale": 0.58},
	"brine_lurker": {"frame": Vector2i(64, 64), "idle_row": 0, "idle_frames": 4, "move_row": 1, "move_frames": 4, "fps": 9.0, "scale": 0.58},
	"sea_leviathan": {"frame": Vector2i(256, 192), "idle_row": 0, "idle_frames": 8, "move_row": 0, "move_frames": 8, "fps": 6.0, "scale": 0.90},
	"drowned_leviathan": {"frame": Vector2i(64, 64), "idle_row": 0, "idle_frames": 4, "move_row": 1, "move_frames": 4, "fps": 6.0, "scale": 0.82},
	"stone_beast": {"frame": Vector2i(144, 112), "idle_row": 0, "idle_frames": 8, "move_row": 1, "move_frames": 8, "fps": 6.0, "scale": 0.64},
	"heartwood_boss": {"frame": Vector2i(128, 144), "idle_row": 0, "idle_frames": 10, "move_row": 0, "move_frames": 10, "fps": 6.0, "scale": 0.64},
	"archive_warden": {"frame": Vector2i(128, 112), "idle_row": 0, "idle_frames": 8, "move_row": 0, "move_frames": 8, "fps": 6.0, "scale": 0.64}
}


static func template(enemy_type: String) -> Dictionary:
	var templates := {
		"wild_slime": {"name": "Wild Slime", "hp": 18, "max_hp": 18, "damage": 7, "damage_type": "physical", "speed": 64.0, "flying": false, "size": Vector2(16, 13), "color": Color("5fbf7b"), "drop": "wild_ichor"},
		"mossling": {"name": "Mossling", "hp": 20, "max_hp": 20, "damage": 6, "damage_type": "physical", "speed": 72.0, "flying": false, "size": Vector2(18, 12), "color": Color("5c9a63"), "drop": "moss_fiber"},
		"cave_worm": {"name": "Cave Worm", "hp": 46, "max_hp": 46, "damage": 11, "damage_type": "physical", "speed": 82.0, "flying": false, "size": Vector2(34, 12), "hitbox_size": Vector2(62, 24), "hitbox_offset": Vector2(0, -6), "color": Color("9b6b4d"), "drop": "wild_ichor", "status_on_hit": "slow"},
		"bat": {"name": "Bat", "hp": 16, "max_hp": 16, "damage": 6, "damage_type": "physical", "speed": 128.0, "flying": true, "size": Vector2(22, 14), "hitbox_size": Vector2(42, 28), "color": Color("4f5165"), "drop": "wild_ichor"},
		"spore_bat": {"name": "Spore Bat", "hp": 22, "max_hp": 22, "damage": 8, "damage_type": "poison", "speed": 118.0, "flying": true, "size": Vector2(21, 14), "hitbox_size": Vector2(42, 24), "color": Color("79c98b"), "drop": "glowcap", "status_on_hit": "poison"},
		"ash_phantom": {"name": "Ash Phantom", "hp": 32, "max_hp": 32, "damage": 10, "damage_type": "fire", "speed": 88.0, "flying": true, "size": Vector2(18, 24), "color": Color("a88cff"), "drop": "memory_shard", "status_on_hit": "burn"},
		"mushroom_beetle": {"name": "Mushroom Beetle", "hp": 34, "max_hp": 34, "damage": 9, "damage_type": "poison", "speed": 54.0, "flying": false, "size": Vector2(20, 14), "hitbox_size": Vector2(56, 28), "hitbox_offset": Vector2(0, -4), "color": Color("65b47d"), "drop": "mushroom_spore", "status_on_hit": "poison"},
		"root_crawler": {"name": "Root Crawler", "hp": 30, "max_hp": 30, "damage": 8, "damage_type": "physical", "speed": 62.0, "flying": false, "size": Vector2(22, 12), "hitbox_size": Vector2(58, 22), "hitbox_offset": Vector2(0, -4), "color": Color("8a6638"), "drop": "root", "status_on_hit": "slow"},
		"ruin_drone": {"name": "Ruin Drone", "hp": 36, "max_hp": 36, "damage": 12, "damage_type": "arcane", "speed": 95.0, "flying": true, "size": Vector2(16, 16), "color": Color("8fa9c9"), "drop": "spark_shard"},
		"ash_sentinel": {"name": "Ash Sentinel", "hp": 48, "max_hp": 48, "damage": 14, "damage_type": "fire", "speed": 56.0, "flying": false, "size": Vector2(20, 28), "color": Color("7b707e"), "drop": "ash_relic", "status_on_hit": "burn"},
		"drowned_guard": {"name": "Drowned Guard", "hp": 44, "max_hp": 44, "damage": 12, "damage_type": "physical", "speed": 50.0, "flying": false, "size": Vector2(20, 24), "color": Color("4e8a94"), "drop": "drowned_pearl", "status_on_hit": "slow"},
		"ember_rootling": {"name": "Ember Rootling", "hp": 52, "max_hp": 52, "damage": 15, "damage_type": "fire", "speed": 64.0, "flying": false, "size": Vector2(24, 18), "color": Color("c15b38"), "drop": "ember_root", "status_on_hit": "burn"},
		"glass_wraith": {"name": "Glass Wraith", "hp": 58, "max_hp": 58, "damage": 16, "damage_type": "arcane", "speed": 92.0, "flying": true, "size": Vector2(18, 28), "color": Color("b8f4ff"), "drop": "abyss_crystal", "status_on_hit": "slow"},
		"stone_beast": {"name": "Stone Beast", "hp": 420, "max_hp": 420, "damage": 22, "damage_type": "physical", "speed": 40.0, "flying": false, "size": Vector2(56, 42), "color": Color("7f7368"), "drop": "beast_core"},
		"night_ember": {"name": "Night Ember", "hp": 28, "max_hp": 28, "damage": 12, "damage_type": "fire", "speed": 92.0, "flying": true, "size": Vector2(15, 15), "color": Color("ee6f46"), "drop": "night_ember", "status_on_hit": "burn"},
		"cave_husk": {"name": "Cave Husk", "hp": 38, "max_hp": 38, "damage": 10, "damage_type": "physical", "speed": 58.0, "flying": false, "size": Vector2(18, 22), "hitbox_size": Vector2(72, 42), "hitbox_offset": Vector2(0, -10), "color": Color("8f8796"), "drop": "wild_ichor"},
		"ash_wisp": {"name": "Ash Wisp", "hp": 22, "max_hp": 22, "damage": 8, "damage_type": "arcane", "speed": 76.0, "flying": true, "size": Vector2(14, 14), "color": Color("b79cff"), "drop": "spark_shard"},
		"brine_lurker": {"name": "Brine Lurker", "hp": 30, "max_hp": 30, "damage": 11, "damage_type": "physical", "speed": 104.0, "flying": true, "size": Vector2(24, 13), "hitbox_size": Vector2(44, 24), "color": Color("3f7f86"), "drop": "brine_scale", "status_on_hit": "slow"},
		"drowned_leviathan": {"name": "Drowned Leviathan", "hp": 500, "max_hp": 500, "damage": 20, "damage_type": "physical", "speed": 74.0, "flying": true, "size": Vector2(46, 20), "hitbox_size": Vector2(78, 34), "hitbox_offset": Vector2(0, -4), "color": Color("2f5f6b"), "drop": "leviathan_tooth", "status_on_hit": "slow", "story_invulnerable": true},
		"sea_leviathan": {"name": "Sea Leviathan", "hp": 500, "max_hp": 500, "damage": 20, "damage_type": "physical", "speed": 58.0, "flying": true, "size": Vector2(120, 54), "hitbox_size": Vector2(150, 76), "hitbox_offset": Vector2(0, -8), "color": Color("2d6470"), "drop": "leviathan_tooth", "status_on_hit": "slow", "story_invulnerable": true},
		"heartwood_boss": {"name": "Heartwood Core", "hp": 260, "max_hp": 260, "damage": 18, "damage_type": "physical", "speed": 46.0, "flying": false, "size": Vector2(42, 48), "color": Color("8b5a36"), "drop": "heartwood_core"},
		"archive_warden": {"name": "Archive Warden", "hp": 620, "max_hp": 620, "damage": 24, "damage_type": "arcane", "speed": 44.0, "flying": false, "size": Vector2(38, 58), "hitbox_size": Vector2(54, 70), "hitbox_offset": Vector2(0, -5), "color": Color("71837b"), "drop": "archive_sigil", "status_on_hit": "slow"}
	}
	return (templates.get(enemy_type, templates["wild_slime"]) as Dictionary).duplicate(true)


static func perception_profile(enemy_type: String) -> Dictionary:
	var profile := {
		"vision_range": 165.0,
		"vision_angle": 120.0,
		"hearing": 1.0,
		"light_sensitivity": 0.75,
		"suspicion_rate": 1.35,
		"suspicion_decay": 0.38,
		"memory_time": 5.0,
		"search_time": 6.0,
		"alert_radius": 150.0,
		"instant_range": 30.0
	}
	var overrides: Dictionary = PERCEPTION_PROFILES.get(enemy_type, {})
	for key in overrides:
		profile[key] = overrides[key]
	return profile


static func movement_profile(enemy_type: String) -> Dictionary:
	var profile := {
		"locomotion": "walk",
		"acceleration": 6.0,
		"air_control": 0.12,
		"ground_snap": 6.0,
		"stuck_turn_time": 0.62,
		"avoid_time": 0.72,
		"navigation_jump": true,
		"jump_speed": -285.0,
		"jump_interval": 1.10,
		"knockback_scale": 1.0
	}
	if enemy_type in ["brine_lurker", "drowned_leviathan", "sea_leviathan"]:
		profile["locomotion"] = "swim"
		profile["ground_snap"] = 0.0
		profile["navigation_jump"] = false
		profile["acceleration"] = 3.4 if enemy_type == "drowned_leviathan" else 4.6
		profile["air_control"] = 1.0
	elif enemy_type in ["bat", "spore_bat", "ash_phantom", "ash_wisp", "ruin_drone", "glass_wraith", "night_ember"]:
		profile["locomotion"] = "hover"
		profile["ground_snap"] = 0.0
		profile["navigation_jump"] = false
	elif enemy_type == "wild_slime":
		profile.merge({"locomotion": "hop", "acceleration": 5.0, "air_control": 0.42, "ground_snap": 0.0, "navigation_jump": false, "hop_speed": -285.0, "hop_interval": 0.72}, true)
	elif enemy_type in ["root_crawler", "cave_worm"]:
		profile.merge({"locomotion": "crawl", "acceleration": 8.5, "air_control": 0.05, "ground_snap": 8.0, "stuck_turn_time": 0.50}, true)
	elif enemy_type in ["mossling", "mushroom_beetle", "ember_rootling"]:
		profile.merge({"locomotion": "scuttle", "acceleration": 7.5, "ground_snap": 7.0}, true)
	elif enemy_type in ["cave_husk", "ash_sentinel", "drowned_guard"]:
		profile.merge({"locomotion": "heavy_walk", "acceleration": 3.8, "air_control": 0.02, "ground_snap": 5.0, "jump_speed": -305.0, "stuck_turn_time": 0.78}, true)
	elif enemy_type in ["stone_beast", "heartwood_boss", "archive_warden"]:
		profile.merge({"locomotion": "heavy_walk", "acceleration": 2.6, "air_control": 0.0, "ground_snap": 4.0, "navigation_jump": false, "stuck_turn_time": 0.90}, true)
		profile["knockback_scale"] = {
			"stone_beast": 0.08,
			"heartwood_boss": 0.12,
			"archive_warden": 0.10
		}.get(enemy_type, 0.10)
	return profile
