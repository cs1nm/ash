extends Node2D

const GameData = preload("res://scripts/game_data.gd")
const AudioManagerScript = preload("res://scripts/audio_manager.gd")
const SaveManager = preload("res://scripts/save_manager.gd")
const EnemyData = preload("res://scripts/enemy_catalog.gd")
const DebugConsoleViewScript = preload("res://scripts/debug_console_view.gd")
const EnemyAnimations = preload("res://scripts/enemy_animation_library.gd")
const UIThemeScript = preload("res://scripts/ui_theme_manager.gd")
const PauseMenuViewScript = preload("res://scripts/pause_menu_view.gd")

const TILE_SIZE := GameData.TILE_SIZE
const WORLD_WIDTH := GameData.WORLD_WIDTH
const WORLD_HEIGHT := GameData.WORLD_HEIGHT
const VIEW_PADDING := GameData.VIEW_PADDING
const GRAVITY := GameData.GRAVITY
const MOVE_SPEED := GameData.MOVE_SPEED
const JUMP_SPEED := GameData.JUMP_SPEED
const PLAYER_SIZE := GameData.PLAYER_SIZE
const AUTO_STEP_HEIGHT := GameData.AUTO_STEP_HEIGHT
const INTERACT_RANGE_TILES := GameData.INTERACT_RANGE_TILES
const SAVE_PATH := GameData.SAVE_PATH
const MAX_HEALTH := GameData.MAX_HEALTH
const FALL_DAMAGE_SPEED := GameData.FALL_DAMAGE_SPEED
const CHUNK_SIZE := GameData.CHUNK_SIZE
const MINIMAP_WIDTH := GameData.MINIMAP_WIDTH
const MINIMAP_HEIGHT := GameData.MINIMAP_HEIGHT
const FULL_MAP_WIDTH := GameData.FULL_MAP_WIDTH
const FULL_MAP_HEIGHT := GameData.FULL_MAP_HEIGHT
const HOTBAR_SIZE := GameData.HOTBAR_SIZE
const INVENTORY_GRID_SIZE := GameData.INVENTORY_GRID_SIZE
const VIRTUAL_JOYSTICK_SCRIPT := preload("res://scripts/virtual_joystick.gd")
const SLOT_SIZE := GameData.SLOT_SIZE
const MIN_CAMERA_ZOOM := GameData.MIN_CAMERA_ZOOM
const MAX_CAMERA_ZOOM := GameData.MAX_CAMERA_ZOOM
const DAY_DURATION := GameData.DAY_DURATION
const NIGHT_DURATION := GameData.NIGHT_DURATION
const FULL_DAY_DURATION := GameData.FULL_DAY_DURATION
const MAX_ENEMIES := GameData.MAX_ENEMIES
const ENEMY_SPAWN_INTERVAL := GameData.ENEMY_SPAWN_INTERVAL
const PLAYER_HURT_COOLDOWN := GameData.PLAYER_HURT_COOLDOWN
const USE_EXTERNAL_ENEMY_ANIMATION_STRIPS := GameData.USE_EXTERNAL_ENEMY_ANIMATION_STRIPS
const LOOT_PICKUP_RADIUS := GameData.LOOT_PICKUP_RADIUS
const STRUCTURE_CHEST_CHANCE := 0.75
const CAVE_CHEST_CHANCE := 0.08
const CHEST_GROUND_SEARCH_RADIUS := 6
const CHEST_GROUND_SEARCH_DEPTH := 16
const TREE_BASE_HARDNESS_MULTIPLIER := 2.25
const MIN_TREE_SPACING := 10
# Surface biome bands: wide procedural regions instead of narrow fixed strips.
const SURFACE_BAND_MIN_WIDTH := 120
const SURFACE_BAND_MAX_WIDTH := 210
# Columns on each side of a band seam where the two neighbouring biomes trade
# blocks, so regions fade into each other instead of ending on a hard line.
const SURFACE_BORDER_BLEND := 24
# How far the seam itself wanders left and right as it goes down. Without this
# the transition still reads as one straight vertical cut, just a dithered one.
const SURFACE_BORDER_MEANDER := 11.0
# Depth in rows that a biome palette reaches below the surface, plus how much
# that depth wobbles so the palette does not end on a flat horizontal line.
const BIOME_PALETTE_DEPTH := 26
const BIOME_PALETTE_DEPTH_JITTER := 7.0
# Rows over which the palette dissolves into ordinary rock instead of stopping
# at one row, so the bottom of the tinted crust has no visible cut either.
const BIOME_PALETTE_FADE := 9
# World edges: instead of an invisible wall the land slopes into a dead sea
# that keeps going past the map, veiled by an ash haze. The columns inside this
# margin bend downwards, the sea fills them, and a current turns the player back.
const WORLD_EDGE_ZONE := 120
const WORLD_EDGE_FLOOR := 96
const WORLD_EDGE_SEA_LEVEL := 58
# Only columns this far into the falloff grow a sea, which keeps the coastline
# out on the margin instead of flooding inland dips.
const WORLD_EDGE_SEA_START := 0.25
# The undertow ramps up over the last stretch and is strongest at the rim.
const WORLD_EDGE_CURRENT_ZONE := 34
# Columns near the map edge where nothing may be carved out. The dead sea sits
# here, and a single cave breaching its floor drains the whole thing, so the
# seabed is protected as bedrock rather than trusting every generator to
# remember to stay away. A margin past the shoreline keeps tunnels from
# undercutting the beach.
const SEABED_PROTECT_MARGIN := 14
const WORLD_EDGE_CURRENT_FORCE := 340.0
# Weather. One global state at a time; how it looks and what it does depends on
# the biome underneath, so a single storm can rain on the forest and blizzard
# on the wasteland without two systems fighting each other.
const WEATHER_CLEAR := "clear"
const WEATHER_RAIN := "rain"
const WEATHER_STORM := "storm"
const WEATHER_BLIZZARD := "blizzard"
const WEATHER_ASHFALL := "ashfall"
const WEATHER_FOG := "fog"
const WEATHER_TYPES: Array[String] = [
	WEATHER_RAIN, WEATHER_STORM, WEATHER_BLIZZARD, WEATHER_ASHFALL, WEATHER_FOG
]
# Depth in tiles past which the surface is no longer heard or felt.
const WEATHER_DEPTH_FADE_START := 6
const WEATHER_DEPTH_SILENT := 20
# Lightning only strikes in the open, near the player, on a cooldown.
const LIGHTNING_MIN_INTERVAL := 3.4
const LIGHTNING_MAX_INTERVAL := 9.0
const LIGHTNING_STRIKE_RANGE := 22
const LIGHTNING_DAMAGE := 26
# Rejection sampling budget for the band layout before the deterministic
# fallback order takes over.
const SURFACE_BAND_LAYOUT_ATTEMPTS := 4000
const SURFACE_BAND_BIOMES: Array[String] = [
	"frost_wasteland", "marsh", "ash_desert", "ash_ruins", "forest"
]
# Band order used when no shuffle passes the neighbour rules. Cycling it never
# repeats a biome and never lets the ash desert touch the frost wasteland.
const SURFACE_BAND_FALLBACK_ORDER: Array[String] = [
	"frost_wasteland", "marsh", "ash_desert", "ash_ruins"
]
const LOOT_MAGNET_RADIUS := GameData.LOOT_MAGNET_RADIUS
const LOOT_DESPAWN_TIME := GameData.LOOT_DESPAWN_TIME
const MAX_OXYGEN := GameData.MAX_OXYGEN
const NORMAL_BODY_TEMPERATURE := GameData.NORMAL_BODY_TEMPERATURE
const MIN_BODY_TEMPERATURE := GameData.MIN_BODY_TEMPERATURE
const MAX_BODY_TEMPERATURE := GameData.MAX_BODY_TEMPERATURE

const PERCEPTION_CALM := "calm"
const PERCEPTION_SUSPICIOUS := "suspicious"
const PERCEPTION_INVESTIGATE := "investigate"
const PERCEPTION_COMBAT := "combat"
const PERCEPTION_SEARCH := "search"
const PERCEPTION_RETURN := "return"
const NOISE_EVENT_LIFETIME := 0.85
const ENEMY_HEARING_RADIUS_MULTIPLIER := 3.0
const ENEMY_VISION_RANGE_MULTIPLIER := 2.0

enum Tile {
	AIR,
	GRASS,
	SNOW_BLOCK,
	DIRT,
	STONE,
	COPPER,
	IRON,
	ASH,
	ROOT,
	WOOD,
	LEAVES,
	RUIN,
	WORKBENCH,
	FURNACE,
	ANVIL,
	TURRET,
	HEART,
	CHEST,
	STONE_ALTAR,
	STONEBLOOD,
	MOSS,
	MUSHROOM_SOIL,
	GLOW_MUSHROOM,
	ASH_BRICK,
	SUNKEN_STONE,
	LAVA_ROOT,
	GLASS_STONE,
	ABYSS_CRYSTAL,
	WATER,
	LAVA,
	WATER_PLANT,
	BUBBLE_VENT,
	DRAIN_VALVE,
	SAPLING,
	TORCH,
	# Surface biome topsoil blocks. Appended after the original tiles so ids in
	# existing save files keep their meaning.
	ASH_SAND,
	FROZEN_DIRT,
	MUD,
	RUBBLE
}

var tile_names: Dictionary = {
	Tile.AIR: "Air",
	Tile.GRASS: "Grass",
	Tile.SNOW_BLOCK: "Snow Block",
	Tile.DIRT: "Dirt",
	Tile.STONE: "Stone",
	Tile.COPPER: "Copper",
	Tile.IRON: "Iron",
	Tile.ASH: "Ash",
	Tile.ROOT: "Root",
	Tile.WOOD: "Wood",
	Tile.LEAVES: "Leaves",
	Tile.RUIN: "Ruin Brick",
	Tile.WORKBENCH: "Workbench",
	Tile.FURNACE: "Furnace",
	Tile.ANVIL: "Anvil",
	Tile.TURRET: "Small Turret",
	Tile.HEART: "Heart of Settlement",
	Tile.CHEST: "Ancient Chest",
	Tile.STONE_ALTAR: "Stone Altar",
	Tile.STONEBLOOD: "Stoneblood Ore",
	Tile.MOSS: "Mossy Loam",
	Tile.MUSHROOM_SOIL: "Fungal Soil",
	Tile.GLOW_MUSHROOM: "Glow Mushroom",
	Tile.ASH_BRICK: "Ash City Brick",
	Tile.SUNKEN_STONE: "Sunken Stone",
	Tile.LAVA_ROOT: "Lava Root",
	Tile.GLASS_STONE: "Glass Stone",
	Tile.ABYSS_CRYSTAL: "Abyss Crystal",
	Tile.WATER: "Water",
	Tile.LAVA: "Lava",
	Tile.WATER_PLANT: "Water Plant",
	Tile.BUBBLE_VENT: "Bubble Vent",
	Tile.DRAIN_VALVE: "Drain Valve",
	Tile.SAPLING: "Sapling",
	Tile.TORCH: "Torch",
	Tile.ASH_SAND: "Ash Sand",
	Tile.FROZEN_DIRT: "Frozen Dirt",
	Tile.MUD: "Mud",
	Tile.RUBBLE: "Rubble"
}

var tile_colors: Dictionary = {
	Tile.GRASS: Color("4f9f5f"),
	Tile.SNOW_BLOCK: Color("b8deed"),
	Tile.DIRT: Color("7a4a2a"),
	Tile.STONE: Color("60646f"),
	Tile.COPPER: Color("b66d3f"),
	Tile.IRON: Color("b9b6a7"),
	Tile.ASH: Color("4b4a54"),
	Tile.ROOT: Color("8d6939"),
	Tile.WOOD: Color("9a6132"),
	Tile.LEAVES: Color("4a7b50"),
	Tile.RUIN: Color("746b83"),
	Tile.WORKBENCH: Color("a0703f"),
	Tile.FURNACE: Color("3d4650"),
	Tile.ANVIL: Color("485468"),
	Tile.TURRET: Color("748c9c"),
	Tile.HEART: Color("d45f7e"),
	Tile.CHEST: Color("b98746"),
	Tile.STONE_ALTAR: Color("7f7368"),
	Tile.STONEBLOOD: Color("6fb3a2"),
	Tile.MOSS: Color("426f47"),
	Tile.MUSHROOM_SOIL: Color("5f4d70"),
	Tile.GLOW_MUSHROOM: Color("6fd6b8"),
	Tile.ASH_BRICK: Color("5d5562"),
	Tile.SUNKEN_STONE: Color("3f6974"),
	Tile.LAVA_ROOT: Color("a04431"),
	Tile.GLASS_STONE: Color("8ccad6"),
	Tile.ABYSS_CRYSTAL: Color("b8f4ff"),
	Tile.WATER: Color("327d9b", 0.72),
	Tile.LAVA: Color("ff6a2b", 0.90),
	Tile.WATER_PLANT: Color("4aa88c"),
	Tile.BUBBLE_VENT: Color("6b8790"),
	Tile.DRAIN_VALVE: Color("7893a0"),
	Tile.SAPLING: Color("63a75e"),
	Tile.TORCH: Color("ffd36b"),
	Tile.ASH_SAND: Color("c9b591"),
	Tile.FROZEN_DIRT: Color("5d7083"),
	Tile.MUD: Color("4f3d2a"),
	Tile.RUBBLE: Color("77695c")
}

var solid_tiles: Dictionary = {
	Tile.GRASS: true,
	Tile.SNOW_BLOCK: true,
	Tile.DIRT: true,
	Tile.STONE: true,
	Tile.COPPER: true,
	Tile.IRON: true,
	Tile.ASH: true,
	Tile.ROOT: true,
	Tile.WOOD: true,
	Tile.RUIN: true,
	Tile.WORKBENCH: true,
	Tile.FURNACE: true,
	Tile.ANVIL: true,
	Tile.TURRET: true,
	Tile.HEART: true,
	Tile.CHEST: true,
	Tile.STONE_ALTAR: true,
	Tile.STONEBLOOD: true,
	Tile.MOSS: true,
	Tile.MUSHROOM_SOIL: true,
	Tile.GLOW_MUSHROOM: true,
	Tile.ASH_BRICK: true,
	Tile.SUNKEN_STONE: true,
	Tile.LAVA_ROOT: true,
	Tile.GLASS_STONE: true,
	Tile.ABYSS_CRYSTAL: true,
	Tile.BUBBLE_VENT: true,
	Tile.DRAIN_VALVE: true,
	Tile.ASH_SAND: true,
	Tile.FROZEN_DIRT: true,
	Tile.MUD: true,
	Tile.RUBBLE: true
}

var tile_hardness: Dictionary = {
	Tile.GRASS: 0.28,
	Tile.SNOW_BLOCK: 0.34,
	Tile.DIRT: 0.24,
	Tile.STONE: 0.55,
	Tile.COPPER: 0.75,
	Tile.IRON: 0.95,
	Tile.ASH: 0.70,
	Tile.ROOT: 0.40,
	Tile.WOOD: 1.05,
	Tile.LEAVES: 0.22,
	Tile.RUIN: 0.85,
	Tile.WORKBENCH: 0.35,
	Tile.FURNACE: 0.65,
	Tile.ANVIL: 0.75,
	Tile.TURRET: 0.55,
	Tile.HEART: 1.20,
	Tile.CHEST: 0.65,
	Tile.STONE_ALTAR: 1.10,
	Tile.STONEBLOOD: 1.15,
	Tile.MOSS: 0.32,
	Tile.MUSHROOM_SOIL: 0.38,
	Tile.GLOW_MUSHROOM: 0.20,
	Tile.ASH_BRICK: 0.95,
	Tile.SUNKEN_STONE: 0.90,
	Tile.LAVA_ROOT: 0.70,
	Tile.GLASS_STONE: 1.05,
	Tile.ABYSS_CRYSTAL: 1.30,
	Tile.WATER_PLANT: 0.16,
	Tile.BUBBLE_VENT: 0.85,
	Tile.DRAIN_VALVE: 1.15,
	Tile.SAPLING: 0.12,
	Tile.TORCH: 0.10,
	Tile.ASH_SAND: 0.20,
	Tile.FROZEN_DIRT: 0.32,
	Tile.MUD: 0.26,
	Tile.RUBBLE: 0.48
}

var tile_required_power: Dictionary = {
	Tile.GRASS: 1,
	Tile.SNOW_BLOCK: 1,
	Tile.DIRT: 1,
	Tile.STONE: 1,
	Tile.COPPER: 1,
	Tile.IRON: 2,
	Tile.ASH: 2,
	Tile.ROOT: 1,
	Tile.WOOD: 1,
	Tile.LEAVES: 1,
	Tile.RUIN: 2,
	Tile.WORKBENCH: 1,
	Tile.FURNACE: 1,
	Tile.ANVIL: 2,
	Tile.TURRET: 2,
	Tile.HEART: 2,
	Tile.CHEST: 1,
	Tile.STONE_ALTAR: 2,
	Tile.STONEBLOOD: 3,
	Tile.MOSS: 1,
	Tile.MUSHROOM_SOIL: 1,
	Tile.GLOW_MUSHROOM: 1,
	Tile.ASH_BRICK: 2,
	Tile.SUNKEN_STONE: 2,
	Tile.LAVA_ROOT: 3,
	Tile.GLASS_STONE: 3,
	Tile.ABYSS_CRYSTAL: 4,
	Tile.WATER_PLANT: 1,
	Tile.BUBBLE_VENT: 2,
	Tile.DRAIN_VALVE: 2,
	Tile.SAPLING: 1,
	Tile.TORCH: 1,
	Tile.ASH_SAND: 1,
	Tile.FROZEN_DIRT: 1,
	Tile.MUD: 1,
	Tile.RUBBLE: 1
}

var tile_to_item: Dictionary = {
	Tile.GRASS: "dirt",
	Tile.SNOW_BLOCK: "snow_block",
	Tile.DIRT: "dirt",
	Tile.STONE: "stone",
	Tile.COPPER: "copper_ore",
	Tile.IRON: "iron_ore",
	Tile.ASH: "ash",
	Tile.ROOT: "root",
	Tile.WOOD: "wood",
	Tile.LEAVES: "leaf",
	Tile.RUIN: "ruin_brick",
	Tile.WORKBENCH: "workbench",
	Tile.FURNACE: "furnace",
	Tile.ANVIL: "anvil",
	Tile.TURRET: "small_turret",
	Tile.HEART: "settlement_heart",
	Tile.CHEST: "ancient_chest",
	Tile.STONE_ALTAR: "stone_altar",
	Tile.STONEBLOOD: "stoneblood_ore",
	Tile.MOSS: "moss_fiber",
	Tile.MUSHROOM_SOIL: "mushroom_spore",
	Tile.GLOW_MUSHROOM: "glowcap",
	Tile.ASH_BRICK: "ash_city_brick",
	Tile.SUNKEN_STONE: "sunken_stone",
	Tile.LAVA_ROOT: "ember_root",
	Tile.GLASS_STONE: "glass_shard",
	Tile.ABYSS_CRYSTAL: "abyss_crystal",
	Tile.WATER_PLANT: "kelp_fiber",
	Tile.BUBBLE_VENT: "sunken_mechanism",
	Tile.DRAIN_VALVE: "drain_valve",
	Tile.SAPLING: "sapling",
	Tile.TORCH: "torch",
	Tile.ASH_SAND: "ash_sand",
	Tile.FROZEN_DIRT: "frozen_dirt",
	Tile.MUD: "mud",
	Tile.RUBBLE: "rubble"
}

var item_to_tile: Dictionary = {
	"dirt": Tile.DIRT,
	"snow_block": Tile.SNOW_BLOCK,
	"stone": Tile.STONE,
	"ash": Tile.ASH,
	"root": Tile.ROOT,
	"wood": Tile.WOOD,
	"leaf": Tile.LEAVES,
	"ruin_brick": Tile.RUIN,
	"workbench": Tile.WORKBENCH,
	"furnace": Tile.FURNACE,
	"anvil": Tile.ANVIL,
	"small_turret": Tile.TURRET,
	"settlement_heart": Tile.HEART,
	"ancient_chest": Tile.CHEST,
	"stone_altar": Tile.STONE_ALTAR,
	"stoneblood_ore": Tile.STONEBLOOD,
	"moss_fiber": Tile.MOSS,
	"mushroom_spore": Tile.MUSHROOM_SOIL,
	"glowcap": Tile.GLOW_MUSHROOM,
	"ash_city_brick": Tile.ASH_BRICK,
	"sunken_stone": Tile.SUNKEN_STONE,
	"ember_root": Tile.LAVA_ROOT,
	"glass_shard": Tile.GLASS_STONE,
	"abyss_crystal": Tile.ABYSS_CRYSTAL,
	"kelp_fiber": Tile.WATER_PLANT,
	"sunken_mechanism": Tile.BUBBLE_VENT,
	"drain_valve": Tile.DRAIN_VALVE,
	"sapling": Tile.SAPLING,
	"torch": Tile.TORCH,
	"ash_sand": Tile.ASH_SAND,
	"frozen_dirt": Tile.FROZEN_DIRT,
	"mud": Tile.MUD,
	"rubble": Tile.RUBBLE
}

var item_names: Dictionary = {
	"dirt": "Dirt",
	"snow_block": "Snow Block",
	"stone": "Stone",
	"copper_ore": "Copper Ore",
	"iron_ore": "Iron Ore",
	"ash": "Ash",
	"root": "Root",
	"wood": "Wood",
	"leaf": "Leaf",
	"sapling": "Sapling",
	"ruin_brick": "Ruin Brick",
	"copper_bar": "Copper Bar",
	"iron_bar": "Iron Bar",
	"ash_glass": "Ash Glass",
	"root_core": "Root Core",
	"spark_shard": "Spark Shard",
	"memory_shard": "Memory Shard",
	"world_memory": "World Memory",
	"wild_ichor": "Wild Ichor",
	"night_ember": "Night Ember",
	"brine_scale": "Brine Scale",
	"leviathan_tooth": "Leviathan Tooth",
	"heartwood_core": "Heartwood Core",
	"ancient_chest": "Ancient Chest",
	"torch": "Torch",
	"stone_altar": "Stone Altar",
	"stoneblood_ore": "Stoneblood Ore",
	"stoneblood_bar": "Stoneblood Bar",
	"beast_core": "Beast Core",
	"cracked_memory_core": "Cracked Memory Core",
	"fungal_memory_shard": "Fungal Memory Shard",
	"sunken_memory_shard": "Sunken Memory Shard",
	"ash_memory_shard": "Ash Memory Shard",
	"ashen_lens": "Ashen Lens",
	"archive_sigil": "Archive Sigil",
	"mushroom_spore": "Mushroom Spore",
	"moss_fiber": "Moss Fiber",
	"glowcap": "Glowcap",
	"ash_city_brick": "Ash City Brick",
	"sunken_stone": "Sunken Stone",
	"drowned_pearl": "Drowned Pearl",
	"kelp_fiber": "Kelp Fiber",
	"sunken_mechanism": "Sunken Mechanism",
	"drain_valve": "Drain Valve",
	"ash_relic": "Ash Relic",
	"ember_root": "Ember Root",
	"glass_shard": "Glass Shard",
	"abyss_crystal": "Abyss Crystal",
	"abyss_lens": "Abyss Lens",
	"diving_charm": "Diving Charm",
	"brine_mail": "Brine Mail",
	"leviathan_fang": "Leviathan Fang",
	"ember_ward": "Ember Ward",
	"harpoon": "Ruin Harpoon",
	"tidal_trident": "Tidal Trident",
	"tide_staff": "Tide Staff",
	"drowned_armor": "Drowned Armor",
	"guardian_core": "Guardian Core",
	"stoneblood_pickaxe": "Stoneblood Pickaxe",
	"stonebreaker_blade": "Stonebreaker Blade",
	"workbench": "Workbench",
	"furnace": "Furnace",
	"anvil": "Anvil",
	"settlement_heart": "Heart of Settlement",
	"wooden_pickaxe": "Wooden Pickaxe",
	"copper_pickaxe": "Copper Pickaxe",
	"iron_pickaxe": "Iron Pickaxe",
	"ash_pickaxe": "Ash Pickaxe",
	"builder_hammer": "Builder Hammer",
	"wooden_sword": "Wooden Sword",
	"copper_sword": "Copper Sword",
	"iron_spear": "Iron Spear",
	"wooden_shield": "Wooden Shield",
	"copper_shield": "Copper Shield",
	"wooden_bow": "Wooden Bow",
	"copper_bow": "Copper Bow",
	"fire_arrows": "Fire Arrows",
	"hand_cannon": "Ruin Hand Cannon",
	"spark_staff": "Spark Staff",
	"root_spirit_rod": "Root Spirit Rod",
	"acid_flasks": "Acid Flasks",
	"small_turret": "Small Turret",
	"ash_sickle": "Ash Sickle",
	"copper_armor": "Copper Armor",
	"iron_armor": "Iron Armor",
	"copper_helmet": "Copper Helmet",
	"copper_chestplate": "Copper Chestplate",
	"copper_greaves": "Copper Greaves",
	"copper_boots": "Copper Boots",
	"iron_helmet": "Iron Helmet",
	"iron_chestplate": "Iron Chestplate",
	"iron_greaves": "Iron Greaves",
	"iron_boots": "Iron Boots",
	"stoneblood_helmet": "Stoneblood Helmet",
	"stoneblood_chestplate": "Stoneblood Chestplate",
	"stoneblood_greaves": "Stoneblood Greaves",
	"stoneblood_boots": "Stoneblood Boots",
	"ash_charm": "Ash Charm",
	"root_ring": "Root Ring",
	"wild_badge": "Wild Badge",
	"ash_sand": "Ash Sand",
	"frozen_dirt": "Frozen Dirt",
	"mud": "Mud",
	"rubble": "Rubble"
}

var tools: Dictionary = {
	"wooden_pickaxe": {"name": "Wooden Pickaxe", "tier": 1, "power": 1, "speed": 0.78},
	"copper_pickaxe": {"name": "Copper Pickaxe", "tier": 2, "power": 2, "speed": 1.15},
	"iron_pickaxe": {"name": "Iron Pickaxe", "tier": 3, "power": 3, "speed": 1.55},
	"ash_pickaxe": {"name": "Ash Pickaxe", "tier": 4, "power": 4, "speed": 1.85},
	"stoneblood_pickaxe": {"name": "Stoneblood Pickaxe", "tier": 5, "power": 5, "speed": 2.05},
	"builder_hammer": {"name": "Builder Hammer", "tier": 1, "power": 1, "speed": 0.75}
}

var gear_stats: Dictionary = {
	"wooden_sword": {"slot": "weapon", "class": "Warrior", "tier": 1, "damage": 6},
	"copper_sword": {"slot": "weapon", "class": "Warrior", "tier": 2, "damage": 11},
	"iron_spear": {"slot": "weapon", "class": "Warrior", "tier": 3, "damage": 17},
	"wooden_shield": {"slot": "accessory", "class": "Shieldbearer", "tier": 1, "defense": 3},
	"copper_shield": {"slot": "accessory", "class": "Shieldbearer", "tier": 2, "defense": 6},
	"wooden_bow": {"slot": "weapon", "class": "Archer", "tier": 1, "damage": 7},
	"copper_bow": {"slot": "weapon", "class": "Archer", "tier": 2, "damage": 12},
	"fire_arrows": {"slot": "accessory", "class": "Archer", "tier": 2, "damage": 4},
	"hand_cannon": {"slot": "weapon", "class": "Sniper", "tier": 4, "damage": 27},
	"spark_staff": {"slot": "weapon", "class": "Mage", "tier": 3, "damage": 18},
	"root_spirit_rod": {"slot": "weapon", "class": "Summoner", "tier": 2, "damage": 14},
	"acid_flasks": {"slot": "weapon", "class": "Alchemist", "tier": 3, "damage": 16},
	"small_turret": {"slot": "weapon", "class": "Engineer", "tier": 3, "damage": 16},
	"ash_sickle": {"slot": "weapon", "class": "Memory Reaper", "tier": 4, "damage": 23},
	"stonebreaker_blade": {"slot": "weapon", "class": "Warrior", "tier": 5, "damage": 34},
	"copper_armor": {"slot": "chest", "class": "Any", "tier": 2, "defense": 5, "cold_protection": 0.08, "heat_protection": 0.06},
	# Copper set: cheap starter plate, 8 defense across the full four pieces.
	"copper_helmet": {"slot": "helmet", "class": "Any", "tier": 2, "defense": 2, "cold_protection": 0.03, "heat_protection": 0.02},
	"copper_chestplate": {"slot": "chest", "class": "Any", "tier": 2, "defense": 3, "cold_protection": 0.04, "heat_protection": 0.03},
	"copper_greaves": {"slot": "legs", "class": "Any", "tier": 2, "defense": 2, "cold_protection": 0.03, "heat_protection": 0.02},
	"copper_boots": {"slot": "boots", "class": "Any", "tier": 2, "defense": 1, "cold_protection": 0.02, "heat_protection": 0.01},
	# Iron set: the workhorse, 14 defense and real weather protection.
	"iron_helmet": {"slot": "helmet", "class": "Any", "tier": 3, "defense": 3, "cold_protection": 0.06, "heat_protection": 0.04},
	"iron_chestplate": {"slot": "chest", "class": "Any", "tier": 3, "defense": 5, "cold_protection": 0.08, "heat_protection": 0.05},
	"iron_greaves": {"slot": "legs", "class": "Any", "tier": 3, "defense": 4, "cold_protection": 0.06, "heat_protection": 0.04},
	"iron_boots": {"slot": "boots", "class": "Any", "tier": 3, "defense": 2, "cold_protection": 0.04, "heat_protection": 0.02},
	# Stoneblood set: forged from Stone Beast ore, 23 defense, endgame plate.
	"stoneblood_helmet": {"slot": "helmet", "class": "Any", "tier": 5, "defense": 5, "cold_protection": 0.10, "heat_protection": 0.09},
	"stoneblood_chestplate": {"slot": "chest", "class": "Any", "tier": 5, "defense": 8, "cold_protection": 0.14, "heat_protection": 0.12},
	"stoneblood_greaves": {"slot": "legs", "class": "Any", "tier": 5, "defense": 6, "cold_protection": 0.10, "heat_protection": 0.09},
	"stoneblood_boots": {"slot": "boots", "class": "Any", "tier": 5, "defense": 4, "cold_protection": 0.08, "heat_protection": 0.06},
	"iron_armor": {"slot": "chest", "class": "Any", "tier": 3, "defense": 9, "cold_protection": 0.18, "heat_protection": 0.10},
	"ash_charm": {"slot": "accessory", "class": "Memory Reaper", "tier": 4, "damage": 3},
	"root_ring": {"slot": "accessory", "class": "Summoner", "tier": 2, "defense": 2},
	"wild_badge": {"slot": "accessory", "class": "Any", "tier": 3, "damage": 2, "defense": 1},
	"diving_charm": {"slot": "accessory", "class": "Any", "tier": 4, "defense": 1, "water_breathing": true, "cold_protection": 0.12},
	"brine_mail": {"slot": "chest", "class": "Any", "tier": 4, "defense": 6, "cold_protection": 0.22},
	"leviathan_fang": {"slot": "weapon", "class": "Warrior", "tier": 6, "damage": 36},
	"ember_ward": {"slot": "accessory", "class": "Any", "tier": 5, "defense": 2, "heat_resistance": true, "heat_protection": 0.58},
	"harpoon": {"slot": "weapon", "class": "Sniper", "tier": 5, "damage": 30},
	"tidal_trident": {"slot": "weapon", "class": "Warrior", "tier": 5, "damage": 29},
	"tide_staff": {"slot": "weapon", "class": "Mage", "tier": 5, "damage": 27},
	"drowned_armor": {"slot": "chest", "class": "Any", "tier": 5, "defense": 13, "water_affinity": true, "cold_protection": 0.45, "heat_protection": 0.04}
}

# Per-enemy perception tuning. Values are intentionally data-driven so new
# creatures can hear, see, remember and alert allies differently without
# changing the state machine.

var recipes: Array[Dictionary] = [
	{"id": "workbench", "station": "hand", "cost": {"wood": 8}, "result": "workbench", "amount": 1},
	{"id": "torch", "station": "hand", "cost": {"wood": 1, "ash": 1}, "result": "torch", "amount": 4},
	{"id": "ash_sift", "station": "hand", "cost": {"ash_sand": 4}, "result": "ash", "amount": 1},
	{"id": "ancient_chest", "station": "workbench", "cost": {"wood": 12, "stone": 6}, "result": "ancient_chest", "amount": 1},
	{"id": "wooden_pickaxe", "station": "workbench", "cost": {"wood": 10, "stone": 4}, "result": "wooden_pickaxe", "amount": 1},
	{"id": "furnace", "station": "workbench", "cost": {"stone": 18, "wood": 4}, "result": "furnace", "amount": 1},
	{"id": "copper_bar", "station": "furnace", "cost": {"copper_ore": 3, "wood": 1}, "result": "copper_bar", "amount": 1},
	{"id": "iron_bar", "station": "furnace", "cost": {"iron_ore": 3, "wood": 1}, "result": "iron_bar", "amount": 1},
	{"id": "ash_glass", "station": "furnace", "cost": {"ash": 4, "stone": 1}, "result": "ash_glass", "amount": 1},
	{"id": "anvil", "station": "workbench", "cost": {"copper_bar": 5, "stone": 8}, "result": "anvil", "amount": 1},
	{"id": "copper_pickaxe", "station": "anvil", "cost": {"copper_bar": 6, "wood": 3}, "result": "copper_pickaxe", "amount": 1},
	{"id": "iron_pickaxe", "station": "anvil", "cost": {"iron_bar": 8, "wood": 3}, "result": "iron_pickaxe", "amount": 1},
	{"id": "ash_pickaxe", "station": "anvil", "cost": {"iron_bar": 6, "ash_glass": 6, "memory_shard": 2}, "result": "ash_pickaxe", "amount": 1},
	{"id": "wooden_sword", "station": "workbench", "cost": {"wood": 8}, "result": "wooden_sword", "amount": 1},
	{"id": "copper_sword", "station": "anvil", "cost": {"copper_bar": 5, "wood": 2}, "result": "copper_sword", "amount": 1},
	{"id": "iron_spear", "station": "anvil", "cost": {"iron_bar": 6, "wood": 4}, "result": "iron_spear", "amount": 1},
	{"id": "wooden_shield", "station": "workbench", "cost": {"wood": 10, "root": 2}, "result": "wooden_shield", "amount": 1},
	{"id": "copper_shield", "station": "anvil", "cost": {"copper_bar": 6, "root_core": 1}, "result": "copper_shield", "amount": 1},
	{"id": "wooden_bow", "station": "workbench", "cost": {"wood": 9, "root": 2}, "result": "wooden_bow", "amount": 1},
	{"id": "copper_bow", "station": "anvil", "cost": {"copper_bar": 4, "wood": 4, "root": 3}, "result": "copper_bow", "amount": 1},
	{"id": "fire_arrows", "station": "workbench", "cost": {"wood": 2, "ash": 2, "copper_ore": 1}, "result": "fire_arrows", "amount": 25},
	{"id": "hand_cannon", "station": "anvil", "cost": {"ruin_brick": 8, "iron_bar": 5, "spark_shard": 1}, "result": "hand_cannon", "amount": 1},
	{"id": "spark_staff", "station": "anvil", "cost": {"spark_shard": 2, "wood": 6, "copper_bar": 2}, "result": "spark_staff", "amount": 1},
	{"id": "root_spirit_rod", "station": "workbench", "cost": {"root_core": 2, "wood": 6}, "result": "root_spirit_rod", "amount": 1},
	{"id": "acid_flasks", "station": "furnace", "cost": {"ash_glass": 2, "ash": 4, "copper_ore": 2}, "result": "acid_flasks", "amount": 12},
	{"id": "small_turret", "station": "anvil", "cost": {"iron_bar": 6, "copper_bar": 4, "ruin_brick": 4}, "result": "small_turret", "amount": 1},
	{"id": "ash_sickle", "station": "anvil", "cost": {"ash_glass": 4, "iron_bar": 4, "memory_shard": 2}, "result": "ash_sickle", "amount": 1},
	{"id": "copper_helmet", "station": "anvil", "cost": {"copper_bar": 5}, "result": "copper_helmet", "amount": 1},
	{"id": "copper_chestplate", "station": "anvil", "cost": {"copper_bar": 8}, "result": "copper_chestplate", "amount": 1},
	{"id": "copper_greaves", "station": "anvil", "cost": {"copper_bar": 6}, "result": "copper_greaves", "amount": 1},
	{"id": "copper_boots", "station": "anvil", "cost": {"copper_bar": 4}, "result": "copper_boots", "amount": 1},
	{"id": "iron_helmet", "station": "anvil", "cost": {"iron_bar": 6}, "result": "iron_helmet", "amount": 1},
	{"id": "iron_chestplate", "station": "anvil", "cost": {"iron_bar": 10}, "result": "iron_chestplate", "amount": 1},
	{"id": "iron_greaves", "station": "anvil", "cost": {"iron_bar": 8}, "result": "iron_greaves", "amount": 1},
	{"id": "iron_boots", "station": "anvil", "cost": {"iron_bar": 5}, "result": "iron_boots", "amount": 1},
	{"id": "stoneblood_helmet", "station": "anvil", "cost": {"stoneblood_bar": 5, "iron_bar": 3}, "result": "stoneblood_helmet", "amount": 1},
	{"id": "stoneblood_chestplate", "station": "anvil", "cost": {"stoneblood_bar": 8, "iron_bar": 5}, "result": "stoneblood_chestplate", "amount": 1},
	{"id": "stoneblood_greaves", "station": "anvil", "cost": {"stoneblood_bar": 6, "iron_bar": 4}, "result": "stoneblood_greaves", "amount": 1},
	{"id": "stoneblood_boots", "station": "anvil", "cost": {"stoneblood_bar": 4, "iron_bar": 3}, "result": "stoneblood_boots", "amount": 1},
	{"id": "ash_charm", "station": "workbench", "cost": {"memory_shard": 2, "ash": 8}, "result": "ash_charm", "amount": 1},
	{"id": "root_ring", "station": "workbench", "cost": {"root_core": 2, "copper_bar": 1}, "result": "root_ring", "amount": 1},
	{"id": "wild_badge", "station": "workbench", "cost": {"wild_ichor": 4, "night_ember": 2, "wood": 6}, "result": "wild_badge", "amount": 1},
	{"id": "stoneblood_bar", "station": "furnace", "cost": {"stoneblood_ore": 3, "ash": 1}, "result": "stoneblood_bar", "amount": 1},
	{"id": "stoneblood_pickaxe", "station": "anvil", "cost": {"stoneblood_bar": 8, "beast_core": 1, "wood": 4}, "result": "stoneblood_pickaxe", "amount": 1},
	{"id": "stonebreaker_blade", "station": "anvil", "cost": {"stoneblood_bar": 10, "beast_core": 1}, "result": "stonebreaker_blade", "amount": 1},
	{"id": "abyss_lens", "station": "anvil", "cost": {"abyss_crystal": 4, "glass_shard": 6, "drowned_pearl": 1}, "result": "abyss_lens", "amount": 1},
	{"id": "diving_charm", "station": "anvil", "cost": {"drowned_pearl": 2, "sunken_stone": 8, "iron_bar": 4}, "result": "diving_charm", "amount": 1},
	{"id": "brine_mail", "station": "anvil", "cost": {"brine_scale": 10, "iron_bar": 5}, "result": "brine_mail", "amount": 1},
	{"id": "leviathan_fang", "station": "anvil", "cost": {"leviathan_tooth": 2, "brine_scale": 6, "stoneblood_bar": 3}, "result": "leviathan_fang", "amount": 1},
	{"id": "ember_ward", "station": "anvil", "cost": {"ember_root": 8, "night_ember": 4, "stoneblood_bar": 2}, "result": "ember_ward", "amount": 1},
	{"id": "harpoon", "station": "anvil", "cost": {"sunken_mechanism": 2, "iron_bar": 7, "kelp_fiber": 4}, "result": "harpoon", "amount": 1},
	{"id": "tidal_trident", "station": "anvil", "cost": {"guardian_core": 1, "drowned_pearl": 3, "stoneblood_bar": 6}, "result": "tidal_trident", "amount": 1},
	{"id": "tide_staff", "station": "anvil", "cost": {"guardian_core": 1, "abyss_crystal": 3, "drowned_pearl": 4}, "result": "tide_staff", "amount": 1},
	{"id": "drowned_armor", "station": "anvil", "cost": {"guardian_core": 1, "sunken_stone": 16, "kelp_fiber": 8}, "result": "drowned_armor", "amount": 1},
	{"id": "ashen_lens", "station": "anvil", "cost": {"fungal_memory_shard": 1, "sunken_memory_shard": 1, "ash_memory_shard": 1}, "result": "ashen_lens", "amount": 1}
]

var world: Array = []
var surface_heights: Array[int] = []
# One deterministic biome id per world column. Surface biomes are kept separate
# from underground biome patches so their borders remain stable after loading.
var surface_biomes: Array[String] = []
# Distance in columns from every column to the nearest surface biome seam, plus
# the biome waiting on the other side of that seam. Both drive the blended
# border strips and are rebuilt whenever the biome map changes.
var border_distances: Array[int] = []
var border_neighbors: Array[String] = []
# Per-column topsoil depth noise, reseeded with the world on every generation.
var topsoil_noise: FastNoiseLite = null
# Breaks border transitions into pockets a few tiles across instead of dithering
# single tiles; reseeded with the world on every generation.
var transition_noise: FastNoiseLite = null
# Wanders the seam sideways as it descends so the border is not a straight cut.
var border_meander_noise: FastNoiseLite = null
var chest_loot: Dictionary = {}
var memory_nodes: Array[Dictionary] = []
var memory_node_textures: Dictionary = {}
var archive_site: Dictionary = {}
var archive_object_textures: Dictionary = {}
var seed := 0
var rng := RandomNumberGenerator.new()
var player_position := Vector2.ZERO
var player_velocity := Vector2.ZERO
var facing := 1
var inventory: Dictionary = {}
var player_statuses: Dictionary = {}
var hotbar: Array[String] = ["wooden_pickaxe", "dirt", "stone", "wood", "workbench"]
var selected_slot := 0
var selected_block := Tile.DIRT
var current_tool := "wooden_pickaxe"
var selected_recipe_index := 0
var equipped_weapon := ""
# Armour is four separate pieces now, not one blob. equipped_armor is kept as
# the chest slot so old saves and existing code keep working.
var equipped_armor := ""
var equipped_helmet := ""
var equipped_legs := ""
var equipped_boots := ""
var equipped_accessory := ""
var selected_inventory_item_id := ""
var held_item_id := ""
var held_item_amount := 0
var pending_inventory_right_drop_id := ""
var pending_inventory_right_drop_consumed := false
var sapling_growth_timer := 0.0
var sapling_positions: Dictionary = {}
var tree_tile_owners: Dictionary = {}
var next_tree_id := 1
var biome_check_timer := 0.0
var cached_biome := "forest"
var hud_update_timer := 0.0
# Cooldown so the dead sea warning does not repeat every frame at the rim.
var world_edge_warning_timer := 0.0
# Set by the story event that finally makes the world-edge leviathan mortal.
var leviathan_story_unlocked := false
var last_message := "Gather wood and stone, then craft a workbench."
var inventory_open := false
var health := MAX_HEALTH
var oxygen := MAX_OXYGEN
var drowning_tick := 0.0
var lava_tick := 0.0
var body_temperature := NORMAL_BODY_TEMPERATURE
var ambient_temperature := 20.0
var temperature_sample_timer := 0.0
var temperature_damage_tick := 0.0
var temperature_visual_state := ""
var mining_target := Vector2i(-999, -999)
var mining_progress := 0.0
# Direct desktop input state. Physical A/D keeps movement working with non-English keyboard layouts.
var physical_move_left_held := false
var physical_move_right_held := false
var physical_noclip_up_held := false
var physical_noclip_down_held := false
var mouse_mine_held := false
var debug_console_open := false
var debug_console_panel: PanelContainer
var debug_console_output: RichTextLabel
var debug_console_input: LineEdit
var debug_console_view: DebugConsoleView
var debug_memory_node_index := -1
var pause_menu_view
var pause_menu_open := false
var noclip_unlocked := false
var noclip_enabled := false
var god_mode_enabled := false
var last_space_press_msec := -10000
var landing_speed := 0.0
var camera: Camera2D
var hud_label: Label
var hud_health_bar: ProgressBar
var hud_armor_value: Label
var hud_status_label: Label
var oxygen_panel: Control
var oxygen_bar: ProgressBar
var oxygen_value: Label
var temperature_panel: Control
var temperature_title: Label
var temperature_bar: ProgressBar
var temperature_value: Label
var minimap_time_label: Label
var minimap_biome_label: Label
var context_hint_panel: Control
var context_hint_label: Label
var hotbar_buttons: Array[Button] = []
var inventory_slot_buttons: Array[Button] = []
var inventory_panel: PanelContainer
var crafting_panel: PanelContainer
var inventory_backdrop: ColorRect
var inventory_shell: PanelContainer
var equipment_overlay: Control
var inventory_title_label: Label
var equipment_label: Label
var equipment_environment_label: Label
var crafting_label: Label
var stations_label: Label
var message_label: Label
var controls_label: Label
var selected_item_label: Label
var assign_hotbar_button: Button
var drop_inventory_button: Button
var held_item_panel: PanelContainer
var held_item_icon: TextureRect
var held_item_amount_label: Label
var weapon_slot_button: Button
var armor_slot_button: Button
var helmet_slot_button: Button
var legs_slot_button: Button
var boots_slot_button: Button
var accessory_slot_button: Button
var recipe_buttons: Array[Button] = []
var craft_button: Button
var boss_panel: PanelContainer
var boss_label: Label
var boss_hp_bar: ProgressBar
var loot_feed_labels: Array[Label] = []
var minimap_panel: PanelContainer
var full_map_panel: PanelContainer
var full_map_backdrop: ColorRect
var full_map_rect: TextureRect
var full_map_open := false
var journal_open := false
var journal_panel: PanelContainer
var journal_backdrop: ColorRect
var journal_tab_buttons: Dictionary = {}
var journal_entry_list: VBoxContainer
var journal_detail_title: Label
var journal_detail_text: RichTextLabel
var journal_progress_label: Label
var journal_access_button: Button
var journal_active_tab := "Recipes"
var journal_selected_entry := ""
var journal_unread_count := 0
var journal_observation_timer := 0.0
var known_recipes: Dictionary = {}
var bestiary_knowledge: Dictionary = {}
var material_knowledge: Dictionary = {}
var alchemy_knowledge: Dictionary = {}
var world_map_image: Image
var world_map_dirty := true
# Persistent fog of war: 0 = unexplored, 1 = discovered.
var explored_tiles := PackedByteArray()
var last_explored_tile := Vector2i(-999, -999)
var visible_light_sources: Array[Dictionary] = []
var perception_noise_events: Array[Dictionary] = []
var next_noise_event_id := 1
var next_enemy_perception_id := 1
var player_footstep_noise_timer := 0.0
var perception_debug_enabled := false
var mobile_controls: Control
var mobile_gameplay_controls: Control
var mobile_ui_enabled := false
var mobile_target_tile := Vector2i(-999, -999)
var mobile_target_valid := false
var mobile_world_touch_index := -1
var mobile_attack_target := Vector2.ZERO
var mobile_attack_target_valid := false
var item_icon_cache: Dictionary = {}
var tile_texture_paths: Dictionary = {}
var tile_textures: Dictionary = {}
var tile_texture_variants: Dictionary = {}
var biome_tile_textures: Dictionary = {}
var enemy_textures: Dictionary = {}
var enemy_animation_textures: Dictionary = {}
var enemy_animation_specs: Dictionary = {}
var enemy_animation_pack_specs: Dictionary = {}
var enemy_sprite_ground_anchors: Dictionary = {}
var enemy_sprite_specs: Dictionary = EnemyData.SPRITE_SPECS.duplicate(true)
var minimap_rect: TextureRect
var chest_panel: PanelContainer
var chest_slot_buttons: Array[Button] = []
var active_chest_key := ""
var active_chest_pos := Vector2i(-999, -999)
var minimap_timer := 0.0
var player_on_floor := false
var active_class := "Warrior"
var ui_font: Font
var ui_theme_manager: AshenrootUITheme
var world_time := 28.0
var weather := WEATHER_CLEAR
var weather_timer := 90.0
var weather_intensity := 0.0          # 0 clearing .. 1 full force
var weather_target_intensity := 0.0
var lightning_timer := 0.0
var lightning_flash := 0.0            # screen flash, seconds remaining
var weather_particles: Array[Dictionary] = []
var weather_sound_timer := 0.0
var enemies: Array[Dictionary] = []
var dying_enemies: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var enemy_projectiles: Array[Dictionary] = []
var enemy_impact_effects: Array[Dictionary] = []
var dropped_items: Array[Dictionary] = []
var damage_numbers: Array[Dictionary] = []
var hit_particles: Array[Dictionary] = []
var attack_cooldown := 0.0
var attack_anim_time := 0.0
var attack_anim_duration := 0.0
var attack_anim_kind := ""
var attack_anim_dir := Vector2.RIGHT
var attack_anim_color := Color("f0d27a")
var enemy_spawn_timer := 0.0
var player_hurt_timer := 0.0
var defeated_enemies := 0
var boss_spawned := false
var boss_defeated := false
var stone_broken_count := 0
var stone_beast_spawned := false
var stone_beast_defeated := false
var archive_warden_spawned := false
var archive_warden_defeated := false
var mushroom_path_opened := false
var last_biome := ""
var loot_notifications: Array[Dictionary] = []
var audio_manager: AshenrootAudioManager
var player_texture: Texture2D
var player_frame_size := Vector2i(48, 64)

# ============================================================
# OPTIMIZATION MODULES
# ============================================================
var liquid_sim: LiquidSim
var renderer_mgr: RendererManager
var world_generation_in_progress := false


func _ready() -> void:
	ui_theme_manager = UIThemeScript.new()
	ui_theme_manager.setup()
	ui_font = ui_theme_manager.regular_font if ui_theme_manager.regular_font != null else ThemeDB.fallback_font
	mobile_ui_enabled = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	
	# Initialize optimization modules
	liquid_sim = LiquidSim.new()
	liquid_sim.setup(Tile.WATER, Tile.LAVA, Tile.AIR, Tile.STONE)
	renderer_mgr = RendererManager.new()
	renderer_mgr.setup(TILE_SIZE, CHUNK_SIZE, WORLD_WIDTH, WORLD_HEIGHT, Tile.AIR)
	
	_setup_texture_paths()
	_load_texture_assets()
	_setup_input_actions()
	_setup_camera()
	_setup_hud()
	_setup_pause_menu()
	ui_theme_manager.apply_font_tree(self)
	audio_manager = AudioManagerScript.new()
	audio_manager.name = "AudioManager"
	add_child(audio_manager)
	audio_manager.setup()
	_generate_world()
	
	# Mark all chunks dirty for initial render
	renderer_mgr.mark_all_dirty()
	
	set_process(true)


func _process(delta: float) -> void:
	if debug_console_open:
		player_velocity = Vector2.ZERO
		_update_camera()
		_update_hud()
		queue_redraw()
		return
	if Input.is_action_just_pressed("regen_world"):
		if liquid_sim != null:
			liquid_sim.clear()
		if renderer_mgr != null:
			renderer_mgr.mark_all_dirty()
		_generate_world()
		return
	if Input.is_action_just_pressed("save_world"):
		_save_game()
	if Input.is_action_just_pressed("load_world"):
		_load_game()
	if Input.is_action_just_pressed("toggle_journal"):
		_set_journal_open(not journal_open)
	if journal_open:
		player_velocity = Vector2.ZERO
		_update_hud()
		queue_redraw()
		return
	if not inventory_open and not full_map_open and Input.is_action_just_pressed("zoom_in"):
		_adjust_camera_zoom(0.14)
	if not inventory_open and not full_map_open and Input.is_action_just_pressed("zoom_out"):
		_adjust_camera_zoom(-0.14)
	if Input.is_action_just_pressed("toggle_inventory"):
		if full_map_open:
			_set_full_map_open(false)
		inventory_open = not inventory_open
		if not inventory_open:
			_close_chest()
	if Input.is_action_just_pressed("toggle_map"):
		_set_full_map_open(not full_map_open)
	if inventory_open and Input.is_action_just_pressed("recipe_prev"):
		_select_recipe(-1)
	if inventory_open and Input.is_action_just_pressed("recipe_next"):
		_select_recipe(1)
	if inventory_open and Input.is_action_just_pressed("craft_item"):
		_craft_selected_recipe()
	if inventory_open and Input.is_action_just_pressed("equip_item"):
		_equip_selected_item()
	if Input.is_action_just_pressed("attack"):
		_try_player_attack()

	_update_day_night(delta)
	_update_weather(delta)
	_update_player(delta)
	
	# Finite liquid physics with partial fill levels, processed near the player.
	if liquid_sim != null:
		var player_tx := int(player_position.x / TILE_SIZE)
		var player_ty := int(player_position.y / TILE_SIZE)
		if liquid_sim.process(delta, world, player_tx, player_ty, solid_tiles) > 0:
			world_map_dirty = true
	
	_update_saplings(delta)
	_update_biome_cache(delta)
	_update_temperature(delta)
	_update_biome_audio()
	_update_memory_nodes(delta)
	_update_archive_site(delta)
	_update_selection()
	_handle_block_actions()
	_update_combat(delta)
	_update_attack_animation(delta)
	_update_world_loot_and_fx(delta)
	_update_knowledge_observations(delta)
	_update_camera()
	_update_minimap(delta)
	world_edge_warning_timer = maxf(0.0, world_edge_warning_timer - delta)
	hud_update_timer += delta
	if hud_update_timer >= 0.10:
		hud_update_timer = 0.0
		_update_hud()
	_update_boss_bar()
	_update_loot_feed()
	_update_held_item_preview()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var console_key := event as InputEventKey
		if console_key.pressed and not console_key.echo and (console_key.keycode == KEY_F1 or console_key.keycode == KEY_QUOTELEFT):
			_set_debug_console_open(not debug_console_open)
			get_viewport().set_input_as_handled()
			return
		if debug_console_open:
			if console_key.pressed and console_key.keycode == KEY_ESCAPE:
				_set_debug_console_open(false)
				get_viewport().set_input_as_handled()
			return
		if journal_open and console_key.pressed and console_key.keycode == KEY_ESCAPE:
			_set_journal_open(false)
			get_viewport().set_input_as_handled()
			return
		if console_key.pressed and not console_key.echo and console_key.keycode == KEY_ESCAPE:
			if inventory_open:
				inventory_open = false
				_close_chest()
				_update_hud()
			elif full_map_open:
				_set_full_map_open(false)
			else:
				_set_pause_menu_open(true)
			get_viewport().set_input_as_handled()
			return
		if console_key.pressed and not console_key.echo and console_key.physical_keycode == KEY_SPACE and noclip_unlocked:
			var now := Time.get_ticks_msec()
			if now - last_space_press_msec <= 360:
				_set_noclip_enabled(not noclip_enabled)
				last_space_press_msec = -10000
			else:
				last_space_press_msec = now
	_track_desktop_input(event)
	if inventory_open and event is InputEventMouseButton:
		var inventory_mouse_event := event as InputEventMouseButton
		if inventory_mouse_event.button_index == MOUSE_BUTTON_RIGHT and not inventory_mouse_event.pressed and pending_inventory_right_drop_id != "":
			if not pending_inventory_right_drop_consumed:
				_drop_inventory_item_to_world(pending_inventory_right_drop_id, 1)
			pending_inventory_right_drop_id = ""
			pending_inventory_right_drop_consumed = false
	if not inventory_open or held_item_id == "":
		return
	if event is InputEventMouseButton and not event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT or mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_release_held_item(mouse_event.position)


func _track_desktop_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.echo:
			return
		# physical_keycode is independent of the current keyboard language.
		if key_event.physical_keycode == KEY_A:
			physical_move_left_held = key_event.pressed
		elif key_event.physical_keycode == KEY_D:
			physical_move_right_held = key_event.pressed
		elif key_event.physical_keycode == KEY_W or key_event.physical_keycode == KEY_SPACE or key_event.physical_keycode == KEY_UP:
			physical_noclip_up_held = key_event.pressed
		elif key_event.physical_keycode == KEY_S or key_event.physical_keycode == KEY_DOWN:
			physical_noclip_down_held = key_event.pressed
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			mouse_mine_held = mouse_event.pressed


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		physical_move_left_held = false
		physical_move_right_held = false
		physical_noclip_up_held = false
		physical_noclip_down_held = false
		mouse_mine_held = false


func _unhandled_input(event: InputEvent) -> void:
	if not _mobile_controls_enabled() or full_map_open or inventory_open or journal_open:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			var world_pos := get_canvas_transform().affine_inverse() * touch.position
			mobile_world_touch_index = touch.index
			_handle_mobile_world_press(world_pos)
			get_viewport().set_input_as_handled()
		elif touch.index == mobile_world_touch_index:
			mobile_world_touch_index = -1
			Input.action_release("mine")
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == mobile_world_touch_index:
			var world_pos := get_canvas_transform().affine_inverse() * drag.position
			mobile_target_tile = Vector2i(floori(world_pos.x / TILE_SIZE), floori(world_pos.y / TILE_SIZE))
			mobile_target_valid = _in_bounds(mobile_target_tile.x, mobile_target_tile.y)
			get_viewport().set_input_as_handled()


func _handle_mobile_world_press(world_pos: Vector2) -> void:
	mobile_target_tile = Vector2i(floori(world_pos.x / TILE_SIZE), floori(world_pos.y / TILE_SIZE))
	mobile_target_valid = _in_bounds(mobile_target_tile.x, mobile_target_tile.y)
	if not mobile_target_valid:
		_try_player_attack_at(world_pos)
		return
	if _enemy_at_world_position(world_pos):
		_try_player_attack_at(world_pos)
		return
	if _can_interact(mobile_target_tile) and _memory_node_index_at_tile(mobile_target_tile) >= 0:
		_activate_memory_node(_memory_node_index_at_tile(mobile_target_tile))
		return
	if _can_interact(mobile_target_tile) and _archive_console_at_tile(mobile_target_tile):
		_activate_archive_console()
		return
	var tile := _get_tile(mobile_target_tile.x, mobile_target_tile.y)
	if _can_interact(mobile_target_tile) and (tile == Tile.CHEST or tile == Tile.STONE_ALTAR):
		_place_target_tile()
		return
	if _can_interact(mobile_target_tile) and tile != Tile.AIR and tile != Tile.WATER and tile != Tile.LAVA:
		Input.action_press("mine")
		return
	if _can_interact(mobile_target_tile) and tile == Tile.AIR and item_to_tile.has(_selected_item()):
		_place_target_tile()
		return
	_try_player_attack_at(world_pos)


func _enemy_at_world_position(world_pos: Vector2) -> bool:
	for enemy in enemies:
		if not _enemy_can_be_hit(enemy):
			continue
		var enemy_rect := _enemy_hitbox_rect(enemy)
		if enemy_rect.grow(10.0).has_point(world_pos):
			return true
	return false


func _draw() -> void:
	_collect_visible_light_sources()
	_draw_background()
	_draw_visible_world()
	_draw_archive_site()
	_draw_memory_nodes()
	_draw_combat_entities()
	_draw_world_loot_and_fx()
	_draw_player()
	_draw_attack_animation()
	_draw_weather()
	_draw_world_edge_haze()
	_draw_darkness_overlay()
	_draw_perception_debug()
	_draw_target_cursor()


func _setup_camera() -> void:
	camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.zoom = Vector2(2.5, 2.5)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 10.0
	add_child(camera)
	camera.make_current()


func _setup_texture_paths() -> void:
	tile_texture_paths = {
		Tile.GRASS: "res://assets/textures/tiles/grass.png",
		Tile.SNOW_BLOCK: "res://assets/textures/tiles/snow_block.png",
		Tile.DIRT: "res://assets/textures/tiles/dirt.png",
		Tile.STONE: "res://assets/textures/tiles/stone.png",
		Tile.COPPER: "res://assets/textures/tiles/copper.png",
		Tile.IRON: "res://assets/textures/tiles/iron.png",
		Tile.ASH: "res://assets/textures/tiles/ash.png",
		Tile.ROOT: "res://assets/textures/tiles/root.png",
		Tile.WOOD: "res://assets/textures/tiles/wood.png",
		Tile.LEAVES: "res://assets/textures/tiles/leaves.png",
		Tile.RUIN: "res://assets/textures/tiles/ruin.png",
		Tile.WORKBENCH: "res://assets/textures/tiles/workbench.png",
		Tile.FURNACE: "res://assets/textures/tiles/furnace.png",
		Tile.ANVIL: "res://assets/textures/tiles/anvil.png",
		Tile.TURRET: "res://assets/textures/tiles/turret.png",
		Tile.HEART: "res://assets/textures/tiles/heart.png",
		Tile.CHEST: "res://assets/textures/tiles/chest.png",
		Tile.STONE_ALTAR: "res://assets/textures/tiles/stone_altar.png",
		Tile.STONEBLOOD: "res://assets/textures/tiles/stoneblood.png",
		Tile.MOSS: "res://assets/textures/tiles/moss.png",
		Tile.MUSHROOM_SOIL: "res://assets/textures/tiles/mushroom_soil.png",
		Tile.GLOW_MUSHROOM: "res://assets/textures/tiles/glow_mushroom.png",
		Tile.ASH_BRICK: "res://assets/textures/tiles/ash_brick.png",
		Tile.SUNKEN_STONE: "res://assets/textures/tiles/sunken_stone.png",
		Tile.LAVA_ROOT: "res://assets/textures/tiles/lava_root.png",
		Tile.GLASS_STONE: "res://assets/textures/tiles/glass_stone.png",
		Tile.ABYSS_CRYSTAL: "res://assets/textures/tiles/abyss_crystal.png",
		Tile.WATER: "res://assets/textures/tiles/water.png",
		Tile.LAVA: "res://assets/textures/tiles/lava.png",
		Tile.SAPLING: "res://assets/textures/tiles/sapling.png",
		Tile.ASH_SAND: "res://assets/textures/tiles/ash_sand.png",
		Tile.FROZEN_DIRT: "res://assets/textures/tiles/frozen_dirt.png",
		Tile.MUD: "res://assets/textures/tiles/mud.png",
		Tile.RUBBLE: "res://assets/textures/tiles/rubble.png"
	}


func _load_texture_assets() -> void:
	tile_textures.clear()
	tile_texture_variants.clear()
	biome_tile_textures.clear()
	var surface_biome_ids := ["frost_wasteland", "marsh", "ash_desert", "ash_ruins"]
	var surface_tile_names := {Tile.GRASS: "grass", Tile.SNOW_BLOCK: "snow_block", Tile.DIRT: "dirt", Tile.STONE: "stone", Tile.LEAVES: "leaves", Tile.WOOD: "wood", Tile.MOSS: "moss"}
	for biome in surface_biome_ids:
		var biome_tiles: Dictionary = {}
		for tile in surface_tile_names.keys():
			var texture := _load_png_texture("res://assets/textures/biomes/%s/%s.png" % [biome, surface_tile_names[tile]])
			if texture != null:
				biome_tiles[int(tile)] = texture
		if not biome_tiles.is_empty():
			biome_tile_textures[biome] = biome_tiles
	for tile in tile_texture_paths.keys():
		var base_path := str(tile_texture_paths[tile])
		var variants: Array[Texture2D] = []
		for suffix in ["", "_1", "_2", "_3"]:
			var variant_path := base_path.replace(".png", "%s.png" % suffix)
			var texture: Texture2D = _load_png_texture(variant_path)
			if texture != null:
				variants.append(texture)
		if not variants.is_empty():
			tile_textures[tile] = variants[0]
			tile_texture_variants[tile] = variants
	for item_id in item_names.keys():
		var texture: Texture2D = _load_png_texture("res://assets/textures/items/%s.png" % str(item_id))
		if texture != null:
			item_icon_cache[str(item_id)] = texture
	memory_node_textures.clear()
	for node_kind in ["fungal", "sunken", "ash"]:
		var node_states: Dictionary = {}
		for state in ["dormant", "activate", "active"]:
			var node_texture := _load_png_texture("res://assets/textures/objects/memory_nodes/%s/%s.png" % [node_kind, state])
			if node_texture != null:
				node_states[state] = node_texture
		if not node_states.is_empty():
			memory_node_textures[node_kind] = node_states
	archive_object_textures = {
		"console_idle": _load_png_texture("res://assets/textures/objects/archive_console/archive_console_idle.png"),
		"console_activate": _load_png_texture("res://assets/textures/objects/archive_console/archive_console_activate.png"),
		"gate_closed": _load_png_texture("res://assets/textures/objects/archive_gate/archive_gate_closed.png"),
		"gate_opening": _load_png_texture("res://assets/textures/objects/archive_gate/archive_gate_opening.png"),
		"gate_open": _load_png_texture("res://assets/textures/objects/archive_gate/archive_gate_open.png"),
		"hologram": _load_png_texture("res://assets/textures/objects/memory_hologram/memory_hologram.png")
	}
	enemy_textures.clear()
	enemy_sprite_ground_anchors.clear()
	for enemy_type in enemy_sprite_specs.keys():
		var texture: Texture2D = _load_png_texture("res://assets/textures/enemies/%s.png" % str(enemy_type))
		if texture != null:
			enemy_textures[str(enemy_type)] = texture
			var sprite_spec: Dictionary = enemy_sprite_specs[enemy_type]
			var frame_size: Vector2i = sprite_spec.get("frame", Vector2i(32, 32))
			var idle_row := int(sprite_spec.get("idle_row", 0))
			var idle_frames := int(sprite_spec.get("idle_frames", 1))
			enemy_sprite_ground_anchors[str(enemy_type)] = _opaque_bottom_anchor(texture, frame_size.x, frame_size.y, idle_frames, idle_row * frame_size.y)
	enemy_animation_textures.clear()
	enemy_animation_specs.clear()
	enemy_animation_pack_specs.clear()
	_load_enemy_animation_pack("wild_slime", "res://assets/textures/enemies/anims/wild_slime/wild_slime_anim.json")
	_load_enemy_animation_pack("mossling", "res://assets/textures/enemies/anims/mossling/mossling_anim.json")
	_load_enemy_animation_pack("root_crawler", "res://assets/textures/enemies/anims/root_crawler/rootcrawler_anim.json")
	_load_enemy_animation_pack("cave_worm", "res://assets/textures/enemies/anims/cave_worm/cave_worm_anim.json")
	_load_enemy_animation_pack("bat", "res://assets/textures/enemies/anims/bat/bat_anim.json")
	_load_enemy_animation_pack("spore_bat", "res://assets/textures/enemies/anims/spore_bat/spore_bat_anim.json")
	_load_enemy_animation_pack("cave_husk", "res://assets/textures/enemies/anims/cave_husk/cave_husk_anim.json")
	_load_enemy_animation_pack("mushroom_beetle", "res://assets/textures/enemies/anims/mushroom_beetle/mushroom_beetle_anim.json")
	_load_enemy_animation_pack("ash_phantom", "res://assets/textures/enemies/anims/ash_phantom/ash_phantom_anim.json")
	_load_enemy_animation_pack("ash_wisp", "res://assets/textures/enemies/anims/ash_wisp/ash_wisp_anim.json")
	_load_enemy_animation_pack("ash_sentinel", "res://assets/textures/enemies/anims/ash_sentinel/ash_sentinel_anim.json")
	_load_enemy_animation_pack("drowned_guard", "res://assets/textures/enemies/anims/drowned_guard/drowned_guard_anim.json")
	_load_enemy_animation_pack("ember_rootling", "res://assets/textures/enemies/anims/ember_rootling/ember_rootling_anim.json")
	_load_enemy_animation_pack("glass_wraith", "res://assets/textures/enemies/anims/glass_wraith/glass_wraith_anim.json")
	_load_enemy_animation_pack("night_ember", "res://assets/textures/enemies/anims/night_ember/night_ember_anim.json")
	_load_enemy_animation_pack("sea_leviathan", "res://assets/textures/enemies/leviathan/leviathan_anim.json")
	_load_enemy_animation_pack("heartwood_boss", "res://assets/textures/enemies/anims/heartwood_boss/heartwood_boss_anim.json")
	_load_enemy_animation_pack("ruin_drone", "res://assets/textures/enemies/anims/ruin_drone/ruin_drone_anim.json")
	_load_enemy_animation_pack("stone_beast", "res://assets/textures/enemies/anims/stone_beast/stone_beast_anim.json")
	_load_enemy_animation_pack("archive_warden", "res://assets/textures/enemies/anims/archive_warden/archive_warden_anim.json")
	_load_enemy_visual_variant("frost_wild_slime", "wild_slime", "res://assets/textures/enemies/anims/wild_slime/frost_variant.png", "res://assets/textures/enemies/anims/wild_slime/frost_variant/wild_slime_anim.json")
	_load_enemy_visual_variant("desert_wild_slime", "wild_slime", "res://assets/textures/enemies/anims/wild_slime/desert_variant.png", "res://assets/textures/enemies/anims/wild_slime/desert_variant/wild_slime_anim.json")
	_load_enemy_visual_variant("frost_bat", "bat", "res://assets/textures/enemies/anims/bat/frost_variant.png", "res://assets/textures/enemies/anims/bat/frost_variant/bat_anim.json")
	if USE_EXTERNAL_ENEMY_ANIMATION_STRIPS:
		var animation_states := {
			"root_crawler": ["idle", "move", "attack_1", "attack_2", "attack_3", "death"],
			"cave_worm": ["idle", "move", "attack_1", "attack_2", "attack_3", "hurt", "death"],
			"bat": ["idle", "move", "attack_1", "attack_2", "hurt", "death"],
			"cave_husk": ["idle", "move", "attack_1", "attack_2", "attack_3", "death"],
			"spore_bat": ["idle", "move", "attack_1", "attack_2", "attack_3", "hurt", "death"],
			"mushroom_beetle": ["idle", "move", "attack_1", "attack_2", "attack_3", "attack_4", "hurt", "death"],
			"ash_phantom": ["idle", "move", "attack_1", "attack_2", "attack_3", "hurt", "death"],
			"ash_wisp": ["idle", "move", "attack_1", "attack_2", "hurt", "death"],
			"ash_sentinel": ["idle", "move", "attack_1", "attack_2", "attack_3", "attack_4", "hurt", "death"],
			"ruin_drone": ["idle", "move", "attack_1", "attack_2", "attack_3", "hurt", "death"],
			"drowned_guard": ["idle", "move", "attack_1", "attack_2", "attack_3", "attack_4", "hurt", "death"],
			"ember_rootling": ["idle", "move", "attack_1", "attack_2", "attack_3", "hurt", "death"],
			"night_ember": ["idle", "move", "attack_1", "attack_2", "attack_3", "hurt", "death"],
			"glass_wraith": ["idle", "move", "attack_1", "attack_2", "attack_3", "attack_4", "hurt", "death"],
			"stone_beast": ["idle", "move", "attack_1", "attack_2", "attack_3", "attack_4", "attack_5", "attack_6", "hurt", "death"],
			"heartwood_boss": ["idle", "move", "spawn", "phase_2", "attack_1", "attack_2", "attack_3", "attack_4", "attack_5", "attack_6", "hurt", "death"]
		}
		for enemy_type in animation_states.keys():
			var state_textures: Dictionary = {}
			for state in animation_states[enemy_type]:
				var anim_texture := _load_png_texture("res://assets/textures/enemies/anims/%s_%s.png" % [str(enemy_type), str(state)])
				if anim_texture != null:
					state_textures[str(state)] = anim_texture
			if not state_textures.is_empty():
				enemy_animation_textures[str(enemy_type)] = state_textures
	player_texture = _load_png_texture("res://assets/textures/player.png")


func _load_png_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	return ResourceLoader.load(path) as Texture2D


func _load_enemy_visual_variant(variant_type: String, base_type: String, texture_path: String, animation_json_path: String) -> void:
	EnemyAnimations.load_visual_variant(
		variant_type,
		base_type,
		texture_path,
		animation_json_path,
		enemy_textures,
		enemy_sprite_specs,
		enemy_sprite_ground_anchors,
		enemy_animation_textures,
		enemy_animation_specs,
		enemy_animation_pack_specs
	)


func _load_enemy_animation_pack(enemy_type: String, json_path: String) -> void:
	EnemyAnimations.load_pack(
		enemy_type,
		json_path,
		enemy_animation_textures,
		enemy_animation_specs,
		enemy_animation_pack_specs,
		enemy_sprite_ground_anchors
	)


func _opaque_bottom_anchor(texture: Texture2D, frame_width: int, frame_height: int, frame_count: int, source_y := 0) -> float:
	return EnemyAnimations.opaque_bottom_anchor(texture, frame_width, frame_height, frame_count, source_y)


func _enemy_animation_spec(enemy_type: String, state: String) -> Dictionary:
	return EnemyAnimations.animation_spec(enemy_animation_specs, enemy_type, state)


func _enemy_animation_visual_state(enemy_type: String, requested_state: String) -> String:
	return EnemyAnimations.visual_state(enemy_animation_textures, enemy_animation_pack_specs, enemy_type, requested_state)


func _enemy_animation_ground_clearance(enemy_type: String) -> float:
	return EnemyAnimations.ground_clearance(enemy_animation_pack_specs, enemy_type)


func _enemy_animation_anchor(enemy_type: String, frame_size: Vector2) -> Vector2:
	return EnemyAnimations.animation_anchor(enemy_animation_pack_specs, enemy_type, frame_size)


func _enemy_animation_state_anchor(enemy_type: String, state: String, frame_size: Vector2) -> Vector2:
	return EnemyAnimations.state_anchor(enemy_animation_specs, enemy_animation_pack_specs, enemy_type, state, frame_size)


func _enemy_animation_attack_event_key(spec: Dictionary) -> String:
	return EnemyAnimations.attack_event_key(spec)


func _enemy_animation_duration(enemy_type: String, state: String, fallback: float) -> float:
	return EnemyAnimations.duration(enemy_animation_specs, enemy_type, state, fallback)


func _enemy_animation_event_time(enemy_type: String, state: String, event_key: String, fallback: float) -> float:
	return EnemyAnimations.event_time(enemy_animation_specs, enemy_type, state, event_key, fallback)


func _enemy_attack_recovery(enemy_type: String, attack_index: int) -> float:
	return EnemyAnimations.attack_recovery(enemy_animation_specs, enemy_type, attack_index)


func _setup_hud() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "HUD"
	add_child(canvas)

	# Final HUD: concise survival readout, compact map, no oversized opaque blocks.
	var status_root := Control.new()
	status_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	status_root.offset_left = 24
	status_root.offset_top = 28
	status_root.offset_right = 304
	status_root.offset_bottom = 122
	status_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(status_root)
	var status_frame := _make_hud_panel(Vector2.ZERO, Vector2(280, 94))
	status_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_root.add_child(status_frame)
	hud_label = Label.new()
	hud_label.position = Vector2(12, 10)
	hud_label.size = Vector2(252, 14)
	hud_label.add_theme_font_size_override("font_size", 10)
	hud_label.add_theme_color_override("font_color", Color("ddd5bc"))
	status_root.add_child(hud_label)
	hud_health_bar = _make_compass_progress_bar(Color("d65455"))
	hud_health_bar.position = Vector2(12, 30)
	hud_health_bar.size = Vector2(256, 12)
	status_root.add_child(hud_health_bar)
	hud_armor_value = Label.new()
	hud_armor_value.position = Vector2(12, 52)
	hud_armor_value.size = Vector2(252, 14)
	hud_armor_value.add_theme_font_size_override("font_size", 9)
	hud_armor_value.add_theme_color_override("font_color", Color("9c9a89"))
	status_root.add_child(hud_armor_value)
	hud_status_label = Label.new()
	hud_status_label.position = Vector2(12, 72)
	hud_status_label.size = Vector2(252, 22)
	hud_status_label.add_theme_font_size_override("font_size", 9)
	hud_status_label.add_theme_color_override("font_color", Color("db8a55"))
	status_root.add_child(hud_status_label)

	temperature_panel = Control.new()
	temperature_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	temperature_panel.offset_left = 24
	temperature_panel.offset_top = 130
	temperature_panel.offset_right = 304
	temperature_panel.offset_bottom = 174
	temperature_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(temperature_panel)
	var temperature_frame := _make_hud_panel(Vector2.ZERO, Vector2(280, 26))
	temperature_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	temperature_panel.add_child(temperature_frame)
	temperature_title = Label.new()
	temperature_title.text = "TEMP"
	temperature_title.position = Vector2(10, 5)
	temperature_title.size = Vector2(38, 14)
	temperature_title.add_theme_font_size_override("font_size", 8)
	temperature_title.add_theme_color_override("font_color", Color("db8a55"))
	temperature_panel.add_child(temperature_title)
	temperature_bar = _make_compass_progress_bar(Color("d9b969"))
	temperature_bar.min_value = MIN_BODY_TEMPERATURE
	temperature_bar.max_value = MAX_BODY_TEMPERATURE
	temperature_bar.position = Vector2(52, 8)
	temperature_bar.size = Vector2(158, 8)
	temperature_panel.add_child(temperature_bar)
	var comfort_marker := ColorRect.new()
	comfort_marker.position = Vector2(131, 7)
	comfort_marker.size = Vector2(1, 10)
	comfort_marker.color = Color("ded8c8", 0.75)
	comfort_marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	temperature_panel.add_child(comfort_marker)
	temperature_value = Label.new()
	temperature_value.position = Vector2(220, 5)
	temperature_value.size = Vector2(50, 14)
	temperature_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	temperature_value.add_theme_font_size_override("font_size", 8)
	temperature_value.add_theme_color_override("font_color", Color("ded8c8"))
	temperature_panel.add_child(temperature_value)

	oxygen_panel = Control.new()
	oxygen_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	oxygen_panel.offset_left = 24
	oxygen_panel.offset_top = 162
	oxygen_panel.offset_right = 304
	oxygen_panel.offset_bottom = 206
	oxygen_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	oxygen_panel.visible = false
	canvas.add_child(oxygen_panel)
	var oxygen_frame := _make_hud_panel(Vector2.ZERO, Vector2(280, 26))
	oxygen_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	oxygen_panel.add_child(oxygen_frame)
	var oxygen_title := Label.new()
	oxygen_title.text = "O2"
	oxygen_title.position = Vector2(10, 5)
	oxygen_title.size = Vector2(38, 14)
	oxygen_title.add_theme_font_size_override("font_size", 8)
	oxygen_title.add_theme_color_override("font_color", Color("53aebf"))
	oxygen_panel.add_child(oxygen_title)
	oxygen_bar = _make_compass_progress_bar(Color("59a5c0"))
	oxygen_bar.position = Vector2(52, 8)
	oxygen_bar.size = Vector2(158, 8)
	oxygen_panel.add_child(oxygen_bar)
	oxygen_value = Label.new()
	oxygen_value.position = Vector2(220, 5)
	oxygen_value.size = Vector2(50, 14)
	oxygen_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	oxygen_value.add_theme_font_size_override("font_size", 8)
	oxygen_value.add_theme_color_override("font_color", Color("8ed0e3"))
	oxygen_panel.add_child(oxygen_value)

	minimap_panel = _make_compass_map_frame()
	minimap_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap_panel.offset_left = -246
	minimap_panel.offset_top = 28
	minimap_panel.offset_right = -24
	minimap_panel.offset_bottom = 184
	minimap_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	minimap_panel.tooltip_text = "Open world map"
	minimap_panel.gui_input.connect(_on_minimap_gui_input)
	canvas.add_child(minimap_panel)
	var minimap_root := Control.new()
	minimap_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	minimap_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_panel.add_child(minimap_root)
	var minimap_title := Label.new()
	minimap_title.text = "WILDERNESS"
	minimap_title.position = Vector2(10, 7)
	minimap_title.size = Vector2(202, 13)
	minimap_title.add_theme_font_size_override("font_size", 8)
	minimap_title.add_theme_color_override("font_color", Color("9c9a89"))
	minimap_root.add_child(minimap_title)
	minimap_rect = TextureRect.new()
	minimap_rect.position = Vector2(0, 0)
	minimap_rect.position = Vector2(10, 24)
	minimap_rect.size = Vector2(202, 88)
	minimap_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	minimap_rect.stretch_mode = TextureRect.STRETCH_SCALE
	minimap_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_root.add_child(minimap_rect)
	minimap_time_label = Label.new()
	minimap_time_label.position = Vector2(10, 118)
	minimap_time_label.size = Vector2(202, 14)
	minimap_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minimap_time_label.add_theme_font_size_override("font_size", 8)
	minimap_time_label.add_theme_color_override("font_color", Color("59a5c0"))
	minimap_root.add_child(minimap_time_label)
	minimap_biome_label = Label.new()
	minimap_biome_label.position = Vector2(10, 134)
	minimap_biome_label.size = Vector2(202, 14)
	minimap_biome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minimap_biome_label.add_theme_font_size_override("font_size", 8)
	minimap_biome_label.add_theme_color_override("font_color", Color("8fc47f"))
	minimap_root.add_child(minimap_biome_label)

	journal_access_button = _make_compass_action_button("FIELD JOURNAL")
	journal_access_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	journal_access_button.offset_left = -246
	journal_access_button.offset_top = 192
	journal_access_button.offset_right = -24
	journal_access_button.offset_bottom = 226
	journal_access_button.pressed.connect(_set_journal_open.bind(true))
	canvas.add_child(journal_access_button)

	var hotbar_root := Control.new()
	hotbar_root.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hotbar_root.offset_left = -208
	hotbar_root.offset_top = -100
	hotbar_root.offset_right = 208
	hotbar_root.offset_bottom = -14
	hotbar_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(hotbar_root)
	var hotbar_frame := _make_hud_panel(Vector2.ZERO, Vector2(416, 86))
	hotbar_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotbar_root.add_child(hotbar_frame)
	var slot_positions := [Vector2(16, 12), Vector2(96, 12), Vector2(176, 12), Vector2(256, 12), Vector2(336, 12)]
	for i in range(HOTBAR_SIZE):
		var slot := _make_slot_button()
		slot.position = slot_positions[i]
		slot.size = Vector2(64, 64)
		slot.custom_minimum_size = Vector2(64, 64)
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.pressed.connect(_on_hotbar_slot_pressed.bind(i))
		slot.gui_input.connect(_on_hotbar_slot_gui_input.bind(i))
		hotbar_buttons.append(slot)
		hotbar_root.add_child(slot)

	context_hint_panel = Control.new()
	context_hint_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	context_hint_panel.offset_left = -140
	context_hint_panel.offset_top = -118
	context_hint_panel.offset_right = 140
	context_hint_panel.offset_bottom = -92
	context_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	context_hint_panel.visible = false
	canvas.add_child(context_hint_panel)
	context_hint_label = Label.new()
	context_hint_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	context_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	context_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	context_hint_label.add_theme_font_size_override("font_size", 10)
	context_hint_label.add_theme_color_override("font_color", Color("d9b969"))
	context_hint_panel.add_child(context_hint_label)

	full_map_backdrop = ColorRect.new()
	full_map_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	full_map_backdrop.color = Color("060907", 0.96)
	full_map_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	full_map_backdrop.visible = false
	full_map_backdrop.z_index = 59
	canvas.add_child(full_map_backdrop)

	full_map_panel = _make_hud_panel(Vector2.ZERO, Vector2.ZERO)
	full_map_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	full_map_panel.anchor_left = 0.10
	full_map_panel.anchor_top = 0.22
	full_map_panel.anchor_right = 0.90
	full_map_panel.anchor_bottom = 0.64
	full_map_panel.offset_left = 0
	full_map_panel.offset_top = 0
	full_map_panel.offset_right = 0
	full_map_panel.offset_bottom = 0
	full_map_panel.visible = false
	full_map_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	full_map_panel.z_index = 60
	canvas.add_child(full_map_panel)
	var full_map_box := VBoxContainer.new()
	full_map_box.add_theme_constant_override("separation", 6)
	full_map_panel.add_child(full_map_box)
	var full_map_header := HBoxContainer.new()
	full_map_box.add_child(full_map_header)
	var full_map_title := Label.new()
	full_map_title.text = "WORLD MAP  //  EXPLORED TERRITORY"
	full_map_title.add_theme_font_size_override("font_size", 18)
	full_map_title.add_theme_color_override("font_color", Color("82c7b1"))
	full_map_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	full_map_header.add_child(full_map_title)
	var full_map_close := Button.new()
	full_map_close.text = "CLOSE  [ESC]"
	full_map_close.tooltip_text = "Close map"
	full_map_close.custom_minimum_size = Vector2(112, 34)
	full_map_close.focus_mode = Control.FOCUS_NONE
	full_map_close.pressed.connect(_set_full_map_open.bind(false))
	ui_theme_manager.apply_button(full_map_close)
	full_map_header.add_child(full_map_close)
	full_map_rect = TextureRect.new()
	# The generated map remains 1280 px wide internally, but its UI minimum must
	# not force the close button outside a 1280-wide logical viewport.
	full_map_rect.custom_minimum_size = Vector2(720, FULL_MAP_HEIGHT)
	full_map_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	full_map_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	full_map_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	full_map_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	full_map_box.add_child(full_map_rect)

	chest_panel = _make_compass_clear_panel()
	chest_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	chest_panel.offset_left = -364
	chest_panel.offset_top = 122
	chest_panel.offset_right = -56
	chest_panel.offset_bottom = 470
	chest_panel.visible = false
	chest_panel.z_index = 52
	canvas.add_child(chest_panel)
	var chest_box := VBoxContainer.new()
	chest_box.add_theme_constant_override("separation", 8)
	chest_panel.add_child(chest_box)
	var chest_title := Label.new()
	chest_title.text = "ANCIENT CHEST"
	chest_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chest_title.add_theme_font_size_override("font_size", 11)
	chest_title.add_theme_color_override("font_color", Color("d9b969"))
	chest_box.add_child(chest_title)
	var chest_grid := GridContainer.new()
	chest_grid.columns = 4
	chest_grid.add_theme_constant_override("h_separation", 8)
	chest_grid.add_theme_constant_override("v_separation", 8)
	chest_box.add_child(chest_grid)
	for i in range(15):
		var chest_slot := _make_slot_button()
		chest_slot.custom_minimum_size = Vector2(64, 64)
		chest_slot.mouse_filter = Control.MOUSE_FILTER_STOP
		chest_slot.gui_input.connect(_on_chest_slot_gui_input.bind(i))
		chest_slot_buttons.append(chest_slot)
		chest_grid.add_child(chest_slot)

	boss_panel = _make_compass_clear_panel()
	boss_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	boss_panel.anchor_left = 0.5
	boss_panel.anchor_right = 0.5
	boss_panel.offset_left = -250
	boss_panel.offset_top = 12
	boss_panel.offset_right = 250
	boss_panel.offset_bottom = 48
	boss_panel.visible = false
	boss_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(boss_panel)
	var boss_box := VBoxContainer.new()
	boss_box.add_theme_constant_override("separation", 2)
	boss_panel.add_child(boss_box)
	boss_label = Label.new()
	boss_label.add_theme_font_size_override("font_size", 11)
	boss_label.add_theme_color_override("font_color", Color("d9b969"))
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_box.add_child(boss_label)
	boss_hp_bar = _make_compass_progress_bar(Color("d65455"))
	boss_hp_bar.custom_minimum_size = Vector2(496, 5)
	boss_hp_bar.show_percentage = false
	boss_hp_bar.max_value = 100.0
	boss_box.add_child(boss_hp_bar)

	var loot_feed := VBoxContainer.new()
	loot_feed.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	loot_feed.offset_left = -205
	loot_feed.offset_top = 300
	loot_feed.offset_right = -18
	loot_feed.offset_bottom = 470
	loot_feed.alignment = BoxContainer.ALIGNMENT_END
	loot_feed.add_theme_constant_override("separation", 7)
	loot_feed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(loot_feed)
	for i in range(5):
		var feed_label := Label.new()
		feed_label.add_theme_font_size_override("font_size", 11)
		feed_label.add_theme_color_override("font_color", Color("ded8c8"))
		feed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		loot_feed_labels.append(feed_label)
		loot_feed.add_child(feed_label)

	# Inventory overlay: dim world, floating equipment / backpack / crafting areas.
	inventory_backdrop = ColorRect.new()
	inventory_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	inventory_backdrop.color = Color("060907", 0.84)
	# The dimmer is visual only. It must never consume clicks meant for slots.
	inventory_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_backdrop.visible = false
	inventory_backdrop.z_index = 50
	canvas.add_child(inventory_backdrop)

	# One cohesive inventory screen sits behind the live equipment, backpack and
	# crafting controls. The controls stay independent so all existing drag/drop
	# and crafting logic remains intact.
	inventory_shell = _make_hud_panel(Vector2.ZERO, Vector2.ZERO)
	inventory_shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	inventory_shell.anchor_left = 0.035
	inventory_shell.anchor_top = 0.06
	inventory_shell.anchor_right = 0.965
	inventory_shell.anchor_bottom = 0.93
	inventory_shell.offset_left = 0
	inventory_shell.offset_top = 0
	inventory_shell.offset_right = 0
	inventory_shell.offset_bottom = 0
	inventory_shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_shell.visible = false
	inventory_shell.z_index = 50
	canvas.add_child(inventory_shell)
	var inventory_shell_root := Control.new()
	inventory_shell_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	inventory_shell_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_shell.add_child(inventory_shell_root)
	var inventory_shell_title := Label.new()
	inventory_shell_title.text = "INVENTORY  //  LOADOUT & CRAFT"
	inventory_shell_title.position = Vector2(18, 12)
	inventory_shell_title.size = Vector2(520, 22)
	inventory_shell_title.add_theme_font_size_override("font_size", 14)
	inventory_shell_title.add_theme_color_override("font_color", Color("82c7b1"))
	inventory_shell_root.add_child(inventory_shell_title)
	var inventory_shell_hint := Label.new()
	inventory_shell_hint.text = "I / TAB  CLOSE"
	inventory_shell_hint.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	inventory_shell_hint.offset_left = -150
	inventory_shell_hint.offset_top = 14
	inventory_shell_hint.offset_right = -18
	inventory_shell_hint.offset_bottom = 32
	inventory_shell_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	inventory_shell_hint.add_theme_font_size_override("font_size", 9)
	inventory_shell_hint.add_theme_color_override("font_color", Color("9c9a89"))
	inventory_shell_root.add_child(inventory_shell_hint)
	var inventory_shell_line := ColorRect.new()
	inventory_shell_line.set_anchors_preset(Control.PRESET_TOP_WIDE)
	inventory_shell_line.offset_left = 16
	inventory_shell_line.offset_top = 42
	inventory_shell_line.offset_right = -16
	inventory_shell_line.offset_bottom = 44
	inventory_shell_line.color = Color("71837b", 0.85)
	inventory_shell_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_shell_root.add_child(inventory_shell_line)

	equipment_overlay = Control.new()
	equipment_overlay.set_anchors_preset(Control.PRESET_TOP_LEFT)
	equipment_overlay.offset_left = 72
	equipment_overlay.offset_top = 112
	equipment_overlay.offset_right = 320
	equipment_overlay.offset_bottom = 590
	equipment_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	equipment_overlay.visible = false
	equipment_overlay.z_index = 51
	canvas.add_child(equipment_overlay)
	var equipment_frame := _make_hud_panel(Vector2(-10, -12), Vector2(248, 430))
	equipment_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	equipment_overlay.add_child(equipment_frame)
	equipment_label = Label.new()
	equipment_label.text = "EQUIPPED"
	equipment_label.position = Vector2(70, 0)
	equipment_label.size = Vector2(120, 20)
	equipment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipment_label.add_theme_font_size_override("font_size", 11)
	equipment_label.add_theme_color_override("font_color", Color("9f998d"))
	equipment_overlay.add_child(equipment_label)
	var equipment_line := ColorRect.new()
	equipment_line.position = Vector2(48, 18)
	equipment_line.size = Vector2(150, 1)
	equipment_line.color = Color("806043", 0.7)
	equipment_overlay.add_child(equipment_line)
	var equipment_box := VBoxContainer.new()
	equipment_box.position = Vector2(0, 32)
	equipment_box.size = Vector2(220, 350)
	# Six rows have to fit inside the frame: tightened from 14 so the charm
	# slot and the weather readout stay inside the panel instead of spilling
	# out of the bottom.
	equipment_box.add_theme_constant_override("separation", 6)
	equipment_overlay.add_child(equipment_box)
	var weapon_row := HBoxContainer.new()
	weapon_row.add_theme_constant_override("separation", 12)
	equipment_box.add_child(weapon_row)
	weapon_slot_button = _make_slot_button()
	weapon_slot_button.custom_minimum_size = Vector2(46, 46)
	weapon_slot_button.tooltip_text = "Weapon (select it on the hotbar)"
	weapon_slot_button.gui_input.connect(_on_equipment_slot_gui_input.bind("weapon"))
	weapon_row.add_child(weapon_slot_button)
	var weapon_label := Label.new()
	weapon_label.text = "IN HAND"
	weapon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	weapon_label.add_theme_font_size_override("font_size", 9)
	weapon_label.add_theme_color_override("font_color", Color("ded8c8"))
	weapon_row.add_child(weapon_label)
	# Four armour pieces, head to foot, each its own slot.
	helmet_slot_button = _make_equipment_row(equipment_box, "HELMET", "helmet")
	armor_slot_button = _make_equipment_row(equipment_box, "CHEST", "chest")
	legs_slot_button = _make_equipment_row(equipment_box, "GREAVES", "legs")
	boots_slot_button = _make_equipment_row(equipment_box, "BOOTS", "boots")
	var accessory_row := HBoxContainer.new()
	accessory_row.add_theme_constant_override("separation", 12)
	equipment_box.add_child(accessory_row)
	accessory_slot_button = _make_slot_button()
	accessory_slot_button.custom_minimum_size = Vector2(46, 46)
	accessory_slot_button.tooltip_text = "Charm"
	accessory_slot_button.gui_input.connect(_on_equipment_slot_gui_input.bind("accessory"))
	accessory_row.add_child(accessory_slot_button)
	var accessory_label := Label.new()
	accessory_label.text = "CHARM"
	accessory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	accessory_label.add_theme_font_size_override("font_size", 9)
	accessory_label.add_theme_color_override("font_color", Color("ded8c8"))
	accessory_row.add_child(accessory_label)
	equipment_environment_label = Label.new()
	equipment_environment_label.custom_minimum_size = Vector2(210, 36)
	equipment_environment_label.add_theme_font_size_override("font_size", 8)
	equipment_environment_label.add_theme_color_override("font_color", Color("9f998d"))
	equipment_environment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipment_box.add_child(equipment_environment_label)

	inventory_panel = _make_compass_clear_panel()
	inventory_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	inventory_panel.anchor_left = 0.5
	inventory_panel.anchor_right = 0.5
	inventory_panel.offset_left = -245
	inventory_panel.offset_top = 112
	inventory_panel.offset_right = 245
	inventory_panel.offset_bottom = 620
	inventory_panel.visible = false
	inventory_panel.z_index = 51
	canvas.add_child(inventory_panel)
	var inventory_box := VBoxContainer.new()
	inventory_box.add_theme_constant_override("separation", 8)
	inventory_panel.add_child(inventory_box)
	inventory_title_label = Label.new()
	inventory_title_label.text = "BACKPACK"
	inventory_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_title_label.add_theme_font_size_override("font_size", 11)
	inventory_title_label.add_theme_color_override("font_color", Color("9f998d"))
	inventory_title_label.visible = true
	inventory_box.add_child(inventory_title_label)
	var inv_grid := GridContainer.new()
	inv_grid.columns = 6
	inv_grid.add_theme_constant_override("h_separation", 8)
	inv_grid.add_theme_constant_override("v_separation", 8)
	inventory_box.add_child(inv_grid)
	for i in range(INVENTORY_GRID_SIZE):
		var inv_slot := _make_slot_button()
		inv_slot.custom_minimum_size = Vector2(64, 64)
		inv_slot.gui_input.connect(_on_inventory_slot_gui_input.bind(i))
		inv_slot.pressed.connect(_on_inventory_slot_pressed.bind(i))
		inventory_slot_buttons.append(inv_slot)
		inv_grid.add_child(inv_slot)
	selected_item_label = Label.new()
	selected_item_label.custom_minimum_size = Vector2(420, 104)
	selected_item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	selected_item_label.add_theme_font_size_override("font_size", 9)
	selected_item_label.add_theme_color_override("font_color", Color("ded8c8"))
	selected_item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_item_label.visible = true
	inventory_box.add_child(selected_item_label)
	var inventory_actions := HBoxContainer.new()
	inventory_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	inventory_actions.add_theme_constant_override("separation", 8)
	inventory_actions.visible = true
	inventory_box.add_child(inventory_actions)
	assign_hotbar_button = _make_compass_action_button("TO HOTBAR")
	assign_hotbar_button.pressed.connect(_assign_selected_inventory_to_hotbar)
	inventory_actions.add_child(assign_hotbar_button)
	drop_inventory_button = _make_compass_action_button("DROP")
	drop_inventory_button.pressed.connect(_drop_selected_inventory_item)
	drop_inventory_button.visible = false
	inventory_actions.add_child(drop_inventory_button)
	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 9)
	message_label.add_theme_color_override("font_color", Color("9f998d"))
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.visible = true
	inventory_box.add_child(message_label)

	crafting_panel = _make_compass_clear_panel()
	crafting_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	crafting_panel.offset_left = -364
	crafting_panel.offset_top = 112
	crafting_panel.offset_right = -54
	crafting_panel.offset_bottom = 620
	crafting_panel.visible = false
	crafting_panel.z_index = 51
	canvas.add_child(crafting_panel)
	var crafting_box := VBoxContainer.new()
	crafting_box.add_theme_constant_override("separation", 8)
	crafting_panel.add_child(crafting_box)
	var recipe_title := Label.new()
	recipe_title.text = "QUICK CRAFT"
	recipe_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	recipe_title.add_theme_font_size_override("font_size", 11)
	recipe_title.add_theme_color_override("font_color", Color("9f998d"))
	recipe_title.visible = true
	crafting_box.add_child(recipe_title)
	var recipe_scroll := ScrollContainer.new()
	recipe_scroll.custom_minimum_size = Vector2(300, 220)
	crafting_box.add_child(recipe_scroll)
	var recipe_list := GridContainer.new()
	recipe_list.columns = 4
	recipe_list.add_theme_constant_override("h_separation", 8)
	recipe_list.add_theme_constant_override("v_separation", 8)
	recipe_scroll.add_child(recipe_list)
	for i in range(recipes.size()):
		var recipe_button := _make_slot_button()
		recipe_button.custom_minimum_size = Vector2(64, 64)
		recipe_button.focus_mode = Control.FOCUS_NONE
		recipe_button.add_theme_font_size_override("font_size", 10)
		recipe_button.pressed.connect(_on_recipe_button_pressed.bind(i))
		recipe_buttons.append(recipe_button)
		recipe_list.add_child(recipe_button)
	crafting_label = Label.new()
	crafting_label.custom_minimum_size = Vector2(300, 110)
	crafting_label.add_theme_font_size_override("font_size", 10)
	crafting_label.add_theme_color_override("font_color", Color("ded8c8"))
	crafting_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	crafting_label.visible = true
	crafting_box.add_child(crafting_label)
	craft_button = _make_compass_action_button("CRAFT")
	craft_button.pressed.connect(_craft_selected_recipe)
	crafting_box.add_child(craft_button)
	stations_label = Label.new()
	stations_label.visible = false
	crafting_box.add_child(stations_label)
	controls_label = Label.new()
	controls_label.visible = false
	crafting_box.add_child(controls_label)

	held_item_panel = _make_hud_panel(Vector2(0, 0), Vector2(72, 40))
	held_item_panel.visible = false
	held_item_panel.z_index = 55
	canvas.add_child(held_item_panel)
	var held_row := HBoxContainer.new()
	held_row.add_theme_constant_override("separation", 4)
	held_item_panel.add_child(held_row)
	held_item_icon = TextureRect.new()
	held_item_icon.custom_minimum_size = Vector2(26, 26)
	held_item_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	held_item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	held_row.add_child(held_item_icon)
	held_item_amount_label = Label.new()
	held_item_amount_label.add_theme_font_size_override("font_size", 13)
	held_row.add_child(held_item_amount_label)

	_setup_journal(canvas)
	_setup_mobile_controls(canvas)
	_setup_debug_console(canvas)


func _setup_journal(canvas: CanvasLayer) -> void:
	journal_backdrop = ColorRect.new()
	journal_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	journal_backdrop.color = Color("060907", 0.86)
	journal_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	journal_backdrop.visible = false
	journal_backdrop.z_index = 68
	canvas.add_child(journal_backdrop)

	journal_panel = _make_hud_panel(Vector2.ZERO, Vector2.ZERO)
	journal_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	journal_panel.anchor_left = 0.09
	journal_panel.anchor_top = 0.08
	journal_panel.anchor_right = 0.91
	journal_panel.anchor_bottom = 0.92
	journal_panel.offset_left = 0
	journal_panel.offset_top = 0
	journal_panel.offset_right = 0
	journal_panel.offset_bottom = 0
	journal_panel.visible = false
	journal_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	journal_panel.z_index = 69
	canvas.add_child(journal_panel)

	var journal_root := VBoxContainer.new()
	journal_root.add_theme_constant_override("separation", 10)
	journal_panel.add_child(journal_root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	journal_root.add_child(header)
	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 0)
	header.add_child(title_box)
	var title := Label.new()
	title.text = "FIELD JOURNAL  //  ARCHIVE"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("82c7b1"))
	title_box.add_child(title)
	journal_progress_label = Label.new()
	journal_progress_label.add_theme_font_size_override("font_size", 10)
	journal_progress_label.add_theme_color_override("font_color", Color("8fa790"))
	title_box.add_child(journal_progress_label)
	var close_button := _make_compass_action_button("X")
	close_button.custom_minimum_size = Vector2(38, 34)
	close_button.tooltip_text = "Close journal"
	close_button.pressed.connect(_set_journal_open.bind(false))
	header.add_child(close_button)

	var header_line := ColorRect.new()
	header_line.custom_minimum_size = Vector2(1, 1)
	header_line.color = Color("8a6a42", 0.85)
	header_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	journal_root.add_child(header_line)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	journal_root.add_child(tabs)
	for tab_name in ["Recipes", "Bestiary", "Materials", "Alchemy"]:
		var tab_button := _make_journal_tab_button(tab_name)
		tab_button.pressed.connect(_select_journal_tab.bind(tab_name))
		journal_tab_buttons[tab_name] = tab_button
		tabs.add_child(tab_button)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	journal_root.add_child(body)

	var index_panel := _make_inner_panel()
	index_panel.custom_minimum_size = Vector2(300, 420)
	body.add_child(index_panel)
	var index_box := VBoxContainer.new()
	index_box.add_theme_constant_override("separation", 6)
	index_panel.add_child(index_box)
	var index_title := Label.new()
	index_title.text = "INDEX"
	index_title.add_theme_font_size_override("font_size", 10)
	index_title.add_theme_color_override("font_color", Color("ad9a73"))
	index_box.add_child(index_title)
	var entry_scroll := ScrollContainer.new()
	entry_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	entry_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	index_box.add_child(entry_scroll)
	journal_entry_list = VBoxContainer.new()
	journal_entry_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journal_entry_list.add_theme_constant_override("separation", 4)
	entry_scroll.add_child(journal_entry_list)

	var detail_panel := _make_inner_panel()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail_panel)
	var detail_box := VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 8)
	detail_panel.add_child(detail_box)
	journal_detail_title = Label.new()
	journal_detail_title.text = "Select an entry"
	journal_detail_title.add_theme_font_size_override("font_size", 17)
	journal_detail_title.add_theme_color_override("font_color", Color("e7d7ad"))
	detail_box.add_child(journal_detail_title)
	var detail_line := ColorRect.new()
	detail_line.custom_minimum_size = Vector2(1, 1)
	detail_line.color = Color("526453", 0.8)
	detail_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail_box.add_child(detail_line)
	journal_detail_text = RichTextLabel.new()
	journal_detail_text.bbcode_enabled = true
	journal_detail_text.fit_content = false
	journal_detail_text.scroll_active = true
	journal_detail_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	journal_detail_text.add_theme_font_size_override("normal_font_size", 13)
	journal_detail_text.add_theme_color_override("default_color", Color("c8c4b7"))
	detail_box.add_child(journal_detail_text)


func _make_inner_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", ui_theme_manager.panel_style("dark", 12.0))
	return panel


func _make_journal_tab_button(tab_name: String) -> Button:
	var button := Button.new()
	button.text = tab_name.to_upper()
	button.custom_minimum_size = Vector2(138, 34)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 10)
	_apply_journal_tab_style(button, false)
	return button


func _apply_journal_tab_style(button: Button, selected: bool) -> void:
	ui_theme_manager.apply_button(button, "rare" if selected else "normal")
	button.add_theme_color_override("font_color", Color("b79cff") if selected else Color("ddd5bc"))


func _make_journal_entry_button(label_text: String, entry_id: String, known: bool) -> Button:
	var button := Button.new()
	button.text = label_text
	button.tooltip_text = label_text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(270, 38)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 11)
	if known and journal_active_tab in ["Recipes", "Materials"]:
		button.icon = _item_icon(entry_id)
		button.expand_icon = true
	ui_theme_manager.apply_button(button, "rare" if entry_id == journal_selected_entry else "normal")
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_color_override("font_color", Color("ddd5bc") if known else Color("9c9a89"))
	return button


func _set_journal_open(open: bool) -> void:
	journal_open = open
	if open:
		inventory_open = false
		_close_chest()
		_set_full_map_open(false)
		journal_unread_count = 0
		_refresh_journal()
	if journal_panel != null:
		journal_panel.visible = open
	if journal_backdrop != null:
		journal_backdrop.visible = open
	if mobile_controls != null:
		mobile_controls.visible = _mobile_controls_enabled() and not open


func _select_journal_tab(tab_name: String) -> void:
	journal_active_tab = tab_name
	journal_selected_entry = ""
	_refresh_journal()


func _select_journal_entry(entry_id: String) -> void:
	journal_selected_entry = entry_id
	_refresh_journal()


func _refresh_journal() -> void:
	if journal_entry_list == null:
		return
	for tab_name in journal_tab_buttons.keys():
		_apply_journal_tab_style(journal_tab_buttons[tab_name], str(tab_name) == journal_active_tab)
	for child in journal_entry_list.get_children():
		journal_entry_list.remove_child(child)
		child.queue_free()

	var entries := _journal_entries(journal_active_tab)
	if journal_selected_entry == "" and not entries.is_empty():
		journal_selected_entry = str(entries[0])
	for entry_variant in entries:
		var entry_id := str(entry_variant)
		var known := _journal_entry_is_known(journal_active_tab, entry_id)
		var entry_button := _make_journal_entry_button(_journal_entry_label(journal_active_tab, entry_id), entry_id, known)
		entry_button.pressed.connect(_select_journal_entry.bind(entry_id))
		journal_entry_list.add_child(entry_button)
	_update_journal_detail()
	_update_journal_progress()


func _journal_entries(tab_name: String) -> Array[String]:
	var entries: Array[String] = []
	if tab_name == "Recipes":
		for recipe in recipes:
			entries.append(str(recipe.get("id", recipe.get("result", ""))))
	elif tab_name == "Bestiary":
		for enemy_type in EnemyData.PERCEPTION_PROFILES.keys():
			entries.append(str(enemy_type))
		entries.sort()
	elif tab_name == "Materials":
		for item_id in item_names.keys():
			var material_id := str(item_id)
			if _is_journal_material(material_id):
				entries.append(material_id)
		entries.sort()
	elif tab_name == "Alchemy":
		for result_id in alchemy_knowledge.keys():
			entries.append(str(result_id))
		entries.sort()
		if entries.is_empty():
			entries.append("__empty__")
	return entries


func _journal_entry_is_known(tab_name: String, entry_id: String) -> bool:
	if tab_name == "Recipes":
		return bool(known_recipes.get(entry_id, false))
	if tab_name == "Bestiary":
		return int((bestiary_knowledge.get(entry_id, {}) as Dictionary).get("stage", 0)) > 0
	if tab_name == "Materials":
		return int((material_knowledge.get(entry_id, {}) as Dictionary).get("stage", 0)) > 0
	if tab_name == "Alchemy":
		return entry_id != "__empty__" and alchemy_knowledge.has(entry_id)
	return false


func _journal_entry_label(tab_name: String, entry_id: String) -> String:
	if entry_id == "__empty__":
		return "No experiments recorded"
	if not _journal_entry_is_known(tab_name, entry_id):
		return "Unknown entry"
	if tab_name == "Recipes" or tab_name == "Materials" or tab_name == "Alchemy":
		return _item_display_name(entry_id)
	if tab_name == "Bestiary":
		return str(_enemy_template(entry_id).get("name", entry_id.capitalize()))
	return entry_id


func _update_journal_detail() -> void:
	if journal_detail_title == null or journal_detail_text == null:
		return
	var entry_id := journal_selected_entry
	if entry_id == "" or entry_id == "__empty__":
		journal_detail_title.text = "No recorded knowledge"
		journal_detail_text.text = "[color=#879086]Experiments and discoveries will be written here automatically.[/color]"
		return
	var known := _journal_entry_is_known(journal_active_tab, entry_id)
	if not known:
		journal_detail_title.text = "Unknown entry"
		journal_detail_text.text = "[color=#777f76]This knowledge has not been discovered yet.[/color]\n\nSearch ruins, observe creatures, collect unfamiliar materials, and conduct experiments."
		return
	journal_detail_title.text = _journal_entry_label(journal_active_tab, entry_id)
	match journal_active_tab:
		"Recipes":
			journal_detail_text.text = _recipe_journal_text(entry_id)
		"Bestiary":
			journal_detail_text.text = _bestiary_journal_text(entry_id)
		"Materials":
			journal_detail_text.text = _material_journal_text(entry_id)
		"Alchemy":
			journal_detail_text.text = _alchemy_journal_text(entry_id)


func _update_journal_progress() -> void:
	if journal_progress_label == null:
		return
	var entries := _journal_entries(journal_active_tab)
	var known_count := 0
	for entry_id in entries:
		if _journal_entry_is_known(journal_active_tab, entry_id):
			known_count += 1
	var total := 0 if entries == ["__empty__"] else entries.size()
	journal_progress_label.text = "%s  |  %d / %d entries" % [journal_active_tab, known_count, total]


func _reset_knowledge() -> void:
	known_recipes.clear()
	bestiary_knowledge.clear()
	material_knowledge.clear()
	alchemy_knowledge.clear()
	for recipe in recipes:
		var recipe_id := str(recipe.get("id", recipe.get("result", "")))
		var station := str(recipe.get("station", "hand"))
		if station == "hand" or recipe_id in ["wooden_pickaxe", "ancient_chest", "furnace"]:
			known_recipes[recipe_id] = true
	for starting_material in ["dirt", "wood"]:
		material_knowledge[starting_material] = {
			"stage": 1,
			"found": int(inventory.get(starting_material, 0))
		}
	journal_unread_count = 0
	journal_observation_timer = 0.0


func _record_recipe_known(recipe_id: String) -> void:
	if recipe_id == "" or bool(known_recipes.get(recipe_id, false)):
		return
	known_recipes[recipe_id] = true
	_mark_journal_updated()


func _update_knowledge_observations(delta: float) -> void:
	journal_observation_timer += delta
	if journal_observation_timer < 0.45:
		return
	journal_observation_timer = 0.0
	for enemy in enemies:
		var enemy_pos: Vector2 = enemy.get("pos", Vector2.ZERO)
		if player_position.distance_to(enemy_pos) > 420.0:
			continue
		if _has_perception_line_of_sight(player_position, enemy_pos):
			_observe_enemy(str(enemy.get("type", "")))


func _observe_enemy(enemy_type: String) -> void:
	if enemy_type == "":
		return
	var record: Dictionary = bestiary_knowledge.get(enemy_type, {"stage": 0, "kills": 0})
	if int(record.get("stage", 0)) >= 1:
		return
	record["stage"] = 1
	bestiary_knowledge[enemy_type] = record
	_mark_journal_updated()


func _record_enemy_kill(enemy_type: String) -> void:
	if enemy_type == "":
		return
	var record: Dictionary = bestiary_knowledge.get(enemy_type, {"stage": 0, "kills": 0})
	var kills := int(record.get("kills", 0)) + 1
	var old_stage := int(record.get("stage", 0))
	record["kills"] = kills
	record["stage"] = 3 if kills >= 3 else 2
	bestiary_knowledge[enemy_type] = record
	if int(record["stage"]) > old_stage:
		_mark_journal_updated()


func _is_journal_material(item_id: String) -> bool:
	if not item_names.has(item_id):
		return false
	if tools.has(item_id) or gear_stats.has(item_id):
		return false
	return item_id not in [
		"workbench", "furnace", "anvil", "settlement_heart", "ancient_chest",
		"stone_altar", "drain_valve", "sapling", "torch"
	]


func _record_material_found(item_id: String, amount: int) -> void:
	if amount <= 0 or not _is_journal_material(item_id):
		return
	var record: Dictionary = material_knowledge.get(item_id, {"stage": 0, "found": 0})
	var old_stage := int(record.get("stage", 0))
	var found := int(record.get("found", 0)) + amount
	record["found"] = found
	record["stage"] = 3 if found >= 15 else (2 if found >= 5 else 1)
	material_knowledge[item_id] = record
	if int(record["stage"]) > old_stage:
		_mark_journal_updated()
	elif journal_open:
		_refresh_journal()


func _record_alchemy_result(result_id: String, ingredients: Dictionary) -> void:
	var record: Dictionary = alchemy_knowledge.get(result_id, {"attempts": 0, "ingredients": {}})
	record["attempts"] = int(record.get("attempts", 0)) + 1
	record["ingredients"] = ingredients.duplicate(true)
	alchemy_knowledge[result_id] = record
	_mark_journal_updated()


func _mark_journal_updated() -> void:
	journal_unread_count += 1
	if journal_open:
		_refresh_journal()


func _recipe_journal_text(recipe_id: String) -> String:
	for recipe in recipes:
		if str(recipe.get("id", "")) != recipe_id:
			continue
		var cost: Dictionary = recipe.get("cost", {})
		return "[color=#ad9a73]CRAFTING STATION[/color]\n%s\n\n[color=#ad9a73]REQUIRED MATERIALS[/color]\n%s\n\n[color=#819783]STATUS[/color]\nRecorded and understood." % [
			_station_display_name(str(recipe.get("station", "hand"))),
			_recipe_cost_text(recipe)
		]
	return "Recipe data is unavailable."


func _bestiary_journal_text(enemy_type: String) -> String:
	var record: Dictionary = bestiary_knowledge.get(enemy_type, {})
	var stage := int(record.get("stage", 0))
	var kills := int(record.get("kills", 0))
	var data := _enemy_template(enemy_type)
	var text := "[color=#ad9a73]HABITAT[/color]\n%s\n\n[color=#819783]RESEARCH[/color]\nStage %d of 4  |  Kills recorded: %d" % [
		_enemy_habitat(enemy_type),
		stage,
		kills
	]
	if stage >= 2:
		var approximate_hp := maxi(5, int(round(float(data.get("max_hp", 10)) / 5.0) * 5.0))
		text += "\n\n[color=#ad9a73]COMBAT OBSERVATION[/color]\nRough vitality: about %d\nKnown damage: %s" % [
			approximate_hp,
			str(data.get("damage_type", "physical")).capitalize()
		]
		var status := str(data.get("status_on_hit", ""))
		if status != "":
			text += "\nKnown effect: %s" % status.capitalize()
	if stage >= 3:
		var profile := _enemy_perception_profile(enemy_type)
		text += "\n\n[color=#ad9a73]BEHAVIOR AND SPOILS[/color]\nCommon drop: %s\nHearing: %s\nLight response: %s" % [
			_item_display_name(str(data.get("drop", "wild_ichor"))),
			_knowledge_rating(float(profile.get("hearing", 1.0))),
			_knowledge_rating(float(profile.get("light_sensitivity", 1.0)))
		]
	if stage < 4:
		text += "\n\n[color=#777f76]Study a trophy to reveal exact resistances and rare spoils.[/color]"
	return text


func _material_journal_text(item_id: String) -> String:
	var record: Dictionary = material_knowledge.get(item_id, {})
	var stage := int(record.get("stage", 0))
	var found := int(record.get("found", 0))
	var text := "[color=#819783]DISCOVERY[/color]\nRecognized material. Samples collected: %d\n\n[color=#ad9a73]APPEARANCE[/color]\nRecorded in the field journal." % found
	if stage >= 2:
		var uses := _recipes_using_material(item_id)
		text += "\n\n[color=#ad9a73]KNOWN USES[/color]\n%s" % (", ".join(uses) if not uses.is_empty() else "No practical use recorded yet.")
	if stage >= 3:
		text += "\n\n[color=#ad9a73]MEASURED PROPERTIES[/color]\nInventory count: %d\nRecipe connections: %d" % [
			int(inventory.get(item_id, 0)),
			_recipes_using_material(item_id).size()
		]
	else:
		text += "\n\n[color=#777f76]Collect more samples to reveal practical and measured properties.[/color]"
	return text


func _alchemy_journal_text(result_id: String) -> String:
	var record: Dictionary = alchemy_knowledge.get(result_id, {})
	var ingredients: Dictionary = record.get("ingredients", {})
	var parts: Array[String] = []
	for item_id in ingredients.keys():
		parts.append("%s x%d" % [_item_display_name(str(item_id)), int(ingredients[item_id])])
	return "[color=#ad9a73]RECORDED RESULT[/color]\n%s\n\n[color=#ad9a73]INGREDIENTS[/color]\n%s\n\n[color=#819783]EXPERIMENTS[/color]\n%d successful preparation(s)." % [
		_item_display_name(result_id),
		", ".join(parts),
		int(record.get("attempts", 0))
	]


func _recipes_using_material(item_id: String) -> Array[String]:
	var uses: Array[String] = []
	for recipe in recipes:
		var cost: Dictionary = recipe.get("cost", {})
		if cost.has(item_id):
			uses.append(_item_display_name(str(recipe.get("result", ""))))
	return uses


func _enemy_habitat(enemy_type: String) -> String:
	if enemy_type in ["wild_slime", "mossling", "root_crawler", "heartwood_boss"]:
		return "Forest surface and root-choked clearings"
	if enemy_type in ["cave_worm", "bat", "cave_husk", "stone_beast"]:
		return "Deep caves and exposed stone chambers"
	if enemy_type in ["spore_bat", "mushroom_beetle"]:
		return "Mushroom halls"
	if enemy_type in ["ash_phantom", "ash_wisp", "ruin_drone", "ash_sentinel"]:
		return "Ash cities and abandoned ruins"
	if enemy_type == "archive_warden":
		return "The sealed Archive beneath the ash city"
	if enemy_type == "drowned_guard":
		return "Sunken ruins"
	if enemy_type in ["ember_rootling", "night_ember"]:
		return "Lava-root depths"
	if enemy_type == "glass_wraith":
		return "Glass abyss"
	if enemy_type in ["brine_lurker", "drowned_leviathan", "sea_leviathan"]:
		return "Deep water of the dead sea, far from either shore"
	return "Habitat not yet classified"


func _knowledge_rating(value: float) -> String:
	if value >= 1.45:
		return "Very high"
	if value >= 1.1:
		return "High"
	if value >= 0.75:
		return "Moderate"
	return "Low"


func _setup_debug_console(canvas: CanvasLayer) -> void:
	debug_console_view = DebugConsoleViewScript.new()
	debug_console_view.setup(canvas, ui_theme_manager)
	debug_console_view.command_submitted.connect(_execute_debug_command)
	debug_console_view.close_requested.connect(_set_debug_console_open.bind(false))
	debug_console_panel = debug_console_view.panel
	debug_console_output = debug_console_view.output
	debug_console_input = debug_console_view.input
	_console_print("Console ready. Type [color=#d8c477]help[/color] for commands.")


func _setup_pause_menu() -> void:
	pause_menu_view = PauseMenuViewScript.new()
	add_child(pause_menu_view)
	pause_menu_view.setup(ui_theme_manager)
	pause_menu_view.resume_requested.connect(_set_pause_menu_open.bind(false))
	pause_menu_view.save_requested.connect(_save_from_pause_menu)
	pause_menu_view.quit_requested.connect(_quit_from_pause_menu)
	pause_menu_view.ui_scale_changed.connect(_set_ui_scale)
	_set_ui_scale(pause_menu_view.ui_scale)


func _set_pause_menu_open(open: bool) -> void:
	pause_menu_open = open
	if pause_menu_view == null:
		return
	if open:
		if debug_console_open:
			_set_debug_console_open(false)
		if journal_open:
			_set_journal_open(false)
		inventory_open = false
		_close_chest()
		if full_map_open:
			_set_full_map_open(false)
		physical_move_left_held = false
		physical_move_right_held = false
		mouse_mine_held = false
		Input.action_release("mine")
		Input.action_release("attack")
	pause_menu_view.set_open(open)
	get_tree().paused = open
	if not open:
		_update_hud()


func _save_from_pause_menu() -> void:
	_save_game()
	pause_menu_view.show_saved_message()


func _quit_from_pause_menu() -> void:
	get_tree().paused = false
	get_tree().quit()


func _set_ui_scale(scale: float) -> void:
	get_window().content_scale_factor = scale


func _set_debug_console_open(open: bool) -> void:
	debug_console_open = open
	if debug_console_panel == null:
		return
	physical_move_left_held = false
	physical_move_right_held = false
	physical_noclip_up_held = false
	physical_noclip_down_held = false
	mouse_mine_held = false
	Input.action_release("mine")
	Input.action_release("attack")
	if open:
		inventory_open = false
		_set_full_map_open(false)
	debug_console_view.set_open(open)
	_update_mobile_controls_visibility()


func _refocus_debug_console_input() -> void:
	if debug_console_view != null:
		debug_console_view.refocus()


func _console_print(message: String) -> void:
	if debug_console_view != null:
		debug_console_view.print_line(message)


func _execute_debug_command(command_line: String) -> void:
	var parts := command_line.split(" ", false)
	if parts.is_empty():
		return
	var command := str(parts[0]).to_lower()
	if command in ["help", "помощь"]:
		_console_print("[color=#d8c477]give <item_id> [count][/color] - give an item")
		_console_print("[color=#d8c477]give_all [count][/color] - give every item")
		_console_print("[color=#d8c477]spawn <mob_id> [count][/color] - summon creatures")
		_console_print("[color=#d8c477]nodes[/color] / [color=#d8c477]node <fungal|sunken|ash>[/color] - visit memory nodes")
		_console_print("[color=#d8c477]archive[/color] - visit the Archive Console")
		_console_print("[color=#d8c477]items [filter][/color] / [color=#d8c477]mobs[/color] - show IDs")
		_console_print("[color=#d8c477]noclip [on/off][/color] - collisions and flight; double Space toggles it")
		_console_print("[color=#d8c477]god [on/off][/color] - immortality")
		_console_print("[color=#d8c477]temp [value][/color] - inspect or set body temperature")
		_console_print("[color=#d8c477]perception [on/off][/color] - show vision, noise and AI states")
		_console_print("[color=#d8c477]noise [radius][/color] - emit a test noise at the player")
		_console_print("[color=#d8c477]learn all[/color] / [color=#d8c477]learn <recipe_id>[/color] - discover recipes")
		_console_print("[color=#d8c477]weather [type][/color] - inspect or force the weather")
		_console_print("[color=#d8c477]killall[/color], [color=#d8c477]clear[/color]")
		return
	if command in ["clear", "очистить"]:
		debug_console_output.clear()
		return
	if command in ["items", "предметы"]:
		var filter := str(parts[1]).to_lower() if parts.size() > 1 else ""
		var ids: Array[String] = []
		for item_id in item_names.keys():
			if filter == "" or str(item_id).contains(filter) or _item_display_name(str(item_id)).to_lower().contains(filter):
				ids.append(str(item_id))
		ids.sort()
		_console_print(", ".join(ids))
		return
	if command in ["mobs", "enemies", "мобы", "существа"]:
		var ids: Array[String] = []
		for enemy_id in enemy_sprite_specs.keys():
			ids.append(str(enemy_id))
		ids.sort()
		_console_print(", ".join(ids))
		return
	if command in ["give_all", "all_items", "все_предметы"]:
		var amount := clampi(int(parts[1]) if parts.size() > 1 and str(parts[1]).is_valid_int() else 99, 1, 9999)
		for item_id in item_names.keys():
			_add_item(str(item_id), amount)
		_console_print("[color=#82d49a]Added every item x%d.[/color]" % amount)
		return
	if command in ["give", "item", "предмет"]:
		if parts.size() < 2:
			_console_print("[color=#e68a78]Usage: give <item_id> [count][/color]")
			return
		var item_id := str(parts[1]).to_lower()
		if item_id in ["all", "все"]:
			var all_amount := clampi(int(parts[2]) if parts.size() > 2 and str(parts[2]).is_valid_int() else 99, 1, 9999)
			for all_item_id in item_names.keys():
				_add_item(str(all_item_id), all_amount)
			_console_print("[color=#82d49a]Added every item x%d.[/color]" % all_amount)
			return
		if not item_names.has(item_id):
			_console_print("[color=#e68a78]Unknown item: %s. Use items.[/color]" % item_id)
			return
		var amount := clampi(int(parts[2]) if parts.size() > 2 and str(parts[2]).is_valid_int() else 1, 1, 9999)
		_add_item(item_id, amount)
		_console_print("[color=#82d49a]Added %s x%d.[/color]" % [_item_display_name(item_id), amount])
		return
	if command in ["spawn", "summon", "призвать"]:
		if parts.size() < 2:
			_console_print("[color=#e68a78]Usage: spawn <mob_id> [count][/color]")
			return
		var enemy_id := str(parts[1]).to_lower()
		var count := clampi(int(parts[2]) if parts.size() > 2 and str(parts[2]).is_valid_int() else 1, 1, 20)
		if enemy_id in ["all", "все"]:
			for all_enemy_id in enemy_sprite_specs.keys():
				_spawn_debug_enemy(str(all_enemy_id), 1)
			_console_print("[color=#82d49a]Summoned every creature.[/color]")
			return
		if not enemy_sprite_specs.has(enemy_id):
			_console_print("[color=#e68a78]Unknown creature: %s. Use mobs.[/color]" % enemy_id)
			return
		_spawn_debug_enemy(enemy_id, count)
		_console_print("[color=#82d49a]Summoned %s x%d.[/color]" % [enemy_id, count])
		return
	if command in ["node", "nodes", "memory_node", "find_node"]:
		var requested_node := str(parts[1]).to_lower() if parts.size() > 1 else "next"
		_debug_visit_memory_node(requested_node)
		return
	if command in ["archive", "archive_console", "find_archive"]:
		_debug_visit_archive_site()
		return
	if command in ["weather", "погода"]:
		if parts.size() < 2:
			_console_print("[color=#d8c477]Current: %s (%d%%)[/color]" % [
				_weather_display_name(weather), int(_weather_strength() * 100.0)])
			_console_print("[color=#d8c477]weather <clear|rain|storm|blizzard|ashfall|fog>[/color]")
			return
		var wanted := str(parts[1]).to_lower()
		if wanted != WEATHER_CLEAR and not WEATHER_TYPES.has(wanted):
			_console_print("[color=#e68a78]Unknown weather: %s[/color]" % wanted)
			return
		_start_weather(wanted, 240.0)
		weather_intensity = weather_target_intensity
		_console_print("[color=#82d49a]Weather set to %s.[/color]" % _weather_display_name(wanted))
		return
	if command in ["killall", "kill_all", "убить_всех"]:
		enemies.clear()
		enemy_projectiles.clear()
		enemy_impact_effects.clear()
		_console_print("[color=#82d49a]All creatures removed.[/color]")
		return
	if command in ["noclip", "ноклип"]:
		noclip_unlocked = true
		var next_value := _debug_toggle_value(parts, noclip_enabled)
		_set_noclip_enabled(next_value)
		return
	if command in ["god", "immortal", "бессмертие"]:
		god_mode_enabled = _debug_toggle_value(parts, god_mode_enabled)
		if god_mode_enabled:
			health = MAX_HEALTH
			player_statuses.clear()
			_console_print("[color=#82d49a]God mode enabled.[/color]")
		else:
			_console_print("[color=#d8c477]God mode disabled.[/color]")
		return
	if command in ["temp", "temperature"]:
		if parts.size() > 1:
			var requested_temperature := str(parts[1])
			if not requested_temperature.is_valid_float():
				_console_print("[color=#e68a78]Usage: temp [value][/color]")
				return
			body_temperature = clampf(float(requested_temperature), MIN_BODY_TEMPERATURE, MAX_BODY_TEMPERATURE)
			temperature_visual_state = ""
		_console_print("[color=#82d49a]Body %.1f C | ambient %.1f C | cold %d%% | heat %d%%[/color]" % [
			body_temperature,
			ambient_temperature,
			int(round(_temperature_protection("cold_protection") * 100.0)),
			int(round(_temperature_protection("heat_protection") * 100.0))
		])
		return
	if command in ["perception", "ai_debug", "perception_debug"]:
		perception_debug_enabled = _debug_toggle_value(parts, perception_debug_enabled)
		_console_print("[color=#82d49a]Perception debug %s.[/color]" % ("enabled" if perception_debug_enabled else "disabled"))
		return
	if command in ["noise", "make_noise"]:
		var radius := clampf(float(parts[1]) if parts.size() > 1 and str(parts[1]).is_valid_float() else 180.0, 20.0, 600.0)
		_emit_noise(player_position, radius, "debug", 1.0)
		_console_print("[color=#82d49a]Noise emitted: radius %.0f.[/color]" % radius)
		return
	if command in ["learn", "knowledge", "research"]:
		if parts.size() < 2:
			_console_print("[color=#e68a78]Usage: learn all | learn <recipe_id>[/color]")
			return
		var recipe_id := str(parts[1]).to_lower()
		if recipe_id == "all":
			var learned_count := _learn_all_recipes()
			_console_print("[color=#82d49a]Learned %d recipe(s).[/color]" % learned_count)
			return
		if not _recipe_id_exists(recipe_id):
			_console_print("[color=#e68a78]Unknown recipe: %s.[/color]" % recipe_id)
			return
		var was_known := bool(known_recipes.get(recipe_id, false))
		_record_recipe_known(recipe_id)
		_ensure_selected_recipe_known()
		_update_hud()
		_console_print("[color=#82d49a]%s recipe: %s.[/color]" % [
			"Already knew" if was_known else "Learned",
			_item_display_name(recipe_id)
		])
		return
	_console_print("[color=#e68a78]Unknown command: %s. Type help.[/color]" % command)


func _debug_toggle_value(parts: PackedStringArray, current: bool) -> bool:
	if parts.size() < 2:
		return not current
	var value := str(parts[1]).to_lower()
	if value in ["on", "1", "true", "вкл", "включить"]:
		return true
	if value in ["off", "0", "false", "выкл", "выключить"]:
		return false
	return not current


func _set_noclip_enabled(enabled: bool) -> void:
	noclip_enabled = enabled
	player_velocity = Vector2.ZERO
	landing_speed = 0.0
	if enabled:
		_console_print("[color=#82d49a]Noclip enabled. WASD/Arrows move, Space/W goes up, S goes down.[/color]")
	else:
		_console_print("[color=#d8c477]Noclip disabled.[/color]")


func _spawn_debug_enemy(enemy_id: String, count: int) -> void:
	var template := _enemy_template(enemy_id)
	var flying := bool(template.get("flying", false))
	var size: Vector2 = template.get("size", Vector2(16, 16))
	for index in range(count):
		var side := -1 if index % 2 == 0 else 1
		var distance := 52.0 + float(index / 2) * 22.0
		var spawn_pos := player_position + Vector2(float(side) * distance, -40.0 if flying else -8.0)
		if not flying:
			spawn_pos = _find_spawn_position_near_player(3 + index, 7 + index, false, size)
		_spawn_enemy(enemy_id, spawn_pos)


func _debug_visit_memory_node(requested_kind: String) -> void:
	if memory_nodes.is_empty():
		_console_print("[color=#e68a78]No memory nodes exist in this world.[/color]")
		return
	var target_index := -1
	if requested_kind in ["", "next"]:
		debug_memory_node_index = wrapi(debug_memory_node_index + 1, 0, memory_nodes.size())
		target_index = debug_memory_node_index
	else:
		for index in range(memory_nodes.size()):
			var node: Dictionary = memory_nodes[index]
			if str(node.get("kind", "")).to_lower() == requested_kind:
				target_index = index
				break
	if target_index < 0:
		_console_print("[color=#e68a78]Unknown node: %s. Use fungal, sunken, ash, or next.[/color]" % requested_kind)
		return
	debug_memory_node_index = target_index
	var target_node: Dictionary = memory_nodes[target_index]
	var tile_pos: Vector2i = target_node.get("tile_pos", Vector2i.ZERO)
	player_position = Vector2(
		(float(tile_pos.x) + 0.5) * TILE_SIZE,
		(float(tile_pos.y) + 1.0) * TILE_SIZE - PLAYER_SIZE.y * 0.5 - 1.0
	)
	player_velocity = Vector2.ZERO
	landing_speed = 0.0
	_reveal_player_surroundings()
	_update_camera()
	var node_kind := str(target_node.get("kind", "memory"))
	var node_state := str(target_node.get("state", "dormant"))
	last_message = "Located %s Memory Node." % node_kind.capitalize()
	_console_print("[color=#82d49a]%s node: tile %d, %d | %s[/color]" % [
		node_kind.capitalize(), tile_pos.x, tile_pos.y, node_state
	])


func _debug_visit_archive_site() -> void:
	if archive_site.is_empty():
		_console_print("[color=#e68a78]The Archive site does not exist in this world.[/color]")
		return
	var console_tile: Vector2i = archive_site.get("console_tile", Vector2i.ZERO)
	var arrival_tile := console_tile + Vector2i(-3, 0)
	player_position = Vector2(
		(float(arrival_tile.x) + 0.5) * TILE_SIZE,
		(float(console_tile.y) + 1.0) * TILE_SIZE - PLAYER_SIZE.y * 0.5 - 1.0
	)
	player_velocity = Vector2.ZERO
	landing_speed = 0.0
	_reveal_player_surroundings()
	_update_camera()
	last_message = "Located the Archive Console."
	_console_print("[color=#82d49a]Archive Console: tile %d, %d | console %s | gate %s[/color]" % [
		console_tile.x,
		console_tile.y,
		str(archive_site.get("console_state", "idle")),
		str(archive_site.get("gate_state", "closed"))
	])


func _setup_mobile_controls(canvas: CanvasLayer) -> void:
	mobile_controls = Control.new()
	mobile_controls.name = "MobileControls"
	mobile_controls.set_anchors_preset(Control.PRESET_FULL_RECT)
	mobile_controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_controls.visible = mobile_ui_enabled
	mobile_controls.z_index = 40
	canvas.add_child(mobile_controls)

	mobile_gameplay_controls = Control.new()
	mobile_gameplay_controls.name = "MobileGameplayControls"
	mobile_gameplay_controls.set_anchors_preset(Control.PRESET_FULL_RECT)
	mobile_gameplay_controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_controls.add_child(mobile_gameplay_controls)

	var left_group := Control.new()
	left_group.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	left_group.offset_left = 78
	left_group.offset_top = -220
	left_group.offset_right = 250
	left_group.offset_bottom = -48
	left_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_gameplay_controls.add_child(left_group)
	var joystick := Control.new()
	joystick.set_script(VIRTUAL_JOYSTICK_SCRIPT)
	joystick.position = Vector2(0, 0)
	joystick.size = Vector2(172, 172)
	left_group.add_child(joystick)

	var right_group := Control.new()
	right_group.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	right_group.offset_left = -342
	right_group.offset_top = -286
	right_group.offset_right = -28
	right_group.offset_bottom = -28
	right_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_gameplay_controls.add_child(right_group)
	_add_mobile_hold_button(right_group, "JUMP", Vector2(0, 116), "jump", "Jump", Vector2(132, 132), true)
	_add_mobile_tap_button(right_group, "ATK", Vector2(160, 0), _mobile_attack_button_pressed, "Attack", Vector2(136, 136), true)

	var top_group := Control.new()
	top_group.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	top_group.offset_left = -396
	top_group.offset_top = 14
	top_group.offset_right = -328
	top_group.offset_bottom = 66
	top_group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_controls.add_child(top_group)
	_add_mobile_tap_button(top_group, "INV", Vector2.ZERO, _toggle_inventory_from_ui, "Inventory", Vector2(68, 52))


func _add_mobile_hold_button(parent: Control, text: String, position: Vector2, action: StringName, tooltip: String, size := Vector2(68, 68), circular := false) -> void:
	var button := _make_mobile_button(text, position, size, tooltip, circular)
	button.button_down.connect(_mobile_action_down.bind(action))
	button.button_up.connect(_mobile_action_up.bind(action))
	button.mouse_exited.connect(_mobile_action_up.bind(action))
	parent.add_child(button)


func _add_mobile_tap_button(parent: Control, text: String, position: Vector2, callback: Callable, tooltip: String, size := Vector2(68, 58), circular := false) -> void:
	var button := _make_mobile_button(text, position, size, tooltip, circular)
	button.pressed.connect(callback)
	parent.add_child(button)


func _make_mobile_button(text: String, position: Vector2, size: Vector2, tooltip: String, circular := false) -> Button:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = size
	button.custom_minimum_size = size
	button.tooltip_text = tooltip
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 15)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("111821", 0.70)
	normal.border_color = Color("9bb3bc", 0.78)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(int(minf(size.x, size.y) * 0.5) if circular else 6)
	button.add_theme_stylebox_override("normal", normal)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("d0a84c", 0.88)
	pressed.border_color = Color("ffe39a")
	button.add_theme_stylebox_override("pressed", pressed)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("263443", 0.82)
	button.add_theme_stylebox_override("hover", hover)
	return button


func _mobile_action_down(action: StringName) -> void:
	Input.action_press(action)


func _mobile_action_up(action: StringName) -> void:
	Input.action_release(action)


func _release_mobile_actions() -> void:
	mobile_world_touch_index = -1
	for action in [&"move_left", &"move_right", &"jump", &"mine", &"place", &"attack"]:
		Input.action_release(action)


func _toggle_inventory_from_ui() -> void:
	if full_map_open:
		_set_full_map_open(false)
	inventory_open = not inventory_open
	if not inventory_open:
		_close_chest()
	_update_mobile_controls_visibility()


func _toggle_map_from_ui() -> void:
	_set_full_map_open(not full_map_open)


func _on_minimap_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
			_toggle_map_from_ui()
			minimap_panel.accept_event()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_toggle_map_from_ui()
			minimap_panel.accept_event()


func _mobile_attack_button_pressed() -> void:
	_try_player_attack_at(player_position + Vector2(float(facing) * 100.0, 0.0))


func _mobile_controls_enabled() -> bool:
	return mobile_ui_enabled


func _set_full_map_open(open: bool) -> void:
	full_map_open = open
	if full_map_panel != null:
		full_map_panel.visible = open
	if full_map_backdrop != null:
		full_map_backdrop.visible = open
	if open:
		inventory_open = false
		_close_chest()
		_release_mobile_actions()
		_refresh_map_textures()
	_update_mobile_controls_visibility()


func _update_mobile_controls_visibility() -> void:
	if mobile_controls != null:
		mobile_controls.visible = mobile_ui_enabled and not full_map_open and not journal_open and not debug_console_open
	if mobile_gameplay_controls != null:
		mobile_gameplay_controls.visible = mobile_ui_enabled and not full_map_open and not inventory_open and not journal_open and not debug_console_open
		if not mobile_gameplay_controls.visible:
			_release_mobile_actions()


func _play_sound(sound_name: String) -> void:
	if audio_manager != null:
		audio_manager.play(sound_name)


func _make_hud_panel(position: Vector2, size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.offset_left = position.x
	panel.offset_top = position.y
	panel.offset_right = position.x + size.x
	panel.offset_bottom = position.y + size.y
	panel.add_theme_stylebox_override("panel", ui_theme_manager.panel_style("main", 10.0))
	return panel


func _make_compass_clear_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", ui_theme_manager.panel_style("dark", 10.0))
	return panel


func _make_compass_map_frame() -> PanelContainer:
	var panel := _make_compass_clear_panel()
	panel.add_theme_stylebox_override("panel", ui_theme_manager.panel_style("main", 9.0))
	return panel


func _make_compass_progress_bar(fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.show_percentage = false
	var kind := "generic"
	if fill_color.r > fill_color.g * 1.25:
		kind = "health"
	elif fill_color.g > fill_color.r and fill_color.g > fill_color.b:
		kind = "stamina"
	elif fill_color.b > fill_color.r:
		kind = "mana"
	ui_theme_manager.apply_progress_bar(bar, kind, fill_color)
	return bar


func _apply_compass_hotbar_slot_style(button: Button, selected: bool) -> void:
	ui_theme_manager.apply_slot(button, selected, button.icon != null, button.disabled and button.icon != null)


func _make_compass_action_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(106, 32)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 9)
	ui_theme_manager.apply_button(button)
	return button


func _apply_compass_inventory_slot_style(button: Button, selected: bool, equipment := false) -> void:
	ui_theme_manager.apply_slot(button, selected, button.icon != null, false)


func _make_slot_button() -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	button.focus_mode = Control.FOCUS_NONE
	button.expand_icon = true
	button.add_theme_font_size_override("font_size", 10)
	_apply_slot_style(button, false)
	return button


func _apply_slot_style(button: Button, selected: bool) -> void:
	ui_theme_manager.apply_slot(button, selected, button.icon != null, false)


func _setup_input_actions() -> void:
	_ensure_key_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_key_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_key_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_ensure_key_action("regen_world", [KEY_R])
	_ensure_key_action("save_world", [KEY_F5])
	_ensure_key_action("load_world", [KEY_F9])
	_ensure_key_action("toggle_inventory", [KEY_TAB, KEY_I])
	_ensure_key_action("toggle_map", [KEY_M])
	_ensure_key_action("toggle_journal", [KEY_J])
	_ensure_key_action("recipe_prev", [KEY_Z])
	_ensure_key_action("recipe_next", [KEY_X])
	_ensure_key_action("craft_item", [KEY_C])
	_ensure_key_action("equip_item", [KEY_E])
	_ensure_key_action("attack", [KEY_F])
	_ensure_key_action("hotbar_1", [KEY_1])
	_ensure_key_action("hotbar_2", [KEY_2])
	_ensure_key_action("hotbar_3", [KEY_3])
	_ensure_key_action("hotbar_4", [KEY_4])
	_ensure_key_action("hotbar_5", [KEY_5])
	_ensure_mouse_action("mine", MOUSE_BUTTON_LEFT)
	_ensure_mouse_action("place", MOUSE_BUTTON_RIGHT)
	_ensure_mouse_action("zoom_in", MOUSE_BUTTON_WHEEL_UP)
	_ensure_mouse_action("zoom_out", MOUSE_BUTTON_WHEEL_DOWN)


func _ensure_key_action(action: StringName, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for keycode in keycodes:
		var exists := false
		for event in InputMap.action_get_events(action):
			if event is InputEventKey and event.keycode == keycode:
				exists = true
				break
		if exists:
			continue
		var key_event := InputEventKey.new()
		key_event.keycode = keycode
		InputMap.action_add_event(action, key_event)


func _ensure_mouse_action(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventMouseButton and event.button_index == button:
			return
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = button
	InputMap.action_add_event(action, mouse_event)


func _generate_world() -> void:
	world_generation_in_progress = true
	if liquid_sim != null:
		liquid_sim.clear()
	seed = int(Time.get_unix_time_from_system()) % 1000000000
	rng.seed = seed
	_reset_inventory()
	health = MAX_HEALTH
	oxygen = MAX_OXYGEN
	body_temperature = NORMAL_BODY_TEMPERATURE
	ambient_temperature = 20.0
	temperature_sample_timer = 0.0
	temperature_damage_tick = 0.0
	temperature_visual_state = ""
	drowning_tick = 0.0
	lava_tick = 0.0
	sapling_growth_timer = 0.0
	enemies.clear()
	dying_enemies.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	enemy_impact_effects.clear()
	perception_noise_events.clear()
	dropped_items.clear()
	damage_numbers.clear()
	hit_particles.clear()
	loot_notifications.clear()
	attack_anim_time = 0.0
	attack_anim_kind = ""
	held_item_id = ""
	held_item_amount = 0
	world_time = 28.0
	weather = WEATHER_CLEAR
	weather_timer = rng.randf_range(45.0, 120.0)
	weather_intensity = 0.0
	weather_target_intensity = 0.0
	lightning_timer = 0.0
	lightning_flash = 0.0
	weather_particles.clear()
	defeated_enemies = 0
	boss_spawned = false
	boss_defeated = false
	stone_broken_count = 0
	stone_beast_spawned = false
	stone_beast_defeated = false
	archive_warden_spawned = false
	archive_warden_defeated = false
	mushroom_path_opened = false
	leviathan_story_unlocked = false
	last_biome = ""
	player_statuses.clear()
	mining_progress = 0.0
	mining_target = Vector2i(-999, -999)
	world.clear()
	surface_heights.clear()
	surface_biomes.clear()
	border_distances.clear()
	border_neighbors.clear()
	chest_loot.clear()
	memory_nodes.clear()
	archive_site.clear()
	debug_memory_node_index = -1
	sapling_positions.clear()
	tree_tile_owners.clear()
	next_tree_id = 1
	_reset_knowledge()
	biome_check_timer = 0.0
	hud_update_timer = 0.0

	var height_noise := FastNoiseLite.new()
	height_noise.seed = seed
	height_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	height_noise.frequency = 0.018
	height_noise.fractal_octaves = 4

	var cave_noise := FastNoiseLite.new()
	cave_noise.seed = seed + 1009
	cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	cave_noise.frequency = 0.055
	cave_noise.fractal_octaves = 3

	var ore_noise := FastNoiseLite.new()
	ore_noise.seed = seed + 2027
	ore_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	ore_noise.frequency = 0.105
	ore_noise.fractal_octaves = 2

	for x in range(WORLD_WIDTH):
		var h := int(44 + height_noise.get_noise_1d(float(x)) * 12.0 + sin(float(x) * 0.035) * 5.0)
		h = clampi(h, 24, 66)
		# Near the map edge the ground bends down into a dead sea, so the world
		# ends in a shoreline instead of an invisible wall.
		h = _apply_edge_falloff(x, h)
		surface_heights.append(h)
	_build_surface_biome_map()

	for y in range(WORLD_HEIGHT):
		var row: Array[int] = []
		for x in range(WORLD_WIDTH):
			row.append(_pick_base_tile(x, y, cave_noise, ore_noise))
		world.append(row)

	_carve_spawn_area()
	_add_cave_networks()
	_add_biomes()
	_add_ash_pockets()
	_add_cave_structures()
	_add_landmark_structures()
	_add_cave_decorations()
	_add_trees()
	_add_roots()
	_add_ruins()
	_place_generated_memory_nodes()
	_place_archive_site()
	_stabilize_generated_chests()
	world_generation_in_progress = false
	if liquid_sim != null:
		liquid_sim.rebuild(world)
	_spawn_player()
	_reset_exploration()
	_reveal_player_surroundings()
	cached_biome = _compute_current_biome()
	_update_minimap(999.0)


func _reset_inventory() -> void:
	inventory.clear()
	inventory["wooden_pickaxe"] = 1
	inventory["builder_hammer"] = 1
	inventory["dirt"] = 24
	inventory["wood"] = 12
	current_tool = "wooden_pickaxe"
	hotbar = ["wooden_pickaxe", "dirt", "stone", "wood", "workbench"]
	selected_slot = 0
	selected_block = Tile.DIRT
	selected_recipe_index = 0
	equipped_weapon = ""
	equipped_armor = ""
	equipped_helmet = ""
	equipped_legs = ""
	equipped_boots = ""
	equipped_accessory = ""
	selected_inventory_item_id = ""
	last_message = "Gather wood and stone, then craft a workbench."


func _build_surface_biome_map() -> void:
	surface_biomes.clear()
	topsoil_noise = FastNoiseLite.new()
	topsoil_noise.seed = seed + 2791
	topsoil_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	topsoil_noise.frequency = 0.085
	topsoil_noise.fractal_octaves = 2
	_setup_transition_noise()
	var biome_noise := FastNoiseLite.new()
	biome_noise.seed = seed + 6143
	biome_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	biome_noise.frequency = 0.012
	biome_noise.fractal_octaves = 2
	var layout_rng := RandomNumberGenerator.new()
	layout_rng.seed = seed + 9127
	# Wide bands make each biome a real region instead of a tiny strip. The band
	# count is rolled first, then widths jitter around the average and get
	# nudged one tile at a time until they cover the world exactly. This keeps
	# every band inside the min/max range, including the last one.
	var band_count := layout_rng.randi_range(7, 9)
	var average_width := int(WORLD_WIDTH / band_count)
	var widths: Array[int] = []
	var width_sum := 0
	for i in range(band_count):
		var width := clampi(
			layout_rng.randi_range(average_width - 40, average_width + 40),
			SURFACE_BAND_MIN_WIDTH,
			SURFACE_BAND_MAX_WIDTH
		)
		widths.append(width)
		width_sum += width
	var adjust_index := 0
	while width_sum != WORLD_WIDTH:
		if width_sum < WORLD_WIDTH and widths[adjust_index] < SURFACE_BAND_MAX_WIDTH:
			widths[adjust_index] += 1
			width_sum += 1
		elif width_sum > WORLD_WIDTH and widths[adjust_index] > SURFACE_BAND_MIN_WIDTH:
			widths[adjust_index] -= 1
			width_sum -= 1
		adjust_index = (adjust_index + 1) % band_count
	var band_ends: Array[int] = []
	var covered := 0
	for width in widths:
		covered += width
		band_ends.append(covered)
	var spawn_x := int(WORLD_WIDTH / 2)
	var spawn_band := band_ends.size() - 1
	for i in range(band_ends.size()):
		var band_start := 0 if i == 0 else band_ends[i - 1]
		if spawn_x >= band_start and spawn_x < band_ends[i]:
			spawn_band = i
			break
	var band_biomes := _assign_band_biomes(band_ends.size(), spawn_band, layout_rng)
	var band_index := 0
	for x in range(WORLD_WIDTH):
		# Noise nudges band borders so transitions weave instead of forming a flat
		# vertical line. The band index only moves forward, which keeps one-column
		# biome pockets from appearing along the border.
		var border_wobble := int(round(biome_noise.get_noise_1d(float(x)) * 18.0))
		while band_index < band_ends.size() - 1 and x >= band_ends[band_index] + border_wobble:
			band_index += 1
		var column_biome: String = band_biomes[band_index]
		# The spawn corridor is always forest, independent of the world seed.
		if abs(x - spawn_x) <= 42:
			column_biome = "forest"
		surface_biomes.append(column_biome)
	_rebuild_border_metadata()


func _setup_transition_noise() -> void:
	# Pocket noise: breaks the transition into clumps a few tiles across.
	# Fractal octaves give the clumps ragged edges instead of round blobs.
	transition_noise = FastNoiseLite.new()
	transition_noise.seed = seed + 5511
	transition_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	transition_noise.frequency = 0.14
	transition_noise.fractal_octaves = 3
	transition_noise.fractal_gain = 0.62
	# Meander noise: shifts the whole seam sideways as it descends, so the
	# border is a wandering line rather than a dithered vertical cut.
	border_meander_noise = FastNoiseLite.new()
	border_meander_noise.seed = seed + 7723
	border_meander_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	border_meander_noise.frequency = 0.035
	border_meander_noise.fractal_octaves = 2


func _border_meander_offset(x: int, y: int) -> float:
	# Low-frequency horizontal drift of the seam, sampled per depth so the
	# border snakes as it goes down instead of running straight.
	if border_meander_noise == null:
		return 0.0
	var drift := border_meander_noise.get_noise_2d(float(x) * 0.35, float(y))
	return drift * SURFACE_BORDER_MEANDER


func _biomes_conflict(first: String, second: String) -> bool:
	# The ash desert and the frost wasteland are climate opposites, so a world
	# never puts them in touching bands.
	if first == "ash_desert" and second == "frost_wasteland":
		return true
	return first == "frost_wasteland" and second == "ash_desert"


func _band_assignment_is_valid(band_biomes: Array[String], spawn_band: int) -> bool:
	for i in range(band_biomes.size()):
		if i == spawn_band and band_biomes[i] != "forest":
			return false
		if i == 0:
			continue
		var previous: String = band_biomes[i - 1]
		var current: String = band_biomes[i]
		# Two identical bands in a row would read as one huge region.
		if previous == current:
			return false
		if _biomes_conflict(previous, current):
			return false
	return true


func _assign_band_biomes(
	band_count: int, spawn_band: int, layout_rng: RandomNumberGenerator
) -> Array[String]:
	# Every world contains all five biome types, so one of each goes into the
	# pool first and the leftover slots are filled at random. Shuffles that
	# break the neighbour rules are rerolled rather than patched, which keeps
	# the result unbiased and always legal.
	for attempt in range(SURFACE_BAND_LAYOUT_ATTEMPTS):
		var pool: Array[String] = []
		for biome in SURFACE_BAND_BIOMES:
			if biome == "forest":
				# The pinned spawn band already covers the forest requirement.
				continue
			pool.append(biome)
		while pool.size() < band_count - 1:
			pool.append(SURFACE_BAND_BIOMES[layout_rng.randi_range(0, SURFACE_BAND_BIOMES.size() - 1)])
		for i in range(pool.size() - 1, 0, -1):
			var swap_index := layout_rng.randi_range(0, i)
			var swapped: String = pool[i]
			pool[i] = pool[swap_index]
			pool[swap_index] = swapped
		var band_biomes: Array[String] = []
		var pool_index := 0
		for i in range(band_count):
			if i == spawn_band:
				band_biomes.append("forest")
				continue
			band_biomes.append(pool[pool_index])
			pool_index += 1
		if _band_assignment_is_valid(band_biomes, spawn_band):
			return band_biomes
	return _fallback_band_biomes(band_count, spawn_band)


func _fallback_band_biomes(band_count: int, spawn_band: int) -> Array[String]:
	# Deterministic safety net: cycling the fallback order never repeats a
	# biome and never places the ash desert next to the frost wasteland.
	var band_biomes: Array[String] = []
	var cycle_index := 0
	for i in range(band_count):
		if i == spawn_band:
			band_biomes.append("forest")
			continue
		band_biomes.append(SURFACE_BAND_FALLBACK_ORDER[cycle_index % SURFACE_BAND_FALLBACK_ORDER.size()])
		cycle_index += 1
	return band_biomes


func _rebuild_border_metadata() -> void:
	# Distance to the nearest biome seam per column, together with the biome on
	# the far side of that seam. Both feed the blended border strips.
	border_distances.clear()
	border_neighbors.clear()
	var width := surface_biomes.size()
	if width == 0:
		return
	for i in range(width):
		border_distances.append(width)
		border_neighbors.append("")
	var seams: Array[int] = []
	for x in range(1, width):
		if surface_biomes[x] != surface_biomes[x - 1]:
			seams.append(x)
	for seam in seams:
		var left_biome: String = surface_biomes[seam - 1]
		var right_biome: String = surface_biomes[seam]
		# The seam sits between seam - 1 and seam, so distance 0 means the
		# column directly touches the other biome.
		for offset in range(SURFACE_BORDER_BLEND):
			var left_x := seam - 1 - offset
			if left_x >= 0 and offset < border_distances[left_x]:
				border_distances[left_x] = offset
				border_neighbors[left_x] = right_biome
			var right_x := seam + offset
			if right_x < width and offset < border_distances[right_x]:
				border_distances[right_x] = offset
				border_neighbors[right_x] = left_biome


func _blended_biome_at(x: int, y: int, biome: String) -> String:
	# Inside the blend strip the two neighbouring biomes trade clustered
	# pockets, and the seam itself meanders with depth, so the border reads as
	# a ragged interlocking zone instead of one vertical line.
	if border_distances.size() != surface_biomes.size() or transition_noise == null:
		return biome
	if x < 0 or x >= border_distances.size():
		return biome
	var distance: int = border_distances[x]
	if distance >= SURFACE_BORDER_BLEND:
		return biome
	var neighbor: String = border_neighbors[x]
	if neighbor.is_empty() or neighbor == biome:
		return biome
	# Meandering pushes the effective seam sideways per row: a positive offset
	# pulls the neighbour deeper into this biome, a negative one holds it back.
	var effective_distance := float(distance) - _border_meander_offset(x, y)
	if effective_distance >= float(SURFACE_BORDER_BLEND):
		return biome
	# Past the wandering seam the neighbour simply owns the tile; otherwise the
	# odds fade from 50/50 on the seam to a pure biome at the edge of the strip.
	var takes_neighbor := effective_distance < 0.0
	if not takes_neighbor:
		var own_chance := 0.5 + 0.5 * (effective_distance / float(SURFACE_BORDER_BLEND))
		var pocket := transition_noise.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
		takes_neighbor = pocket > own_chance
	return neighbor if takes_neighbor else biome


func _visual_biome_at(x: int, y: int) -> String:
	# Palette lookup for rendering. It runs the same blend as terrain
	# generation so tinting cannot draw a hard seam over blended ground.
	return _blended_biome_at(x, y, _surface_biome_at_column(x))


func _topsoil_depth_at_column(x: int, biome: String) -> int:
	var noise_value := 0.0
	if topsoil_noise != null:
		noise_value = topsoil_noise.get_noise_1d(float(x))
	# Every biome gets its own topsoil depth profile, from the thin frozen crust
	# of the wasteland to the deep drifts of the ash desert.
	match biome:
		"ash_desert":
			return maxi(4, 8 + int(round(noise_value * 4.0)))
		"marsh":
			return maxi(2, 5 + int(round(noise_value * 3.0)))
		"frost_wasteland":
			return maxi(2, 4 + int(round(noise_value * 3.0)))
		"ash_ruins":
			return maxi(2, 4 + int(round(noise_value * 3.0)))
		_:
			return maxi(2, 5 + int(round(noise_value * 3.0)))


func _scaled_count(base: int) -> int:
	# Generation pass densities are tuned for the classic 560-column world; keep
	# them constant when the world grows so wider worlds stay just as full.
	return maxi(1, int(round(float(base) * float(WORLD_WIDTH) / 560.0)))


func _is_biome_topsoil_tile(tile: int) -> bool:
	return tile == Tile.ASH_SAND or tile == Tile.FROZEN_DIRT or tile == Tile.MUD or tile == Tile.RUBBLE


func _surface_biome_at_column(x: int) -> String:
	if surface_biomes.size() == WORLD_WIDTH:
		return surface_biomes[clampi(x, 0, WORLD_WIDTH - 1)]
	return "forest"


func _surface_biome_at_player() -> String:
	var tile_x := floori(player_position.x / TILE_SIZE)
	return _surface_biome_at_column(tile_x)


func _pick_base_tile(x: int, y: int, cave_noise: FastNoiseLite, ore_noise: FastNoiseLite) -> int:
	var surface_y: int = surface_heights[x]
	if y < surface_y:
		# Above ground near the rim the dead sea fills everything below its
		# waterline, so the map ends in open water rather than empty air.
		var sea_level := _edge_sea_level_at(x)
		if sea_level >= 0 and y >= sea_level:
			return Tile.WATER
		return Tile.AIR
	var biome := _blended_biome_at(x, y, _surface_biome_at_column(x))
	if y == surface_y:
		# The visible ground block belongs to the biome, not just its tint.
		if biome == "frost_wasteland":
			return Tile.SNOW_BLOCK
		if biome == "ash_desert":
			return Tile.ASH_SAND
		return Tile.GRASS

	var depth := y - surface_y
	var cave_value := cave_noise.get_noise_2d(float(x), float(y))
	if depth > 8 and cave_value > 0.34:
		return Tile.AIR

	# Topsoil is biome-specific all the way down, not only the first row: the
	# desert is real ash sand, the marsh is wet mud, the wasteland is frozen
	# dirt and the ruins sit on rubble.
	if depth <= _topsoil_depth_at_column(x, biome):
		match biome:
			"frost_wasteland":
				return Tile.FROZEN_DIRT
			"marsh":
				return Tile.MUD
			"ash_desert":
				return Tile.ASH_SAND
			"ash_ruins":
				return Tile.RUBBLE
		return Tile.DIRT

	var ore_value := ore_noise.get_noise_2d(float(x), float(y))
	if depth > 14 and ore_value > 0.58:
		return Tile.COPPER
	if depth > 28 and ore_value < -0.60:
		return Tile.IRON
	if depth > 44 and cave_value < -0.48:
		return Tile.ASH

	return Tile.STONE


func _add_cave_networks() -> void:
	var room_centers: Array[Vector2i] = []
	for i in range(_scaled_count(44)):
		var x := rng.randi_range(WORLD_EDGE_ZONE + 8, WORLD_WIDTH - WORLD_EDGE_ZONE - 9)
		var surface_y: int = surface_heights[x]
		var y := rng.randi_range(surface_y + 14, WORLD_HEIGHT - 18)
		var radius_x := rng.randi_range(5, 13)
		var radius_y := rng.randi_range(3, 8)
		var center := Vector2i(x, y)
		room_centers.append(center)
		_carve_cave_blob(center, radius_x, radius_y)
	room_centers.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return a.x < b.x
	)
	for i in range(room_centers.size() - 1):
		if rng.randf() < 0.88:
			_carve_tunnel(room_centers[i], room_centers[i + 1], rng.randi_range(2, 3))
	# Occasional cross-links create loops instead of one long cave chain.
	for i in range(room_centers.size() - 2):
		if rng.randf() < 0.28:
			_carve_tunnel(room_centers[i], room_centers[i + 2], 2)


func _add_biomes() -> void:
	_add_forest_floor_details()
	_add_marsh_ponds()
	_add_mushroom_halls()
	_add_ash_cities()
	_add_sunken_ruins()
	_add_lava_roots()
	_add_glass_abyss()


func _add_forest_floor_details() -> void:
	for x in range(6, WORLD_WIDTH - 6):
		var ground_y: int = surface_heights[x]
		if _get_tile(x, ground_y) == Tile.GRASS and rng.randf() < 0.22:
			_set_tile(x, ground_y, Tile.MOSS)
		if rng.randf() < 0.035:
			_add_forest_cache(Vector2i(x, ground_y - 1))


func _add_forest_cache(pos: Vector2i) -> void:
	for x in range(pos.x - 2, pos.x + 3):
		if _in_bounds(x, pos.y + 1) and _get_tile(x, pos.y + 1) != Tile.AIR:
			_set_tile(x, pos.y + 1, Tile.MOSS)


func _add_marsh_ponds() -> void:
	# Surface ponds make the marsh read differently from the other surface
	# biomes and give the finite water sim something to do above ground.
	var pond_centers: Array[int] = []
	for attempt in range(_scaled_count(30)):
		if pond_centers.size() >= _scaled_count(3):
			break
		var x := rng.randi_range(WORLD_EDGE_ZONE + 8, WORLD_WIDTH - WORLD_EDGE_ZONE - 9)
		if _surface_biome_at_column(x) != "marsh":
			continue
		var too_close := false
		for other in pond_centers:
			if abs(x - other) < 26:
				too_close = true
				break
		if too_close:
			continue
		pond_centers.append(x)
		_carve_marsh_pond(x)


func _carve_marsh_pond(center_x: int) -> void:
	var half_width := rng.randi_range(4, 8)
	var depth := rng.randi_range(3, 5)
	for dx in range(-half_width, half_width + 1):
		var x := center_x + dx
		if not _in_bounds(x, 0):
			continue
		var surface_y: int = surface_heights[x]
		var rim_taper := int(round(absf(float(dx)) / float(maxi(1, half_width)) * 2.0))
		var dig_depth := maxi(1, depth - rim_taper)
		for y in range(surface_y, surface_y + dig_depth):
			_set_tile(x, y, Tile.AIR)
		# Keep the water level below the pond rim so the pool stays contained;
		# the shallowest shore columns become open mud instead of water.
		if dig_depth >= 2:
			for y in range(surface_y + 1, surface_y + dig_depth):
				_set_tile(x, y, Tile.WATER)
	# A moss rim frames every pond and keeps the marsh palette on the surface.
	for rim_x in [center_x - half_width - 1, center_x + half_width + 1]:
		if not _in_bounds(rim_x, 0):
			continue
		var rim_y: int = surface_heights[rim_x]
		if _get_tile(rim_x, rim_y) == Tile.GRASS:
			_set_tile(rim_x, rim_y, Tile.MOSS)


func _add_mushroom_halls() -> void:
	for i in range(_scaled_count(8)):
		var x := rng.randi_range(48, WORLD_WIDTH - 49)
		var y := rng.randi_range(surface_heights[x] + 42, WORLD_HEIGHT - 48)
		var center := Vector2i(x, y)
		_carve_cave_blob(center, rng.randi_range(10, 20), rng.randi_range(5, 10))
		_paint_biome_patch(center, rng.randi_range(13, 22), rng.randi_range(7, 12), Tile.MUSHROOM_SOIL, Tile.STONE)
		for cap in range(rng.randi_range(9, 18)):
			var px := center.x + rng.randi_range(-18, 18)
			var py := center.y + rng.randi_range(-7, 9)
			if _in_bounds(px, py) and _get_tile(px, py) == Tile.AIR and _get_tile(px, py + 1) != Tile.AIR:
				_set_tile(px, py, Tile.GLOW_MUSHROOM)
		_try_place_cave_chest(center + Vector2i(rng.randi_range(-5, 5), rng.randi_range(-1, 2)), "mushroom")


func _add_ash_cities() -> void:
	for i in range(_scaled_count(5)):
		var w := rng.randi_range(20, 34)
		var h := rng.randi_range(8, 14)
		var left := rng.randi_range(35, WORLD_WIDTH - w - 35)
		var top := rng.randi_range(72, WORLD_HEIGHT - 68)
		for y in range(top, top + h):
			for x in range(left, left + w):
				var border := x == left or x == left + w - 1 or y == top or y == top + h - 1
				var column := (x - left) % 7 == 0 and y > top + 2
				if border or column:
					_set_tile(x, y, Tile.ASH_BRICK)
				else:
					_set_tile(x, y, Tile.AIR)
		for tower in range(rng.randi_range(2, 4)):
			var tx := left + rng.randi_range(3, w - 4)
			for y in range(top - rng.randi_range(3, 7), top + 1):
				_set_tile(tx, y, Tile.ASH_BRICK)
		_try_place_structure_chest(Vector2i(left + rng.randi_range(3, w - 4), top + h - 2), "ash_city")


func _add_sunken_ruins() -> void:
	for i in range(_scaled_count(6)):
		var center := Vector2i(rng.randi_range(28, WORLD_WIDTH - 29), rng.randi_range(88, WORLD_HEIGHT - 46))
		var radius_x := rng.randi_range(8, 16)
		var radius_y := rng.randi_range(4, 8)
		_carve_cave_blob(center, radius_x, radius_y)
		_paint_biome_patch(center, radius_x + 3, radius_y + 2, Tile.SUNKEN_STONE, Tile.STONE)
		_fill_liquid_pool(center, radius_x - 1, radius_y, center.y, Tile.WATER)
		for col in range(rng.randi_range(3, 6)):
			var x := center.x + rng.randi_range(-12, 12)
			for y in range(center.y - rng.randi_range(2, 5), center.y + rng.randi_range(2, 5)):
				if rng.randf() > 0.18:
					_set_tile(x, y, Tile.SUNKEN_STONE)
		_try_place_structure_chest(center + Vector2i(rng.randi_range(-4, 4), rng.randi_range(0, 3)), "sunken")


func _add_lava_roots() -> void:
	for i in range(_scaled_count(34)):
		var x := rng.randi_range(WORLD_EDGE_ZONE + 8, WORLD_WIDTH - WORLD_EDGE_ZONE - 9)
		var y := rng.randi_range(WORLD_HEIGHT - 72, WORLD_HEIGHT - 16)
		var length := rng.randi_range(14, 42)
		for step in range(length):
			if not _in_bounds(x, y):
				break
			if _get_tile(x, y) != Tile.AIR:
				_set_tile(x, y, Tile.LAVA_ROOT)
			if rng.randf() < 0.18:
				_set_tile(x + rng.randi_range(-1, 1), y, Tile.ASH)
			x += rng.randi_range(-1, 1)
			y += rng.randi_range(-1, 1)
	for i in range(_scaled_count(5)):
		var pos := Vector2i(rng.randi_range(35, WORLD_WIDTH - 36), rng.randi_range(WORLD_HEIGHT - 58, WORLD_HEIGHT - 18))
		var radius_x := rng.randi_range(7, 13)
		var radius_y := rng.randi_range(3, 6)
		_carve_cave_blob(pos, radius_x, radius_y)
		_fill_liquid_pool(pos, radius_x - 1, radius_y, pos.y + 1, Tile.LAVA)
		_try_place_cave_chest(pos, "lava_root")


func _add_glass_abyss() -> void:
	for i in range(_scaled_count(7)):
		var center := Vector2i(rng.randi_range(28, WORLD_WIDTH - 29), rng.randi_range(WORLD_HEIGHT - 46, WORLD_HEIGHT - 12))
		_carve_cave_blob(center, rng.randi_range(12, 24), rng.randi_range(5, 11))
		_paint_biome_patch(center, rng.randi_range(15, 27), rng.randi_range(7, 13), Tile.GLASS_STONE, Tile.STONE)
		for crystal in range(rng.randi_range(8, 18)):
			var x := center.x + rng.randi_range(-20, 20)
			var y := center.y + rng.randi_range(-8, 10)
			if _in_bounds(x, y) and _get_tile(x, y) != Tile.AIR and rng.randf() < 0.55:
				_set_tile(x, y, Tile.ABYSS_CRYSTAL)
		_try_place_cave_chest(center + Vector2i(rng.randi_range(-5, 5), rng.randi_range(-1, 3)), "glass")


func _paint_biome_patch(center: Vector2i, radius_x: int, radius_y: int, tile: int, replace_tile: int) -> void:
	for y in range(center.y - radius_y, center.y + radius_y + 1):
		for x in range(center.x - radius_x, center.x + radius_x + 1):
			if not _in_bounds(x, y) or _is_protected_seabed(x, y):
				continue
			var dx := float(x - center.x) / float(maxi(1, radius_x))
			var dy := float(y - center.y) / float(maxi(1, radius_y))
			if dx * dx + dy * dy > 1.0 + rng.randf_range(-0.18, 0.18):
				continue
			var current := _get_tile(x, y)
			if current == replace_tile or current == Tile.DIRT or current == Tile.ASH or current == Tile.RUIN:
				_set_tile(x, y, tile)
			elif _is_biome_topsoil_tile(current):
				_set_tile(x, y, tile)


func _fill_liquid_pool(center: Vector2i, radius_x: int, radius_y: int, surface_y: int, liquid_tile: int) -> void:
	for y in range(center.y - radius_y, center.y + radius_y + 1):
		for x in range(center.x - radius_x, center.x + radius_x + 1):
			if not _in_bounds(x, y) or y < surface_y:
				continue
			var dx := float(x - center.x) / float(maxi(1, radius_x))
			var dy := float(y - center.y) / float(maxi(1, radius_y))
			if dx * dx + dy * dy <= 1.0 and _get_tile(x, y) == Tile.AIR:
				_set_tile(x, y, liquid_tile)


func _carve_cave_blob(center: Vector2i, radius_x: int, radius_y: int) -> void:
	for y in range(center.y - radius_y - 1, center.y + radius_y + 2):
		for x in range(center.x - radius_x - 1, center.x + radius_x + 2):
			if not _in_bounds(x, y) or _is_protected_seabed(x, y):
				continue
			var dx := float(x - center.x) / float(maxi(1, radius_x))
			var dy := float(y - center.y) / float(maxi(1, radius_y))
			var ragged := rng.randf_range(-0.20, 0.28)
			if dx * dx + dy * dy <= 1.0 + ragged:
				_set_tile(x, y, Tile.AIR)
	for drip in range(rng.randi_range(2, 5)):
		var start_x := center.x + rng.randi_range(-radius_x, radius_x)
		var length := rng.randi_range(3, 9)
		for step in range(length):
			var drip_x := start_x + rng.randi_range(-1, 1)
			var drip_y := center.y + radius_y + step
			if _is_protected_seabed(drip_x, drip_y):
				continue
			_set_tile(drip_x, drip_y, Tile.AIR)


func _carve_tunnel(a: Vector2i, b: Vector2i, radius: int) -> void:
	var current := a
	var guard := 0
	while current.distance_to(b) > 2.0 and guard < 260:
		guard += 1
		if rng.randf() < 0.62:
			current.x += signi(b.x - current.x)
		else:
			current.y += signi(b.y - current.y)
		current.y += rng.randi_range(-1, 1) if rng.randf() < 0.24 else 0
		for yy in range(current.y - radius, current.y + radius + 1):
			for xx in range(current.x - radius, current.x + radius + 1):
				if _is_protected_seabed(xx, yy):
					continue
				if Vector2(xx - current.x, yy - current.y).length() <= float(radius) + rng.randf_range(-0.2, 0.8):
					_set_tile(xx, yy, Tile.AIR)


func _add_cave_structures() -> void:
	for i in range(_scaled_count(11)):
		var center := _find_cave_floor_position()
		if center.x < 0:
			continue
		if rng.randf() < 0.55:
			_add_ruin_room(center)
		else:
			_add_root_shrine(center)


func _find_cave_floor_position() -> Vector2i:
	for attempt in range(80):
		var x := rng.randi_range(WORLD_EDGE_ZONE + 8, WORLD_WIDTH - WORLD_EDGE_ZONE - 9)
		var surface_y: int = surface_heights[x]
		var y := rng.randi_range(surface_y + 18, WORLD_HEIGHT - 14)
		for scan_y in range(y, mini(WORLD_HEIGHT - 4, y + 16)):
			if _get_tile(x, scan_y) == Tile.AIR and _get_tile(x, scan_y + 1) != Tile.AIR:
				return Vector2i(x, scan_y)
	return Vector2i(-1, -1)


func _place_generated_memory_nodes() -> void:
	if not memory_nodes.is_empty():
		return
	var node_tiles := {
		"fungal": Tile.MUSHROOM_SOIL,
		"sunken": Tile.SUNKEN_STONE,
		"ash": Tile.ASH_BRICK
	}
	for node_kind in ["fungal", "sunken", "ash"]:
		var tile_pos := _find_memory_node_floor(int(node_tiles[node_kind]))
		if tile_pos.x < 0:
			push_warning("Could not place %s memory node" % node_kind)
			continue
		memory_nodes.append({
			"kind": node_kind,
			"tile_pos": tile_pos,
			"state": "dormant",
			"anim_time": 0.0
		})


func _find_memory_node_floor(floor_tile: int) -> Vector2i:
	var candidates: Array[Vector2i] = []
	for y in range(7, WORLD_HEIGHT - 2):
		for x in range(WORLD_EDGE_ZONE + 6, WORLD_WIDTH - WORLD_EDGE_ZONE - 6):
			if _get_tile(x, y + 1) != floor_tile:
				continue
			var clear := true
			for rise in range(6):
				var open_tile := _get_tile(x, y - rise)
				if open_tile != Tile.AIR and open_tile != Tile.WATER:
					clear = false
					break
			if not clear:
				continue
			if _get_tile(x - 1, y + 1) == Tile.AIR or _get_tile(x + 1, y + 1) == Tile.AIR:
				continue
			candidates.append(Vector2i(x, y))
			if candidates.size() >= 160:
				break
		if candidates.size() >= 160:
			break
	if candidates.is_empty():
		return Vector2i(-1, -1)
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func _memory_node_world_position(node: Dictionary) -> Vector2:
	var tile_pos: Vector2i = node.get("tile_pos", Vector2i(-1, -1))
	return Vector2(
		(float(tile_pos.x) + 0.5) * TILE_SIZE,
		(float(tile_pos.y) + 1.0) * TILE_SIZE
	)


func _memory_node_index_at_tile(tile_pos: Vector2i) -> int:
	for index in range(memory_nodes.size()):
		var node_pos: Vector2i = memory_nodes[index].get("tile_pos", Vector2i(-999, -999))
		if abs(tile_pos.x - node_pos.x) <= 1 and tile_pos.y <= node_pos.y and tile_pos.y >= node_pos.y - 4:
			return index
	return -1


func _activate_memory_node(index: int) -> void:
	if index < 0 or index >= memory_nodes.size():
		return
	var node: Dictionary = memory_nodes[index]
	var state := str(node.get("state", "dormant"))
	var node_kind := str(node.get("kind", ""))
	if state == "active":
		last_message = "%s Memory Node is already awake." % node_kind.capitalize()
		return
	if state == "activate":
		last_message = "%s Memory Node is responding." % node_kind.capitalize()
		return
	if int(inventory.get("cracked_memory_core", 0)) <= 0:
		last_message = "The node rejects the signal. A cracked memory core is required."
		return
	node["state"] = "activate"
	node["anim_time"] = 0.0
	memory_nodes[index] = node
	_play_sound("pickup")
	last_message = "%s Memory Node is waking." % node_kind.capitalize()


func _update_memory_nodes(delta: float) -> void:
	for index in range(memory_nodes.size()):
		var node: Dictionary = memory_nodes[index]
		var state := str(node.get("state", "dormant"))
		if state == "dormant":
			continue
		var anim_time := float(node.get("anim_time", 0.0)) + delta
		if state == "activate" and anim_time >= 8.0 / 9.0:
			node["state"] = "active"
			node["anim_time"] = 0.0
			memory_nodes[index] = node
			_complete_memory_node(str(node.get("kind", "")))
			continue
		node["anim_time"] = anim_time
		memory_nodes[index] = node


func _complete_memory_node(node_kind: String) -> void:
	var reward_by_kind := {
		"fungal": "fungal_memory_shard",
		"sunken": "sunken_memory_shard",
		"ash": "ash_memory_shard"
	}
	var reward := str(reward_by_kind.get(node_kind, ""))
	if reward != "" and int(inventory.get(reward, 0)) <= 0:
		_add_item(reward, 1)
	if _all_memory_nodes_active():
		_record_recipe_known("ashen_lens")
		last_message = "All memory signals align. The Ashen Lens recipe has been restored."
	else:
		last_message = "%s recovered from the %s node." % [_item_display_name(reward), node_kind.capitalize()]
	_play_sound("pickup")


func _all_memory_nodes_active() -> bool:
	for required_kind in ["fungal", "sunken", "ash"]:
		var found_active := false
		for node in memory_nodes:
			var data: Dictionary = node
			if str(data.get("kind", "")) == required_kind and str(data.get("state", "")) == "active":
				found_active = true
				break
		if not found_active:
			return false
	return true


func _serialize_memory_nodes() -> Array:
	var serialized: Array = []
	for node in memory_nodes:
		var data: Dictionary = node
		var tile_pos: Vector2i = data.get("tile_pos", Vector2i(-1, -1))
		serialized.append({
			"kind": str(data.get("kind", "")),
			"tile_pos": [tile_pos.x, tile_pos.y],
			"state": str(data.get("state", "dormant")),
			"anim_time": float(data.get("anim_time", 0.0))
		})
	return serialized


func _restore_memory_nodes(serialized: Variant) -> void:
	memory_nodes.clear()
	if serialized is Array:
		for entry_variant in serialized:
			if not entry_variant is Dictionary:
				continue
			var entry: Dictionary = entry_variant
			var coords: Array = entry.get("tile_pos", [])
			if coords.size() < 2:
				continue
			memory_nodes.append({
				"kind": str(entry.get("kind", "")),
				"tile_pos": Vector2i(int(coords[0]), int(coords[1])),
				"state": str(entry.get("state", "dormant")),
				"anim_time": float(entry.get("anim_time", 0.0))
			})
	if memory_nodes.is_empty():
		_place_generated_memory_nodes()


func _draw_memory_nodes() -> void:
	const NODE_SCALE := 0.64
	for node in memory_nodes:
		var data: Dictionary = node
		var node_kind := str(data.get("kind", ""))
		var state := str(data.get("state", "dormant"))
		var node_states: Dictionary = memory_node_textures.get(node_kind, {})
		var texture: Texture2D = node_states.get(state, null)
		if texture == null:
			continue
		var frame_count := 1
		var fps := 1.0
		var loop := false
		if state == "activate":
			frame_count = 8
			fps = 9.0
		elif state == "active":
			frame_count = 6
			fps = 6.0
			loop = true
		var frame_width := maxi(1, int(texture.get_width() / frame_count))
		var raw_frame := int(floor(float(data.get("anim_time", 0.0)) * fps))
		var frame_index := raw_frame % frame_count if loop else mini(frame_count - 1, raw_frame)
		var world_pos := _memory_node_world_position(data)
		var anchor := Vector2(32.0, 91.0)
		var draw_size := Vector2(frame_width, texture.get_height()) * NODE_SCALE
		draw_texture_rect_region(
			texture,
			Rect2(world_pos - anchor * NODE_SCALE, draw_size),
			Rect2(frame_index * frame_width, 0, frame_width, texture.get_height())
		)


func _place_archive_site() -> void:
	if not archive_site.is_empty():
		return
	var floor_pos := _find_archive_site_floor()
	if floor_pos.x < 0:
		push_warning("Could not place the Archive site")
		return
	for x in range(floor_pos.x - 7, floor_pos.x + 10):
		_set_tile(x, floor_pos.y + 1, Tile.ASH_BRICK)
		for y in range(floor_pos.y - 7, floor_pos.y + 1):
			_set_tile(x, y, Tile.AIR)
	archive_site = {
		"console_tile": floor_pos + Vector2i(-3, 0),
		"gate_tile": floor_pos + Vector2i(5, 0),
		"console_state": "idle",
		"gate_state": "closed",
		"anim_time": 0.0,
		"hologram_time": 0.0
	}


func _find_archive_site_floor() -> Vector2i:
	var candidates: Array[Vector2i] = []
	for y in range(9, WORLD_HEIGHT - 3):
		for x in range(WORLD_EDGE_ZONE + 10, WORLD_WIDTH - WORLD_EDGE_ZONE - 11):
			if _get_tile(x, y + 1) != Tile.ASH_BRICK:
				continue
			var too_close_to_node := false
			for node in memory_nodes:
				var node_pos: Vector2i = (node as Dictionary).get("tile_pos", Vector2i(-999, -999))
				if node_pos.distance_to(Vector2i(x, y)) < 12.0:
					too_close_to_node = true
					break
			if not too_close_to_node:
				candidates.append(Vector2i(x, y))
	if not candidates.is_empty():
		return candidates[rng.randi_range(0, candidates.size() - 1)]
	for x in range(WORLD_EDGE_ZONE + 12, WORLD_WIDTH - WORLD_EDGE_ZONE - 12):
		if _surface_biome_at_column(x) == "ash_ruins":
			return Vector2i(x, int(surface_heights[x]) - 1)
	return Vector2i(-1, -1)


func _archive_object_world_position(tile_pos: Vector2i) -> Vector2:
	return Vector2(
		(float(tile_pos.x) + 0.5) * TILE_SIZE,
		(float(tile_pos.y) + 1.0) * TILE_SIZE
	)


func _archive_console_at_tile(tile_pos: Vector2i) -> bool:
	if archive_site.is_empty():
		return false
	var console_tile: Vector2i = archive_site.get("console_tile", Vector2i(-999, -999))
	return abs(tile_pos.x - console_tile.x) <= 2 and tile_pos.y <= console_tile.y and tile_pos.y >= console_tile.y - 3


func _activate_archive_console() -> void:
	if archive_site.is_empty():
		return
	var console_state := str(archive_site.get("console_state", "idle"))
	if console_state == "activating":
		last_message = "The Archive Console is reconstructing the memory."
		return
	if console_state == "active":
		last_message = "The restored memory points beyond the open Archive Gate."
		return
	if int(inventory.get("ashen_lens", 0)) <= 0:
		last_message = "The console has an empty lens socket. An Ashen Lens is required."
		return
	if int(inventory.get("archive_sigil", 0)) <= 0:
		last_message = "The Ashen Lens responds, but the Archive Sigil is missing."
		return
	inventory["ashen_lens"] = int(inventory.get("ashen_lens", 0)) - 1
	inventory["archive_sigil"] = int(inventory.get("archive_sigil", 0)) - 1
	archive_site["console_state"] = "activating"
	archive_site["anim_time"] = 0.0
	archive_site["hologram_time"] = 0.0
	_play_sound("pickup")
	last_message = "The Ashen Lens settles into the console. Archived memory is returning."


func _update_archive_site(delta: float) -> void:
	if archive_site.is_empty():
		return
	_update_archive_warden_encounter()
	var console_state := str(archive_site.get("console_state", "idle"))
	var gate_state := str(archive_site.get("gate_state", "closed"))
	if console_state != "idle":
		archive_site["hologram_time"] = float(archive_site.get("hologram_time", 0.0)) + delta
	if console_state == "activating":
		var console_time := float(archive_site.get("anim_time", 0.0)) + delta
		archive_site["anim_time"] = console_time
		if console_time >= 10.0 / 9.0:
			archive_site["console_state"] = "active"
			archive_site["gate_state"] = "opening"
			archive_site["anim_time"] = 0.0
			last_message = "The memory stabilizes. The Archive Gate is opening."
	elif gate_state == "opening":
		var gate_time := float(archive_site.get("anim_time", 0.0)) + delta
		archive_site["anim_time"] = gate_time
		if gate_time >= 10.0 / 8.0:
			archive_site["gate_state"] = "open"
			archive_site["anim_time"] = 0.0
			last_message = "The Archive Gate is open."


func _update_archive_warden_encounter() -> void:
	if archive_warden_defeated or archive_site.is_empty():
		return
	if str(archive_site.get("console_state", "idle")) != "idle":
		return
	if not _all_memory_nodes_active() or int(inventory.get("ashen_lens", 0)) <= 0:
		return
	var console_tile: Vector2i = archive_site.get("console_tile", Vector2i(-999, -999))
	var console_pos := _archive_object_world_position(console_tile)
	if player_position.distance_to(console_pos) > 260.0:
		return
	if _count_enemies_of_type("archive_warden") > 0:
		archive_warden_spawned = true
		return
	var gate_tile: Vector2i = archive_site.get("gate_tile", console_tile + Vector2i(8, 0))
	var template := _enemy_template("archive_warden")
	var warden_size: Vector2 = template.get("size", Vector2(38, 58))
	var spawn_pos := Vector2(
		(float(gate_tile.x - 3) + 0.5) * TILE_SIZE,
		(float(gate_tile.y) + 1.0) * TILE_SIZE - warden_size.y * 0.5
	)
	_spawn_enemy("archive_warden", spawn_pos)
	if not enemies.is_empty():
		var warden: Dictionary = enemies[-1]
		warden["home_pos"] = spawn_pos
		_force_enemy_combat(warden, player_position, false)
	archive_warden_spawned = true
	_spawn_hit_particles(spawn_pos + Vector2(0.0, -18.0), Color("82c7b1"), 14)
	_emit_noise(spawn_pos, 240.0, "archive_warden_awaken", 1.4)
	last_message = "The Ashen Lens resonates. The Archive Warden awakens before the sealed gate."


func _archive_gate_collision_rect() -> Rect2:
	if archive_site.is_empty() or str(archive_site.get("gate_state", "closed")) == "open":
		return Rect2()
	var gate_tile: Vector2i = archive_site.get("gate_tile", Vector2i(-999, -999))
	var gate_pos := _archive_object_world_position(gate_tile)
	return Rect2(gate_pos + Vector2(-16.0, -76.0), Vector2(32.0, 76.0))


func _serialize_archive_site() -> Dictionary:
	if archive_site.is_empty():
		return {}
	var console_tile: Vector2i = archive_site.get("console_tile", Vector2i(-1, -1))
	var gate_tile: Vector2i = archive_site.get("gate_tile", Vector2i(-1, -1))
	return {
		"console_tile": [console_tile.x, console_tile.y],
		"gate_tile": [gate_tile.x, gate_tile.y],
		"console_state": str(archive_site.get("console_state", "idle")),
		"gate_state": str(archive_site.get("gate_state", "closed")),
		"anim_time": float(archive_site.get("anim_time", 0.0)),
		"hologram_time": float(archive_site.get("hologram_time", 0.0))
	}


func _restore_archive_site(serialized: Variant) -> void:
	archive_site.clear()
	if serialized is Dictionary:
		var data: Dictionary = serialized
		var console_coords: Array = data.get("console_tile", [])
		var gate_coords: Array = data.get("gate_tile", [])
		if console_coords.size() >= 2 and gate_coords.size() >= 2:
			archive_site = {
				"console_tile": Vector2i(int(console_coords[0]), int(console_coords[1])),
				"gate_tile": Vector2i(int(gate_coords[0]), int(gate_coords[1])),
				"console_state": str(data.get("console_state", "idle")),
				"gate_state": str(data.get("gate_state", "closed")),
				"anim_time": float(data.get("anim_time", 0.0)),
				"hologram_time": float(data.get("hologram_time", 0.0))
			}
	if archive_site.is_empty():
		_place_archive_site()


func _draw_archive_site() -> void:
	if archive_site.is_empty():
		return
	const CONSOLE_SCALE := 0.72
	const GATE_SCALE := 0.64
	const HOLOGRAM_SCALE := 0.72
	var anim_time := float(archive_site.get("anim_time", 0.0))
	var console_state := str(archive_site.get("console_state", "idle"))
	var gate_state := str(archive_site.get("gate_state", "closed"))
	var gate_texture: Texture2D = archive_object_textures.get("gate_%s" % gate_state, null)
	if gate_texture != null:
		var gate_frames := 10 if gate_state == "opening" else 1
		var gate_frame := mini(gate_frames - 1, int(floor(anim_time * 8.0)))
		var gate_frame_width := int(gate_texture.get_width() / gate_frames)
		var gate_pos := _archive_object_world_position(archive_site.get("gate_tile", Vector2i.ZERO))
		draw_texture_rect_region(
			gate_texture,
			Rect2(gate_pos - Vector2(48.0, 127.0) * GATE_SCALE, Vector2(gate_frame_width, gate_texture.get_height()) * GATE_SCALE),
			Rect2(gate_frame * gate_frame_width, 0, gate_frame_width, gate_texture.get_height())
		)
	var console_texture: Texture2D = archive_object_textures.get("console_idle" if console_state == "idle" else "console_activate", null)
	if console_texture != null:
		var console_frames := 6 if console_state == "idle" else 10
		var console_fps := 5.0 if console_state == "idle" else 9.0
		var console_frame := 9
		if console_state == "idle":
			console_frame = int(floor(Time.get_ticks_msec() / 1000.0 * console_fps)) % console_frames
		elif console_state == "activating":
			console_frame = mini(console_frames - 1, int(floor(anim_time * console_fps)))
		var console_frame_width := int(console_texture.get_width() / console_frames)
		var console_pos := _archive_object_world_position(archive_site.get("console_tile", Vector2i.ZERO))
		draw_texture_rect_region(
			console_texture,
			Rect2(console_pos - Vector2(32.0, 59.0) * CONSOLE_SCALE, Vector2(console_frame_width, console_texture.get_height()) * CONSOLE_SCALE),
			Rect2(console_frame * console_frame_width, 0, console_frame_width, console_texture.get_height())
		)
	if console_state != "idle":
		var hologram_texture: Texture2D = archive_object_textures.get("hologram", null)
		if hologram_texture != null:
			var hologram_frame_width := int(hologram_texture.get_width() / 8)
			var hologram_frame := int(floor(float(archive_site.get("hologram_time", 0.0)) * 8.0)) % 8
			var hologram_pos := _archive_object_world_position(archive_site.get("console_tile", Vector2i.ZERO)) - Vector2(0.0, 40.0)
			draw_texture_rect_region(
				hologram_texture,
				Rect2(hologram_pos - Vector2(32.0, 59.0) * HOLOGRAM_SCALE, Vector2(hologram_frame_width, hologram_texture.get_height()) * HOLOGRAM_SCALE),
				Rect2(hologram_frame * hologram_frame_width, 0, hologram_frame_width, hologram_texture.get_height())
			)


func _add_cave_decorations() -> void:
	# A small number of physical cave props create readable silhouettes without
	# closing off the generated cave network.
	for i in range(_scaled_count(160)):
		var x := rng.randi_range(WORLD_EDGE_ZONE + 6, WORLD_WIDTH - WORLD_EDGE_ZONE - 7)
		var y := rng.randi_range(surface_heights[x] + 12, WORLD_HEIGHT - 12)
		if _get_tile(x, y) != Tile.AIR:
			continue
		var above := _get_tile(x, y - 1)
		var below := _get_tile(x, y + 1)
		if above != Tile.AIR and rng.randf() < 0.42:
			var length := rng.randi_range(1, 3)
			for step in range(length):
				if _get_tile(x, y + step) == Tile.AIR:
					_set_tile(x, y + step, Tile.STONE)
		elif below != Tile.AIR and rng.randf() < 0.34:
			var length := rng.randi_range(1, 2)
			for step in range(length):
				if _get_tile(x, y - step) == Tile.AIR:
					_set_tile(x, y - step, Tile.STONE)
		elif below == Tile.MUSHROOM_SOIL or below == Tile.MOSS:
			_set_tile(x, y, Tile.GLOW_MUSHROOM)
		elif rng.randf() < 0.22 and below != Tile.AIR:
			_set_tile(x, y, Tile.ROOT)


func _add_ruin_room(center: Vector2i) -> void:
	var w := rng.randi_range(7, 12)
	var h := rng.randi_range(4, 6)
	var left := clampi(center.x - int(w / 2), 2, WORLD_WIDTH - w - 2)
	var top := clampi(center.y - h + 1, 2, WORLD_HEIGHT - h - 2)
	for y in range(top, top + h):
		for x in range(left, left + w):
			var border := x == left or x == left + w - 1 or y == top or y == top + h - 1
			if border:
				_set_tile(x, y, Tile.RUIN)
			else:
				_set_tile(x, y, Tile.AIR)
	var door_x := left + int(w / 2)
	_set_tile(door_x, top + h - 1, Tile.AIR)
	_set_tile(door_x, top + h - 2, Tile.AIR)
	_try_place_structure_chest(Vector2i(left + rng.randi_range(2, w - 3), top + h - 2), "ruin")
	if rng.randf() < 0.45:
		_set_tile(left + rng.randi_range(2, w - 3), top + h - 2, Tile.STONE_ALTAR)


func _add_root_shrine(center: Vector2i) -> void:
	var w := rng.randi_range(6, 10)
	var left := clampi(center.x - int(w / 2), 2, WORLD_WIDTH - w - 2)
	var floor_y := clampi(center.y, 4, WORLD_HEIGHT - 4)
	for x in range(left, left + w):
		_set_tile(x, floor_y + 1, Tile.ROOT)
		if rng.randf() < 0.45:
			_set_tile(x, floor_y, Tile.AIR)
	for pillar_x in [left + 1, left + w - 2]:
		for y in range(floor_y - rng.randi_range(2, 4), floor_y + 1):
			_set_tile(pillar_x, y, Tile.ROOT)
	_try_place_structure_chest(Vector2i(left + rng.randi_range(2, w - 3), floor_y), "root")
	if rng.randf() < 0.35:
		_set_tile(left + int(w / 2), floor_y, Tile.STONE_ALTAR)


func _add_landmark_structures() -> void:
	# Large landmarks give the cave network destinations instead of only random
	# rooms. They use existing tiles so art can be upgraded independently later.
	var placed: Array[Vector2i] = []
	var placed_count := 0
	var attempts := 0
	while placed_count < _scaled_count(16) and attempts < _scaled_count(180):
		attempts += 1
		var center := _find_cave_floor_position()
		if center.x < 0 or not _landmark_area_is_clear(center, 9, 8):
			continue
		var too_close := false
		for other in placed:
			if center.distance_to(other) < 32.0:
				too_close = true
				break
		if too_close:
			continue

		var kind := placed_count % 5 if placed_count < 5 else rng.randi_range(0, 4)
		match kind:
			0:
				_add_abandoned_mine(center)
			1:
				_add_flooded_cistern(center)
			2:
				_add_lava_forge(center)
			3:
				_add_crystal_vault(center)
			4:
				_add_root_sanctum(center)
		placed.append(center)
		placed_count += 1


func _landmark_area_is_clear(center: Vector2i, half_width: int, height: int) -> bool:
	if center.x - half_width < 3 or center.x + half_width >= WORLD_WIDTH - 3:
		return false
	if center.y - height < 8 or center.y + 2 >= WORLD_HEIGHT:
		return false
	for y in range(center.y - height, center.y + 2):
		for x in range(center.x - half_width, center.x + half_width + 1):
			var tile := _get_tile(x, y)
			if tile == Tile.CHEST or tile == Tile.STONE_ALTAR or tile == Tile.WORKBENCH or tile == Tile.FURNACE or tile == Tile.ANVIL or tile == Tile.TURRET or tile == Tile.HEART:
				return false
			if tile == Tile.WATER or tile == Tile.LAVA or tile == Tile.BUBBLE_VENT or tile == Tile.DRAIN_VALVE:
				return false
	return true


func _prepare_landmark(center: Vector2i, half_width: int, height: int) -> Dictionary:
	var floor_y := center.y + 1
	var left := center.x - half_width
	var right := center.x + half_width
	var top := floor_y - height
	for y in range(top, floor_y):
		for x in range(left, right + 1):
			_set_tile(x, y, Tile.AIR)
	for x in range(left, right + 1):
		if _get_tile(x, floor_y) == Tile.AIR:
			_set_tile(x, floor_y, Tile.STONE)
	return {"left": left, "right": right, "top": top, "floor": floor_y}


func _carve_landmark_entrance(left: int, right: int, floor_y: int) -> void:
	var direction := -1 if rng.randf() < 0.5 else 1
	var wall_x := left if direction < 0 else right
	for step in range(5):
		var x := wall_x + direction * step
		_set_tile(x, floor_y - 3, Tile.AIR)
		_set_tile(x, floor_y - 2, Tile.AIR)
	# Some landmarks receive a second exit and become useful cave shortcuts.
	if rng.randf() < 0.38:
		direction *= -1
		wall_x = left if direction < 0 else right
		for step in range(3):
			var x := wall_x + direction * step
			_set_tile(x, floor_y - 3, Tile.AIR)
			_set_tile(x, floor_y - 2, Tile.AIR)


func _add_abandoned_mine(center: Vector2i) -> void:
	var room := _prepare_landmark(center, 7, 7)
	var left := int(room["left"])
	var right := int(room["right"])
	var top := int(room["top"])
	var floor_y := int(room["floor"])
	for x in range(left, right + 1):
		_set_tile(x, top, Tile.WOOD)
	for support_x in [left, left + 4, right]:
		for y in range(top, floor_y):
			_set_tile(support_x, y, Tile.WOOD)
		var torch_x: int = int(support_x) + 1 if int(support_x) < right else int(support_x) - 1
		if _get_tile(torch_x, top + 2) == Tile.AIR:
			_set_tile(torch_x, top + 2, Tile.TORCH)
	if rng.randf() < 0.55:
		_set_tile(center.x - 3, floor_y - 1, Tile.STONE)
		_set_tile(center.x - 2, floor_y - 1, Tile.STONE)
	_try_place_structure_chest(Vector2i(center.x + rng.randi_range(-2, 2), floor_y - 1), "ruin")


func _add_flooded_cistern(center: Vector2i) -> void:
	var room := _prepare_landmark(center, 8, 7)
	var left := int(room["left"])
	var right := int(room["right"])
	var top := int(room["top"])
	var floor_y := int(room["floor"])
	for x in range(left, right + 1):
		_set_tile(x, top, Tile.SUNKEN_STONE)
	for y in range(top, floor_y):
		_set_tile(left, y, Tile.SUNKEN_STONE)
		_set_tile(right, y, Tile.SUNKEN_STONE)
	for x in range(left + 2, right - 1):
		_set_tile(x, floor_y - 2, Tile.WATER)
		_set_tile(x, floor_y - 1, Tile.WATER)
	_set_tile(left + 2, floor_y, Tile.BUBBLE_VENT)
	_set_tile(right - 2, floor_y, Tile.DRAIN_VALVE)
	for x in range(left + 2, left + 5):
		_set_tile(x, floor_y - 2, Tile.SUNKEN_STONE)
	_try_place_structure_chest(Vector2i(left + 3, floor_y - 3), "sunken")
	_carve_landmark_entrance(left, right, floor_y)


func _add_lava_forge(center: Vector2i) -> void:
	var room := _prepare_landmark(center, 8, 7)
	var left := int(room["left"])
	var right := int(room["right"])
	var top := int(room["top"])
	var floor_y := int(room["floor"])
	for x in range(left, right + 1):
		_set_tile(x, top, Tile.ASH_BRICK)
	for y in range(top, floor_y):
		_set_tile(left, y, Tile.ASH_BRICK)
		_set_tile(right, y, Tile.ASH_BRICK)
	for x in range(center.x - 4, center.x + 5):
		_set_tile(x, floor_y, Tile.ASH_BRICK)
		_set_tile(x, floor_y - 1, Tile.LAVA)
	_set_tile(left + 2, floor_y - 1, Tile.STONE_ALTAR)
	_set_tile(right - 2, floor_y - 1, Tile.LAVA_ROOT)
	_try_place_structure_chest(Vector2i(left + 2, floor_y - 2), "lava_root")
	_carve_landmark_entrance(left, right, floor_y)


func _add_crystal_vault(center: Vector2i) -> void:
	var room := _prepare_landmark(center, 8, 8)
	var left := int(room["left"])
	var right := int(room["right"])
	var top := int(room["top"])
	var floor_y := int(room["floor"])
	for x in range(left, right + 1):
		_set_tile(x, top, Tile.GLASS_STONE)
		if x % 2 == 0:
			_set_tile(x, floor_y, Tile.GLASS_STONE)
	for y in range(top, floor_y):
		_set_tile(left, y, Tile.GLASS_STONE)
		_set_tile(right, y, Tile.GLASS_STONE)
	for x in range(left + 2, right - 1, 2):
		_set_tile(x, top + 1, Tile.ABYSS_CRYSTAL)
		if rng.randf() < 0.7:
			_set_tile(x, floor_y - 1, Tile.ABYSS_CRYSTAL)
	_try_place_structure_chest(Vector2i(center.x, floor_y - 1), "glass")
	_carve_landmark_entrance(left, right, floor_y)


func _add_root_sanctum(center: Vector2i) -> void:
	var room := _prepare_landmark(center, 7, 7)
	var left := int(room["left"])
	var right := int(room["right"])
	var top := int(room["top"])
	var floor_y := int(room["floor"])
	for x in range(left + 1, right):
		if x % 2 == 0:
			_set_tile(x, top, Tile.ROOT)
	for pillar_x in [left + 1, right - 1]:
		for y in range(top, floor_y):
			_set_tile(pillar_x, y, Tile.ROOT)
	for x in range(left + 2, right - 1):
		_set_tile(x, floor_y, Tile.MOSS)
	_set_tile(center.x, floor_y - 1, Tile.STONE_ALTAR)
	for mushroom_x in [left + 3, right - 3]:
		_set_tile(mushroom_x, floor_y - 1, Tile.GLOW_MUSHROOM)
	_try_place_structure_chest(Vector2i(left + 3, floor_y - 1), "root")


func _try_place_structure_chest(pos: Vector2i, loot_kind: String) -> bool:
	if rng.randf() >= STRUCTURE_CHEST_CHANCE:
		return false
	return _place_chest(pos, _make_chest_loot(loot_kind))


func _try_place_cave_chest(pos: Vector2i, loot_kind: String) -> bool:
	if rng.randf() >= CAVE_CHEST_CHANCE:
		return false
	return _place_chest(pos, _make_chest_loot(loot_kind))


func _place_chest(pos: Vector2i, loot: Dictionary) -> bool:
	var grounded_pos := _find_grounded_chest_position(pos)
	if grounded_pos.x < 0:
		return false
	_set_tile(grounded_pos.x, grounded_pos.y, Tile.CHEST)
	chest_loot[_tile_key(grounded_pos)] = loot
	return true


func _find_grounded_chest_position(pos: Vector2i) -> Vector2i:
	for drop in range(CHEST_GROUND_SEARCH_DEPTH + 1):
		for distance in range(CHEST_GROUND_SEARCH_RADIUS + 1):
			var offsets := [0] if distance == 0 else [-distance, distance]
			for offset in offsets:
				var candidate := Vector2i(pos.x + offset, pos.y + drop)
				if not _in_bounds(candidate.x, candidate.y) or not _in_bounds(candidate.x, candidate.y + 1):
					continue
				if _get_tile(candidate.x, candidate.y) == Tile.AIR and _is_solid(candidate.x, candidate.y + 1):
					return candidate
	return Vector2i(-1, -1)


func _stabilize_generated_chests() -> void:
	var chest_positions: Array[Vector2i] = []
	for y in range(WORLD_HEIGHT - 1):
		for x in range(WORLD_WIDTH):
			if _get_tile(x, y) == Tile.CHEST:
				chest_positions.append(Vector2i(x, y))
	for chest_pos in chest_positions:
		if _is_solid(chest_pos.x, chest_pos.y + 1):
			continue
		var old_key := _tile_key(chest_pos)
		var loot: Dictionary = chest_loot.get(old_key, {})
		chest_loot.erase(old_key)
		_set_tile(chest_pos.x, chest_pos.y, Tile.AIR)
		var grounded_pos := _find_grounded_chest_position(chest_pos)
		if grounded_pos.x < 0:
			continue
		_set_tile(grounded_pos.x, grounded_pos.y, Tile.CHEST)
		chest_loot[_tile_key(grounded_pos)] = loot


func _make_chest_loot(kind: String) -> Dictionary:
	var loot := {}
	loot["torch"] = rng.randi_range(3, 7)
	loot["wood"] = rng.randi_range(4, 10)
	if kind == "forest":
		loot["moss_fiber"] = rng.randi_range(5, 12)
		if rng.randf() < 0.24:
			loot["wild_badge"] = 1
	elif kind == "mushroom":
		loot["mushroom_spore"] = rng.randi_range(4, 9)
		loot["glowcap"] = rng.randi_range(2, 6)
		if rng.randf() < 0.26:
			loot["root_ring"] = 1
	elif kind == "ash_city":
		loot["ash_city_brick"] = rng.randi_range(8, 18)
		loot["ash_relic"] = rng.randi_range(1, 2)
		if rng.randf() < 0.24:
			loot["ash_sickle"] = 1
	elif kind == "sunken":
		loot["sunken_stone"] = rng.randi_range(8, 16)
		loot["drowned_pearl"] = 1
		if rng.randf() < 0.22:
			loot["hand_cannon"] = 1
	elif kind == "lava_root":
		loot["ember_root"] = rng.randi_range(5, 11)
		loot["night_ember"] = rng.randi_range(2, 5)
		if rng.randf() < 0.26:
			loot["fire_arrows"] = rng.randi_range(15, 30)
	elif kind == "glass":
		loot["glass_shard"] = rng.randi_range(5, 12)
		loot["abyss_crystal"] = rng.randi_range(2, 5)
		if rng.randf() < 0.20:
			loot["abyss_lens"] = 1
	elif kind == "ruin":
		loot["ruin_brick"] = rng.randi_range(4, 10)
		if rng.randf() < 0.58:
			loot["spark_shard"] = rng.randi_range(1, 2)
		if rng.randf() < 0.25:
			loot["hand_cannon"] = 1
	else:
		loot["root"] = rng.randi_range(5, 12)
		if rng.randf() < 0.62:
			loot["root_core"] = 1
		if rng.randf() < 0.22:
			loot["root_spirit_rod"] = 1
	if rng.randf() < 0.45:
		loot["copper_bar"] = rng.randi_range(2, 5)
	if rng.randf() < 0.25:
		loot["iron_bar"] = rng.randi_range(1, 3)
	return loot


func _tile_key(pos: Vector2i) -> String:
	return "%d,%d" % [pos.x, pos.y]


func _unlock_stone_beast_progression() -> void:
	if mushroom_path_opened:
		return
	mushroom_path_opened = true
	for i in range(_scaled_count(32)):
		var x := rng.randi_range(WORLD_EDGE_ZONE + 8, WORLD_WIDTH - WORLD_EDGE_ZONE - 9)
		var y := rng.randi_range(surface_heights[x] + 34, WORLD_HEIGHT - 10)
		for yy in range(y - 2, y + 3):
			for xx in range(x - 3, x + 4):
				if _in_bounds(xx, yy) and _get_tile(xx, yy) == Tile.STONE and rng.randf() < 0.42:
					_set_tile(xx, yy, Tile.STONEBLOOD)
	for i in range(_scaled_count(5)):
		var center := _find_cave_floor_position()
		if center.x >= 0:
			_carve_cave_blob(center + Vector2i(rng.randi_range(-5, 5), rng.randi_range(2, 8)), rng.randi_range(7, 12), rng.randi_range(4, 7))
			for x in range(center.x - 5, center.x + 6):
				if _in_bounds(x, center.y + 1) and rng.randf() < 0.55:
					_set_tile(x, center.y + 1, Tile.ROOT)


func _carve_spawn_area() -> void:
	var center := int(WORLD_WIDTH / 2)
	for x in range(center - 8, center + 9):
		if not _in_bounds(x, 0):
			continue
		var ground_y: int = surface_heights[x]
		for y in range(ground_y - 8, ground_y):
			_set_tile(x, y, Tile.AIR)
		_set_tile(x, ground_y, Tile.GRASS)


func _add_ash_pockets() -> void:
	for i in range(_scaled_count(9)):
		var center_x := rng.randi_range(25, WORLD_WIDTH - 26)
		var center_y := rng.randi_range(72, WORLD_HEIGHT - 14)
		var radius := rng.randi_range(6, 13)
		for y in range(center_y - radius, center_y + radius + 1):
			for x in range(center_x - radius, center_x + radius + 1):
				if not _in_bounds(x, y):
					continue
				var dist := Vector2(x - center_x, y - center_y).length()
				if dist < float(radius) * rng.randf_range(0.65, 1.1) and _get_tile(x, y) == Tile.STONE:
					_set_tile(x, y, Tile.ASH)


func _add_trees() -> void:
	var last_tree_x := -MIN_TREE_SPACING
	for x in range(8, WORLD_WIDTH - 8):
		if x - last_tree_x < MIN_TREE_SPACING:
			continue
		if rng.randf() > 0.055:
			continue
		var ground_y: int = surface_heights[x]
		var ground_tile := _get_tile(x, ground_y)
		if ground_tile != Tile.GRASS and ground_tile != Tile.ASH_SAND:
			continue
		last_tree_x = x
		var tree_id := _allocate_tree_id()
		var is_tall := rng.randf() < 0.12
		# Only bleached dead trunks survive on the ash desert drifts.
		var is_dead := ground_tile == Tile.ASH_SAND or (not is_tall and rng.randf() < 0.14)
		if ground_tile == Tile.ASH_SAND:
			is_tall = false
		var height := rng.randi_range(9, 12) if is_tall else (rng.randi_range(7, 9) if is_dead else rng.randi_range(6, 9))
		for y in range(ground_y - height, ground_y):
			_set_tree_tile(x, y, Tile.WOOD, tree_id)
			if is_tall and y > ground_y - 3:
				_set_tile(x - 1, y, Tile.ROOT)
				_set_tile(x + 1, y, Tile.ROOT)

		var branch_count := rng.randi_range(2, 4) if is_tall else rng.randi_range(1, 2)
		var branch_ends: Array[Vector2i] = []
		for branch_index in range(branch_count):
			var dir := -1 if branch_index % 2 == 0 else 1
			if rng.randf() < 0.35:
				dir *= -1
			var min_from_top := 3 if is_tall else 2
			var max_from_ground := height - 3
			var branch_y := ground_y - rng.randi_range(min_from_top, max_from_ground)
			var length := rng.randi_range(3, 5) if is_tall else rng.randi_range(2, 3)
			var rise := rng.randi_range(1, 2) if is_tall else rng.randi_range(0, 1)
			branch_ends.append(_add_tree_branch(Vector2i(x, branch_y), dir, length, rise, tree_id))

		var crown_center := Vector2i(x, ground_y - height)
		if is_dead:
			for root_offset in range(-2, 3):
				if root_offset != 0 and _get_tile(x + root_offset, ground_y - 1) == Tile.AIR:
					_set_tile(x + root_offset, ground_y - 1, Tile.ROOT)
		else:
			_add_leaf_cluster(crown_center, rng.randi_range(4, 5) if is_tall else rng.randi_range(3, 4), rng.randi_range(3, 4) if is_tall else rng.randi_range(2, 3), tree_id)
			_add_leaf_cluster(crown_center + Vector2i(-3, 1), rng.randi_range(2, 3), rng.randi_range(2, 3), tree_id)
			_add_leaf_cluster(crown_center + Vector2i(3, 1), rng.randi_range(2, 3), rng.randi_range(2, 3), tree_id)
			if is_tall:
				_add_leaf_cluster(crown_center + Vector2i(0, -2), rng.randi_range(3, 4), 2, tree_id)
			for branch_end in branch_ends:
				_add_leaf_cluster(branch_end + Vector2i(0, -1), rng.randi_range(2, 3), rng.randi_range(2, 3), tree_id)


func _allocate_tree_id() -> int:
	var tree_id := next_tree_id
	next_tree_id += 1
	return tree_id


func _set_tree_tile(x: int, y: int, tile: int, tree_id: int) -> void:
	if not _in_bounds(x, y):
		return
	var key := "%d,%d" % [x, y]
	var current := _get_tile(x, y)
	if current != Tile.AIR and int(tree_tile_owners.get(key, -1)) != tree_id:
		return
	_set_tile(x, y, tile)
	tree_tile_owners[key] = tree_id


func _add_tree_branch(start: Vector2i, dir: int, length: int, rise: int, tree_id: int) -> Vector2i:
	var end := start
	for i in range(1, length + 1):
		var branch_x := start.x + dir * i
		var branch_y := start.y - int(round(float(i) / float(maxi(1, length)) * float(rise)))
		end = Vector2i(branch_x, branch_y)
		_set_tree_tile(branch_x, branch_y, Tile.WOOD, tree_id)
		if i > 2 and i % 3 == 0 and rng.randf() < 0.7:
			_set_tree_tile(branch_x, branch_y - 1, Tile.WOOD, tree_id)
		if i > 3 and rng.randf() < 0.28:
			var offshoot_dir := -dir if rng.randf() < 0.45 else dir
			_set_tree_tile(branch_x + offshoot_dir, branch_y - 1, Tile.WOOD, tree_id)
	return end


func _add_leaf_cluster(center: Vector2i, radius_x: int, radius_y: int, tree_id: int) -> void:
	for yy in range(center.y - radius_y, center.y + radius_y + 1):
		for xx in range(center.x - radius_x, center.x + radius_x + 1):
			if not _in_bounds(xx, yy):
				continue
			var dx := float(xx - center.x) / float(maxi(1, radius_x))
			var dy := float(yy - center.y) / float(maxi(1, radius_y))
			var edge_noise := rng.randf_range(-0.28, 0.22)
			if dx * dx + dy * dy <= 1.0 + edge_noise and _get_tile(xx, yy) == Tile.AIR:
				_set_tree_tile(xx, yy, Tile.LEAVES, tree_id)


func _update_saplings(delta: float) -> void:
	sapling_growth_timer += delta
	if sapling_growth_timer < 4.0:
		return
	sapling_growth_timer = 0.0
	var grown := 0
	for key in sapling_positions.keys():
		var pos: Vector2i = sapling_positions[key]
		if _get_tile(pos.x, pos.y) != Tile.SAPLING:
			sapling_positions.erase(key)
			continue
		if rng.randf() > 0.18:
			continue
		if _can_grow_sapling(pos):
			_grow_sapling(pos)
			grown += 1
			if grown >= 3:
				return


func _can_grow_sapling(pos: Vector2i) -> bool:
	var below := _get_tile(pos.x, pos.y + 1)
	if below != Tile.GRASS and below != Tile.DIRT and below != Tile.MOSS and below != Tile.MUD:
		return false
	for y in range(pos.y - 10, pos.y + 1):
		for x in range(pos.x - 4, pos.x + 5):
			if not _in_bounds(x, y):
				return false
			var tile := _get_tile(x, y)
			if tile != Tile.AIR and tile != Tile.SAPLING and tile != Tile.LEAVES:
				return false
	return true


func _grow_sapling(pos: Vector2i) -> void:
	var tree_id := _allocate_tree_id()
	var height := rng.randi_range(6, 8)
	_set_tile(pos.x, pos.y, Tile.AIR)
	for y in range(pos.y - height + 1, pos.y + 1):
		_set_tree_tile(pos.x, y, Tile.WOOD, tree_id)
	var crown := Vector2i(pos.x, pos.y - height + 1)
	_add_leaf_cluster(crown, rng.randi_range(3, 4), rng.randi_range(2, 3), tree_id)
	_add_leaf_cluster(crown + Vector2i(-2, 1), 2, 2, tree_id)
	_add_leaf_cluster(crown + Vector2i(2, 1), 2, 2, tree_id)
	for branch_index in range(rng.randi_range(1, 2)):
		var dir := -1 if branch_index % 2 == 0 else 1
		var branch_y := pos.y - rng.randi_range(3, height - 2)
		var branch_end := _add_tree_branch(Vector2i(pos.x, branch_y), dir, rng.randi_range(2, 3), rng.randi_range(0, 1), tree_id)
		_add_leaf_cluster(branch_end, 2, 2, tree_id)


func _add_roots() -> void:
	for i in range(_scaled_count(42)):
		var x := rng.randi_range(WORLD_EDGE_ZONE + 6, WORLD_WIDTH - WORLD_EDGE_ZONE - 7)
		var y: int = surface_heights[x] + rng.randi_range(5, 32)
		var length := rng.randi_range(10, 30)
		for step in range(length):
			if not _in_bounds(x, y):
				break
			if _get_tile(x, y) != Tile.AIR:
				_set_tile(x, y, Tile.ROOT)
			x += rng.randi_range(-1, 1)
			y += rng.randi_range(0, 1)


func _add_ruins() -> void:
	for i in range(_scaled_count(7)):
		var w := rng.randi_range(5, 11)
		var h := rng.randi_range(4, 7)
		var x0 := rng.randi_range(20, WORLD_WIDTH - w - 20)
		var y0 := surface_heights[x0] + rng.randi_range(18, 58)
		for y in range(y0, y0 + h):
			for x in range(x0, x0 + w):
				if not _in_bounds(x, y):
					continue
				var is_wall := x == x0 or x == x0 + w - 1 or y == y0 or y == y0 + h - 1
				if is_wall and rng.randf() > 0.15:
					_set_tile(x, y, Tile.RUIN)
				elif not is_wall:
					_set_tile(x, y, Tile.AIR)
		_try_place_structure_chest(Vector2i(x0 + rng.randi_range(1, w - 2), y0 + h - 2), "ruin")


func _spawn_player() -> void:
	var spawn_x := int(WORLD_WIDTH / 2)
	var spawn_y: int = surface_heights[spawn_x] - 3
	player_position = Vector2(spawn_x * TILE_SIZE, spawn_y * TILE_SIZE)
	player_velocity = Vector2.ZERO
	player_on_floor = false
	landing_speed = 0.0
	_update_camera()


func _reset_exploration() -> void:
	explored_tiles.resize(WORLD_WIDTH * WORLD_HEIGHT)
	explored_tiles.fill(0)
	last_explored_tile = Vector2i(-999, -999)
	world_map_dirty = true


func _reveal_player_surroundings() -> void:
	if explored_tiles.size() != WORLD_WIDTH * WORLD_HEIGHT:
		_reset_exploration()
	var center := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
	if center == last_explored_tile:
		return
	last_explored_tile = center
	var changed := false
	const REVEAL_RADIUS_X := 13
	const REVEAL_RADIUS_Y := 8
	for y in range(center.y - REVEAL_RADIUS_Y, center.y + REVEAL_RADIUS_Y + 1):
		for x in range(center.x - REVEAL_RADIUS_X, center.x + REVEAL_RADIUS_X + 1):
			if not _in_bounds(x, y):
				continue
			var nx := float(x - center.x) / float(REVEAL_RADIUS_X)
			var ny := float(y - center.y) / float(REVEAL_RADIUS_Y)
			if nx * nx + ny * ny > 1.0:
				continue
			var index := y * WORLD_WIDTH + x
			if explored_tiles[index] == 0:
				explored_tiles[index] = 1
				changed = true
	if changed:
		world_map_dirty = true


func _is_tile_explored(x: int, y: int) -> bool:
	if not _in_bounds(x, y) or explored_tiles.size() != WORLD_WIDTH * WORLD_HEIGHT:
		return false
	return explored_tiles[y * WORLD_WIDTH + x] != 0


func _update_player(delta: float) -> void:
	if noclip_enabled:
		var horizontal := float(int(Input.is_action_pressed("move_right") or physical_move_right_held) - int(Input.is_action_pressed("move_left") or physical_move_left_held))
		var vertical := float(int(physical_noclip_down_held) - int(physical_noclip_up_held))
		var direction := Vector2(horizontal, vertical).normalized()
		var noclip_speed := 430.0 if Input.is_key_pressed(KEY_SHIFT) else 270.0
		player_velocity = direction * noclip_speed
		player_position += player_velocity * delta
		player_position.x = clampf(player_position.x, PLAYER_SIZE.x * 0.5, WORLD_WIDTH * TILE_SIZE - PLAYER_SIZE.x * 0.5)
		player_position.y = clampf(player_position.y, PLAYER_SIZE.y * 0.5, WORLD_HEIGHT * TILE_SIZE - PLAYER_SIZE.y * 0.5)
		if absf(horizontal) > 0.01:
			facing = 1 if horizontal > 0.0 else -1
		player_on_floor = false
		landing_speed = 0.0
		_reveal_player_surroundings()
		return
	var was_on_floor := player_on_floor
	player_on_floor = _is_on_floor()
	var direction := 0.0
	if not full_map_open and not player_statuses.has("root_bind"):
		var move_left := Input.is_action_pressed("move_left") or physical_move_left_held
		var move_right := Input.is_action_pressed("move_right") or physical_move_right_held
		direction = float(int(move_right) - int(move_left))
	var in_water := _player_overlaps_tile(Tile.WATER)
	var in_lava := _player_overlaps_tile(Tile.LAVA)
	var in_liquid := in_water or in_lava
	if absf(direction) > 0.01:
		facing = 1 if direction > 0.0 else -1
	var liquid_speed := 0.62 if in_water else (0.43 if in_lava else 1.0)
	player_velocity.x = direction * MOVE_SPEED * _player_speed_multiplier() * liquid_speed
	if in_liquid:
		var gravity_scale := 0.20 if in_water else 0.12
		player_velocity.y += GRAVITY * gravity_scale * delta
		if not full_map_open and not player_statuses.has("root_bind") and Input.is_action_pressed("jump"):
			player_velocity.y -= (650.0 if in_water else 430.0) * delta
		player_velocity.y = clampf(player_velocity.y, -190.0 if in_water else -125.0, 175.0 if in_water else 105.0)
		landing_speed = 0.0
	else:
		player_velocity.y += GRAVITY * delta
		landing_speed = maxf(landing_speed, player_velocity.y)

	if not full_map_open and not player_statuses.has("root_bind") and Input.is_action_just_pressed("jump") and player_on_floor and not in_liquid:
		player_velocity.y = JUMP_SPEED
		player_on_floor = false
		landing_speed = 0.0
		_emit_noise(player_position, 62.0, "jump", 0.65)

	_apply_world_edge_current(delta)
	_move_player(Vector2(player_velocity.x * delta, 0.0))
	_move_player(Vector2(0.0, player_velocity.y * delta))
	player_on_floor = _is_on_floor()
	_reveal_player_surroundings()
	if player_on_floor and not was_on_floor:
		if landing_speed > 185.0:
			_emit_noise(player_position, clampf(58.0 + (landing_speed - 185.0) * 0.35, 58.0, 175.0), "landing", 0.85)
		_apply_fall_damage(landing_speed)
		landing_speed = 0.0
	_update_player_footstep_noise(delta, in_liquid)
	_update_liquid_hazards(delta, in_water, in_lava)


func _apply_world_edge_current(delta: float) -> void:
	# Rather than stopping dead at an invisible wall, the dead sea pushes the
	# player back inland. The push grows towards the rim, so swimming out feels
	# like fighting a current and turning around always works.
	var tile_x := player_position.x / TILE_SIZE
	var distance := minf(tile_x, float(WORLD_WIDTH - 1) - tile_x)
	if distance >= float(WORLD_EDGE_CURRENT_ZONE):
		return
	var strength := 1.0 - distance / float(WORLD_EDGE_CURRENT_ZONE)
	var inward := 1.0 if tile_x < float(WORLD_WIDTH) * 0.5 else -1.0
	player_velocity.x += inward * WORLD_EDGE_CURRENT_FORCE * strength * strength * delta
	if strength > 0.55 and world_edge_warning_timer <= 0.0:
		world_edge_warning_timer = 6.0
		last_message = "The dead sea drags you back. There is nothing beyond it."


func _update_player_footstep_noise(delta: float, in_liquid: bool) -> void:
	player_footstep_noise_timer = maxf(0.0, player_footstep_noise_timer - delta)
	if not player_on_floor or absf(player_velocity.x) < MOVE_SPEED * 0.45:
		return
	if player_footstep_noise_timer > 0.0:
		return
	var radius := 54.0 if in_liquid else 78.0
	var strength := 0.55 if in_liquid else 0.72
	_emit_noise(player_position, radius * _weather_noise_mask(), "footstep", strength)
	player_footstep_noise_timer = 0.48 if in_liquid else 0.38


func _player_overlaps_tile(tile: int) -> bool:
	var rect := Rect2(player_position - PLAYER_SIZE * 0.45, PLAYER_SIZE * 0.90)
	var min_x := floori(rect.position.x / TILE_SIZE)
	var max_x := floori((rect.end.x - 1.0) / TILE_SIZE)
	var min_y := floori(rect.position.y / TILE_SIZE)
	var max_y := floori((rect.end.y - 1.0) / TILE_SIZE)
	var liquid := tile == Tile.WATER or tile == Tile.LAVA
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if _get_tile(x, y) != tile:
				continue
			if not liquid:
				return true
			# A partially filled liquid tile only counts where the liquid
			# actually is, so ankle-deep puddles do not trigger swimming.
			var fill_top := float(y + 1) * TILE_SIZE - float(TILE_SIZE) * _liquid_fill_ratio(x, y)
			if rect.end.y > fill_top:
				return true
	return false


func _player_head_submerged() -> bool:
	var head_y := player_position.y - PLAYER_SIZE.y * 0.38
	var head_tile := Vector2i(floori(player_position.x / TILE_SIZE), floori(head_y / TILE_SIZE))
	if _get_tile(head_tile.x, head_tile.y) != Tile.WATER:
		return false
	# Only drown when the head is under the actual waterline of that tile.
	var fill_top := float(head_tile.y + 1) * TILE_SIZE - float(TILE_SIZE) * _liquid_fill_ratio(head_tile.x, head_tile.y)
	return head_y > fill_top


func _equipped_accessory_has(property_name: String) -> bool:
	if equipped_accessory == "" or not gear_stats.has(equipped_accessory):
		return false
	return bool((gear_stats[equipped_accessory] as Dictionary).get(property_name, false))


func _temperature_protection(property_name: String) -> float:
	var total := 0.0
	for item_id in _equipped_gear_ids():
		if gear_stats.has(item_id):
			total += float((gear_stats[item_id] as Dictionary).get(property_name, 0.0))
	return clampf(total, 0.0, 0.85)


func _update_liquid_hazards(delta: float, in_water: bool, in_lava: bool) -> void:
	var can_breathe := _equipped_accessory_has("water_breathing")
	if in_water and _player_head_submerged() and not can_breathe:
		oxygen = maxf(0.0, oxygen - 17.0 * delta)
	else:
		oxygen = minf(MAX_OXYGEN, oxygen + 34.0 * delta)
	if oxygen <= 0.0:
		drowning_tick -= delta
		if drowning_tick <= 0.0:
			drowning_tick = 1.0
			_damage_player(7)
			last_message = "You are drowning."
	else:
		drowning_tick = 0.0

	if in_lava:
		lava_tick -= delta
		if lava_tick <= 0.0:
			lava_tick = 0.65
			if _equipped_accessory_has("heat_resistance"):
				_damage_player(2)
			else:
				_damage_player(10)
				_apply_player_status("burn")
				last_message = "The lava is burning you."
	else:
		lava_tick = 0.0


func _update_temperature(delta: float) -> void:
	temperature_sample_timer -= delta
	if temperature_sample_timer <= 0.0:
		temperature_sample_timer = 0.25
		ambient_temperature = _sample_ambient_temperature()
	var target_temperature := _temperature_target_for_environment(ambient_temperature)
	var target_distance := absf(target_temperature - body_temperature)
	var adjustment_rate := 0.28 + minf(6.0, target_distance) * 0.08
	if is_equal_approx(target_temperature, NORMAL_BODY_TEMPERATURE):
		adjustment_rate = 0.55
	body_temperature = move_toward(body_temperature, target_temperature, adjustment_rate * delta)
	body_temperature = clampf(body_temperature, MIN_BODY_TEMPERATURE, MAX_BODY_TEMPERATURE)
	_update_temperature_consequences(delta)


func _sample_ambient_temperature() -> float:
	if _player_overlaps_tile(Tile.LAVA):
		return 72.0
	var biome := _current_biome()
	var daylight := clampf((_daylight_factor() - 0.38) / 0.62, 0.0, 1.0)
	var environment := 13.0
	if biome == "forest":
		environment = lerpf(5.0, 23.0, daylight)
	elif biome == "mushroom_halls":
		environment = 18.0
	elif biome == "ash_city":
		environment = 30.0
	elif biome == "sunken_ruins":
		environment = 7.0
	elif biome == "lava_roots":
		environment = 34.0
	elif biome == "glass_abyss":
		environment = -12.0
	else:
		var tile_pos := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
		var surface_y := int(surface_heights[clampi(tile_pos.x, 0, surface_heights.size() - 1)]) if not surface_heights.is_empty() else tile_pos.y
		var depth := maxi(0, tile_pos.y - surface_y)
		environment = clampf(14.0 - float(depth) * 0.045, 6.0, 14.0)
	return environment + _local_heat_bonus(8) + _weather_temperature_shift()


func _local_heat_bonus(radius: int) -> float:
	var center := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
	var strongest_bonus := 0.0
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var tile := _get_tile(x, y)
			var source_heat := 0.0
			if tile == Tile.LAVA:
				source_heat = 38.0
			elif tile == Tile.LAVA_ROOT:
				source_heat = 14.0
			elif tile == Tile.FURNACE:
				source_heat = 10.0
			elif tile == Tile.TORCH:
				source_heat = 6.0
			if source_heat <= 0.0:
				continue
			var distance := Vector2(center).distance_to(Vector2(x, y))
			if distance > float(radius):
				continue
			var influence := 1.0 - distance / float(radius + 1)
			strongest_bonus = maxf(strongest_bonus, source_heat * influence)
	return strongest_bonus


func _temperature_target_for_environment(environment: float, cold_protection := -1.0, heat_protection := -1.0) -> float:
	var cold_resistance := _temperature_protection("cold_protection") if cold_protection < 0.0 else clampf(cold_protection, 0.0, 0.85)
	var heat_resistance := _temperature_protection("heat_protection") if heat_protection < 0.0 else clampf(heat_protection, 0.0, 0.85)
	var target := NORMAL_BODY_TEMPERATURE
	if environment < 14.0:
		var cold_deviation := minf(9.0, (14.0 - environment) * 0.32)
		target -= cold_deviation * (1.0 - cold_resistance)
	elif environment > 28.0:
		var heat_deviation := minf(9.0, (environment - 28.0) * 0.22)
		target += heat_deviation * (1.0 - heat_resistance)
	return clampf(target, MIN_BODY_TEMPERATURE, MAX_BODY_TEMPERATURE)


func _update_temperature_consequences(delta: float) -> void:
	var dangerous_cold := body_temperature <= 31.0
	var dangerous_heat := body_temperature >= 43.0
	if not dangerous_cold and not dangerous_heat:
		temperature_damage_tick = 0.0
		return
	temperature_damage_tick -= delta
	if temperature_damage_tick > 0.0:
		return
	temperature_damage_tick = 1.25
	_damage_player(4 if dangerous_cold else 5)
	last_message = "Your body temperature is dangerously low." if dangerous_cold else "Your body temperature is dangerously high."


func _temperature_action_multiplier() -> float:
	if body_temperature <= 31.0 or body_temperature >= 43.0:
		return 0.72
	if body_temperature < 34.0 or body_temperature > 40.0:
		return 0.86
	return 1.0


func _apply_fall_damage(speed: float) -> void:
	if speed <= FALL_DAMAGE_SPEED:
		return
	var damage := maxi(0, int((speed - FALL_DAMAGE_SPEED) / 28.0) - _total_defense())
	if damage <= 0:
		return
	_damage_player(damage)


func _damage_player(amount: int) -> void:
	if god_mode_enabled:
		health = MAX_HEALTH
		return
	if amount <= 0:
		return
	if player_hurt_timer > 0.0:
		return
	health = maxi(0, health - amount)
	player_hurt_timer = PLAYER_HURT_COOLDOWN
	_spawn_damage_number(player_position + Vector2(0, -22), amount, Color("ff7777"))
	_play_sound("hurt")
	last_message = "Ouch! Took %d damage." % amount
	if health <= 0:
		_respawn_player()


func _incoming_damage(amount: int, damage_type: String) -> int:
	var defense := _total_defense()
	if player_statuses.has("armor_break"):
		defense = maxi(0, defense - 3)
	if damage_type == "poison":
		defense = int(floor(float(defense) * 0.55))
	elif damage_type == "fire" or damage_type == "arcane":
		defense = int(floor(float(defense) * 0.72))
	var final_damage := maxi(1, amount - defense)
	if damage_type == "physical" and player_statuses.has("fragile"):
		final_damage = int(ceil(float(final_damage) * 1.20))
	return final_damage


func _apply_player_status(status: String) -> void:
	var duration := 3.0
	if status == "poison":
		duration = 5.0
	elif status == "burn":
		duration = 4.0
	elif status == "slow":
		duration = 2.5
	elif status == "root_bind":
		duration = 0.8
	elif status == "fragile":
		duration = 4.0
	elif status == "wet":
		duration = 4.0
		player_statuses.erase("burn")
	elif status == "armor_break":
		duration = 5.0
	# Reapplying an effect refreshes its duration instead of stacking strength.
	player_statuses[status] = {"time": duration, "tick": 0.0}


func _player_speed_multiplier() -> float:
	if player_statuses.has("root_bind"):
		return 0.0
	var multiplier := 1.0
	if player_statuses.has("slow"):
		multiplier *= 0.55
	if player_statuses.has("wet"):
		multiplier *= 0.80
	return multiplier * _temperature_action_multiplier()


func _respawn_player() -> void:
	health = MAX_HEALTH
	oxygen = MAX_OXYGEN
	body_temperature = NORMAL_BODY_TEMPERATURE
	ambient_temperature = 20.0
	temperature_sample_timer = 0.0
	temperature_damage_tick = 0.0
	temperature_visual_state = ""
	drowning_tick = 0.0
	lava_tick = 0.0
	# Keep living and dying mobs in the world when the player respawns. Death
	# resets the player, not the simulation around them.
	projectiles.clear()
	enemy_projectiles.clear()
	enemy_impact_effects.clear()
	perception_noise_events.clear()
	dropped_items.clear()
	damage_numbers.clear()
	hit_particles.clear()
	attack_anim_time = 0.0
	attack_anim_kind = ""
	held_item_id = ""
	held_item_amount = 0
	_spawn_player()



func _player_depth_below_surface() -> int:
	if surface_heights.is_empty():
		return 0
	var tile_x := clampi(floori(player_position.x / TILE_SIZE), 0, surface_heights.size() - 1)
	var tile_y := floori(player_position.y / TILE_SIZE)
	return maxi(0, tile_y - int(surface_heights[tile_x]))


func _weather_exposure() -> float:
	# 1.0 on the surface, fading to 0.0 by WEATHER_DEPTH_SILENT tiles down.
	# Underground the weather is neither seen, heard nor felt.
	var depth := _player_depth_below_surface()
	if depth <= WEATHER_DEPTH_FADE_START:
		return 1.0
	if depth >= WEATHER_DEPTH_SILENT:
		return 0.0
	var span := float(WEATHER_DEPTH_SILENT - WEATHER_DEPTH_FADE_START)
	return clampf(1.0 - float(depth - WEATHER_DEPTH_FADE_START) / span, 0.0, 1.0)


func _weather_strength() -> float:
	# How much the current weather actually affects the player right now.
	if weather == WEATHER_CLEAR:
		return 0.0
	return weather_intensity * _weather_exposure()


func _enemy_is_exposed_to_weather(pos: Vector2) -> bool:
	if surface_heights.is_empty():
		return false
	var tile_x := clampi(floori(pos.x / TILE_SIZE), 0, surface_heights.size() - 1)
	var tile_y := floori(pos.y / TILE_SIZE)
	return tile_y <= int(surface_heights[tile_x]) + WEATHER_DEPTH_FADE_START


func _weather_display_name(kind: String) -> String:
	match kind:
		WEATHER_RAIN:
			return "Rain"
		WEATHER_STORM:
			return "Thunderstorm"
		WEATHER_BLIZZARD:
			return "Blizzard"
		WEATHER_ASHFALL:
			return "Ash Storm"
		WEATHER_FOG:
			return "Fog"
	return "Clear"


func _weather_temperature_shift() -> float:
	# Weather pushes the ambient temperature, and the surface biome decides how
	# the same global system reads locally: rain over the ash desert is a warm
	# downpour, over the wasteland it is sleet.
	var strength := _weather_strength()
	if strength <= 0.0:
		return 0.0
	var biome := _surface_biome_at_player()
	var shift := 0.0
	match weather:
		WEATHER_RAIN:
			shift = -6.0
		WEATHER_STORM:
			shift = -9.0
		WEATHER_BLIZZARD:
			shift = -22.0
		WEATHER_ASHFALL:
			shift = 16.0
		WEATHER_FOG:
			shift = -3.0
	if biome == "frost_wasteland" and shift < 0.0:
		shift *= 1.5
	elif biome == "ash_desert" and shift > 0.0:
		shift *= 1.35
	return shift * strength


func _weather_visibility_penalty() -> float:
	# 0 clear .. 1 cannot see. Drives both the overlay and enemy vision.
	var strength := _weather_strength()
	if strength <= 0.0:
		return 0.0
	var penalty := 0.0
	match weather:
		WEATHER_BLIZZARD:
			penalty = 0.72
		WEATHER_ASHFALL:
			penalty = 0.60
		WEATHER_FOG:
			penalty = 0.66
		WEATHER_STORM:
			penalty = 0.34
		WEATHER_RAIN:
			penalty = 0.22
	return penalty * strength


func _weather_noise_mask() -> float:
	# Loud weather drowns out footsteps; fog does the opposite and carries them.
	var strength := _weather_strength()
	if strength <= 0.0:
		return 1.0
	match weather:
		WEATHER_STORM:
			return 1.0 - 0.55 * strength
		WEATHER_RAIN:
			return 1.0 - 0.35 * strength
		WEATHER_BLIZZARD:
			return 1.0 - 0.45 * strength
		WEATHER_FOG:
			return 1.0 + 0.30 * strength
	return 1.0


func _pick_next_weather() -> String:
	# Weighted by the biome the player is standing in, but the result is global.
	var biome := _surface_biome_at_player()
	var weights := {
		WEATHER_RAIN: 30.0, WEATHER_STORM: 14.0, WEATHER_BLIZZARD: 10.0,
		WEATHER_ASHFALL: 10.0, WEATHER_FOG: 20.0,
	}
	match biome:
		"frost_wasteland":
			weights[WEATHER_BLIZZARD] = 46.0
			weights[WEATHER_RAIN] = 8.0
		"ash_desert":
			weights[WEATHER_ASHFALL] = 46.0
			weights[WEATHER_RAIN] = 6.0
			weights[WEATHER_BLIZZARD] = 2.0
		"marsh":
			weights[WEATHER_FOG] = 40.0
			weights[WEATHER_RAIN] = 38.0
		"ash_ruins":
			weights[WEATHER_FOG] = 30.0
			weights[WEATHER_ASHFALL] = 24.0
	var total := 0.0
	for key in weights:
		total += float(weights[key])
	var roll := rng.randf() * total
	for key in weights:
		roll -= float(weights[key])
		if roll <= 0.0:
			return str(key)
	return WEATHER_RAIN


func _start_weather(kind: String, duration: float) -> void:
	weather = kind
	weather_timer = duration
	weather_target_intensity = 1.0 if kind != WEATHER_CLEAR else 0.0
	weather_particles.clear()
	if kind != WEATHER_CLEAR and _weather_exposure() > 0.35:
		last_message = "%s rolls in." % _weather_display_name(kind)


func _update_weather(delta: float) -> void:
	weather_timer -= delta
	if weather_timer <= 0.0:
		if weather == WEATHER_CLEAR:
			_start_weather(_pick_next_weather(), rng.randf_range(55.0, 130.0))
		else:
			_start_weather(WEATHER_CLEAR, rng.randf_range(90.0, 220.0))
	# Ease in and out so weather never snaps on.
	var ease_rate := 0.35 * delta
	weather_intensity = move_toward(weather_intensity, weather_target_intensity, ease_rate)
	if weather == WEATHER_CLEAR and weather_intensity <= 0.01:
		weather_particles.clear()
	lightning_flash = maxf(0.0, lightning_flash - delta * 3.2)
	_update_weather_particles(delta)
	_update_lightning(delta)
	_update_weather_effects(delta)


func _update_weather_effects(delta: float) -> void:
	var strength := _weather_strength()
	if strength < 0.25:
		return
	# Rain soaks the player, a blizzard chills, ash burns the lungs.
	weather_sound_timer -= delta
	if weather_sound_timer <= 0.0:
		weather_sound_timer = 2.0
		match weather:
			WEATHER_RAIN, WEATHER_STORM:
				_apply_player_status("wet")
			WEATHER_BLIZZARD:
				if _temperature_protection("cold_protection") < 0.35:
					_apply_player_status("slow")
			WEATHER_ASHFALL:
				if _temperature_protection("heat_protection") < 0.30:
					oxygen = maxf(0.0, oxygen - 6.0 * strength)


func _update_lightning(delta: float) -> void:
	if weather != WEATHER_STORM:
		lightning_timer = 0.0
		return
	var strength := _weather_strength()
	if strength < 0.4:
		return
	lightning_timer -= delta
	if lightning_timer > 0.0:
		return
	lightning_timer = rng.randf_range(LIGHTNING_MIN_INTERVAL, LIGHTNING_MAX_INTERVAL)
	_strike_lightning()


func _strike_lightning() -> void:
	# Strikes near the player, but only where the sky is actually open, so
	# standing under cover or underground is real protection.
	var player_tile_x := floori(player_position.x / TILE_SIZE)
	var offset := rng.randi_range(-LIGHTNING_STRIKE_RANGE, LIGHTNING_STRIKE_RANGE)
	var strike_x := clampi(player_tile_x + offset, 2, WORLD_WIDTH - 3)
	var ground_y := -1
	for y in range(0, WORLD_HEIGHT - 1):
		if _is_solid(strike_x, y):
			ground_y = y
			break
	if ground_y < 0:
		return
	# Anything under a roof is safe: the first solid tile has to be the surface.
	if ground_y > int(surface_heights[strike_x]) + 3:
		return
	lightning_flash = 0.35
	_play_sound("hit")
	# The strike leaves molten ground behind.
	_set_tile(strike_x, ground_y, Tile.LAVA)
	_spawn_hit_particles(Vector2(strike_x * TILE_SIZE + 8, ground_y * TILE_SIZE), Color("ffe6a8"), 10)
	_emit_noise(Vector2(strike_x * TILE_SIZE, ground_y * TILE_SIZE), 420.0, "thunder", 1.6)
	# Close strikes hurt, and the player has to be out in the open too.
	var distance_tiles := absi(strike_x - player_tile_x)
	if distance_tiles <= 3 and _player_depth_below_surface() <= 2:
		_damage_player(maxi(1, LIGHTNING_DAMAGE - _total_defense()))
		_apply_player_status("burn")
		last_message = "Lightning strikes beside you!"


func _update_weather_particles(delta: float) -> void:
	var strength := _weather_strength()
	if strength <= 0.02 or camera == null:
		weather_particles.clear()
		return
	var view := get_viewport_rect().size / camera.zoom
	var centre := camera.get_screen_center_position()
	var left := centre.x - view.x * 0.5
	var top := centre.y - view.y * 0.5
	var wanted := 0
	var fall := Vector2.ZERO
	match weather:
		WEATHER_RAIN:
			wanted = int(150 * strength)
			fall = Vector2(-70.0, 620.0)
		WEATHER_STORM:
			wanted = int(210 * strength)
			fall = Vector2(-160.0, 760.0)
		WEATHER_BLIZZARD:
			wanted = int(190 * strength)
			fall = Vector2(-190.0, 190.0)
		WEATHER_ASHFALL:
			wanted = int(160 * strength)
			fall = Vector2(150.0, 130.0)
		WEATHER_FOG:
			wanted = 0
	while weather_particles.size() > wanted:
		weather_particles.pop_back()
	while weather_particles.size() < wanted:
		weather_particles.append({
			"pos": Vector2(left + rng.randf() * view.x, top + rng.randf() * view.y),
			"speed": rng.randf_range(0.75, 1.3),
		})
	for particle in weather_particles:
		var pos: Vector2 = particle["pos"]
		pos += fall * float(particle["speed"]) * delta
		# Wrap around the view so the field always looks full.
		if pos.y > top + view.y:
			pos.y = top - 8.0
			pos.x = left + rng.randf() * view.x
		if pos.x < left - 12.0:
			pos.x = left + view.x
		elif pos.x > left + view.x + 12.0:
			pos.x = left
		particle["pos"] = pos


func _draw_weather() -> void:
	var strength := _weather_strength()
	if strength <= 0.02:
		return
	var view := get_viewport_rect().size / camera.zoom
	var centre := camera.get_screen_center_position()
	var top_left := centre - view * 0.5
	var screen := Rect2(top_left, view)
	# Overcast tint, then the particle field, then the flash.
	var tint := Color(0.05, 0.07, 0.10, 0.30 * strength)
	match weather:
		WEATHER_BLIZZARD:
			tint = Color(0.62, 0.72, 0.80, 0.34 * strength)
		WEATHER_ASHFALL:
			tint = Color(0.32, 0.20, 0.13, 0.40 * strength)
		WEATHER_FOG:
			tint = Color(0.55, 0.58, 0.55, 0.42 * strength)
	draw_rect(screen, tint)
	for particle in weather_particles:
		var pos: Vector2 = particle["pos"]
		match weather:
			WEATHER_RAIN, WEATHER_STORM:
				var length := 9.0 if weather == WEATHER_RAIN else 13.0
				draw_line(pos, pos + Vector2(-1.6, length), Color("9fc4d8", 0.55), 1.0)
			WEATHER_BLIZZARD:
				draw_rect(Rect2(pos, Vector2(2, 2)), Color("eaf4ff", 0.80))
			WEATHER_ASHFALL:
				draw_rect(Rect2(pos, Vector2(2, 2)), Color("caa77d", 0.62))
	if lightning_flash > 0.0:
		draw_rect(screen, Color(0.92, 0.95, 1.0, clampf(lightning_flash, 0.0, 0.55)))


func _update_day_night(delta: float) -> void:
	world_time = fposmod(world_time + delta, FULL_DAY_DURATION)


func _is_night() -> bool:
	return world_time >= DAY_DURATION


func _daylight_factor() -> float:
	if _is_night():
		return 0.38
	if world_time < 90.0:
		return lerpf(0.38, 1.0, world_time / 90.0)
	if world_time > DAY_DURATION - 120.0:
		return lerpf(1.0, 0.38, (world_time - (DAY_DURATION - 120.0)) / 120.0)
	return 1.0


func _time_period_text() -> String:
	if _is_night():
		var remaining := int(ceil(FULL_DAY_DURATION - world_time))
		return "Night %02d:%02d" % [remaining / 60, remaining % 60]
	var day_remaining := int(ceil(DAY_DURATION - world_time))
	return "Day %02d:%02d" % [day_remaining / 60, day_remaining % 60]


func _update_combat(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	player_hurt_timer = maxf(0.0, player_hurt_timer - delta)
	_update_noise_events(delta)
	_collect_visible_light_sources()
	enemy_spawn_timer -= delta
	if enemy_spawn_timer <= 0.0:
		enemy_spawn_timer = ENEMY_SPAWN_INTERVAL
		_try_spawn_enemy()
	if defeated_enemies >= 10 and not boss_spawned and not boss_defeated:
		_spawn_enemy("heartwood_boss", _find_spawn_position_near_player(18, 26))
		boss_spawned = true
		_play_sound("boss")
		last_message = "The old root heart has awakened."
	_update_enemy_ai(delta)
	_update_enemy_deaths(delta)
	_update_projectiles(delta)
	_update_enemy_projectiles(delta)
	_update_enemy_impact_effects(delta)
	_update_engineer_turret(delta)
	_update_status_effects(delta)


func _try_spawn_enemy() -> void:
	if enemies.size() >= MAX_ENEMIES:
		return
	# The dead sea has its own spawn rules: the further out the player swims,
	# the more it hunts back. This is what makes the world edge dangerous
	# instead of merely impassable.
	if _try_spawn_sea_creature():
		return
	var player_tile := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
	var depth := player_tile.y - int(surface_heights[clampi(player_tile.x, 0, surface_heights.size() - 1)])
	var near_ruins := _has_tile_near_player(Tile.RUIN, 13)
	var near_roots := _has_tile_near_player(Tile.ROOT, 10)
	var biome := _current_biome()
	var in_cave := depth > 10
	var spawn_chance := 0.22
	if _is_night():
		spawn_chance = 0.70
	elif in_cave:
		spawn_chance = 0.48
	if near_ruins:
		spawn_chance += 0.18
	if rng.randf() > spawn_chance:
		return
	var enemy_type := "ash_wisp"
	if biome == "glass_abyss":
		enemy_type = "glass_wraith"
	elif biome == "lava_roots":
		enemy_type = "ember_rootling"
	elif biome == "sunken_ruins":
		enemy_type = "drowned_guard"
	elif biome == "ash_city":
		enemy_type = "ash_sentinel" if rng.randf() < 0.55 else "ruin_drone"
	elif biome == "mushroom_halls":
		enemy_type = "mushroom_beetle" if rng.randf() < 0.65 else "spore_bat"
	elif biome == "forest" and rng.randf() < 0.45:
		enemy_type = "mossling"
	elif not in_cave and biome == "frost_wasteland":
		# Surface frost variants reuse the normal combat logic and only swap art.
		enemy_type = "wild_slime" if rng.randf() < 0.52 else "bat"
	elif not in_cave and biome == "ash_desert":
		enemy_type = "wild_slime"
	elif not in_cave and biome == "marsh":
		enemy_type = "mossling" if rng.randf() < 0.62 else "wild_slime"
	elif near_ruins and rng.randf() < 0.55:
		enemy_type = "ruin_drone"
	elif _is_night():
		enemy_type = "ash_phantom" if rng.randf() < 0.42 else "night_ember"
	elif mushroom_path_opened and depth > 24 and rng.randf() < 0.35:
		enemy_type = "mushroom_beetle"
	elif near_roots and rng.randf() < 0.55:
		enemy_type = "root_crawler"
	elif in_cave:
		enemy_type = "cave_worm" if rng.randf() < 0.34 else ("bat" if rng.randf() < 0.5 else "cave_husk")
	elif rng.randf() < 0.55:
		enemy_type = "wild_slime"
	var spawn_data := _enemy_template(enemy_type)
	var pos := _find_spawn_position_near_player(18, 30, bool(spawn_data.get("flying", false)), spawn_data.get("size", Vector2(16, 16)))
	_spawn_enemy(enemy_type, pos)


func _sea_threat_level() -> float:
	# 0.0 on dry land or at the shore, 1.0 out where the undertow is strongest.
	# Only counts while the player is actually in the water: if the sea has
	# been drained there is no threat and therefore no spawns.
	if not _player_overlaps_tile(Tile.WATER):
		return 0.0
	var tile_x := player_position.x / TILE_SIZE
	var distance := minf(tile_x, float(WORLD_WIDTH - 1) - tile_x)
	if distance >= float(WORLD_EDGE_ZONE):
		return 0.0
	var offshore := 1.0 - distance / float(WORLD_EDGE_ZONE)
	# Ignore the first stretch so paddling at the beach stays safe.
	if offshore <= WORLD_EDGE_SEA_START:
		return 0.0
	return clampf((offshore - WORLD_EDGE_SEA_START) / (1.0 - WORLD_EDGE_SEA_START), 0.0, 1.0)


func _count_enemies_of_type(enemy_type: String) -> int:
	var count := 0
	for enemy in enemies:
		if str(enemy.get("type", "")) == enemy_type:
			count += 1
	return count


func _find_sea_spawn_position() -> Vector2:
	# Look for open water near the player, preferring spots slightly further
	# out to sea so creatures close in from the deep.
	for attempt in range(26):
		var angle := rng.randf() * TAU
		var radius := rng.randf_range(7.0, 17.0) * TILE_SIZE
		var candidate := player_position + Vector2(cos(angle), sin(angle)) * radius
		if candidate.x < TILE_SIZE or candidate.x > float(WORLD_WIDTH - 2) * TILE_SIZE:
			continue
		if not _tile_is_water_at(candidate):
			continue
		# Keep a little distance so nothing materialises on top of the player.
		if candidate.distance_to(player_position) < 6.0 * TILE_SIZE:
			continue
		# A single wet tile is not a sea. If the pool has drained there must be
		# no spawn at all, so require real water around and below the spot.
		if not _has_open_water_body(candidate):
			continue
		return candidate
	return Vector2.ZERO


func _has_open_water_body(world_pos: Vector2) -> bool:
	# Counts water in a small box around the candidate. A puddle left behind by
	# a drained sea cannot pass this, so creatures simply stop appearing.
	var tile_x := floori(world_pos.x / TILE_SIZE)
	var tile_y := floori(world_pos.y / TILE_SIZE)
	var water := 0
	for y in range(tile_y - 2, tile_y + 4):
		for x in range(tile_x - 3, tile_x + 4):
			if _get_tile(x, y) == Tile.WATER:
				water += 1
	if water < 18:
		return false
	# It also has to be deep: three tiles of water straight down.
	for depth in range(1, 4):
		if _get_tile(tile_x, tile_y + depth) != Tile.WATER:
			return false
	return true


func _try_spawn_sea_creature() -> bool:
	var threat := _sea_threat_level()
	if threat <= 0.0:
		return false
	# Swarmers come first and stay common; the leviathan only shows up deep
	# out and is capped so the far water is deadly but not an instant wall.
	var spawn_chance := lerpf(0.30, 0.92, threat)
	if rng.randf() > spawn_chance:
		return true
	var enemy_type := "brine_lurker"
	# The Sea Leviathan is the border itself: one at a time, only far out, and
	# it takes priority over everything else in the water.
	if threat > 0.55 and _count_enemies_of_type("sea_leviathan") == 0:
		enemy_type = "sea_leviathan"
	elif threat > 0.62 and _count_enemies_of_type("drowned_leviathan") < 2 \
			and rng.randf() < lerpf(0.0, 0.35, (threat - 0.62) / 0.38):
		enemy_type = "drowned_leviathan"
	elif _count_enemies_of_type("brine_lurker") >= 5:
		return true
	var pos := _find_sea_spawn_position()
	if pos == Vector2.ZERO:
		return true
	_spawn_enemy(enemy_type, pos)
	if enemy_type == "sea_leviathan" and world_edge_warning_timer <= 0.0:
		world_edge_warning_timer = 8.0
		last_message = "The water goes still. Something ancient has noticed you."
	elif enemy_type == "drowned_leviathan" and world_edge_warning_timer <= 0.0:
		world_edge_warning_timer = 6.0
		last_message = "Something vast moves in the deep water."
	return true


func _compute_current_biome() -> String:
	var tile_pos := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
	var surface_y: int = surface_heights[clampi(tile_pos.x, 0, surface_heights.size() - 1)]
	var depth := tile_pos.y - surface_y
	if _has_tile_near_player(Tile.ABYSS_CRYSTAL, 14) or tile_pos.y > WORLD_HEIGHT - 44:
		return "glass_abyss"
	if _has_tile_near_player(Tile.LAVA_ROOT, 13):
		return "lava_roots"
	if _has_tile_near_player(Tile.SUNKEN_STONE, 13):
		return "sunken_ruins"
	if _has_tile_near_player(Tile.ASH_BRICK, 14):
		return "ash_city"
	if _has_tile_near_player(Tile.GLOW_MUSHROOM, 14) or _has_tile_near_player(Tile.MUSHROOM_SOIL, 14):
		return "mushroom_halls"
	if depth <= 10:
		return _surface_biome_at_column(tile_pos.x)
	# Frost caves are a distinct underground climate, but remain tied to the
	# frost surface above them instead of being scattered world-wide.
	if _surface_biome_at_column(tile_pos.x) == "frost_wasteland":
		return "frost_caves"
	return "caves"


func _current_biome() -> String:
	return cached_biome


func _update_biome_cache(delta: float) -> void:
	biome_check_timer += delta
	if biome_check_timer < 0.25:
		return
	biome_check_timer = 0.0
	cached_biome = _compute_current_biome()


func _update_biome_audio() -> void:
	var biome := cached_biome
	if biome == last_biome:
		return
	last_biome = biome
	var sound_name := "cave_event"
	if biome == "forest":
		sound_name = "forest_event"
	elif biome == "mushroom_halls":
		sound_name = "mushroom_event"
	elif biome == "ash_city":
		sound_name = "ash_event"
	elif biome == "sunken_ruins":
		sound_name = "water_event"
	elif biome == "lava_roots":
		sound_name = "lava_event"
	elif biome == "glass_abyss":
		sound_name = "glass_event"
	_play_sound(sound_name)
	last_message = "Entered %s." % _biome_display_name(biome)


func _has_tile_near_player(tile: int, radius: int) -> bool:
	var center := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if _in_bounds(x, y) and _get_tile(x, y) == tile:
				return true
	return false


func _find_spawn_position_near_player(min_tiles: int, max_tiles: int, flying := false, spawn_size := Vector2(16, 16)) -> Vector2:
	var player_tile := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
	for attempt in range(30):
		var dir := -1 if rng.randf() < 0.5 else 1
		var x := clampi(player_tile.x + dir * rng.randi_range(min_tiles, max_tiles), 4, WORLD_WIDTH - 5)
		if flying:
			var flying_y := clampi(player_tile.y + rng.randi_range(-8, 7), 4, WORLD_HEIGHT - 6)
			var flying_rect := Rect2(Vector2(x * TILE_SIZE + 8.0, flying_y * TILE_SIZE + 8.0) - spawn_size * 0.5, spawn_size)
			if not _rect_collides(flying_rect):
				return flying_rect.get_center()
			continue
		# Search for a real floor around the player's current depth. Ground enemies
		# no longer spawn in mid-air above the surface.
		for offset in range(0, 54):
			var sign_dir := -1 if offset % 2 == 0 else 1
			var y := player_tile.y + sign_dir * int(ceil(float(offset) * 0.5))
			if y < 2 or y >= WORLD_HEIGHT - 3:
				continue
			if _get_tile(x, y) != Tile.AIR or not _is_solid(x, y + 1):
				continue
			var ground_pos := Vector2(x * TILE_SIZE + TILE_SIZE * 0.5, (y + 1) * TILE_SIZE - spawn_size.y * 0.5)
			var ground_rect := Rect2(ground_pos - spawn_size * 0.5, spawn_size)
			if not _rect_collides(ground_rect):
				return ground_pos
	return player_position + Vector2(TILE_SIZE * min_tiles, -TILE_SIZE * 4)


func _find_bat_roost_position(origin: Vector2, size: Vector2) -> Vector2:
	var origin_tile := Vector2i(floori(origin.x / TILE_SIZE), floori(origin.y / TILE_SIZE))
	for upward in range(0, 11):
		var ceiling_y := origin_tile.y - upward
		if ceiling_y < 1:
			break
		for x_offset in [0, -1, 1, -2, 2]:
			var ceiling_x := origin_tile.x + int(x_offset)
			if ceiling_x < 1 or ceiling_x >= WORLD_WIDTH - 1:
				continue
			if not _is_solid(ceiling_x, ceiling_y):
				continue
			var candidate := Vector2(
				ceiling_x * TILE_SIZE + TILE_SIZE * 0.5,
				(ceiling_y + 1) * TILE_SIZE + size.y * 0.5 + 1.0
			)
			if _enemy_position_valid(candidate, size):
				return candidate
	return Vector2(-1.0, -1.0)


func _enemy_surface_visual_variant(enemy_type: String, pos: Vector2) -> String:
	if enemy_type != "wild_slime" and enemy_type != "bat":
		return enemy_type
	var tile_x := clampi(floori(pos.x / TILE_SIZE), 0, WORLD_WIDTH - 1)
	var surface_y := surface_heights[tile_x] if tile_x < surface_heights.size() else 0
	# Cave creatures keep their normal visual. Variants are surface climates only.
	if pos.y > float((surface_y + 10) * TILE_SIZE):
		return enemy_type
	var surface_biome := _surface_biome_at_column(tile_x)
	if surface_biome == "frost_wasteland":
		return "frost_wild_slime" if enemy_type == "wild_slime" else "frost_bat"
	if surface_biome == "ash_desert" and enemy_type == "wild_slime":
		return "desert_wild_slime"
	return enemy_type


func _enemy_visual_type(enemy: Dictionary) -> String:
	var enemy_type := str(enemy.get("type", "wild_slime"))
	var variant := str(enemy.get("visual_variant", enemy_type))
	return variant if enemy_textures.has(variant) else enemy_type


func _is_sea_creature(enemy_type: String) -> bool:
	return enemy_type in ["brine_lurker", "drowned_leviathan", "sea_leviathan"]


func _tile_is_water_at(world_pos: Vector2) -> bool:
	var tile_x := floori(world_pos.x / TILE_SIZE)
	var tile_y := floori(world_pos.y / TILE_SIZE)
	if _get_tile(tile_x, tile_y) != Tile.WATER:
		return false
	# Respect the liquid fill level so a creature cannot swim through the air
	# gap above a half-filled tile.
	var filled := float(TILE_SIZE) * _liquid_fill_ratio(tile_x, tile_y)
	var fill_top := float(tile_y + 1) * TILE_SIZE - filled
	return world_pos.y > fill_top


func _constrain_sea_creature(
	enemy: Dictionary, pos: Vector2, size: Vector2, delta: float
) -> Vector2:
	# Water is a hard boundary, not a suggestion. Chasing a flying or noclipping
	# player used to drag sea creatures into the sky, because the AI climbed
	# faster than the old gentle sink could pull them back. The body is now
	# snapped to the surface instead, so a fish can never leave the sea.
	if _tile_is_water_at(pos):
		enemy["beached_time"] = 0.0
		var head := pos - Vector2(0.0, size.y * 0.4)
		if not _tile_is_water_at(head):
			# Breaching: push the body down until the head is under again.
			pos.y += 46.0 * delta
		return pos

	# Out of the water. Find the surface directly below and clamp onto it.
	var tile_x := floori(pos.x / TILE_SIZE)
	var tile_y := floori(pos.y / TILE_SIZE)
	var surface_y := -1
	for step in range(1, 26):
		var probe := tile_y + step
		if probe >= WORLD_HEIGHT:
			break
		if _get_tile(tile_x, probe) == Tile.WATER:
			surface_y = probe
			break
	if surface_y >= 0:
		# Snap to just under the waterline rather than drifting down to it.
		var target_y := float(surface_y) * TILE_SIZE + size.y * 0.5 + 2.0
		pos.y = minf(target_y, pos.y + maxf(120.0 * delta, target_y - pos.y))
		enemy["beached_time"] = 0.0
		enemy["vel"] = Vector2.ZERO
		return pos

	# No water anywhere below: it is genuinely beached and suffocates.
	var beached := float(enemy.get("beached_time", 0.0)) + delta
	enemy["beached_time"] = beached
	pos.y += 46.0 * delta
	if beached > 2.6:
		enemy["hp"] = 0
	return pos


func _enemy_base_tier(enemy_type: String) -> int:
	if enemy_type in ["wild_slime", "mossling", "bat"]:
		return 1
	if enemy_type in ["root_crawler", "cave_worm", "cave_husk", "spore_bat", "mushroom_beetle"]:
		return 2
	if enemy_type in ["ash_wisp", "ash_phantom", "ruin_drone", "drowned_guard", "brine_lurker", "heartwood_boss"]:
		return 3
	if enemy_type in ["ash_sentinel", "ember_rootling", "night_ember", "stone_beast"]:
		return 4
	if enemy_type in ["glass_wraith", "drowned_leviathan", "sea_leviathan"]:
		return 5
	if enemy_type == "archive_warden":
		return 6
	return 1


func _player_progression_tier() -> int:
	var tier := 1
	if gear_stats.has(equipped_weapon):
		tier = maxi(tier, int((gear_stats[equipped_weapon] as Dictionary).get("tier", 1)))
	if tools.has(current_tool):
		tier = maxi(tier, maxi(1, int((tools[current_tool] as Dictionary).get("tier", 1)) - 1))
	for item_id in _equipped_gear_ids():
		if gear_stats.has(item_id):
			tier = maxi(tier, int((gear_stats[item_id] as Dictionary).get("tier", 1)) - 1)
	if boss_defeated:
		tier = maxi(tier, 3)
	if stone_beast_defeated:
		tier = maxi(tier, 4)
	if archive_warden_defeated:
		tier = maxi(tier, 6)
	return clampi(tier, 1, 6)


func _effective_enemy_tier(enemy_type: String) -> int:
	var base_tier := _enemy_base_tier(enemy_type)
	var player_tier := _player_progression_tier()
	var catch_up := int(ceil(float(maxi(0, player_tier - base_tier)) * 0.5))
	return clampi(base_tier + catch_up, base_tier, 6)


func _apply_enemy_progression(data: Dictionary, enemy_type: String) -> void:
	var tier := _effective_enemy_tier(enemy_type)
	var hp_multipliers := [1.0, 1.15, 1.35, 1.60, 1.90, 2.25]
	var damage_multipliers := [1.0, 1.08, 1.18, 1.30, 1.43, 1.58]
	var speed_multipliers := [1.0, 1.02, 1.04, 1.06, 1.08, 1.10]
	var base_hp := int(data.get("max_hp", data.get("hp", 1)))
	var base_damage := int(data.get("damage", 1))
	var base_speed := float(data.get("speed", 50.0))
	var scaled_hp := maxi(1, int(round(float(base_hp) * float(hp_multipliers[tier - 1]))))
	data["tier"] = tier
	data["base_tier"] = _enemy_base_tier(enemy_type)
	data["base_max_hp"] = base_hp
	data["base_damage"] = base_damage
	data["max_hp"] = scaled_hp
	data["hp"] = scaled_hp
	data["damage"] = maxi(1, int(round(float(base_damage) * float(damage_multipliers[tier - 1]))))
	data["speed"] = base_speed * float(speed_multipliers[tier - 1])


func _spawn_enemy(enemy_type: String, pos: Vector2) -> void:
	var data := _enemy_template(enemy_type)
	_apply_enemy_progression(data, enemy_type)
	data["perception_id"] = next_enemy_perception_id
	next_enemy_perception_id += 1
	data["type"] = enemy_type
	data["visual_variant"] = _enemy_surface_visual_variant(enemy_type, pos)
	data["pos"] = pos
	data["vel"] = Vector2.ZERO
	data["hit_timer"] = 0.0
	data["stun_timer"] = 0.0
	data["attack_windup"] = 0.0
	data["attack_flash"] = 0.0
	data["attack_cooldown"] = rng.randf_range(0.25, 0.8)
	data["facing"] = -1 if rng.randf() < 0.5 else 1
	data["anim_offset"] = rng.randf() * 10.0
	data["anim_state"] = "idle"
	data["anim_time"] = 0.0
	data["home_pos"] = pos
	data["perception_state"] = PERCEPTION_CALM
	data["suspicion"] = 0.0
	data["last_known_pos"] = pos
	data["investigate_pos"] = pos
	data["search_target"] = pos
	data["memory_timer"] = 0.0
	data["search_timer"] = 0.0
	data["search_step_timer"] = 0.0
	data["last_noise_id"] = 0
	data["can_see_player"] = false
	data["alert_cooldown"] = 0.0
	data["idle_look_timer"] = rng.randf_range(1.2, 3.5)
	data["last_safe_pos"] = pos
	data["stuck_time"] = 0.0
	data["jump_cooldown"] = rng.randf_range(0.15, 0.45)
	data["hop_timer"] = rng.randf_range(0.35, 0.75) if enemy_type == "wild_slime" else 0.0
	data["avoid_timer"] = 0.0
	data["avoid_direction"] = 0
	data["burrow_hidden"] = false
	data["burrow_origin"] = pos
	data["burrow_target"] = pos
	data["burrow_dust_started"] = false
	data["roll_active"] = false
	data["roll_direction"] = int(data["facing"])
	data["roll_dust_started"] = false
	data["roll_time"] = 0.0
	data["roosting"] = false
	data["wake_timer"] = 0.0
	data["dive_phase"] = ""
	data["dive_timer"] = 0.0
	data["dive_direction"] = Vector2.ZERO
	data["dive_hit"] = false
	data["alert_timer"] = 0.0
	data["trail_timer"] = rng.randf_range(0.05, 0.35)
	if enemy_type == "bat":
		var roost_pos := _find_bat_roost_position(pos, data.get("size", Vector2(22, 14)))
		if roost_pos.x >= 0.0:
			data["pos"] = roost_pos
			data["home_pos"] = roost_pos
			data["last_safe_pos"] = roost_pos
			data["roosting"] = true
			data["anim_state"] = "hang_idle"
	# Bats can be moved to a cave roost after their initial spawn point was
	# chosen, so resolve the surface palette one more time at the final position.
	data["visual_variant"] = _enemy_surface_visual_variant(enemy_type, data["pos"])
	if enemy_type == "heartwood_boss" or enemy_type == "archive_warden":
		data["spawn_timer"] = _enemy_animation_duration(enemy_type, "spawn", 0.85)
		data["phase_two"] = false
		data["phase_timer"] = 0.0
		data["anim_state"] = "spawn"
		data["perception_state"] = PERCEPTION_COMBAT
		data["last_known_pos"] = player_position
		data["memory_timer"] = float(_enemy_perception_profile(enemy_type).get("memory_time", 10.0))
	enemies.append(data)


func _enemy_template(enemy_type: String) -> Dictionary:
	return EnemyData.template(enemy_type)


func _enemy_perception_profile(enemy_type: String) -> Dictionary:
	return EnemyData.perception_profile(enemy_type)


func _enemy_movement_profile(enemy_type: String) -> Dictionary:
	return EnemyData.movement_profile(enemy_type)


func _emit_noise(pos: Vector2, radius: float, kind: String, strength := 1.0) -> void:
	if radius <= 0.0:
		return
	perception_noise_events.append({
		"id": next_noise_event_id,
		"pos": pos,
		"radius": radius,
		"kind": kind,
		"strength": clampf(strength, 0.05, 2.0),
		"life": NOISE_EVENT_LIFETIME,
		"max_life": NOISE_EVENT_LIFETIME
	})
	next_noise_event_id += 1
	while perception_noise_events.size() > 32:
		perception_noise_events.pop_front()


func _update_noise_events(delta: float) -> void:
	for i in range(perception_noise_events.size() - 1, -1, -1):
		var event: Dictionary = perception_noise_events[i]
		event["life"] = float(event.get("life", 0.0)) - delta
		if float(event["life"]) <= 0.0:
			perception_noise_events.remove_at(i)
		else:
			perception_noise_events[i] = event


func _player_visibility_light() -> float:
	var tile_x := clampi(floori(player_position.x / TILE_SIZE), 0, WORLD_WIDTH - 1)
	var tile_y := clampi(floori(player_position.y / TILE_SIZE), 0, WORLD_HEIGHT - 1)
	var environment_light := _light_at_tile(tile_x, tile_y, true)
	if _selected_item() == "torch" and int(inventory.get("torch", 0)) > 0:
		environment_light = maxf(environment_light, 1.0)
	return clampf(environment_light, 0.02, 1.0)


func _has_perception_line_of_sight(from_pos: Vector2, to_pos: Vector2) -> bool:
	var delta_pos := to_pos - from_pos
	var distance := delta_pos.length()
	if distance <= 1.0:
		return true
	var steps := maxi(2, ceili(distance / (TILE_SIZE * 0.35)))
	for step in range(1, steps):
		var sample := from_pos.lerp(to_pos, float(step) / float(steps))
		var tile_x := floori(sample.x / TILE_SIZE)
		var tile_y := floori(sample.y / TILE_SIZE)
		if _is_solid(tile_x, tile_y):
			return false
	return true


func _enemy_can_see_player(enemy: Dictionary, pos: Vector2, profile: Dictionary) -> bool:
	var to_player := player_position - pos
	var distance := to_player.length()
	var light := _player_visibility_light()
	var light_sensitivity := clampf(float(profile.get("light_sensitivity", 0.75)), 0.0, 1.0)
	var illuminated_range_factor := lerpf(0.38, 1.12, light)
	var range_factor := lerpf(1.0, illuminated_range_factor, light_sensitivity)
	var effective_range := float(profile.get("vision_range", 165.0)) * range_factor * ENEMY_VISION_RANGE_MULTIPLIER
	# Weather blinds enemies as much as it blinds the player, but only for
	# creatures actually out in it.
	if _weather_visibility_penalty() > 0.0 and _enemy_is_exposed_to_weather(pos):
		effective_range *= clampf(1.0 - _weather_visibility_penalty() * 0.8, 0.25, 1.0)
	enemy["debug_vision_range"] = effective_range
	enemy["debug_player_light"] = light
	if distance > effective_range:
		return false
	if distance > float(profile.get("instant_range", 30.0)):
		var facing_direction := Vector2(float(int(enemy.get("facing", 1))), 0.0)
		var direction := to_player.normalized()
		var half_angle := deg_to_rad(float(profile.get("vision_angle", 120.0)) * 0.5)
		if facing_direction.dot(direction) < cos(half_angle):
			return false
	var eye_height := maxf(3.0, float((enemy.get("size", Vector2(16, 16)) as Vector2).y) * 0.28)
	var eye_pos := pos + Vector2(0.0, -eye_height)
	var player_chest := player_position + Vector2(0.0, -PLAYER_SIZE.y * 0.16)
	return _has_perception_line_of_sight(eye_pos, player_chest)


func _strongest_heard_noise(enemy: Dictionary, pos: Vector2, profile: Dictionary) -> Dictionary:
	var last_noise_id := int(enemy.get("last_noise_id", 0))
	var newest_noise_id := last_noise_id
	var best_event: Dictionary = {}
	var best_score := 0.0
	var hearing := maxf(0.0, float(profile.get("hearing", 1.0)))
	for noise in perception_noise_events:
		var event: Dictionary = noise
		var event_id := int(event.get("id", 0))
		if event_id <= last_noise_id:
			continue
		newest_noise_id = maxi(newest_noise_id, event_id)
		var noise_pos: Vector2 = event.get("pos", pos)
		var effective_radius := float(event.get("radius", 0.0)) * hearing * ENEMY_HEARING_RADIUS_MULTIPLIER
		var distance := pos.distance_to(noise_pos)
		if effective_radius <= 0.0 or distance > effective_radius:
			continue
		var occlusion := 1.0 if _has_perception_line_of_sight(pos, noise_pos) else 0.52
		var score := float(event.get("strength", 1.0)) * (1.0 - distance / effective_radius) * occlusion
		if score > best_score:
			best_score = score
			best_event = event
			best_event["heard_score"] = score
	enemy["last_noise_id"] = newest_noise_id
	return best_event


func _enemy_alert_group(enemy_type: String) -> String:
	if enemy_type in ["wild_slime", "mossling", "root_crawler", "heartwood_boss"]:
		return "roots"
	if enemy_type in ["cave_worm", "bat", "cave_husk", "stone_beast"]:
		return "cave"
	if enemy_type in ["spore_bat", "mushroom_beetle"]:
		return "fungal"
	if enemy_type in ["ash_phantom", "ash_wisp", "ash_sentinel"]:
		return "ash"
	if enemy_type in ["ruin_drone", "drowned_guard", "archive_warden"]:
		return "ruins"
	if enemy_type in ["ember_rootling", "night_ember"]:
		return "ember"
	if enemy_type == "glass_wraith":
		return "abyss"
	return enemy_type


func _broadcast_enemy_alert(source_enemy: Dictionary, target_pos: Vector2) -> void:
	var source_pos: Vector2 = source_enemy.get("pos", target_pos)
	var source_id := int(source_enemy.get("perception_id", -1))
	var source_group := _enemy_alert_group(str(source_enemy.get("type", "")))
	var profile := _enemy_perception_profile(str(source_enemy.get("type", "")))
	var radius := float(profile.get("alert_radius", 150.0))
	for ally in enemies:
		var ally_data: Dictionary = ally
		if int(ally_data.get("perception_id", -2)) == source_id:
			continue
		if _enemy_alert_group(str(ally_data.get("type", ""))) != source_group:
			continue
		var ally_pos: Vector2 = ally_data.get("pos", source_pos)
		if ally_pos.distance_to(source_pos) > radius:
			continue
		if not _has_perception_line_of_sight(source_pos, ally_pos) and ally_pos.distance_to(source_pos) > radius * 0.55:
			continue
		if str(ally_data.get("perception_state", PERCEPTION_CALM)) == PERCEPTION_COMBAT:
			continue
		ally_data["perception_state"] = PERCEPTION_INVESTIGATE
		ally_data["suspicion"] = maxf(float(ally_data.get("suspicion", 0.0)), 0.72)
		ally_data["investigate_pos"] = target_pos
		ally_data["last_known_pos"] = target_pos
		ally_data["search_timer"] = float(_enemy_perception_profile(str(ally_data.get("type", ""))).get("search_time", 6.0))


func _force_enemy_combat(enemy: Dictionary, target_pos: Vector2, broadcast := true) -> void:
	var was_in_combat := str(enemy.get("perception_state", PERCEPTION_CALM)) == PERCEPTION_COMBAT
	var profile := _enemy_perception_profile(str(enemy.get("type", "")))
	enemy["perception_state"] = PERCEPTION_COMBAT
	enemy["suspicion"] = 1.0
	enemy["last_known_pos"] = target_pos
	enemy["investigate_pos"] = target_pos
	enemy["memory_timer"] = float(profile.get("memory_time", 5.0))
	if broadcast and not was_in_combat and float(enemy.get("alert_cooldown", 0.0)) <= 0.0:
		enemy["alert_cooldown"] = 1.0
		_broadcast_enemy_alert(enemy, target_pos)


func _update_enemy_perception(enemy: Dictionary, pos: Vector2, delta: float) -> Dictionary:
	var enemy_type := str(enemy.get("type", ""))
	var profile := _enemy_perception_profile(enemy_type)
	var previous_state := str(enemy.get("perception_state", PERCEPTION_CALM))
	var state := previous_state
	var suspicion := clampf(float(enemy.get("suspicion", 0.0)), 0.0, 1.0)
	var memory_timer := maxf(0.0, float(enemy.get("memory_timer", 0.0)))
	var search_timer := maxf(0.0, float(enemy.get("search_timer", 0.0)))
	var alert_cooldown := maxf(0.0, float(enemy.get("alert_cooldown", 0.0)) - delta)
	if state == PERCEPTION_CALM:
		var idle_look_timer := float(enemy.get("idle_look_timer", 1.0)) - delta
		if idle_look_timer <= 0.0:
			enemy["facing"] = -int(enemy.get("facing", 1))
			idle_look_timer = rng.randf_range(1.4, 3.8)
		enemy["idle_look_timer"] = idle_look_timer
	var can_see_player := _enemy_can_see_player(enemy, pos, profile)
	var player_distance := pos.distance_to(player_position)
	var heard_noise := _strongest_heard_noise(enemy, pos, profile)

	if can_see_player:
		enemy["last_known_pos"] = player_position
		enemy["investigate_pos"] = player_position
		memory_timer = float(profile.get("memory_time", 5.0))
		var distance_factor := clampf(1.25 - player_distance / maxf(1.0, float(enemy.get("debug_vision_range", 165.0))), 0.35, 1.25)
		suspicion = clampf(suspicion + delta * float(profile.get("suspicion_rate", 1.35)) * distance_factor, 0.0, 1.0)
		if previous_state == PERCEPTION_COMBAT or player_distance <= float(profile.get("instant_range", 30.0)) or suspicion >= 1.0:
			state = PERCEPTION_COMBAT
		else:
			state = PERCEPTION_SUSPICIOUS
	else:
		if state == PERCEPTION_COMBAT:
			memory_timer = maxf(0.0, memory_timer - delta)
			if memory_timer <= 0.0:
				state = PERCEPTION_SEARCH
				search_timer = float(profile.get("search_time", 6.0))
				enemy["search_step_timer"] = 0.0
		elif state == PERCEPTION_SUSPICIOUS:
			suspicion = maxf(0.0, suspicion - delta * float(profile.get("suspicion_decay", 0.38)))
			if suspicion <= 0.0:
				state = PERCEPTION_RETURN

	if not heard_noise.is_empty():
		var noise_pos: Vector2 = heard_noise.get("pos", pos)
		var heard_score := float(heard_noise.get("heard_score", 0.0))
		if state == PERCEPTION_COMBAT and not can_see_player:
			enemy["last_known_pos"] = noise_pos
			memory_timer = float(profile.get("memory_time", 5.0))
		elif state != PERCEPTION_COMBAT and heard_score >= 0.08:
			state = PERCEPTION_INVESTIGATE
			enemy["investigate_pos"] = noise_pos
			enemy["last_known_pos"] = noise_pos
			suspicion = maxf(suspicion, clampf(heard_score, 0.25, 0.88))
			search_timer = float(profile.get("search_time", 6.0))

	var target_pos: Vector2 = enemy.get("home_pos", pos)
	var has_move_target := false
	if state == PERCEPTION_COMBAT:
		target_pos = player_position if can_see_player else enemy.get("last_known_pos", player_position)
		has_move_target = true
	elif state == PERCEPTION_INVESTIGATE:
		target_pos = enemy.get("investigate_pos", pos)
		has_move_target = true
		if pos.distance_to(target_pos) <= 18.0:
			state = PERCEPTION_SEARCH
			search_timer = maxf(search_timer, float(profile.get("search_time", 6.0)))
			enemy["search_step_timer"] = 0.0
	elif state == PERCEPTION_SEARCH:
		search_timer = maxf(0.0, search_timer - delta)
		var search_step_timer := float(enemy.get("search_step_timer", 0.0)) - delta
		if search_step_timer <= 0.0 or pos.distance_to(enemy.get("search_target", pos)) <= 14.0:
			var spread := 54.0 if bool(enemy.get("flying", false)) else 42.0
			var vertical_spread := 34.0 if bool(enemy.get("flying", false)) else 0.0
			var search_origin: Vector2 = enemy.get("last_known_pos", pos)
			enemy["search_target"] = search_origin + Vector2(rng.randf_range(-spread, spread), rng.randf_range(-vertical_spread, vertical_spread))
			search_step_timer = rng.randf_range(0.8, 1.5)
		enemy["search_step_timer"] = search_step_timer
		target_pos = enemy.get("search_target", enemy.get("last_known_pos", pos))
		has_move_target = true
		if search_timer <= 0.0:
			state = PERCEPTION_RETURN
	elif state == PERCEPTION_RETURN:
		target_pos = enemy.get("home_pos", pos)
		has_move_target = true
		if pos.distance_to(target_pos) <= 16.0:
			state = PERCEPTION_CALM
			suspicion = 0.0
			has_move_target = false
	elif state == PERCEPTION_SUSPICIOUS:
		target_pos = player_position

	if state == PERCEPTION_COMBAT and previous_state != PERCEPTION_COMBAT and alert_cooldown <= 0.0:
		alert_cooldown = 1.0
		if not _enemy_animation_spec(enemy_type, "alert").is_empty():
			enemy["alert_timer"] = _enemy_animation_duration(enemy_type, "alert", 0.45)
			enemy["anim_state"] = "alert"
			enemy["anim_time"] = 0.0
		_broadcast_enemy_alert(enemy, enemy.get("last_known_pos", player_position))

	enemy["perception_state"] = state
	enemy["suspicion"] = suspicion
	enemy["memory_timer"] = memory_timer
	enemy["search_timer"] = search_timer
	enemy["alert_cooldown"] = alert_cooldown
	enemy["can_see_player"] = can_see_player
	return {
		"state": state,
		"target_pos": target_pos,
		"has_move_target": has_move_target,
		"can_attack_player": state == PERCEPTION_COMBAT and can_see_player,
		"player_distance": player_distance
	}


func _update_enemy_ai(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if i >= enemies.size():
			continue
		var enemy: Dictionary = enemies[i]
		var enemy_type := str(enemy.get("type", ""))
		var spawn_timer := maxf(0.0, float(enemy.get("spawn_timer", 0.0)) - delta)
		enemy["spawn_timer"] = spawn_timer
		if spawn_timer > 0.0:
			if str(enemy.get("anim_state", "")) != "spawn":
				enemy["anim_state"] = "spawn"
				enemy["anim_time"] = 0.0
			else:
				enemy["anim_time"] = float(enemy.get("anim_time", 0.0)) + delta
			enemies[i] = enemy
			continue
		var hp_ratio := float(enemy.get("hp", 1)) / float(maxi(1, int(enemy.get("max_hp", 1))))
		if enemy_type in ["heartwood_boss", "archive_warden"] and not bool(enemy.get("phase_two", false)) and hp_ratio <= 0.50:
			enemy["phase_two"] = true
			enemy["phase_timer"] = _enemy_animation_duration(enemy_type, "phase_2", 0.90)
			var phase_color := Color("82c7b1") if enemy_type == "archive_warden" else Color("9ce36d")
			_spawn_hit_particles(enemy["pos"] as Vector2, phase_color, 12)
		var phase_timer := maxf(0.0, float(enemy.get("phase_timer", 0.0)) - delta)
		enemy["phase_timer"] = phase_timer
		if phase_timer > 0.0:
			if str(enemy.get("anim_state", "")) != "phase_2":
				enemy["anim_state"] = "phase_2"
				enemy["anim_time"] = 0.0
			else:
				enemy["anim_time"] = float(enemy.get("anim_time", 0.0)) + delta
			enemies[i] = enemy
			continue
		enemy["hit_timer"] = maxf(0.0, float(enemy.get("hit_timer", 0.0)) - delta)
		enemy["stun_timer"] = maxf(0.0, float(enemy.get("stun_timer", 0.0)) - delta)
		enemy["attack_cooldown"] = maxf(0.0, float(enemy.get("attack_cooldown", 0.0)) - delta)
		enemy["guard_time"] = maxf(0.0, float(enemy.get("guard_time", 0.0)) - delta)
		enemy["attack_flash"] = maxf(0.0, float(enemy.get("attack_flash", 0.0)) - delta)
		enemy["roll_time"] = maxf(0.0, float(enemy.get("roll_time", 0.0)) - delta)
		enemy["dive_timer"] = maxf(0.0, float(enemy.get("dive_timer", 0.0)) - delta)
		enemy["alert_timer"] = maxf(0.0, float(enemy.get("alert_timer", 0.0)) - delta)
		enemy["trail_timer"] = maxf(0.0, float(enemy.get("trail_timer", 0.0)) - delta)
		enemy["jump_cooldown"] = maxf(0.0, float(enemy.get("jump_cooldown", 0.0)) - delta)
		enemy["hop_timer"] = maxf(0.0, float(enemy.get("hop_timer", 0.0)) - delta)
		enemy["avoid_timer"] = maxf(0.0, float(enemy.get("avoid_timer", 0.0)) - delta)
		var pos: Vector2 = enemy["pos"]
		var old_pos := pos
		var vel: Vector2 = enemy["vel"]
		var size: Vector2 = enemy["size"]
		var last_safe_pos: Vector2 = enemy.get("last_safe_pos", pos)
		var burrow_hidden_at_frame_start := bool(enemy.get("burrow_hidden", false))
		if not burrow_hidden_at_frame_start and not _enemy_position_valid(pos, size):
			pos = _recover_enemy_position(pos, size, last_safe_pos)
			old_pos = pos
			vel = Vector2.ZERO
		var perception := _update_enemy_perception(enemy, pos, delta)
		var target_position: Vector2 = perception.get("target_pos", pos)
		var has_move_target := bool(perception.get("has_move_target", false))
		var can_attack_player := bool(perception.get("can_attack_player", false))
		var player_distance := float(perception.get("player_distance", pos.distance_to(player_position)))
		if enemy_type == "spore_bat" and float(enemy.get("trail_timer", 0.0)) <= 0.0:
			_spawn_enemy_impact(pos + Vector2(float(-int(enemy.get("facing", 1))) * 5.0, 4.0), "spore_bat", "spore_trail", 1, false, 0.44)
			enemy["trail_timer"] = 0.48
		if enemy_type == "bat":
			var wake_timer := float(enemy.get("wake_timer", 0.0))
			if bool(enemy.get("roosting", false)):
				var perception_state := str(perception.get("state", PERCEPTION_CALM))
				if perception_state != PERCEPTION_CALM or player_distance <= 118.0:
					enemy["roosting"] = false
					wake_timer = _enemy_animation_duration("bat", "wake_up", 0.40)
					enemy["wake_timer"] = wake_timer
					enemy["anim_state"] = "wake_up"
					enemy["anim_time"] = 0.0
				else:
					enemy["vel"] = Vector2.ZERO
					enemy["anim_state"] = "hang_idle"
					enemy["anim_time"] = float(enemy.get("anim_time", 0.0)) + delta
					enemies[i] = enemy
					continue
			if wake_timer > 0.0:
				wake_timer = maxf(0.0, wake_timer - delta)
				enemy["wake_timer"] = wake_timer
				enemy["vel"] = Vector2.ZERO
				if str(enemy.get("anim_state", "")) != "wake_up":
					enemy["anim_state"] = "wake_up"
					enemy["anim_time"] = 0.0
				else:
					enemy["anim_time"] = float(enemy.get("anim_time", 0.0)) + delta
				enemies[i] = enemy
				continue
		var to_player := target_position - pos
		var distance := to_player.length()
		var facing := int(enemy.get("facing", 1))
		if has_move_target or str(perception.get("state", PERCEPTION_CALM)) == PERCEPTION_SUSPICIOUS:
			facing = 1 if to_player.x >= 0.0 else -1
		if absf(to_player.x) > 2.0 and (has_move_target or str(perception.get("state", PERCEPTION_CALM)) == PERCEPTION_SUSPICIOUS):
			enemy["facing"] = facing
		var speed := float(enemy.get("speed", 50.0))
		var movement_profile := _enemy_movement_profile(enemy_type)
		if enemy_type in ["heartwood_boss", "archive_warden"] and bool(enemy.get("phase_two", false)):
			speed *= 1.25
		var statuses: Dictionary = enemy.get("statuses", {})
		if statuses.has("slow"):
			speed *= 0.55
		var flying := bool(enemy.get("flying", false))
		var attack_range := _enemy_attack_range(enemy_type, size, flying)
		var windup_duration := 0.42 if flying else 0.32
		if enemy_type == "stone_beast":
			attack_range = 46.0
			windup_duration = 0.60
		elif enemy_type == "heartwood_boss":
			attack_range = 118.0
			windup_duration = 0.50
		elif enemy_type == "archive_warden":
			attack_range = 185.0
			windup_duration = 0.55
		var attack_windup := float(enemy.get("attack_windup", 0.0))
		var stunned := float(enemy.get("stun_timer", 0.0)) > 0.0
		var alerting := float(enemy.get("alert_timer", 0.0)) > 0.0
		var move_intent := 0
		var desired_flying_velocity := Vector2.ZERO
		var vertical_attack_tolerance := maxf(28.0, size.y * 1.25)
		var can_begin_attack := can_attack_player and player_distance <= attack_range
		if not flying and _enemy_attack_kind(enemy_type, int(enemy.get("attack_index", 1))) in ["melee", "dash", "roll", "slam", "whip", "memory_blade", "memory_pulse"]:
			can_begin_attack = can_begin_attack and absf(player_position.y - pos.y) <= vertical_attack_tolerance

		if alerting:
			vel = vel.move_toward(Vector2.ZERO, speed * 7.0 * delta)
		elif stunned:
			enemy["roll_active"] = false
			enemy["roll_time"] = 0.0
			vel.x = move_toward(vel.x, 0.0, speed * 3.0 * delta)
		elif attack_windup > 0.0:
			attack_windup = maxf(0.0, attack_windup - delta)
			var active_attack_index := int(enemy.get("attack_index", 1))
			if enemy_type in ["root_crawler", "cave_worm"] and active_attack_index == 3:
				pos = _update_enemy_burrow_windup(enemy, pos, attack_windup)
			if enemy_type == "cave_worm" and active_attack_index == 2:
				_update_cave_worm_roll_windup(enemy, pos, attack_windup)
			if not bool(enemy.get("roll_active", false)):
				vel.x = move_toward(vel.x, 0.0, speed * 7.0 * delta)
			if attack_windup <= 0.0:
				var attack_state := "attack_%d" % int(enemy.get("attack_index", 1))
				var has_authored_attack := not _enemy_animation_spec(enemy_type, attack_state).is_empty()
				enemy["attack_flash"] = _enemy_attack_recovery(enemy_type, int(enemy.get("attack_index", 1))) if has_authored_attack else 0.16
				enemy["attack_cooldown"] = 1.10 if flying else 0.95
				if enemy_type in ["heartwood_boss", "archive_warden"] and bool(enemy.get("phase_two", false)):
					enemy["attack_cooldown"] = float(enemy["attack_cooldown"]) * 0.72
				vel += _execute_enemy_attack(enemy, pos, facing, player_distance, attack_range)
		else:
			if float(enemy.get("attack_cooldown", 0.0)) <= 0.0 and can_begin_attack:
				var next_attack := _choose_enemy_attack_index(enemy)
				enemy["attack_index"] = next_attack
				attack_windup = _enemy_attack_windup(str(enemy.get("type", "")), next_attack, windup_duration)
				enemy["attack_total"] = attack_windup
				vel.x = 0.0
				if enemy_type in ["root_crawler", "cave_worm"] and next_attack == 3:
					_prepare_enemy_burrow(enemy, pos, size)
				if enemy_type == "cave_worm" and next_attack == 2:
					_prepare_cave_worm_roll(enemy)
			else:
				if flying and has_move_target:
					var hover_offset := attack_range * 0.72 if can_attack_player else 0.0
					if enemy_type == "bat" and can_attack_player:
						hover_offset = 58.0
					elif enemy_type == "spore_bat" and can_attack_player:
						hover_offset = 40.0
					var hover_target := target_position + Vector2(float(-facing) * hover_offset, sin(float(Time.get_ticks_msec()) / 260.0 + float(enemy.get("anim_offset", 0.0))) * 12.0)
					var desired := hover_target - pos
					desired_flying_velocity = desired.normalized() * speed if desired.length() > 3.0 else Vector2.ZERO
					if _is_sea_creature(enemy_type) and desired_flying_velocity.y < 0.0:
						# A fish will not chase a target up into the air. It can
						# still rise inside the water, just never out of it.
						var above := pos - Vector2(0.0, size.y * 0.5 + 4.0)
						if not _tile_is_water_at(above):
							desired_flying_velocity.y = 0.0
				else:
					var stopping_distance := attack_range * 0.72 if can_attack_player else 12.0
					move_intent = facing if has_move_target and distance > stopping_distance else 0

		var bat_dive_phase := str(enemy.get("dive_phase", ""))
		var bat_diving := enemy_type == "bat" and bat_dive_phase != ""
		var cave_worm_rolling := enemy_type == "cave_worm" and bool(enemy.get("roll_active", false)) and (attack_windup > 0.0 or float(enemy.get("roll_time", 0.0)) > 0.0)
		if not flying and not stunned and not alerting and attack_windup <= 0.0 and not cave_worm_rolling:
			var avoid_direction := int(enemy.get("avoid_direction", 0))
			if float(enemy.get("avoid_timer", 0.0)) > 0.0 and avoid_direction != 0:
				move_intent = avoid_direction
			var movement_on_floor := _enemy_on_floor(pos, size)
			var desired_x := float(move_intent) * speed
			var movement_control := 1.0 if movement_on_floor else float(movement_profile.get("air_control", 0.12))
			var acceleration := float(movement_profile.get("acceleration", 6.0))
			vel.x = move_toward(vel.x, desired_x, speed * acceleration * movement_control * delta)
		if cave_worm_rolling and not stunned:
			vel.x = float(int(enemy.get("roll_direction", enemy.get("facing", 1)))) * 245.0
		elif enemy_type == "cave_worm" and bool(enemy.get("roll_active", false)):
			enemy["roll_active"] = false

		var burrow_hidden := bool(enemy.get("burrow_hidden", false))
		if burrow_hidden:
			vel = Vector2.ZERO
		elif not flying:
			var on_floor := _enemy_on_floor(pos, size)
			if on_floor and vel.y > 0.0:
				vel.y = 0.0
			if enemy_type == "wild_slime" and not stunned and attack_windup <= 0.0 and move_intent != 0 and on_floor and float(enemy.get("hop_timer", 0.0)) <= 0.0:
				vel.y = float(movement_profile.get("hop_speed", -285.0))
				vel.x = float(move_intent) * speed * 1.12
				enemy["hop_timer"] = float(movement_profile.get("hop_interval", 0.72))
			elif not stunned and not alerting and attack_windup <= 0.0 and move_intent != 0 and on_floor and bool(movement_profile.get("navigation_jump", true)) and float(enemy.get("jump_cooldown", 0.0)) <= 0.0:
				var blocked_ahead := _enemy_wall_ahead(pos, size, move_intent)
				if blocked_ahead and not _enemy_can_step_up(pos, size, move_intent):
					vel.y = float(movement_profile.get("jump_speed", -285.0))
					enemy["jump_cooldown"] = float(movement_profile.get("jump_interval", 1.10))
			vel.y += GRAVITY * delta
			pos = _move_enemy(pos, vel * delta, size)
			if on_floor and vel.y >= 0.0 and str(movement_profile.get("locomotion", "walk")) != "hop":
				pos = _enemy_snap_to_ground(pos, size, float(movement_profile.get("ground_snap", 6.0)))
			if _enemy_on_floor(pos, size) and vel.y > 0.0:
				vel.y = 0.0
			var expected_motion := move_intent != 0 and attack_windup <= 0.0 and not stunned
			var made_progress := absf(old_pos.x - pos.x) > maxf(0.25, speed * delta * 0.12)
			var stuck_time := float(enemy.get("stuck_time", 0.0))
			stuck_time = maxf(0.0, stuck_time - delta * 2.0) if not expected_motion or made_progress else stuck_time + delta
			if stuck_time > float(movement_profile.get("stuck_turn_time", 0.62)) and _enemy_on_floor(pos, size):
				enemy["avoid_direction"] = -facing
				enemy["avoid_timer"] = float(movement_profile.get("avoid_time", 0.72))
				stuck_time = 0.0
			enemy["stuck_time"] = stuck_time
		else:
			if bat_diving:
				var dive_direction: Vector2 = enemy.get("dive_direction", Vector2(float(facing), 0.65))
				if dive_direction.length_squared() < 0.01:
					dive_direction = Vector2(float(facing), 0.65).normalized()
				if bat_dive_phase == "loop":
					vel = dive_direction * 285.0
					var dive_start_pos := pos
					pos = _move_flying_enemy(pos, vel * delta, size)
					var player_rect := Rect2(player_position - PLAYER_SIZE * 0.5, PLAYER_SIZE)
					var dive_rect := Rect2(pos - Vector2(18.0, 16.0), Vector2(36.0, 32.0))
					if not bool(enemy.get("dive_hit", false)) and dive_rect.intersects(player_rect):
						_enemy_hit_player(enemy, facing)
						enemy["dive_hit"] = true
					var dive_blocked := dive_start_pos.distance_to(pos) < maxf(0.1, vel.length() * delta * 0.20)
					if float(enemy.get("dive_timer", 0.0)) <= 0.0 or dive_blocked:
						bat_dive_phase = "recover"
						enemy["dive_phase"] = bat_dive_phase
						enemy["dive_timer"] = _enemy_animation_duration("bat", "dive_recover", 0.50)
						vel = Vector2(-dive_direction.x * 55.0, -145.0)
				else:
					var recover_velocity := Vector2(-dive_direction.x * 42.0, -105.0)
					vel = vel.move_toward(recover_velocity, speed * 6.0 * delta)
					pos = _move_flying_enemy(pos, vel * delta, size)
					if float(enemy.get("dive_timer", 0.0)) <= 0.0:
						enemy["dive_phase"] = ""
						enemy["dive_hit"] = false
						vel *= 0.35
			elif not stunned and not alerting and attack_windup <= 0.0:
				desired_flying_velocity += _enemy_flying_avoidance(pos, size, desired_flying_velocity) * speed
				vel = vel.move_toward(desired_flying_velocity.limit_length(speed), speed * 4.5 * delta)
			else:
				vel = vel.move_toward(Vector2.ZERO, speed * 5.0 * delta)
			if not bat_diving:
				pos = _move_flying_enemy(pos, vel * delta, size)
			var flying_progress := old_pos.distance_to(pos)
			if desired_flying_velocity.length_squared() > 25.0 and flying_progress < 0.2:
				var flying_stuck := float(enemy.get("stuck_time", 0.0)) + delta
				if flying_stuck > 0.35:
					vel.y += (-1.0 if target_position.y <= pos.y else 1.0) * speed * 0.85
					vel.x *= -0.45
					flying_stuck = 0.0
				enemy["stuck_time"] = flying_stuck
			else:
				enemy["stuck_time"] = maxf(0.0, float(enemy.get("stuck_time", 0.0)) - delta * 2.0)

		if not burrow_hidden and not _enemy_position_valid(pos, size):
			pos = _recover_enemy_position(pos, size, last_safe_pos)
			vel = Vector2.ZERO
		elif not burrow_hidden and (flying or _enemy_on_floor(pos, size)):
			enemy["last_safe_pos"] = pos
		enemy["attack_windup"] = attack_windup
		var next_anim_state := "idle"
		var current_attack_state := "attack_%d" % int(enemy.get("attack_index", 1))
		var playing_authored_attack := not _enemy_animation_spec(enemy_type, current_attack_state).is_empty() and (attack_windup > 0.0 or float(enemy.get("attack_flash", 0.0)) > 0.0)
		if enemy_type == "bat" and str(enemy.get("dive_phase", "")) == "loop":
			next_anim_state = "dive_loop"
		elif enemy_type == "bat" and str(enemy.get("dive_phase", "")) == "recover":
			next_anim_state = "dive_recover"
		elif playing_authored_attack:
			next_anim_state = "attack_%d" % int(enemy.get("attack_index", 1))
		elif float(enemy.get("hit_timer", 0.0)) > 0.0:
			next_anim_state = "hurt"
		elif stunned and not _enemy_animation_spec(enemy_type, "stunned").is_empty():
			next_anim_state = "stunned"
		elif alerting and not _enemy_animation_spec(enemy_type, "alert").is_empty():
			next_anim_state = "alert"
		elif attack_windup > 0.0 or float(enemy.get("attack_flash", 0.0)) > 0.0:
			next_anim_state = "attack_%d" % int(enemy.get("attack_index", 1))
		elif vel.length_squared() > 100.0:
			next_anim_state = "move"
		if next_anim_state != str(enemy.get("anim_state", "idle")):
			enemy["anim_state"] = next_anim_state
			enemy["anim_time"] = 0.0
		else:
			enemy["anim_time"] = float(enemy.get("anim_time", 0.0)) + delta
		if _is_sea_creature(enemy_type):
			# Sea creatures cannot leave the water: they are held under the
			# surface and beach themselves if their pool is drained.
			pos = _constrain_sea_creature(enemy, pos, size, delta)
		enemy["pos"] = pos
		enemy["vel"] = vel
		if int(enemy.get("hp", 1)) <= 0:
			_kill_enemy(i)


func _prepare_enemy_burrow(enemy: Dictionary, pos: Vector2, size: Vector2) -> void:
	var target := _find_spawn_position_near_player(2, 3, false, size)
	if not _enemy_position_valid(target, size):
		target = pos
	enemy["burrow_origin"] = pos
	enemy["burrow_target"] = target
	enemy["burrow_hidden"] = false
	enemy["burrow_dust_started"] = false


func _prepare_root_crawler_burrow(enemy: Dictionary, pos: Vector2, size: Vector2) -> void:
	_prepare_enemy_burrow(enemy, pos, size)


func _update_enemy_burrow_windup(enemy: Dictionary, pos: Vector2, remaining: float) -> Vector2:
	var enemy_type := str(enemy.get("type", "root_crawler"))
	var total := maxf(0.01, float(enemy.get("attack_total", 1.0)))
	var elapsed := maxf(0.0, total - remaining)
	var hide_time := _enemy_animation_event_time(enemy_type, "attack_3", "burrow_start_frames", total * 0.43)
	if elapsed < hide_time:
		return pos
	var origin: Vector2 = enemy.get("burrow_origin", pos)
	var target: Vector2 = enemy.get("burrow_target", pos)
	if not bool(enemy.get("burrow_dust_started", false)):
		var size: Vector2 = enemy.get("size", Vector2(22, 12))
		var effect_scale := 0.56 if enemy_type == "cave_worm" else 0.48
		_spawn_enemy_impact(origin + Vector2(0.0, size.y * 0.5), enemy_type, "burrow_dust", int(enemy.get("facing", 1)), true, effect_scale)
		enemy["burrow_dust_started"] = true
	enemy["burrow_hidden"] = true
	var travel_ratio := clampf((elapsed - hide_time) / maxf(0.01, total - hide_time), 0.0, 1.0)
	return origin.lerp(target, smoothstep(0.0, 1.0, travel_ratio))


func _update_root_crawler_burrow_windup(enemy: Dictionary, pos: Vector2, remaining: float) -> Vector2:
	return _update_enemy_burrow_windup(enemy, pos, remaining)


func _prepare_cave_worm_roll(enemy: Dictionary) -> void:
	enemy["roll_active"] = false
	enemy["roll_direction"] = int(enemy.get("facing", 1))
	enemy["roll_dust_started"] = false
	enemy["roll_time"] = 0.0


func _update_cave_worm_roll_windup(enemy: Dictionary, pos: Vector2, remaining: float) -> void:
	var total := maxf(0.01, float(enemy.get("attack_total", 10.0 / 14.0)))
	var elapsed := maxf(0.0, total - remaining)
	var roll_start_time := _enemy_animation_event_time("cave_worm", "attack_2", "roll_start_frames", total * 0.90)
	if elapsed < roll_start_time:
		return
	if not bool(enemy.get("roll_dust_started", false)):
		var size: Vector2 = enemy.get("size", Vector2(34, 12))
		_spawn_enemy_impact(pos + Vector2(0.0, size.y * 0.5), "cave_worm", "roll_dust", int(enemy.get("roll_direction", enemy.get("facing", 1))), true, 0.56)
		enemy["roll_dust_started"] = true
	enemy["roll_active"] = true


func _enemy_attack_range(enemy_type: String, size: Vector2, flying: bool) -> float:
	if enemy_type == "bat":
		return 145.0
	if enemy_type == "spore_bat":
		return 92.0
	if enemy_type in ["ash_wisp", "ruin_drone", "glass_wraith", "night_ember", "ash_phantom"]:
		return 150.0
	if enemy_type in ["ash_sentinel", "drowned_guard", "ember_rootling", "cave_husk", "mushroom_beetle"]:
		return 92.0
	if enemy_type == "root_crawler":
		return 44.0
	if enemy_type == "heartwood_boss":
		return 118.0
	if enemy_type == "archive_warden":
		return 185.0
	return maxf(24.0, size.x * (1.45 if flying else 1.05))


func _enemy_wall_ahead(pos: Vector2, size: Vector2, direction: int) -> bool:
	var probe_x := pos.x + float(direction) * (size.x * 0.5 + 3.0)
	var probe := Rect2(Vector2(probe_x - 1.5, pos.y - size.y * 0.5 + 3.0), Vector2(3.0, maxf(4.0, size.y - 6.0)))
	return _rect_collides(probe)


func _enemy_flying_avoidance(pos: Vector2, size: Vector2, desired_velocity: Vector2) -> Vector2:
	if desired_velocity.length_squared() < 1.0:
		return Vector2.ZERO
	var direction := desired_velocity.normalized()
	var forward_pos := pos + direction * (size.length() * 0.45 + 8.0)
	if not _rect_collides(Rect2(forward_pos - size * 0.45, size * 0.9)):
		return Vector2.ZERO
	var perpendicular := Vector2(-direction.y, direction.x)
	var left_clear := not _rect_collides(Rect2(pos + perpendicular * 14.0 - size * 0.45, size * 0.9))
	var right_clear := not _rect_collides(Rect2(pos - perpendicular * 14.0 - size * 0.45, size * 0.9))
	if left_clear and not right_clear:
		return perpendicular
	if right_clear and not left_clear:
		return -perpendicular
	return Vector2(0.0, -1.0 if player_position.y <= pos.y else 1.0)

func _update_enemy_deaths(delta: float) -> void:
	for i in range(dying_enemies.size() - 1, -1, -1):
		var corpse: Dictionary = dying_enemies[i]
		var flying_corpse_type := str(corpse.get("type", ""))
		if flying_corpse_type in ["bat", "spore_bat"]:
			var death_phase := str(corpse.get("death_phase", "fall"))
			corpse["death_anim_time"] = float(corpse.get("death_anim_time", 0.0)) + delta
			if death_phase == "fall":
				var corpse_pos: Vector2 = corpse.get("pos", Vector2.ZERO)
				var corpse_size: Vector2 = corpse.get("size", Vector2(22, 14))
				var corpse_velocity: Vector2 = corpse.get("death_velocity", Vector2.ZERO)
				corpse_velocity.y = minf(390.0, corpse_velocity.y + GRAVITY * 0.72 * delta)
				corpse_velocity.x = move_toward(corpse_velocity.x, 0.0, 55.0 * delta)
				var previous_pos := corpse_pos
				corpse_pos = _move_enemy(corpse_pos, corpse_velocity * delta, corpse_size)
				corpse["pos"] = corpse_pos
				corpse["death_velocity"] = corpse_velocity
				var stopped_falling := corpse_pos.distance_to(previous_pos) < maxf(0.08, corpse_velocity.length() * delta * 0.18)
				if _enemy_on_floor(corpse_pos, corpse_size) or (corpse_velocity.y > 20.0 and stopped_falling):
					corpse["death_phase"] = "impact"
					corpse["death_velocity"] = Vector2.ZERO
					if flying_corpse_type == "bat":
						corpse["death_anim_time"] = 0.0
						corpse["death_time"] = _enemy_animation_duration("bat", "death_impact", 0.50)
						_spawn_hit_particles(corpse_pos + Vector2(0.0, corpse_size.y * 0.5), Color("8d8499"), 5)
					else:
						corpse["death_anim_time"] = _enemy_animation_duration("spore_bat", "death", 0.84)
						corpse["death_time"] = _enemy_animation_duration("spore_bat", "death_impact", 0.60)
						_spawn_enemy_impact(corpse_pos + Vector2(0.0, corpse_size.y * 0.5), "spore_bat", "death_impact", int(corpse.get("facing", 1)), false, 0.44)
						_spawn_hit_particles(corpse_pos + Vector2(0.0, corpse_size.y * 0.5), Color("62c6a8"), 6)
				elif float(corpse["death_anim_time"]) >= 4.0:
					dying_enemies.remove_at(i)
					continue
			else:
				corpse["death_time"] = float(corpse.get("death_time", 0.0)) - delta
				if float(corpse["death_time"]) <= 0.0:
					dying_enemies.remove_at(i)
					continue
			dying_enemies[i] = corpse
			continue
		corpse["death_time"] = float(corpse.get("death_time", 0.0)) - delta
		var corpse_type := str(corpse.get("type", ""))
		if corpse_type == "cave_husk" and not bool(corpse.get("death_vfx_spawned", false)):
			var death_elapsed := float(corpse.get("death_total", 0.0)) - float(corpse.get("death_time", 0.0))
			if death_elapsed >= 6.0 / 5.9:
				_spawn_enemy_impact(corpse.get("pos", Vector2.ZERO), "cave_husk", "death_vfx", int(corpse.get("facing", 1)), true, 0.50)
				corpse["death_vfx_spawned"] = true
		elif corpse_type == "ruin_drone" and not bool(corpse.get("death_vfx_spawned", false)):
			var drone_death_elapsed := float(corpse.get("death_total", 0.0)) - float(corpse.get("death_time", 0.0))
			if drone_death_elapsed >= 7.0 / 11.0:
				_spawn_enemy_impact(corpse.get("pos", Vector2.ZERO), "ruin_drone", "death_vfx", int(corpse.get("facing", 1)), true, 0.50)
				corpse["death_vfx_spawned"] = true
		elif corpse_type == "stone_beast" and not bool(corpse.get("death_vfx_spawned", false)):
			var beast_death_elapsed := float(corpse.get("death_total", 0.0)) - float(corpse.get("death_time", 0.0))
			if beast_death_elapsed >= 10.0 / 8.0:
				var beast_size: Vector2 = corpse.get("size", Vector2(42, 30))
				var beast_ground := (corpse.get("pos", Vector2.ZERO) as Vector2) + Vector2(0.0, beast_size.y * 0.5)
				_spawn_enemy_impact(beast_ground, "stone_beast", "death_dust", int(corpse.get("facing", 1)), true, 0.72)
				corpse["death_vfx_spawned"] = true
		elif corpse_type == "archive_warden" and not bool(corpse.get("death_vfx_spawned", false)):
			var warden_death_elapsed := float(corpse.get("death_total", 0.0)) - float(corpse.get("death_time", 0.0))
			if warden_death_elapsed >= 9.0 / 8.0:
				var core_pos := (corpse.get("pos", Vector2.ZERO) as Vector2) + Vector2(0.0, -15.0)
				_spawn_enemy_impact(core_pos, "archive_warden", "warden_death_vfx", int(corpse.get("facing", 1)), false, 0.64)
				corpse["death_vfx_spawned"] = true
		if float(corpse["death_time"]) <= 0.0:
			dying_enemies.remove_at(i)
		else:
			dying_enemies[i] = corpse


func _enemy_attack_count(enemy_type: String) -> int:
	if enemy_type == "stone_beast" or enemy_type == "heartwood_boss":
		return 6
	if enemy_type in ["ash_sentinel", "drowned_guard", "glass_wraith", "archive_warden"]:
		return 4
	if enemy_type in ["root_crawler", "cave_worm", "bat", "cave_husk", "mushroom_beetle", "ash_phantom", "ruin_drone", "ember_rootling", "night_ember"]:
		return 3
	if enemy_type in ["wild_slime", "mossling", "spore_bat", "ash_wisp"]:
		return 2
	return 1


func _choose_enemy_attack_index(enemy: Dictionary) -> int:
	var enemy_type := str(enemy.get("type", ""))
	var count := _enemy_attack_count(enemy_type)
	var previous := int(enemy.get("attack_index", 0))
	if enemy_type == "archive_warden":
		var warden_pos: Vector2 = enemy.get("pos", Vector2.ZERO)
		var distance := warden_pos.distance_to(player_position)
		if distance <= 76.0:
			return 1 if previous != 1 else 4
		if _count_enemies_of_type("ruin_drone") < 2 and previous != 3:
			return 3
		return 4 if previous == 2 else 2
	if enemy_type == "bat":
		var pos: Vector2 = enemy.get("pos", Vector2.ZERO)
		if pos.distance_to(player_position) <= 44.0 and previous != 1:
			return 1
		return 3 if previous == 2 else 2
	if str(enemy.get("type", "")) == "spore_bat":
		var spore_pos: Vector2 = enemy.get("pos", Vector2.ZERO)
		if spore_pos.distance_to(player_position) <= 44.0 and previous != 1:
			return 1
		return 2
	return previous % count + 1


func _enemy_attack_windup(enemy_type: String, attack_index: int, default_time: float) -> float:
	var state := "attack_%d" % attack_index
	var animation_spec := _enemy_animation_spec(enemy_type, state)
	if not animation_spec.is_empty():
		var event_key := _enemy_animation_attack_event_key(animation_spec)
		return _enemy_animation_event_time(enemy_type, state, event_key, default_time)
	if enemy_type == "mossling" and attack_index == 2:
		return 0.60
	if enemy_type == "root_crawler" and attack_index == 3:
		return 0.75
	if enemy_type == "cave_worm" and attack_index == 3:
		return 0.90
	if enemy_type == "bat" and attack_index == 2:
		return 0.50
	if enemy_type == "cave_husk" and attack_index == 3:
		return 0.65
	if enemy_type == "spore_bat" and attack_index == 2:
		return 0.55
	if enemy_type == "mushroom_beetle" and attack_index == 2:
		return 0.70
	if enemy_type == "ash_phantom" and attack_index == 1:
		return 0.55
	if enemy_type == "ash_wisp" and attack_index == 2:
		return 0.80
	if enemy_type == "ash_sentinel" and attack_index == 4:
		return 0.55
	if enemy_type == "ruin_drone" and attack_index == 2:
		return 0.80
	if enemy_type == "drowned_guard" and attack_index == 2:
		return 0.55
	if enemy_type == "drowned_guard" and attack_index == 3:
		return 0.60
	if enemy_type == "ember_rootling" and attack_index == 3:
		return 0.70
	if enemy_type == "night_ember" and attack_index == 3:
		return 1.20
	if enemy_type == "glass_wraith" and attack_index in [3, 4]:
		return 0.80
	if enemy_type == "stone_beast" and attack_index in [3, 4, 5]:
		return 0.75
	if enemy_type == "stone_beast" and attack_index == 6:
		return 0.60
	if enemy_type == "heartwood_boss" and attack_index in [2, 4, 5, 6]:
		return 0.75
	if enemy_type == "archive_warden" and attack_index in [2, 3, 4]:
		return 0.75
	return default_time


func _enemy_attack_kind(enemy_type: String, attack_index := 1) -> String:
	if enemy_type == "wild_slime":
		return "dash" if attack_index == 1 else "burst"
	if enemy_type == "mossling":
		return "melee" if attack_index == 1 else "dash"
	if enemy_type == "root_crawler":
		return "melee" if attack_index == 1 else ("whip" if attack_index == 2 else "burrow")
	if enemy_type == "cave_worm":
		return "melee" if attack_index == 1 else ("roll" if attack_index == 2 else "burrow")
	if enemy_type == "bat":
		return "bite" if attack_index == 1 else ("pulse" if attack_index == 2 else "dive")
	if enemy_type == "cave_husk":
		return "reach" if attack_index == 1 else ("rock_throw" if attack_index == 2 else "slam")
	if enemy_type == "spore_bat":
		return "bite" if attack_index == 1 else "spore_burst"
	if enemy_type == "mushroom_beetle":
		return "bite" if attack_index == 1 else ("dash" if attack_index == 2 else "projectile")
	if enemy_type == "ash_phantom":
		return "claw" if attack_index == 1 else ("phase_dash" if attack_index == 2 else "projectile")
	if enemy_type == "ash_wisp":
		return "projectile" if attack_index == 1 else "burst"
	if enemy_type == "ash_sentinel":
		return "melee" if attack_index == 1 else ("slam" if attack_index == 2 else ("projectile" if attack_index == 3 else "guard"))
	if enemy_type == "ruin_drone":
		return "projectile" if attack_index == 1 else ("laser" if attack_index == 2 else "pulse")
	if enemy_type == "drowned_guard":
		return "melee" if attack_index == 1 else ("harpoon" if attack_index == 2 else ("wave" if attack_index == 3 else "guard"))
	if enemy_type == "ember_rootling":
		return "melee" if attack_index == 1 else ("projectile" if attack_index == 2 else "rootburst")
	if enemy_type == "night_ember":
		return "dash" if attack_index == 1 else ("triple" if attack_index == 2 else "burst")
	if enemy_type == "glass_wraith":
		return "shardfan" if attack_index == 1 else ("teleport_slash" if attack_index == 2 else ("laser" if attack_index == 3 else "cage"))
	if enemy_type == "stone_beast":
		return ["melee", "dash", "shockwave", "rockfall", "spikes", "guard"][attack_index - 1]
	if enemy_type == "heartwood_boss":
		return ["melee", "rootburst", "seed", "summon", "flowers", "heal"][attack_index - 1]
	if enemy_type == "archive_warden":
		return ["memory_blade", "memory_beam", "memory_summon", "memory_pulse"][attack_index - 1]
	return "melee"


func _execute_enemy_attack(enemy: Dictionary, pos: Vector2, facing: int, distance: float, attack_range: float) -> Vector2:
	var enemy_type := str(enemy.get("type", ""))
	var attack_index := int(enemy.get("attack_index", 1))
	var kind := _enemy_attack_kind(enemy_type, attack_index)
	var raw_damage := int(enemy.get("damage", 1))
	if kind == "memory_blade":
		var blade_center := pos + Vector2(float(facing) * 42.0, -4.0)
		var blade_rect := Rect2(blade_center - Vector2(42.0, 28.0), Vector2(84.0, 56.0))
		if blade_rect.intersects(Rect2(player_position - PLAYER_SIZE * 0.5, PLAYER_SIZE)):
			_enemy_hit_player(enemy, facing, "slow")
		_emit_noise(pos, 150.0, "memory_blade", 1.0)
		return Vector2.ZERO
	if kind == "memory_beam":
		var beam_spec := _enemy_animation_spec("archive_warden", "attack_2")
		var beam_spawn_data: Array = beam_spec.get("projectile_spawn", [106, 50])
		var beam_anchor := _enemy_animation_anchor("archive_warden", Vector2(128, 112))
		var beam_local := (Vector2(float(beam_spawn_data[0]), float(beam_spawn_data[1])) - beam_anchor) * _enemy_sprite_scale("archive_warden")
		beam_local.x *= float(facing)
		var beam_pos := pos + beam_local
		var beam_direction := (player_position - beam_pos).normalized()
		if beam_direction.length_squared() < 0.01:
			beam_direction = Vector2(float(facing), 0.0)
		var beam_damage := int(ceil(float(raw_damage) * (1.35 if bool(enemy.get("phase_two", false)) else 1.15)))
		_spawn_enemy_projectile(beam_pos, beam_direction * 285.0, beam_damage, Color("82c7b1"), "arcane", "slow", "archive_memory")
		_spawn_enemy_impact(beam_pos, "archive_warden", "memory_beam_vfx", facing, true, 0.82)
		_emit_noise(beam_pos, 205.0, "memory_beam", 1.25)
		_play_sound("shoot")
		return Vector2.ZERO
	if kind == "memory_summon":
		var drones_needed := maxi(0, 2 - _count_enemies_of_type("ruin_drone"))
		for summon_index in range(drones_needed):
			var summon_offset := Vector2(float(-1 if summon_index == 0 else 1) * 42.0, -48.0)
			_spawn_enemy("ruin_drone", pos + summon_offset)
		_spawn_hit_particles(pos + Vector2(0.0, -28.0), Color("b79cff"), 10)
		_emit_noise(pos, 180.0, "archive_summon", 1.15)
		return Vector2.ZERO
	if kind == "memory_pulse":
		var pulse_range := 104.0 if bool(enemy.get("phase_two", false)) else 88.0
		var pulse_ground := pos + Vector2(0.0, float((enemy.get("size", Vector2(38, 58)) as Vector2).y) * 0.5)
		_spawn_enemy_impact(pulse_ground, "archive_warden", "memory_pulse_vfx", facing, true, 0.82)
		_spawn_hit_particles(pos + Vector2(0.0, 18.0), Color("82c7b1"), 14)
		if distance <= pulse_range:
			_enemy_hit_player(enemy, facing, "slow")
			var push_direction := (player_position - pos).normalized()
			if push_direction.length_squared() < 0.01:
				push_direction = Vector2(float(facing), -0.15)
			player_velocity += push_direction * 175.0 + Vector2(0.0, -35.0)
		_emit_noise(pos, 245.0, "memory_pulse", 1.35)
		return Vector2.ZERO
	if kind == "bite":
		if distance <= 44.0:
			_enemy_hit_player(enemy, facing)
		return Vector2.ZERO
	if kind == "claw":
		var claw_pos := pos + Vector2(float(facing) * 22.0, -4.0)
		_spawn_enemy_impact(claw_pos, "ash_phantom", "slash_vfx", facing, false, 0.50)
		if distance <= 48.0:
			_enemy_hit_player(enemy, facing, "burn")
		return Vector2.ZERO
	if kind == "phase_dash":
		_spawn_enemy_impact(pos - Vector2(float(facing) * 12.0, 0.0), "ash_phantom", "dash_vfx", facing, false, 0.50)
		if distance <= 72.0:
			_enemy_hit_player(enemy, facing, "burn")
		var phase_direction := (player_position - pos).normalized()
		if phase_direction.length_squared() < 0.01:
			phase_direction = Vector2(float(facing), 0.0)
		_emit_noise(pos, 120.0, "phantom_dash", 0.85)
		return phase_direction * 230.0
	if kind == "dive":
		var dive_direction := (player_position + Vector2(0.0, 10.0) - pos).normalized()
		if dive_direction.length_squared() < 0.01:
			dive_direction = Vector2(float(facing), 0.65).normalized()
		enemy["dive_phase"] = "loop"
		enemy["dive_timer"] = 0.42
		enemy["dive_direction"] = dive_direction
		enemy["dive_hit"] = false
		enemy["attack_flash"] = 0.42 + _enemy_animation_duration("bat", "dive_recover", 0.50)
		_emit_noise(pos, 105.0, "bat_dive", 0.75)
		return Vector2.ZERO
	if kind == "spore_burst":
		_spawn_enemy_impact(pos, "spore_bat", "spore_cloud", facing, false, 0.44)
		if distance <= 52.0:
			_enemy_hit_player(enemy, facing, "poison")
		_emit_noise(pos, 135.0, "spore_burst", 0.90)
		return Vector2.ZERO
	if kind == "burst":
		var burst_color := Color("9ce36d")
		var burst_type := "poison"
		var burst_status := "poison"
		var burst_count := 6
		if enemy_type == "ash_phantom" or enemy_type == "ash_wisp" or enemy_type == "night_ember":
			burst_color = Color("ff8a45")
			burst_type = "fire"
			burst_status = "burn"
		elif enemy_type == "spore_bat":
			burst_count = 5
		for burst_index in range(burst_count):
			var burst_dir := Vector2.RIGHT.rotated(float(burst_index) * TAU / float(burst_count))
			var applied_status := burst_status
			if enemy_type == "wild_slime" and rng.randf() >= 0.25:
				applied_status = ""
			var special := "wild_ichor" if enemy_type == "wild_slime" else ""
			_spawn_enemy_projectile(pos + burst_dir * 8.0, burst_dir * 150.0, raw_damage, burst_color, burst_type, applied_status, special)
		if enemy_type == "ash_wisp":
			_spawn_enemy_impact(pos, "ash_wisp", "burst_vfx", facing, true, 0.44)
		elif enemy_type == "night_ember":
			_spawn_enemy_impact(pos, "night_ember", "burst_vfx", facing, true, 0.44)
		return Vector2.ZERO
	if kind == "whip":
		var whip_impact_pos := pos + Vector2(float(facing) * 34.0, 5.0)
		_spawn_enemy_impact(whip_impact_pos, "root_crawler", "whip_impact", facing, true, 0.48)
		if distance <= 52.0:
			_enemy_hit_player(enemy, facing, "root_bind")
		return Vector2.ZERO
	if kind == "burrow":
		enemy["burrow_hidden"] = false
		enemy["burrow_dust_started"] = false
		enemy["pos"] = pos
		var burrower_size: Vector2 = enemy.get("size", Vector2(22, 12))
		var emerge_facing := 1 if player_position.x >= pos.x else -1
		enemy["facing"] = emerge_facing
		var effect_scale := 0.56 if enemy_type == "cave_worm" else 0.52
		_spawn_enemy_impact(pos + Vector2(0.0, burrower_size.y * 0.5), enemy_type, "burrow_dust", emerge_facing, true, effect_scale)
		if pos.distance_to(player_position) <= 72.0:
			_enemy_hit_player(enemy, emerge_facing, "root_bind" if enemy_type == "root_crawler" else "slow")
		return Vector2.ZERO
	if kind == "pulse":
		var pulse_range := 82.0 if enemy_type == "bat" else 68.0
		if enemy_type == "ruin_drone":
			_spawn_enemy_impact(pos, "ruin_drone", "pulse_vfx", facing, true, 0.50)
		if distance <= pulse_range:
			_enemy_hit_player(enemy, facing)
			player_velocity += Vector2(float(facing) * 150.0, -25.0)
		if enemy_type == "bat":
			_emit_noise(pos, 205.0, "sonic_pulse", 1.20)
			_play_sound("shoot")
		return Vector2.ZERO
	if kind == "slam":
		if enemy_type == "cave_husk":
			_spawn_enemy_impact(pos, "cave_husk", "slam_vfx", facing, true, 0.50)
		elif enemy_type == "ash_sentinel":
			var sentinel_ground: Vector2 = pos + Vector2(0.0, float((enemy.get("size", Vector2(24, 28)) as Vector2).y) * 0.5)
			_spawn_enemy_impact(sentinel_ground, "ash_sentinel", "ground_cracks", facing, true, 0.50)
			_spawn_enemy_impact(sentinel_ground, "ash_sentinel", "slam_vfx", facing, true, 0.50)
		if distance <= 42.0:
			_enemy_hit_player(enemy, facing, "armor_break")
		return Vector2.ZERO
	if kind == "reach":
		var reach_center := pos + Vector2(float(facing) * 38.0, -8.0)
		var reach_rect := Rect2(reach_center - Vector2(36.0, 19.0), Vector2(72.0, 38.0))
		var player_rect := Rect2(player_position - PLAYER_SIZE * 0.5, PLAYER_SIZE)
		if reach_rect.intersects(player_rect):
			_enemy_hit_player(enemy, facing)
		return Vector2.ZERO
	if kind == "rock_throw":
		var throw_spec := _enemy_animation_spec("cave_husk", "attack_2")
		var spawn_data: Array = throw_spec.get("projectile_spawn", [112, 46])
		var spawn_local := Vector2(float(spawn_data[0]) - 80.0, float(spawn_data[1]) - 89.0) * _enemy_sprite_scale("cave_husk")
		spawn_local.x *= float(facing)
		var rock_spawn := pos + spawn_local
		var rock_direction := (player_position - rock_spawn).normalized()
		if rock_direction.length_squared() < 0.01:
			rock_direction = Vector2(float(facing), -0.12).normalized()
		var rock_velocity := rock_direction * 205.0
		rock_velocity.y = minf(rock_velocity.y - 38.0, -55.0)
		_spawn_enemy_projectile(rock_spawn, rock_velocity, raw_damage, Color("9b8a6f"), "physical", "slow", "cave_husk_rock")
		_emit_noise(rock_spawn, 125.0, "rock_throw", 0.85)
		return Vector2.ZERO
	if kind == "guard":
		enemy["guard_time"] = 1.35
		return Vector2.ZERO
	if kind == "harpoon":
		var harpoon_spec := _enemy_animation_spec("drowned_guard", "attack_2")
		var harpoon_spawn_data: Array = harpoon_spec.get("projectile_spawn", [118, 52])
		var harpoon_anchor := _enemy_animation_anchor("drowned_guard", Vector2(160, 128))
		var harpoon_local := (Vector2(float(harpoon_spawn_data[0]), float(harpoon_spawn_data[1])) - harpoon_anchor) * _enemy_sprite_scale("drowned_guard")
		harpoon_local.x *= float(facing)
		var harpoon_pos := pos + harpoon_local
		var harpoon_dir := (player_position - harpoon_pos).normalized()
		if harpoon_dir.length_squared() < 0.01:
			harpoon_dir = Vector2(float(facing), 0.0)
		_spawn_enemy_projectile(harpoon_pos, harpoon_dir * 130.0, raw_damage, Color("86c8d0"), "physical", "slow", "drowned_harpoon")
		return Vector2.ZERO
	if kind == "wave":
		var wave_dir := Vector2(float(facing), 0)
		var guard_size: Vector2 = enemy.get("size", Vector2(24, 28))
		var wave_pos := pos + Vector2(float(facing) * 18.0, guard_size.y * 0.5)
		_spawn_enemy_projectile(wave_pos, wave_dir * 70.0, raw_damage, Color("62b8ca"), "physical", "wet", "drowned_wave")
		return Vector2.ZERO
	if kind == "rootburst":
		if enemy_type == "ember_rootling":
			var root_target_ground := player_position + Vector2(0.0, PLAYER_SIZE.y * 0.5)
			_spawn_enemy_impact(root_target_ground, "ember_rootling", "root_burst_vfx", facing, true, 0.50)
		if distance <= 64.0:
			_enemy_hit_player(enemy, facing, "root_bind" if enemy_type == "heartwood_boss" else "burn")
			if enemy_type != "heartwood_boss":
				_apply_player_status("root_bind")
		return Vector2.ZERO
	if kind == "triple":
		var triple_spec := _enemy_animation_spec("night_ember", "attack_2")
		var triple_spawn_data: Array = triple_spec.get("projectile_spawn", [73, 48])
		var triple_anchor := _enemy_animation_anchor("night_ember", Vector2(96, 96))
		var triple_local := (Vector2(float(triple_spawn_data[0]), float(triple_spawn_data[1])) - triple_anchor) * _enemy_sprite_scale("night_ember")
		triple_local.x *= float(facing)
		var triple_pos := pos + triple_local
		var triple_fan: Array = triple_spec.get("projectile_fan_degrees", [-30, 0, 30])
		for triple_angle in triple_fan:
			var flame_dir := Vector2(float(facing), 0).rotated(deg_to_rad(float(triple_angle)) * float(facing))
			_spawn_enemy_projectile(triple_pos, flame_dir * 150.0, raw_damage, Color("ff8a45"), "fire", "burn", "night_fire")
		return Vector2.ZERO
	if kind == "seed":
		var seed_dir := (player_position - pos).normalized()
		_spawn_enemy_projectile(pos + seed_dir * 14.0, seed_dir * 175.0, raw_damage, Color("c790d3"), "physical", "slow", "seed")
		return Vector2.ZERO
	if kind == "summon":
		var mossling_spawn_size: Vector2 = _enemy_template("mossling").get("size", Vector2(22, 16))
		for summon_index in range(2):
			var summon_pos := _find_spawn_position_near_player(7 + summon_index * 2, 10 + summon_index * 2, false, mossling_spawn_size)
			_spawn_enemy("mossling", summon_pos)
		return Vector2.ZERO
	if kind == "flowers":
		for flower_index in range(5):
			var flower_dir := Vector2.RIGHT.rotated(float(flower_index) * TAU / 5.0)
			_spawn_enemy_projectile(pos + flower_dir * 10.0, flower_dir * 115.0, raw_damage, Color("9ce36d"), "poison", "poison", "flower")
		return Vector2.ZERO
	if kind == "heal":
		var maximum_hp := int(enemy.get("max_hp", 1))
		enemy["hp"] = mini(maximum_hp, int(enemy.get("hp", 1)) + int(ceil(float(maximum_hp) * 0.12)))
		_spawn_hit_particles(pos, Color("8fdb82"), 9)
		return Vector2.ZERO
	if kind == "shardfan":
		var shard_spec := _enemy_animation_spec("glass_wraith", "attack_1")
		var shard_spawn_data: Array = shard_spec.get("projectile_spawn", [96, 76])
		var shard_anchor := _enemy_animation_anchor("glass_wraith", Vector2(144, 160))
		var shard_local := (Vector2(float(shard_spawn_data[0]), float(shard_spawn_data[1])) - shard_anchor) * _enemy_sprite_scale("glass_wraith")
		shard_local.x *= float(facing)
		var shard_pos := pos + shard_local
		var fan_degrees: Array = shard_spec.get("projectile_fan_degrees", [-52, -26, 0, 26, 52])
		for fan_degrees_value in fan_degrees:
			var shard_dir := Vector2(float(facing), 0).rotated(deg_to_rad(float(fan_degrees_value)) * float(facing))
			_spawn_enemy_projectile(shard_pos, shard_dir * 145.0, raw_damage, Color("b8f4ff"), "physical", "fragile", "glass_shard")
		return Vector2.ZERO
	if kind == "teleport_slash":
		var arrival_pos := player_position - Vector2(float(facing) * 22.0, 0.0)
		_spawn_enemy_impact(pos, "glass_wraith", "teleport_vfx", facing, true, 0.50)
		_spawn_enemy_impact(arrival_pos, "glass_wraith", "teleport_vfx", -facing, true, 0.50)
		_spawn_enemy_impact(arrival_pos, "glass_wraith", "slash_vfx", facing, true, 0.50)
		if distance <= 68.0:
			_enemy_hit_player(enemy, facing, "fragile")
		return Vector2(float(facing) * 230.0, -35.0)
	if kind == "cage":
		_spawn_enemy_impact(player_position, "glass_wraith", "cage_vfx", facing, true, 0.50)
		if distance <= 88.0:
			_enemy_hit_player(enemy, facing, "root_bind")
		return Vector2.ZERO
	if kind == "shockwave":
		if enemy_type == "stone_beast":
			var beast_ground := pos + Vector2(0.0, float((enemy.get("size", Vector2(42, 30)) as Vector2).y) * 0.5)
			_spawn_enemy_impact(beast_ground, "stone_beast", "shockwave_vfx", facing, true, 0.72)
		if distance <= 80.0:
			_enemy_hit_player(enemy, facing, "slow")
		return Vector2.ZERO
	if kind == "rockfall":
		for offset in [-32.0, 0.0, 32.0]:
			var rock_target := player_position + Vector2(offset, -70.0)
			_spawn_enemy_projectile(rock_target, Vector2(0, 130.0), raw_damage, Color("a9a49a"), "physical", "slow", "stone_falling_rock")
		return Vector2.ZERO
	if kind == "spikes":
		if enemy_type == "stone_beast":
			var spikes_ground := player_position + Vector2(0.0, PLAYER_SIZE.y * 0.5)
			_spawn_enemy_impact(spikes_ground, "stone_beast", "spikes_vfx", facing, true, 0.72)
		if distance <= 96.0:
			_enemy_hit_player(enemy, facing, "slow")
		return Vector2.ZERO
	if kind == "projectile" or kind == "laser":
		if enemy_type == "glass_wraith" and kind == "laser":
			var beam_origin := pos + Vector2(float(facing) * 18.0, -2.0)
			_spawn_enemy_impact(beam_origin, "glass_wraith", "laser_beam", facing, true, 0.50)
			if distance <= 160.0:
				_enemy_hit_player(enemy, facing, "fragile")
			return Vector2.ZERO
		if enemy_type == "ruin_drone" and kind == "laser":
			var drone_beam_origin := pos + Vector2(float(facing) * 17.0, 0.0)
			_spawn_enemy_impact(drone_beam_origin, "ruin_drone", "laser_beam", facing, true, 0.50)
			if distance <= 160.0:
				_enemy_hit_player(enemy, facing, "slow")
			return Vector2.ZERO
		var direction := (player_position - pos).normalized()
		if direction.length() < 0.1:
			direction = Vector2(float(facing), 0)
		var color := Color("9fd6e7")
		var status := str(enemy.get("status_on_hit", ""))
		var speed := 180.0
		if enemy_type == "ember_rootling" or enemy_type == "night_ember":
			color = Color("ff8a45")
			status = "burn"
		elif enemy_type == "ash_wisp" or enemy_type == "ash_sentinel":
			color = Color("b79cff")
		elif enemy_type == "ash_phantom":
			color = Color("ff9c68")
			status = "burn"
		elif enemy_type == "mushroom_beetle":
			color = Color("9ce36d")
			status = "poison"
		elif enemy_type == "spore_bat":
			color = Color("9ce36d")
			status = "poison"
		elif enemy_type == "glass_wraith":
			color = Color("aef7ff")
			status = "slow"
		elif enemy_type == "ruin_drone":
			color = Color("ffe09a")
			status = ""
		elif enemy_type == "heartwood_boss":
			color = Color("d96a94")
			speed = 220.0
		if kind == "laser":
			color = Color("b8f4ff")
			speed = 310.0
			raw_damage = int(ceil(float(raw_damage) * 1.6))
		var projectile_pos := pos + direction * 12.0
		var projectile_special := ""
		if enemy_type == "mushroom_beetle":
			var beetle_spec := _enemy_animation_spec("mushroom_beetle", "attack_3")
			var beetle_spawn: Array = beetle_spec.get("projectile_spawn", [120, 70])
			var beetle_anchor := _enemy_animation_anchor("mushroom_beetle", Vector2(128, 96))
			var beetle_local := (Vector2(float(beetle_spawn[0]), float(beetle_spawn[1])) - beetle_anchor) * _enemy_sprite_scale("mushroom_beetle")
			beetle_local.x *= float(facing)
			projectile_pos = pos + beetle_local
			projectile_special = "mushroom_poison"
			speed = 145.0
		elif enemy_type == "ash_phantom":
			var phantom_spec := _enemy_animation_spec("ash_phantom", "attack_3")
			var phantom_spawn: Array = phantom_spec.get("projectile_spawn", [108, 42])
			var phantom_anchor := _enemy_animation_anchor("ash_phantom", Vector2(128, 128))
			var phantom_local := (Vector2(float(phantom_spawn[0]), float(phantom_spawn[1])) - phantom_anchor) * _enemy_sprite_scale("ash_phantom")
			phantom_local.x *= float(facing)
			projectile_pos = pos + phantom_local
			projectile_special = "ash_phantom_ember"
			speed = 190.0
		elif enemy_type == "ash_wisp":
			var wisp_spec := _enemy_animation_spec("ash_wisp", "attack_1")
			var wisp_spawn: Array = wisp_spec.get("projectile_spawn", [72, 48])
			var wisp_anchor := _enemy_animation_anchor("ash_wisp", Vector2(96, 96))
			var wisp_local := (Vector2(float(wisp_spawn[0]), float(wisp_spawn[1])) - wisp_anchor) * _enemy_sprite_scale("ash_wisp")
			wisp_local.x *= float(facing)
			projectile_pos = pos + wisp_local
			projectile_special = "ash_wisp_ember"
			speed = 120.0
		elif enemy_type == "ash_sentinel":
			var sentinel_spec := _enemy_animation_spec("ash_sentinel", "attack_3")
			var sentinel_spawn: Array = sentinel_spec.get("projectile_spawn", [115, 49])
			var sentinel_anchor := _enemy_animation_anchor("ash_sentinel", Vector2(160, 128))
			var sentinel_local := (Vector2(float(sentinel_spawn[0]), float(sentinel_spawn[1])) - sentinel_anchor) * _enemy_sprite_scale("ash_sentinel")
			sentinel_local.x *= float(facing)
			projectile_pos = pos + sentinel_local
			projectile_special = "sentinel_ash"
			speed = 95.0
		elif enemy_type == "ember_rootling":
			var rootling_spec := _enemy_animation_spec("ember_rootling", "attack_2")
			var rootling_spawn: Array = rootling_spec.get("projectile_spawn", [106, 47])
			var rootling_anchor := _enemy_animation_anchor("ember_rootling", Vector2(144, 112))
			var rootling_local := (Vector2(float(rootling_spawn[0]), float(rootling_spawn[1])) - rootling_anchor) * _enemy_sprite_scale("ember_rootling")
			rootling_local.x *= float(facing)
			projectile_pos = pos + rootling_local
			projectile_special = "ember_seed"
			speed = 105.0
		elif enemy_type == "ruin_drone":
			var drone_spec := _enemy_animation_spec("ruin_drone", "attack_1")
			var drone_spawn: Array = drone_spec.get("projectile_spawn", [98, 64])
			var drone_anchor := _enemy_animation_anchor("ruin_drone", Vector2(128, 128))
			var drone_local := (Vector2(float(drone_spawn[0]), float(drone_spawn[1])) - drone_anchor) * _enemy_sprite_scale("ruin_drone")
			drone_local.x *= float(facing)
			projectile_pos = pos + drone_local
			projectile_special = "ruin_bolt"
			speed = 120.0
		_spawn_enemy_projectile(projectile_pos, direction * speed, raw_damage, color, str(enemy.get("damage_type", "physical")), status, projectile_special)
		_play_sound("shoot")
		return Vector2.ZERO
	if kind == "roll":
		var roll_facing := facing
		if enemy_type == "cave_worm":
			roll_facing = int(enemy.get("roll_direction", facing))
			enemy["facing"] = roll_facing
			enemy["roll_active"] = true
			enemy["roll_time"] = _enemy_attack_recovery(enemy_type, attack_index)
			if not bool(enemy.get("roll_dust_started", false)):
				var worm_size: Vector2 = enemy.get("size", Vector2(34, 12))
				_spawn_enemy_impact(pos + Vector2(0.0, worm_size.y * 0.5), "cave_worm", "roll_dust", roll_facing, true, 0.56)
				enemy["roll_dust_started"] = true
		if distance <= attack_range + 28.0:
			_enemy_hit_player(enemy, roll_facing, "slow")
		if enemy_type == "cave_worm":
			return Vector2.ZERO
		return Vector2(float(facing) * 245.0, -25.0)
	if kind == "dash":
		if enemy_type == "mushroom_beetle":
			var beetle_size: Vector2 = enemy.get("size", Vector2(20, 14))
			_spawn_enemy_impact(pos + Vector2(0.0, beetle_size.y * 0.5), "mushroom_beetle", "dust_vfx", facing, false, 0.50)
			_emit_noise(pos, 105.0, "beetle_charge", 0.75)
		elif enemy_type == "night_ember":
			_spawn_enemy_impact(pos - Vector2(float(facing) * 12.0, 0.0), "night_ember", "flame_trail", facing, true, 0.44)
		elif enemy_type == "stone_beast":
			var charge_ground := pos + Vector2(0.0, float((enemy.get("size", Vector2(42, 30)) as Vector2).y) * 0.5)
			_spawn_enemy_impact(charge_ground, "stone_beast", "dust_trail", facing, true, 0.72)
		if distance <= attack_range + 20.0:
			_enemy_hit_player(enemy, facing)
		var dash_speed := 250.0 if enemy_type == "stone_beast" else 175.0
		var vertical_impulse := float(_enemy_movement_profile(enemy_type).get("hop_speed", 0.0)) if enemy_type == "wild_slime" else 0.0
		return Vector2(float(facing) * dash_speed, vertical_impulse)
	if enemy_type == "mossling" and attack_index == 1:
		var mossling_size: Vector2 = enemy.get("size", Vector2(18, 12))
		var impact_pos := pos + Vector2(float(facing) * 20.0, mossling_size.y * 0.5)
		_spawn_enemy_impact(impact_pos, "mossling", "root_impact", facing, true, 0.50)
	if enemy_type == "cave_worm" and attack_index == 1:
		var bite_impact_pos := pos + Vector2(float(facing) * 34.0, -5.0)
		_spawn_enemy_impact(bite_impact_pos, "cave_worm", "bite_impact", facing, true, 0.56)
	if distance <= attack_range + 14.0:
		_enemy_hit_player(enemy, facing)
	return Vector2.ZERO


func _enemy_hit_player(enemy: Dictionary, facing: int, forced_status := "") -> void:
	_damage_player(_incoming_damage(int(enemy.get("damage", 1)), str(enemy.get("damage_type", "physical"))))
	player_velocity += Vector2(float(facing) * 115.0, -80.0)
	if forced_status != "":
		_apply_player_status(forced_status)
	elif enemy.has("status_on_hit"):
		_apply_player_status(str(enemy["status_on_hit"]))


func _spawn_enemy_projectile(pos: Vector2, vel: Vector2, damage: int, color: Color, damage_type: String, status: String, special := "") -> void:
	enemy_projectiles.append({
		"pos": pos,
		"vel": vel,
		"damage": damage,
		"color": color,
		"life": 2.3,
		"anim_time": 0.0,
		"damage_type": damage_type,
		"status": status,
		"special": special
	})


func _enemy_on_floor(pos: Vector2, size: Vector2) -> bool:
	var foot_rect := Rect2(Vector2(pos.x - size.x * 0.4, pos.y + size.y * 0.5), Vector2(size.x * 0.8, 2.5))
	return _rect_collides(foot_rect)


func _move_enemy(pos: Vector2, motion: Vector2, size: Vector2) -> Vector2:
	if motion.x != 0.0:
		var horizontal_steps := maxi(1, ceili(absf(motion.x)))
		var horizontal_motion := motion.x / float(horizontal_steps)
		for _step in range(horizontal_steps):
			var x_pos := pos + Vector2(horizontal_motion, 0.0)
			if not _rect_collides(Rect2(x_pos - size * 0.5, size)):
				pos = x_pos
				continue
			if _enemy_on_floor(pos, size):
				var step_pos := _enemy_step_position(pos, horizontal_motion, size)
				if step_pos != pos:
					pos = step_pos
					continue
			break
	if motion.y != 0.0:
		var vertical_steps := maxi(1, ceili(absf(motion.y)))
		var vertical_motion := motion.y / float(vertical_steps)
		for _step in range(vertical_steps):
			var y_pos := pos + Vector2(0.0, vertical_motion)
			if _rect_collides(Rect2(y_pos - size * 0.5, size)):
				break
			pos = y_pos
	return pos


func _enemy_snap_to_ground(pos: Vector2, size: Vector2, maximum_distance: float) -> Vector2:
	if maximum_distance <= 0.0 or _rect_collides(Rect2(pos - size * 0.5, size)):
		return pos
	var last_valid := pos
	for step in range(1, ceili(maximum_distance) + 1):
		var candidate := pos + Vector2(0.0, float(step))
		if _rect_collides(Rect2(candidate - size * 0.5, size)):
			return last_valid
		last_valid = candidate
	if _enemy_on_floor(last_valid, size):
		return last_valid
	return pos


func _enemy_can_step_up(pos: Vector2, size: Vector2, direction: int) -> bool:
	return _enemy_step_position(pos, float(direction) * 2.0, size) != pos


func _enemy_step_has_support(pos: Vector2, size: Vector2, direction: int) -> bool:
	var leading_foot_x := pos.x + float(direction) * maxf(1.0, size.x * 0.5 - 1.0)
	var foot_y := pos.y + size.y * 0.5
	return _rect_collides(Rect2(Vector2(leading_foot_x - 2.0, foot_y), Vector2(4.0, 3.0)))


func _enemy_step_position(pos: Vector2, horizontal_motion: float, size: Vector2) -> Vector2:
	var direction := 1 if horizontal_motion > 0.0 else -1
	for step_height in range(1, TILE_SIZE + 2):
		var candidate := pos + Vector2(horizontal_motion, -float(step_height))
		if _rect_collides(Rect2(candidate - size * 0.5, size)):
			continue
		if _enemy_step_has_support(candidate, size, direction):
			return candidate
	return pos


func _enemy_position_valid(pos: Vector2, size: Vector2) -> bool:
	var half := size * 0.5
	if pos.x - half.x < 0.0 or pos.x + half.x >= WORLD_WIDTH * TILE_SIZE:
		return false
	if pos.y - half.y < 0.0 or pos.y + half.y >= WORLD_HEIGHT * TILE_SIZE:
		return false
	return not _rect_collides(Rect2(pos - half, size))


func _enemy_can_be_hit(enemy: Dictionary) -> bool:
	return not bool(enemy.get("burrow_hidden", false))


func _enemy_hitbox_rect(enemy: Dictionary) -> Rect2:
	var physics_size: Vector2 = enemy.get("size", Vector2(16, 16))
	var hitbox_size: Vector2 = enemy.get("hitbox_size", physics_size)
	var hitbox_offset: Vector2 = enemy.get("hitbox_offset", Vector2.ZERO)
	if str(enemy.get("type", "")) == "cave_worm" and str(enemy.get("anim_state", "idle")) == "attack_2":
		hitbox_size = Vector2(36, 36)
		hitbox_offset = Vector2(0, -12)
	var hitbox_center: Vector2 = enemy.get("pos", Vector2.ZERO)
	hitbox_center += hitbox_offset
	return Rect2(hitbox_center - hitbox_size * 0.5, hitbox_size)


func _closest_point_on_rect(rect: Rect2, point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, rect.position.x, rect.end.x),
		clampf(point.y, rect.position.y, rect.end.y)
	)


func _recover_enemy_position(pos: Vector2, size: Vector2, last_safe_pos: Vector2) -> Vector2:
	if _enemy_position_valid(last_safe_pos, size):
		return last_safe_pos
	for origin in [pos, last_safe_pos]:
		for radius in range(1, TILE_SIZE * 4 + 1):
			for x_direction in [0, -1, 1]:
				var candidate: Vector2 = origin + Vector2(float(x_direction * mini(radius, TILE_SIZE * 2)), -float(radius))
				if _enemy_position_valid(candidate, size):
					return candidate
	var fallback := Vector2(
		clampf(pos.x, size.x * 0.5 + 1.0, WORLD_WIDTH * TILE_SIZE - size.x * 0.5 - 1.0),
		clampf(pos.y, size.y * 0.5 + 1.0, WORLD_HEIGHT * TILE_SIZE - size.y * 0.5 - 1.0)
	)
	return fallback


func _move_flying_enemy(pos: Vector2, motion: Vector2, size: Vector2) -> Vector2:
	var steps := maxi(1, ceili(motion.length() / 6.0))
	var step_motion := motion / float(steps)
	for _step in range(steps):
		var next_pos := pos + step_motion
		if not _rect_collides(Rect2(next_pos - size * 0.5, size)):
			pos = next_pos
			continue
		var x_pos := pos + Vector2(step_motion.x, 0.0)
		if not _rect_collides(Rect2(x_pos - size * 0.5, size)):
			pos = x_pos
		var y_pos := pos + Vector2(0.0, step_motion.y)
		if not _rect_collides(Rect2(y_pos - size * 0.5, size)):
			pos = y_pos
	return pos


func _update_projectiles(delta: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = projectiles[i]
		var pos: Vector2 = projectile["pos"]
		var vel: Vector2 = projectile["vel"]
		var kind := str(projectile.get("kind", "bolt"))
		if kind == "spirit":
			var target_index := _nearest_enemy_index(pos, 180.0)
			if target_index >= 0:
				var target: Dictionary = enemies[target_index]
				var target_pos: Vector2 = target["pos"]
				vel = vel.lerp((target_pos - pos).normalized() * 230.0, 0.12)
		if kind == "acid":
			vel.y += 520.0 * delta
		pos += vel * delta
		projectile["pos"] = pos
		projectile["vel"] = vel
		projectile["life"] = float(projectile.get("life", 1.0)) - delta
		var remove: bool = float(projectile["life"]) <= 0.0
		if _get_tile(floori(pos.x / TILE_SIZE), floori(pos.y / TILE_SIZE)) != Tile.AIR:
			remove = true
		for enemy_index in range(enemies.size() - 1, -1, -1):
			var enemy: Dictionary = enemies[enemy_index]
			if not _enemy_can_be_hit(enemy):
				continue
			var enemy_rect := _enemy_hitbox_rect(enemy)
			if enemy_rect.has_point(pos):
				_damage_enemy(enemy_index, int(projectile.get("damage", 1)), Vector2(signf(vel.x), -0.3), str(projectile.get("damage_type", "physical")), str(projectile.get("status", "")))
				remove = true
				if kind == "acid":
					_damage_enemies_in_radius(pos, 28.0, int(projectile.get("damage", 1)) / 2)
				break
		if remove:
			if kind == "cannon":
				_emit_noise(pos, 245.0, "explosion", 1.35)
			elif kind == "acid":
				_emit_noise(pos, 92.0, "acid_impact", 0.75)
			projectiles.remove_at(i)


func _update_enemy_projectiles(delta: float) -> void:
	var player_rect := Rect2(player_position - PLAYER_SIZE * 0.5, PLAYER_SIZE)
	for i in range(enemy_projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = enemy_projectiles[i]
		var pos: Vector2 = projectile["pos"]
		var velocity: Vector2 = projectile["vel"]
		var projectile_special := str(projectile.get("special", ""))
		if projectile_special == "cave_husk_rock":
			velocity.y += 310.0 * delta
			projectile["vel"] = velocity
		pos += velocity * delta
		projectile["pos"] = pos
		projectile["anim_time"] = float(projectile.get("anim_time", 0.0)) + delta
		projectile["life"] = float(projectile.get("life", 0.0)) - delta
		var remove := float(projectile["life"]) <= 0.0
		var tile := _get_tile(floori(pos.x / TILE_SIZE), floori(pos.y / TILE_SIZE))
		if tile != Tile.AIR and tile != Tile.WATER and tile != Tile.LAVA:
			remove = true
		if player_rect.grow(3.0).has_point(pos):
			_damage_player(_incoming_damage(int(projectile.get("damage", 1)), str(projectile.get("damage_type", "physical"))))
			var direction := (projectile["vel"] as Vector2).normalized()
			var special := projectile_special
			if special in ["harpoon", "drowned_harpoon"]:
				player_velocity += -direction * 180.0 + Vector2(0, -35.0)
			else:
				player_velocity += direction * 95.0 + Vector2(0, -45.0)
			var status := str(projectile.get("status", ""))
			if status != "":
				_apply_player_status(status)
			_spawn_hit_particles(pos, projectile.get("color", Color.WHITE), 4)
			remove = true
		if remove:
			if projectile_special == "wild_ichor":
				_spawn_enemy_impact(pos, "wild_slime", "ichor_impact", 1, false, 0.34)
			elif projectile_special == "cave_husk_rock":
				var impact_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "cave_husk", "rock_impact", impact_facing, false, 0.50)
				_emit_noise(pos, 150.0, "rock_impact", 1.0)
			elif projectile_special == "mushroom_poison":
				var poison_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "mushroom_beetle", "poison_impact", poison_facing, false, 0.50)
			elif projectile_special == "ash_phantom_ember":
				var ember_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "ash_phantom", "ember_impact", ember_facing, false, 0.50)
			elif projectile_special == "ash_wisp_ember":
				var wisp_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "ash_wisp", "ember_impact", wisp_facing, true, 0.44)
			elif projectile_special == "sentinel_ash":
				var sentinel_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "ash_sentinel", "projectile_impact", sentinel_facing, true, 0.50)
			elif projectile_special == "drowned_harpoon":
				var harpoon_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "drowned_guard", "harpoon_impact", harpoon_facing, true, 0.50)
			elif projectile_special == "drowned_wave":
				var wave_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "drowned_guard", "wave_impact", wave_facing, true, 0.50)
			elif projectile_special == "ember_seed":
				var seed_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "ember_rootling", "seed_impact", seed_facing, true, 0.50)
			elif projectile_special == "glass_shard":
				var shard_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "glass_wraith", "shard_impact", shard_facing, true, 0.50)
			elif projectile_special == "night_fire":
				var fire_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "night_ember", "fire_impact", fire_facing, true, 0.44)
			elif projectile_special == "ruin_bolt":
				var bolt_facing := 1 if velocity.x >= 0.0 else -1
				_spawn_enemy_impact(pos, "ruin_drone", "bolt_impact", bolt_facing, true, 0.50)
			elif projectile_special == "stone_falling_rock":
				_spawn_enemy_impact(pos, "stone_beast", "rock_impact", 1, true, 0.72)
				_emit_noise(pos, 175.0, "stone_rock_impact", 1.10)
			enemy_projectiles.remove_at(i)
		else:
			enemy_projectiles[i] = projectile


func _spawn_enemy_impact(pos: Vector2, enemy_type: String, effect_state: String, effect_facing := 1, use_pack_anchor := false, effect_scale := 0.34) -> void:
	enemy_impact_effects.append({
		"pos": pos,
		"enemy_type": enemy_type,
		"state": effect_state,
		"facing": effect_facing,
		"use_pack_anchor": use_pack_anchor,
		"scale": effect_scale,
		"time": 0.0,
		"duration": _enemy_animation_duration(enemy_type, effect_state, 0.45)
	})


func _update_enemy_impact_effects(delta: float) -> void:
	for i in range(enemy_impact_effects.size() - 1, -1, -1):
		var effect: Dictionary = enemy_impact_effects[i]
		effect["time"] = float(effect.get("time", 0.0)) + delta
		if float(effect["time"]) >= float(effect.get("duration", 0.45)):
			enemy_impact_effects.remove_at(i)
		else:
			enemy_impact_effects[i] = effect


func _update_engineer_turret(delta: float) -> void:
	if equipped_weapon != "small_turret":
		return
	if attack_cooldown > 0.0:
		return
	var target_index := _nearest_enemy_index(player_position, 220.0)
	if target_index < 0:
		return
	var enemy: Dictionary = enemies[target_index]
	var target_pos: Vector2 = enemy["pos"]
	var dir := (target_pos - player_position).normalized()
	_spawn_projectile(player_position + dir * 14.0, dir * 310.0, _total_damage(), "turret", Color("aeefff"), 1.0, "arcane", "")
	_start_attack_animation("turret", dir, Color("aeefff"), 0.18)
	_play_sound("shoot")
	_emit_noise(player_position, 175.0, "turret_shot", 0.95)
	attack_cooldown = 0.7


func _update_status_effects(delta: float) -> void:
	if god_mode_enabled:
		health = MAX_HEALTH
		player_statuses.clear()
	for status in player_statuses.keys():
		var data: Dictionary = player_statuses[status]
		data["time"] = float(data.get("time", 0.0)) - delta
		data["tick"] = float(data.get("tick", 0.0)) - delta
		if float(data["tick"]) <= 0.0:
			data["tick"] = 1.0
			if status == "poison":
				health = maxi(0, health - 2)
				_spawn_damage_number(player_position + Vector2(0, -28), 2, Color("89e36b"))
			elif status == "burn":
				health = maxi(0, health - 3)
				_spawn_damage_number(player_position + Vector2(0, -28), 3, Color("ff8a3c"))
			if health <= 0:
				_respawn_player()
				return
		player_statuses[status] = data
		if float(data["time"]) <= 0.0:
			player_statuses.erase(status)
			if status == "root_bind":
				_apply_player_status("slow")
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		var statuses: Dictionary = enemy.get("statuses", {})
		for status in statuses.keys():
			var data: Dictionary = statuses[status]
			data["time"] = float(data.get("time", 0.0)) - delta
			data["tick"] = float(data.get("tick", 0.0)) - delta
			if float(data["tick"]) <= 0.0:
				data["tick"] = 1.0
				var tick_damage := 2 if status == "poison" else 3
				enemy["hp"] = int(enemy.get("hp", 1)) - tick_damage
				_spawn_damage_number((enemy["pos"] as Vector2) + Vector2(0, -18), tick_damage, Color("89e36b") if status == "poison" else Color("ff8a3c"))
			statuses[status] = data
			if float(data["time"]) <= 0.0:
				statuses.erase(status)
		enemy["statuses"] = statuses
		if int(enemy.get("hp", 1)) <= 0:
			_kill_enemy(i)


func _try_player_attack() -> void:
	_try_player_attack_at(Vector2.ZERO, false)


func _try_player_attack_at(target: Vector2, use_target := true) -> void:
	if inventory_open or full_map_open or attack_cooldown > 0.0:
		return
	mobile_attack_target = target
	mobile_attack_target_valid = use_target
	if use_target and absf(target.x - player_position.x) > 4.0:
		facing = 1 if target.x > player_position.x else -1
	var weapon := equipped_weapon
	if weapon == "":
		_melee_attack(20.0, 5, 0.34)
	elif weapon.contains("sword") or weapon.contains("sickle"):
		_melee_attack(34.0, _total_damage(), 0.38)
	elif weapon.contains("spear"):
		_melee_attack(48.0, _total_damage() + 2, 0.48)
	elif weapon == "stonebreaker_blade" or weapon == "leviathan_fang":
		_melee_attack(42.0, _total_damage() + 4, 0.42)
	elif weapon == "tidal_trident":
		_melee_attack(56.0, _total_damage() + 3, 0.46)
	elif weapon.contains("bow"):
		_fire_projectile_weapon(330.0, _total_damage(), "arrow", Color("d5a15a"), 0.55)
	elif weapon == "hand_cannon":
		_fire_projectile_weapon(430.0, _total_damage() + 5, "cannon", Color("ffe1a1"), 0.95)
	elif weapon == "harpoon":
		_fire_projectile_weapon(390.0, _total_damage() + 4, "harpoon", Color("8fd5df"), 0.78)
	elif weapon == "spark_staff":
		_fire_projectile_weapon(260.0, _total_damage() + 4, "spark", Color("b79cff"), 0.62)
	elif weapon == "tide_staff":
		_fire_projectile_weapon(300.0, _total_damage() + 4, "tide", Color("72d6dc"), 0.66)
	elif weapon == "root_spirit_rod":
		_fire_projectile_weapon(210.0, _total_damage(), "spirit", Color("80d989"), 0.85)
	elif weapon == "acid_flasks":
		_fire_projectile_weapon(210.0, _total_damage(), "acid", Color("94e86f"), 0.72)
	elif weapon == "small_turret":
		_update_engineer_turret(0.0)
	else:
		_melee_attack(28.0, _total_damage(), 0.45)
	mobile_attack_target_valid = false


func _melee_attack(range_px: float, damage: int, cooldown: float) -> void:
	var center := player_position + Vector2(float(facing) * range_px * 0.6, 0.0)
	var attack_rect := Rect2(center - Vector2(range_px * 0.5, 18.0), Vector2(range_px, 36.0))
	var hit := false
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		if not _enemy_can_be_hit(enemy):
			continue
		var enemy_rect := _enemy_hitbox_rect(enemy)
		if attack_rect.intersects(enemy_rect):
			_damage_enemy(i, damage, Vector2(facing, -0.2), _weapon_damage_type(equipped_weapon), _weapon_status(equipped_weapon))
			hit = true
	var weapon := equipped_weapon
	var anim_kind := "spear" if weapon.contains("spear") else "slash"
	_start_attack_animation(anim_kind, Vector2(facing, 0), Color("f0d27a"), cooldown)
	_play_sound("hit")
	_emit_noise(player_position, 58.0 if weapon == "" else 72.0, "melee", 0.55)
	attack_cooldown = cooldown
	last_message = "Hit!" if hit else "Swing."


func _fire_projectile_weapon(speed: float, damage: int, kind: String, color: Color, cooldown: float) -> void:
	var aim_position := mobile_attack_target if mobile_attack_target_valid else get_global_mouse_position()
	var aim_dir := aim_position - player_position
	if aim_dir.length() < 8.0:
		aim_dir = Vector2(facing, 0)
	var dir := aim_dir.normalized()
	_spawn_projectile(player_position + dir * 14.0, dir * speed, damage, kind, color, 1.5, _projectile_damage_type(kind), _projectile_status(kind))
	var anim_kind := "bow"
	if kind == "cannon":
		anim_kind = "cannon"
	elif kind == "spark" or kind == "spirit" or kind == "tide":
		anim_kind = "staff"
	elif kind == "acid":
		anim_kind = "flask"
	_start_attack_animation(anim_kind, dir, color, cooldown)
	_play_sound("shoot")
	var noise_radius := 145.0
	if kind == "cannon":
		noise_radius = 310.0
	elif kind == "spark" or kind == "spirit" or kind == "tide":
		noise_radius = 185.0
	elif kind == "acid":
		noise_radius = 125.0
	_emit_noise(player_position, noise_radius, "shot_%s" % kind, 1.0)
	attack_cooldown = cooldown
	last_message = "Fired %s." % kind


func _spawn_projectile(pos: Vector2, vel: Vector2, damage: int, kind: String, color: Color, life: float, damage_type: String = "physical", status: String = "") -> void:
	projectiles.append({"pos": pos, "vel": vel, "damage": damage, "kind": kind, "color": color, "life": life, "damage_type": damage_type, "status": status})


func _start_attack_animation(kind: String, dir: Vector2, color: Color, duration: float) -> void:
	attack_anim_kind = kind
	attack_anim_dir = dir.normalized() if dir.length() > 0.01 else Vector2(facing, 0)
	attack_anim_color = color
	attack_anim_duration = maxf(0.12, duration)
	attack_anim_time = attack_anim_duration


func _update_attack_animation(delta: float) -> void:
	attack_anim_time = maxf(0.0, attack_anim_time - delta)
	if attack_anim_time <= 0.0:
		attack_anim_kind = ""


func _weapon_damage_type(weapon: String) -> String:
	if weapon in ["ash_sickle", "spark_staff", "root_spirit_rod", "tide_staff"]:
		return "arcane"
	if weapon == "acid_flasks":
		return "poison"
	return "physical"


func _weapon_status(weapon: String) -> String:
	if weapon == "ash_sickle":
		return "slow"
	return ""


func _projectile_damage_type(kind: String) -> String:
	if kind == "acid":
		return "poison"
	if kind == "spark" or kind == "spirit" or kind == "turret" or kind == "tide":
		return "arcane"
	if kind == "arrow" and equipped_accessory == "fire_arrows":
		return "fire"
	return "physical"


func _projectile_status(kind: String) -> String:
	if kind == "acid":
		return "poison"
	if kind == "spirit":
		return "slow"
	if kind == "harpoon" or kind == "tide":
		return "slow"
	if kind == "arrow" and equipped_accessory == "fire_arrows":
		return "burn"
	return ""


func _damage_enemy(index: int, damage: int, knockback: Vector2, damage_type: String = "physical", status: String = "") -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy: Dictionary = enemies[index]
	_force_enemy_combat(enemy, player_position, true)
	# The world-edge leviathan cannot be killed by ordinary weapons. Damage is
	# refused outright until the story flag is set, so the border stays a wall
	# of teeth rather than a health bar to grind down.
	if bool(enemy.get("story_invulnerable", false)) and not leviathan_story_unlocked:
		enemy["hit_timer"] = 0.12
		if world_edge_warning_timer <= 0.0:
			world_edge_warning_timer = 5.0
			last_message = "Your weapon glances off ancient plated hide."
		return
	var final_damage := damage
	if damage_type == "poison":
		final_damage = int(ceil(float(damage) * 0.85))
	elif damage_type == "fire":
		final_damage = int(ceil(float(damage) * 0.95))
	elif damage_type == "arcane":
		final_damage = int(ceil(float(damage) * 1.08))
	if float(enemy.get("guard_time", 0.0)) > 0.0:
		final_damage = maxi(1, int(ceil(float(final_damage) * 0.40)))
	enemy["hp"] = int(enemy.get("hp", 1)) - final_damage
	var enemy_type := str(enemy.get("type", ""))
	enemy["hit_timer"] = _enemy_animation_duration(enemy_type, "hurt", 0.12) if enemy_type in ["bat", "spore_bat", "cave_husk", "archive_warden"] else 0.12
	if enemy_type == "spore_bat" and rng.randf() < 0.35:
		var spore_cloud_pos: Vector2 = enemy.get("pos", Vector2.ZERO)
		_spawn_enemy_impact(spore_cloud_pos, "spore_bat", "spore_cloud", int(enemy.get("facing", 1)), false, 0.38)
		if spore_cloud_pos.distance_to(player_position) <= 48.0:
			_damage_player(_incoming_damage(3, "poison"))
			_apply_player_status("poison")
	if status != "":
		_apply_enemy_status(enemy, status)
	var enemy_pos: Vector2 = enemy["pos"]
	_spawn_damage_number(enemy_pos + Vector2(0, -18), final_damage, _damage_color(damage_type))
	_spawn_hit_particles(enemy_pos, Color("ffd18a"), 5)
	_play_sound("hit")
	var vel: Vector2 = enemy["vel"]
	var knockback_scale := float(_enemy_movement_profile(enemy_type).get("knockback_scale", 1.0))
	vel += knockback * 150.0 * knockback_scale
	enemy["vel"] = vel
	enemy["stun_timer"] = 0.38 if enemy_type in ["spore_bat", "cave_husk"] else 0.15
	if int(enemy.get("hp", 1)) <= 0:
		_kill_enemy(index)


func _apply_enemy_status(enemy: Dictionary, status: String) -> void:
	var statuses: Dictionary = enemy.get("statuses", {})
	var duration := 4.0
	if status == "slow":
		duration = 2.8
	elif status == "burn":
		duration = 3.5
	elif status == "poison":
		duration = 5.0
	statuses[status] = {"time": duration, "tick": 1.0}
	enemy["statuses"] = statuses


func _damage_color(damage_type: String) -> Color:
	if damage_type == "poison":
		return Color("89e36b")
	if damage_type == "fire":
		return Color("ff8a3c")
	if damage_type == "arcane":
		return Color("c49cff")
	return Color("ffe08a")


func _damage_enemies_in_radius(center: Vector2, radius: float, damage: int) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		if not _enemy_can_be_hit(enemy):
			continue
		var hitbox := _enemy_hitbox_rect(enemy)
		var hit_point := _closest_point_on_rect(hitbox, center)
		if hit_point.distance_to(center) > radius:
			continue
		var pos: Vector2 = enemy["pos"]
		_damage_enemy(i, damage, (pos - center).normalized())


func _kill_enemy(index: int) -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy: Dictionary = enemies[index]
	var drop := str(enemy.get("drop", "wild_ichor"))
	var pos: Vector2 = enemy["pos"]
	var enemy_type := str(enemy.get("type", ""))
	_record_enemy_kill(enemy_type)
	if enemy_type == "stone_beast":
		stone_beast_defeated = true
		_spawn_loot(pos, "beast_core", 1)
		_spawn_loot(pos + Vector2(-12, -8), "cracked_memory_core", 1)
		_spawn_loot(pos + Vector2(12, -8), "stoneblood_ore", 8)
		_unlock_stone_beast_progression()
		last_message = "Stone Beast defeated. A cracked memory core is still pulsing."
	elif enemy_type == "heartwood_boss":
		boss_defeated = true
		_spawn_loot(pos, drop, 1)
		_spawn_loot(pos + Vector2(14, -8), "world_memory", 1)
		last_message = "Heartwood Core defeated. The world remembers you."
	elif enemy_type == "archive_warden":
		archive_warden_defeated = true
		_spawn_loot(pos, "archive_sigil", 1)
		_spawn_loot(pos + Vector2(14, -8), "spark_shard", 4)
		last_message = "Archive Warden defeated. The Archive Sigil answers the Ashen Lens."
	else:
		defeated_enemies += 1
		_spawn_loot(pos, drop, 1)
		if rng.randf() < 0.16:
			_spawn_loot(pos + Vector2(8, -6), "memory_shard", 1)
		last_message = "Defeated %s. Dropped %s." % [str(enemy.get("name", "enemy")), _item_display_name(drop)]
	_spawn_hit_particles(pos, Color("f2d38b"), 9)
	var corpse := enemy.duplicate(true)
	if enemy_type in ["bat", "spore_bat"]:
		corpse["death_phase"] = "fall"
		corpse["death_anim_time"] = 0.0
		corpse["death_velocity"] = (enemy.get("vel", Vector2.ZERO) as Vector2) * 0.45 + Vector2(0.0, 25.0)
		corpse["death_time"] = 4.0
		corpse["death_total"] = 4.0
	else:
		var death_duration := _enemy_animation_duration(enemy_type, "death", 0.36)
		corpse["death_time"] = death_duration
		corpse["death_total"] = death_duration
		corpse["anim_time"] = 0.0
	dying_enemies.append(corpse)
	enemies.remove_at(index)


func _spawn_loot(pos: Vector2, item_id: String, amount: int) -> void:
	if amount <= 0:
		return
	var spread := Vector2(rng.randf_range(-58.0, 58.0), rng.randf_range(-170.0, -95.0))
	_spawn_loot_with_velocity(pos, item_id, amount, spread, 0.35)


func _spawn_loot_with_velocity(pos: Vector2, item_id: String, amount: int, velocity: Vector2, pickup_delay: float) -> void:
	if amount <= 0:
		return
	dropped_items.append({
		"id": item_id,
		"amount": amount,
		"pos": pos,
		"vel": velocity,
		"age": 0.0,
		"bob": rng.randf_range(0.0, TAU),
		"pickup_delay": pickup_delay
	})


func _update_world_loot_and_fx(delta: float) -> void:
	_update_dropped_items(delta)
	_update_damage_numbers(delta)
	_update_hit_particles(delta)


func _update_dropped_items(delta: float) -> void:
	for i in range(dropped_items.size() - 1, -1, -1):
		var item: Dictionary = dropped_items[i]
		var pos: Vector2 = item["pos"]
		var vel: Vector2 = item["vel"]
		var age := float(item.get("age", 0.0)) + delta
		var pickup_delay := maxf(0.0, float(item.get("pickup_delay", 0.0)) - delta)
		var to_player := player_position - pos
		var distance := to_player.length()
		if pickup_delay <= 0.0 and distance < LOOT_MAGNET_RADIUS:
			var pull := clampf(1.0 - distance / LOOT_MAGNET_RADIUS, 0.0, 1.0)
			vel = vel.lerp(to_player.normalized() * lerpf(160.0, 520.0, pull), 0.18)
		else:
			vel.y += GRAVITY * 0.55 * delta
			vel.x = lerpf(vel.x, 0.0, 0.025)
		var moved := _move_loot(pos, vel, delta)
		pos = moved["pos"]
		vel = moved["vel"]
		item["pos"] = pos
		item["vel"] = vel
		item["age"] = age
		item["pickup_delay"] = pickup_delay
		if pickup_delay <= 0.0 and distance < LOOT_PICKUP_RADIUS:
			var picked_id := str(item.get("id", ""))
			var picked_amount := int(item.get("amount", 1))
			_add_item(picked_id, picked_amount)
			_add_loot_notification(picked_id, picked_amount)
			_play_sound("pickup")
			last_message = "Picked up %s x%d." % [_item_display_name(picked_id), picked_amount]
			dropped_items.remove_at(i)
		elif age > LOOT_DESPAWN_TIME:
			dropped_items.remove_at(i)


func _move_loot(pos: Vector2, vel: Vector2, delta: float) -> Dictionary:
	var size := Vector2(10, 10)
	var half := size * 0.5
	if _rect_collides(Rect2(pos - half, size)):
		for step in range(1, 9):
			var candidate := pos + Vector2(0, -float(step) * 2.0)
			if not _rect_collides(Rect2(candidate - half, size)):
				pos = candidate
				vel.y = 0.0
				break

	var x_pos := pos + Vector2(vel.x * delta, 0.0)
	if _rect_collides(Rect2(x_pos - half, size)):
		vel.x = 0.0
	else:
		pos = x_pos

	var y_pos := pos + Vector2(0.0, vel.y * delta)
	if _rect_collides(Rect2(y_pos - half, size)):
		vel.y = 0.0
	else:
		pos = y_pos

	if absf(vel.x) < 2.0:
		vel.x = 0.0
	return {"pos": pos, "vel": vel}


func _spawn_damage_number(pos: Vector2, amount: int, color: Color) -> void:
	damage_numbers.append({
		"text": str(amount),
		"pos": pos,
		"vel": Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-58.0, -42.0)),
		"life": 0.75,
		"color": color
	})


func _update_damage_numbers(delta: float) -> void:
	for i in range(damage_numbers.size() - 1, -1, -1):
		var number: Dictionary = damage_numbers[i]
		var pos: Vector2 = number["pos"]
		var vel: Vector2 = number["vel"]
		pos += vel * delta
		vel.y += 60.0 * delta
		number["pos"] = pos
		number["vel"] = vel
		number["life"] = float(number.get("life", 0.0)) - delta
		if float(number["life"]) <= 0.0:
			damage_numbers.remove_at(i)


func _add_loot_notification(item_id: String, amount: int) -> void:
	loot_notifications.push_front({"text": "+ %s x%d" % [_item_display_name(item_id), amount], "life": 2.5})
	while loot_notifications.size() > loot_feed_labels.size():
		loot_notifications.pop_back()


func _update_loot_feed() -> void:
	var delta := get_process_delta_time()
	for i in range(loot_notifications.size() - 1, -1, -1):
		var note: Dictionary = loot_notifications[i]
		note["life"] = float(note.get("life", 0.0)) - delta
		if float(note["life"]) <= 0.0:
			loot_notifications.remove_at(i)
	for i in range(loot_feed_labels.size()):
		var label := loot_feed_labels[i]
		if i < loot_notifications.size():
			var note: Dictionary = loot_notifications[i]
			var alpha := clampf(float(note.get("life", 0.0)) / 2.5, 0.0, 1.0)
			label.text = str(note.get("text", ""))
			label.modulate = Color(1.0, 0.92, 0.58, alpha)
		else:
			label.text = ""


func _update_held_item_preview() -> void:
	if held_item_panel == null:
		return
	if held_item_id == "":
		held_item_panel.visible = false
		return
	var mouse_pos := get_viewport().get_mouse_position()
	held_item_panel.visible = true
	held_item_panel.offset_left = mouse_pos.x + 16.0
	held_item_panel.offset_top = mouse_pos.y + 14.0
	held_item_panel.offset_right = held_item_panel.offset_left + 72.0
	held_item_panel.offset_bottom = held_item_panel.offset_top + 40.0
	held_item_icon.texture = _item_icon(held_item_id)
	held_item_amount_label.text = "x%d" % held_item_amount


func _spawn_hit_particles(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		var dir := Vector2.RIGHT.rotated(rng.randf_range(0.0, TAU))
		hit_particles.append({
			"pos": pos + dir * rng.randf_range(0.0, 8.0),
			"vel": dir * rng.randf_range(35.0, 115.0),
			"life": rng.randf_range(0.22, 0.48),
			"color": color
		})


func _update_hit_particles(delta: float) -> void:
	for i in range(hit_particles.size() - 1, -1, -1):
		var particle: Dictionary = hit_particles[i]
		var pos: Vector2 = particle["pos"]
		var vel: Vector2 = particle["vel"]
		pos += vel * delta
		vel *= 0.88
		particle["pos"] = pos
		particle["vel"] = vel
		particle["life"] = float(particle.get("life", 0.0)) - delta
		if float(particle["life"]) <= 0.0:
			hit_particles.remove_at(i)


func _nearest_enemy_index(origin: Vector2, max_distance: float) -> int:
	var best_index := -1
	var best_distance := max_distance
	for i in range(enemies.size()):
		var enemy: Dictionary = enemies[i]
		if not _enemy_can_be_hit(enemy):
			continue
		var distance := _closest_point_on_rect(_enemy_hitbox_rect(enemy), origin).distance_to(origin)
		if distance < best_distance:
			best_distance = distance
			best_index = i
	return best_index


func _move_player(motion: Vector2) -> void:
	if motion == Vector2.ZERO:
		return

	var next_pos := player_position + motion
	var next_rect := Rect2(next_pos - PLAYER_SIZE * 0.5, PLAYER_SIZE)

	if not _rect_collides(next_rect):
		player_position = next_pos
		if motion.y > 0.0:
			player_on_floor = false
		return

	if motion.x != 0.0:
		while absf(motion.x) > 0.5:
			var step := Vector2(signf(motion.x), 0.0)
			var stepped_rect := Rect2(player_position + step - PLAYER_SIZE * 0.5, PLAYER_SIZE)
			if _rect_collides(stepped_rect):
				# The terrain is tile-based, so a one-tile rise used to behave like
				# an invisible wall. Step up a single natural terrain tile instead.
				if _try_step_up(step):
					motion.x -= step.x
					continue
				player_velocity.x = 0.0
				return
			player_position += step
			motion.x -= step.x
		player_velocity.x = 0.0
		return

	if motion.y != 0.0:
		while absf(motion.y) > 0.5:
			var step := Vector2(0.0, signf(motion.y))
			var stepped_rect := Rect2(player_position + step - PLAYER_SIZE * 0.5, PLAYER_SIZE)
			if _rect_collides(stepped_rect):
				if motion.y > 0.0:
					player_on_floor = true
				player_velocity.y = 0.0
				return
			player_position += step
			motion.y -= step.y
		player_velocity.y = 0.0


func _try_step_up(horizontal_step: Vector2) -> bool:
	if not player_on_floor:
		return false
	for height in range(1, AUTO_STEP_HEIGHT + 1):
		var candidate_position := player_position + horizontal_step + Vector2(0.0, -float(height))
		var candidate_rect := Rect2(candidate_position - PLAYER_SIZE * 0.5, PLAYER_SIZE)
		if not _rect_collides(candidate_rect):
			player_position = candidate_position
			player_velocity.y = 0.0
			player_on_floor = true
			return true
	return false


func _rect_collides(rect: Rect2) -> bool:
	var gate_collision := _archive_gate_collision_rect()
	if gate_collision.has_area() and gate_collision.intersects(rect):
		return true
	var min_x := floori(rect.position.x / TILE_SIZE)
	var max_x := floori((rect.position.x + rect.size.x - 1.0) / TILE_SIZE)
	var min_y := floori(rect.position.y / TILE_SIZE)
	var max_y := floori((rect.position.y + rect.size.y - 1.0) / TILE_SIZE)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if _is_solid(x, y):
				return true
	return false


func _is_on_floor() -> bool:
	var foot_rect := Rect2(
		Vector2(player_position.x - PLAYER_SIZE.x * 0.5 + 2.0, player_position.y + PLAYER_SIZE.y * 0.5),
		Vector2(PLAYER_SIZE.x - 4.0, 2.0)
	)
	return _rect_collides(foot_rect)


func _handle_block_actions() -> void:
	if inventory_open or full_map_open:
		mining_progress = 0.0
		mining_target = Vector2i(-999, -999)
		return
	# Keep our own mouse state in addition to the InputMap action. This avoids
	# losing a held left click if the action map is not refreshed correctly.
	var is_mining := mouse_mine_held or Input.is_action_pressed("mine")
	if is_mining:
		# Mining always follows the block currently under the cursor. A held
		# button must never keep mining the previous target after the cursor moves.
		var cursor_target := _mouse_tile()
		if mining_target != cursor_target:
			mining_target = cursor_target
			mining_progress = 0.0
		_mine_target_tile(cursor_target)
	else:
		mining_progress = 0.0
		mining_target = Vector2i(-999, -999)

	if Input.is_action_just_pressed("place"):
		_place_target_tile()


func _mine_target_tile(tile_pos: Vector2i) -> void:
	if not _can_interact(tile_pos):
		return
	var tile := _get_tile(tile_pos.x, tile_pos.y)
	if tile == Tile.AIR:
		_advance_mining_target(tile_pos)
		return
	if tile == Tile.WATER or tile == Tile.LAVA:
		mining_progress = 0.0
		mining_target = tile_pos
		return
	if _tool_power() < int(tile_required_power.get(tile, 1)):
		mining_progress = 0.0
		mining_target = tile_pos
		return
	if mining_target != tile_pos:
		mining_target = tile_pos
		mining_progress = 0.0

	var hardness := _mining_hardness(tile, tile_pos)
	mining_progress += get_process_delta_time() * _tool_speed()
	if mining_progress < hardness:
		return
	var mining_world_pos := Vector2(tile_pos) * TILE_SIZE + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
	_emit_noise(mining_world_pos, clampf(82.0 + hardness * 42.0, 82.0, 145.0), "mining", 0.92)

	var item_id := str(tile_to_item.get(tile, "dirt"))
	if tile == Tile.LEAVES:
		_set_tile(tile_pos.x, tile_pos.y, Tile.AIR)
		_start_mining_tool_animation(tile_pos)
		_play_sound("mine")
		_advance_mining_target(tile_pos)
		return
	if tile == Tile.WOOD and _is_tree_base(tile_pos):
		_fell_tree_from(tile_pos)
		_start_mining_tool_animation(tile_pos)
		_play_sound("mine")
		_advance_mining_target(tile_pos)
		return
	if tile == Tile.STONE:
		stone_broken_count += 1
		if stone_broken_count >= 140 and not stone_beast_spawned and not stone_beast_defeated:
			_spawn_stone_beast()
	_spawn_loot(Vector2(tile_pos) * TILE_SIZE + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5), item_id, 1)
	_add_rare_drop(tile, Vector2(tile_pos) * TILE_SIZE + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5))
	if item_to_tile.has(item_id):
		selected_block = int(item_to_tile[item_id])
	_set_tile(tile_pos.x, tile_pos.y, Tile.AIR)
	_settle_unsupported_chest(tile_pos + Vector2i(0, -1))
	_start_mining_tool_animation(tile_pos)
	_play_sound("mine")
	_advance_mining_target(tile_pos)


func _advance_mining_target(from_pos: Vector2i) -> void:
	mining_progress = 0.0
	var player_tile := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
	var direction := Vector2i(signi(from_pos.x - player_tile.x), signi(from_pos.y - player_tile.y))
	if direction == Vector2i.ZERO:
		direction = Vector2i(0, 1)
	for step in range(1, 7):
		var candidate := from_pos + direction * step
		if not _in_bounds(candidate.x, candidate.y) or not _can_interact(candidate):
			break
		var next_tile := _get_tile(candidate.x, candidate.y)
		if next_tile != Tile.AIR and next_tile != Tile.WATER and next_tile != Tile.LAVA:
			mining_target = candidate
			return
	mining_target = Vector2i(-999, -999)


func _start_mining_tool_animation(tile_pos: Vector2i) -> void:
	var target_pos := Vector2(tile_pos) * TILE_SIZE + Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
	var direction := (target_pos - player_position).normalized()
	if direction.length() < 0.1:
		direction = Vector2(float(facing), 0)
	_start_attack_animation("slash", direction, Color("d9b969"), 0.18)


func _mining_hardness(tile: int, tile_pos: Vector2i) -> float:
	var hardness := float(tile_hardness.get(tile, 0.4))
	if tile == Tile.WOOD and _is_tree_base(tile_pos):
		hardness *= TREE_BASE_HARDNESS_MULTIPLIER
	return hardness


func _is_tree_base(tile_pos: Vector2i) -> bool:
	if _get_tile(tile_pos.x, tile_pos.y) != Tile.WOOD:
		return false
	var below := _get_tile(tile_pos.x, tile_pos.y + 1)
	if below == Tile.WOOD or below == Tile.LEAVES:
		return false
	return below == Tile.GRASS or below == Tile.DIRT or below == Tile.MOSS or below == Tile.ROOT or below == Tile.STONE or _is_biome_topsoil_tile(below)


func _fell_tree_from(base_pos: Vector2i) -> void:
	var tree_id := int(tree_tile_owners.get(_tile_key(base_pos), -1))
	if tree_id >= 0:
		_fell_owned_tree(base_pos, tree_id)
		return
	_fell_legacy_tree(base_pos)


func _fell_owned_tree(base_pos: Vector2i, tree_id: int) -> void:
	var owned_wood: Array[Vector2i] = []
	var owned_leaves: Array[Vector2i] = []
	for key_variant in tree_tile_owners.keys():
		var key := str(key_variant)
		if int(tree_tile_owners.get(key, -1)) != tree_id:
			continue
		var parts := key.split(",")
		if parts.size() != 2:
			continue
		var pos := Vector2i(int(parts[0]), int(parts[1]))
		var tile := _get_tile(pos.x, pos.y)
		if tile == Tile.WOOD:
			owned_wood.append(pos)
		elif tile == Tile.LEAVES:
			owned_leaves.append(pos)
	for pos in owned_wood:
		_set_tile(pos.x, pos.y, Tile.AIR)
	for pos in owned_leaves:
		_set_tile(pos.x, pos.y, Tile.AIR)
	_finish_tree_felling(base_pos, owned_wood.size(), owned_leaves.size())


func _fell_legacy_tree(base_pos: Vector2i) -> void:
	const TREE_RADIUS_X := 10
	const TREE_HEIGHT := 18
	var nearby_bases := _nearby_tree_bases(base_pos, TREE_RADIUS_X + 4, 10)
	var wood_queue: Array[Vector2i] = [base_pos]
	var wood_visited := {}
	var owned_wood: Array[Vector2i] = []
	while not wood_queue.is_empty():
		var current: Vector2i = wood_queue.pop_front()
		var key := "%d,%d" % [current.x, current.y]
		if wood_visited.has(key):
			continue
		wood_visited[key] = true
		if not _in_bounds(current.x, current.y):
			continue
		if abs(current.x - base_pos.x) > TREE_RADIUS_X or current.y < base_pos.y - TREE_HEIGHT or current.y > base_pos.y + 1:
			continue
		if _get_tile(current.x, current.y) != Tile.WOOD:
			continue
		if current != base_pos and _is_tree_base(current):
			continue
		if not _tree_tile_belongs_to_base(current, base_pos, nearby_bases):
			continue
		owned_wood.append(current)
		_set_tile(current.x, current.y, Tile.AIR)
		for offset in [
			Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
			Vector2i(1, -1), Vector2i(-1, -1), Vector2i(1, 1), Vector2i(-1, 1)
		]:
			wood_queue.append(current + offset)

	var leaf_queue: Array[Vector2i] = []
	for wood_pos in owned_wood:
		for offset in [
			Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
			Vector2i(1, -1), Vector2i(-1, -1), Vector2i(1, 1), Vector2i(-1, 1)
		]:
			leaf_queue.append(wood_pos + offset)
	var leaf_visited := {}
	var owned_leaves: Array[Vector2i] = []
	while not leaf_queue.is_empty():
		var current: Vector2i = leaf_queue.pop_front()
		var key := "%d,%d" % [current.x, current.y]
		if leaf_visited.has(key):
			continue
		leaf_visited[key] = true
		if not _in_bounds(current.x, current.y):
			continue
		if abs(current.x - base_pos.x) > TREE_RADIUS_X or current.y < base_pos.y - TREE_HEIGHT or current.y > base_pos.y + 1:
			continue
		if _get_tile(current.x, current.y) != Tile.LEAVES:
			continue
		if not _tree_tile_belongs_to_base(current, base_pos, nearby_bases):
			continue
		owned_leaves.append(current)
		_set_tile(current.x, current.y, Tile.AIR)
		for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			leaf_queue.append(current + offset)
	_finish_tree_felling(base_pos, owned_wood.size(), owned_leaves.size())


func _nearby_tree_bases(base_pos: Vector2i, radius_x: int, radius_y: int) -> Array[Vector2i]:
	var bases: Array[Vector2i] = [base_pos]
	for y in range(maxi(0, base_pos.y - radius_y), mini(WORLD_HEIGHT, base_pos.y + radius_y + 1)):
		for x in range(maxi(0, base_pos.x - radius_x), mini(WORLD_WIDTH, base_pos.x + radius_x + 1)):
			var candidate := Vector2i(x, y)
			if candidate != base_pos and _is_tree_base(candidate):
				bases.append(candidate)
	return bases


func _tree_tile_belongs_to_base(tile_pos: Vector2i, base_pos: Vector2i, nearby_bases: Array[Vector2i]) -> bool:
	var own_distance := absf(float(tile_pos.x - base_pos.x)) * 2.0 + absf(float(tile_pos.y - base_pos.y)) * 0.25
	for other_base in nearby_bases:
		if other_base == base_pos:
			continue
		var other_distance := absf(float(tile_pos.x - other_base.x)) * 2.0 + absf(float(tile_pos.y - other_base.y)) * 0.25
		if other_distance <= own_distance:
			return false
	return true


func _finish_tree_felling(base_pos: Vector2i, removed_wood: int, removed_leaves: int) -> void:
	if removed_wood <= 0:
		return
	var drop_pos := Vector2(base_pos) * TILE_SIZE + Vector2(TILE_SIZE * 0.5, -TILE_SIZE * 0.5)
	_spawn_loot(drop_pos, "wood", removed_wood)
	var sapling_chance := clampf(0.16 + float(removed_leaves) * 0.008, 0.16, 0.48)
	var sapling_drop := 1 if rng.randf() < sapling_chance else 0
	if sapling_drop > 0:
		_spawn_loot(drop_pos + Vector2(10, -6), "sapling", sapling_drop)
	last_message = "Tree felled: wood x%d%s." % [removed_wood, ", sapling x1" if sapling_drop > 0 else ""]

func _place_target_tile() -> void:
	var tile_pos := _mouse_tile()
	if not _can_interact(tile_pos):
		return
	var memory_node_index := _memory_node_index_at_tile(tile_pos)
	if memory_node_index >= 0:
		_activate_memory_node(memory_node_index)
		return
	if _archive_console_at_tile(tile_pos):
		_activate_archive_console()
		return
	if _get_tile(tile_pos.x, tile_pos.y) == Tile.STONE_ALTAR:
		_activate_stone_altar(tile_pos)
		return
	if _get_tile(tile_pos.x, tile_pos.y) == Tile.CHEST:
		_open_chest(tile_pos)
		return
	if _get_tile(tile_pos.x, tile_pos.y) != Tile.AIR:
		return
	var item_id := _selected_item()
	if not item_to_tile.has(item_id):
		return
	if int(inventory.get(item_id, 0)) <= 0:
		return
	var tile := int(item_to_tile[item_id])
	if tile == Tile.SAPLING:
		var ground := _get_tile(tile_pos.x, tile_pos.y + 1)
		if ground != Tile.GRASS and ground != Tile.DIRT and ground != Tile.MOSS and ground != Tile.MUD:
			last_message = "Saplings need grass, dirt, moss, or mud below."
			return
	elif tile == Tile.CHEST:
		if not _is_solid(tile_pos.x, tile_pos.y + 1):
			last_message = "Chests need solid ground below."
			return
	elif tile == Tile.TORCH:
		var has_support := (
			_is_solid(tile_pos.x, tile_pos.y + 1)
			or _is_solid(tile_pos.x - 1, tile_pos.y)
			or _is_solid(tile_pos.x + 1, tile_pos.y)
		)
		if not has_support:
			last_message = "Torches need a floor or wall."
			return
	var tile_rect := Rect2(Vector2(tile_pos) * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE))
	var player_rect := Rect2(player_position - PLAYER_SIZE * 0.5, PLAYER_SIZE)
	if tile_rect.intersects(player_rect):
		return
	inventory[item_id] = int(inventory[item_id]) - 1
	selected_block = tile
	_set_tile(tile_pos.x, tile_pos.y, tile)
	if tile == Tile.CHEST:
		chest_loot[_tile_key(tile_pos)] = {}


func _settle_unsupported_chest(chest_pos: Vector2i) -> void:
	if not _in_bounds(chest_pos.x, chest_pos.y) or _get_tile(chest_pos.x, chest_pos.y) != Tile.CHEST:
		return
	if _is_solid(chest_pos.x, chest_pos.y + 1):
		return
	var landing_pos := Vector2i(-1, -1)
	for y in range(chest_pos.y + 1, WORLD_HEIGHT - 1):
		if _get_tile(chest_pos.x, y) == Tile.AIR and _is_solid(chest_pos.x, y + 1):
			landing_pos = Vector2i(chest_pos.x, y)
			break
	if landing_pos.x < 0:
		return

	var old_key := _tile_key(chest_pos)
	var loot: Dictionary = chest_loot.get(old_key, {})
	chest_loot.erase(old_key)
	_set_tile(chest_pos.x, chest_pos.y, Tile.AIR)
	_set_tile(landing_pos.x, landing_pos.y, Tile.CHEST)
	chest_loot[_tile_key(landing_pos)] = loot
	if active_chest_pos == chest_pos:
		active_chest_pos = landing_pos
		active_chest_key = _tile_key(landing_pos)


func _open_chest(tile_pos: Vector2i) -> void:
	var key := _tile_key(tile_pos)
	if not chest_loot.has(key):
		chest_loot[key] = {}
	active_chest_key = key
	active_chest_pos = tile_pos
	inventory_open = true
	last_message = "Opened Ancient Chest."
	_play_sound("pickup")


func _activate_stone_altar(tile_pos: Vector2i) -> void:
	if stone_beast_defeated:
		last_message = "The stone altar is silent."
		return
	if stone_beast_spawned:
		last_message = "The Stone Beast is already awake."
		return
	_spawn_stone_beast()
	_set_tile(tile_pos.x, tile_pos.y, Tile.RUIN)


func _spawn_stone_beast() -> void:
	var pos := _find_spawn_position_near_player(10, 16)
	pos.y += 80.0
	_spawn_enemy("stone_beast", pos)
	stone_beast_spawned = true
	_play_sound("boss")
	last_message = "Stone Beast has broken loose."


func _close_chest() -> void:
	active_chest_key = ""
	active_chest_pos = Vector2i(-999, -999)


func _active_chest_items() -> Array[String]:
	var keys: Array[String] = []
	if active_chest_key == "" or not chest_loot.has(active_chest_key):
		return keys
	var loot: Dictionary = chest_loot[active_chest_key]
	for item_id in loot.keys():
		if int(loot[item_id]) > 0:
			keys.append(str(item_id))
	keys.sort()
	return keys


func _update_selection() -> void:
	for i in range(HOTBAR_SIZE):
		if Input.is_action_just_pressed("hotbar_%d" % (i + 1)):
			selected_slot = i
			var item_id := _selected_item()
			if tools.has(item_id):
				current_tool = item_id
			elif item_to_tile.has(item_id):
				selected_block = int(item_to_tile[item_id])


func _on_hotbar_slot_pressed(index: int) -> void:
	if held_item_id != "":
		return
	selected_slot = clampi(index, 0, hotbar.size() - 1)
	_update_selection_from_hotbar()


func _on_hotbar_slot_gui_input(event: InputEvent, index: int) -> void:
	if not inventory_open or held_item_id == "":
		return
	if event is InputEventMouseButton and not event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT or mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_drop_held_item_on_hotbar(index)
			get_viewport().set_input_as_handled()


func _on_inventory_slot_pressed(index: int) -> void:
	if held_item_id != "":
		return
	var items := _inventory_item_ids()
	if index < 0 or index >= items.size():
		return
	var item_id := str(items[index])
	if int(inventory.get(item_id, 0)) <= 0:
		return
	selected_inventory_item_id = item_id
	# Clicking a wearable piece puts it straight on. Armour has no hotbar slot
	# of its own, so this replaces the old EQUIP button.
	if gear_stats.has(item_id):
		var slot := str((gear_stats[item_id] as Dictionary).get("slot", ""))
		if slot in ["armor", "chest", "helmet", "legs", "boots", "accessory"]:
			_equip_item_id(item_id)
			return
	last_message = "Selected %s." % _item_display_name(item_id)


func _on_inventory_slot_gui_input(event: InputEvent, index: int) -> void:
	if not inventory_open:
		return
	if event is InputEventMouseButton and held_item_id == "":
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT and mouse_event.button_index != MOUSE_BUTTON_RIGHT:
			return
		if not mouse_event.pressed:
			return
		var items := _inventory_item_ids()
		if index < 0 or index >= items.size():
			return
		var item_id := str(items[index])
		var amount := int(inventory.get(item_id, 0))
		if amount <= 0:
			return
		if mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			pending_inventory_right_drop_id = item_id
			pending_inventory_right_drop_consumed = false
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and pending_inventory_right_drop_id == item_id:
			_drop_inventory_item_to_world(item_id, amount)
			pending_inventory_right_drop_consumed = true
		else:
			_take_inventory_stack(item_id, amount)
		get_viewport().set_input_as_handled()


func _on_chest_slot_gui_input(event: InputEvent, index: int) -> void:
	if active_chest_key == "":
		return
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and held_item_id == "":
			if mouse_event.button_index != MOUSE_BUTTON_LEFT and mouse_event.button_index != MOUSE_BUTTON_RIGHT:
				return
			var items := _active_chest_items()
			if index < 0 or index >= items.size():
				return
			var item_id := str(items[index])
			var loot: Dictionary = chest_loot[active_chest_key]
			var amount := int(loot.get(item_id, 0))
			if amount <= 0:
				return
			if mouse_event.button_index == MOUSE_BUTTON_LEFT:
				_transfer_chest_stack_to_inventory(item_id)
			else:
				_take_chest_stack(item_id, maxi(1, int(ceil(float(amount) * 0.5))))
			# Consume only after the transfer, so the click cannot reach world mining.
			get_viewport().set_input_as_handled()
		elif not mouse_event.pressed and held_item_id != "" and (mouse_event.button_index == MOUSE_BUTTON_LEFT or mouse_event.button_index == MOUSE_BUTTON_RIGHT):
			_drop_held_item_on_chest()
			get_viewport().set_input_as_handled()


func _make_equipment_row(parent: VBoxContainer, caption: String, slot: String) -> Button:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	var button := _make_slot_button()
	button.custom_minimum_size = Vector2(46, 46)
	button.tooltip_text = caption.capitalize()
	button.gui_input.connect(_on_equipment_slot_gui_input.bind(slot))
	row.add_child(button)
	var label := Label.new()
	label.text = caption
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color("ded8c8"))
	row.add_child(label)
	return button


func _on_equipment_slot_gui_input(event: InputEvent, slot: String) -> void:
	if not inventory_open or held_item_id == "":
		return
	if event is InputEventMouseButton and not event.pressed:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT or mouse_event.button_index == MOUSE_BUTTON_RIGHT:
			_drop_held_item_on_equipment(slot)
			get_viewport().set_input_as_handled()


func _take_inventory_stack(item_id: String, amount: int) -> void:
	var available := int(inventory.get(item_id, 0))
	var taken := clampi(amount, 1, available)
	inventory[item_id] = available - taken
	if int(inventory.get(item_id, 0)) <= 0:
		inventory.erase(item_id)
	held_item_id = item_id
	held_item_amount = taken
	selected_inventory_item_id = item_id
	last_message = "Dragging %s x%d." % [_item_display_name(item_id), taken]


func _take_chest_stack(item_id: String, amount: int) -> void:
	if active_chest_key == "" or not chest_loot.has(active_chest_key):
		return
	var loot: Dictionary = chest_loot[active_chest_key]
	var available := int(loot.get(item_id, 0))
	var taken := clampi(amount, 1, available)
	loot[item_id] = available - taken
	if int(loot.get(item_id, 0)) <= 0:
		loot.erase(item_id)
	chest_loot[active_chest_key] = loot
	held_item_id = item_id
	held_item_amount = taken
	last_message = "Dragging %s x%d from chest." % [_item_display_name(item_id), taken]


func _transfer_chest_stack_to_inventory(item_id: String) -> void:
	if active_chest_key == "" or not chest_loot.has(active_chest_key):
		return
	var loot: Dictionary = chest_loot[active_chest_key]
	var amount := int(loot.get(item_id, 0))
	if amount <= 0:
		return
	_add_item(item_id, amount)
	loot.erase(item_id)
	chest_loot[active_chest_key] = loot
	selected_inventory_item_id = item_id
	_add_loot_notification(item_id, amount)
	_play_sound("pickup")
	last_message = "Took %s x%d from chest." % [_item_display_name(item_id), amount]


func _drop_inventory_item_to_world(item_id: String, amount: int) -> void:
	var available := int(inventory.get(item_id, 0))
	if available <= 0:
		return
	var dropped := clampi(amount, 1, available)
	inventory[item_id] = available - dropped
	if int(inventory.get(item_id, 0)) <= 0:
		inventory.erase(item_id)
		if selected_inventory_item_id == item_id:
			selected_inventory_item_id = ""
	var drop_pos := player_position + Vector2(float(facing) * 18.0, -6.0)
	var drop_vel := Vector2(float(facing) * 42.0, -28.0)
	_spawn_loot_with_velocity(drop_pos, item_id, dropped, drop_vel, 0.85)
	_clear_equipped_if_missing(item_id)
	last_message = "Dropped %s x%d." % [_item_display_name(item_id), dropped]


func _release_held_item(screen_pos: Vector2) -> void:
	if held_item_id == "":
		return
	for i in range(hotbar_buttons.size()):
		if hotbar_buttons[i].get_global_rect().has_point(screen_pos):
			_drop_held_item_on_hotbar(i)
			return
	if weapon_slot_button.get_global_rect().has_point(screen_pos):
		_drop_held_item_on_equipment("weapon")
		return
	if helmet_slot_button.get_global_rect().has_point(screen_pos):
		_drop_held_item_on_equipment("helmet")
		return
	if legs_slot_button.get_global_rect().has_point(screen_pos):
		_drop_held_item_on_equipment("legs")
		return
	if boots_slot_button.get_global_rect().has_point(screen_pos):
		_drop_held_item_on_equipment("boots")
		return
	if armor_slot_button.get_global_rect().has_point(screen_pos):
		_drop_held_item_on_equipment("chest")
		return
	if accessory_slot_button.get_global_rect().has_point(screen_pos):
		_drop_held_item_on_equipment("accessory")
		return
	if chest_panel.visible and chest_panel.get_global_rect().has_point(screen_pos):
		_drop_held_item_on_chest()
		return
	if inventory_panel.get_global_rect().has_point(screen_pos) or crafting_panel.get_global_rect().has_point(screen_pos):
		_return_held_item_to_inventory()
		return
	_throw_held_item_into_world()


func _drop_held_item_on_hotbar(index: int) -> void:
	if held_item_id == "":
		return
	selected_slot = clampi(index, 0, hotbar.size() - 1)
	hotbar[selected_slot] = held_item_id
	_return_held_item_to_inventory()
	_update_selection_from_hotbar()
	last_message = "Assigned %s to hotbar slot %d." % [_item_display_name(str(hotbar[selected_slot])), selected_slot + 1]


func _drop_held_item_on_equipment(slot: String) -> void:
	if held_item_id == "":
		return
	var held_slot := str((gear_stats.get(held_item_id, {}) as Dictionary).get("slot", ""))
	# Older gear was tagged "armor"; that is the chest slot now. Normalise both
	# sides so a legacy chestplate still drops onto the chest slot.
	if held_slot == "armor":
		held_slot = "chest"
	var target_slot := "chest" if slot == "armor" else slot
	if gear_stats.has(held_item_id) and held_slot == target_slot:
		_equip_item_id(held_item_id)
		_return_held_item_to_inventory()
	else:
		_return_held_item_to_inventory()
		last_message = "That item does not fit this slot."


func _return_held_item_to_inventory() -> void:
	if held_item_id == "":
		return
	_add_item(held_item_id, held_item_amount)
	selected_inventory_item_id = held_item_id
	held_item_id = ""
	held_item_amount = 0


func _drop_held_item_on_chest() -> void:
	if held_item_id == "":
		return
	if active_chest_key == "":
		_return_held_item_to_inventory()
		return
	var loot: Dictionary = chest_loot.get(active_chest_key, {})
	loot[held_item_id] = int(loot.get(held_item_id, 0)) + held_item_amount
	chest_loot[active_chest_key] = loot
	last_message = "Stored %s x%d." % [_item_display_name(held_item_id), held_item_amount]
	held_item_id = ""
	held_item_amount = 0


func _throw_held_item_into_world() -> void:
	if held_item_id == "":
		return
	var drop_pos := player_position + Vector2(float(facing) * 18.0, -6.0)
	var drop_vel := Vector2(float(facing) * 55.0, -45.0)
	_spawn_loot_with_velocity(drop_pos, held_item_id, held_item_amount, drop_vel, 0.75)
	last_message = "Dropped %s x%d." % [_item_display_name(held_item_id), held_item_amount]
	_clear_equipped_if_missing(held_item_id)
	held_item_id = ""
	held_item_amount = 0


func _clear_equipped_if_missing(item_id: String) -> void:
	if int(inventory.get(item_id, 0)) > 0:
		return
	if equipped_weapon == item_id:
		equipped_weapon = ""
	if equipped_armor == item_id:
		equipped_armor = ""
	if equipped_helmet == item_id:
		equipped_helmet = ""
	if equipped_legs == item_id:
		equipped_legs = ""
	if equipped_boots == item_id:
		equipped_boots = ""
	if equipped_accessory == item_id:
		equipped_accessory = ""


func _assign_selected_inventory_to_hotbar() -> void:
	var item_id := selected_inventory_item_id
	if item_id == "" or int(inventory.get(item_id, 0)) <= 0:
		last_message = "Select an inventory item first."
		return
	hotbar[selected_slot] = item_id
	_update_selection_from_hotbar()
	last_message = "Assigned %s to hotbar slot %d." % [_item_display_name(item_id), selected_slot + 1]


func _equip_selected_inventory_item() -> void:
	if selected_inventory_item_id == "":
		last_message = "Select an inventory item first."
		return
	_equip_item_id(selected_inventory_item_id)


func _drop_selected_inventory_item() -> void:
	var item_id := selected_inventory_item_id
	if item_id == "" or int(inventory.get(item_id, 0)) <= 0:
		last_message = "Select an inventory item first."
		return
	inventory[item_id] = int(inventory.get(item_id, 0)) - 1
	if int(inventory.get(item_id, 0)) <= 0:
		inventory.erase(item_id)
		selected_inventory_item_id = ""
	var drop_pos := player_position + Vector2(float(facing) * 18.0, -6.0)
	var drop_vel := Vector2(float(facing) * 55.0, -45.0)
	_spawn_loot_with_velocity(drop_pos, item_id, 1, drop_vel, 0.75)
	last_message = "Dropped %s." % _item_display_name(item_id)


func _sanitize_hotbar() -> void:
	# A hotbar slot is only a reference to an item that actually exists.
	# Clear stale references immediately after crafting, placing, or dropping.
	for i in range(hotbar.size()):
		var item_id := str(hotbar[i])
		if item_id == "" or int(inventory.get(item_id, 0)) <= 0:
			hotbar[i] = ""
	if selected_slot >= 0 and selected_slot < hotbar.size() and str(hotbar[selected_slot]) == "":
		_update_selection_from_hotbar()


func _inventory_item_ids() -> Array[String]:
	var keys: Array[String] = []
	for item_id in inventory.keys():
		if int(inventory[item_id]) <= 0:
			continue
		if int(inventory[item_id]) > 0:
			keys.append(str(item_id))
	keys.sort()
	return keys


func _selected_item() -> String:
	if selected_slot < 0 or selected_slot >= hotbar.size():
		return ""
	return str(hotbar[selected_slot])


func _add_item(item_id: String, amount: int) -> void:
	inventory[item_id] = int(inventory.get(item_id, 0)) + amount
	_record_material_found(item_id, amount)


func _add_rare_drop(tile: int, pos: Vector2) -> void:
	if tile == Tile.ROOT and rng.randf() < 0.12:
		_spawn_loot(pos + Vector2(4, -6), "root_core", 1)
		last_message = "Found rare material: Root Core."
	elif tile == Tile.RUIN and rng.randf() < 0.14:
		_spawn_loot(pos + Vector2(4, -6), "spark_shard", 1)
		last_message = "Found rare material: Spark Shard."
	elif tile == Tile.ASH and rng.randf() < 0.16:
		_spawn_loot(pos + Vector2(4, -6), "memory_shard", 1)
		last_message = "Found rare material: Memory Shard."
	elif tile == Tile.MOSS and rng.randf() < 0.10:
		_spawn_loot(pos + Vector2(4, -6), "wild_badge", 1)
		_play_sound("forest_event")
		last_message = "Mini-event: a forest cache opened."
	elif tile == Tile.GLOW_MUSHROOM and rng.randf() < 0.20:
		_spawn_loot(pos + Vector2(4, -6), "glowcap", 1)
		_play_sound("mushroom_event")
		last_message = "Found rare material: Glowcap."
	elif tile == Tile.ASH_BRICK and rng.randf() < 0.12:
		_spawn_loot(pos + Vector2(4, -6), "ash_relic", 1)
		_play_sound("ash_event")
		last_message = "Mini-event: ash bells answer under the city."
	elif tile == Tile.SUNKEN_STONE and rng.randf() < 0.12:
		_spawn_loot(pos + Vector2(4, -6), "drowned_pearl", 1)
		_play_sound("water_event")
		last_message = "Found rare material: Drowned Pearl."
	elif tile == Tile.LAVA_ROOT and rng.randf() < 0.14:
		_spawn_loot(pos + Vector2(4, -6), "night_ember", 1)
		_play_sound("lava_event")
		last_message = "Mini-event: lava roots pulse with heat."
	elif tile == Tile.ABYSS_CRYSTAL and rng.randf() < 0.18:
		_spawn_loot(pos + Vector2(4, -6), "abyss_lens", 1)
		_play_sound("glass_event")
		last_message = "Mini-event: the glass abyss sings."


func _select_recipe(direction: int) -> void:
	var known_indices := _known_recipe_indices()
	if known_indices.is_empty():
		return
	var current_position := known_indices.find(selected_recipe_index)
	if current_position < 0:
		selected_recipe_index = known_indices[0]
		return
	selected_recipe_index = known_indices[wrapi(current_position + direction, 0, known_indices.size())]


func _on_recipe_button_pressed(index: int) -> void:
	if index < 0 or index >= recipes.size() or not _recipe_is_known(recipes[index]):
		return
	selected_recipe_index = index
	_update_hud()


func _craft_selected_recipe() -> void:
	var recipe := _selected_recipe()
	if recipe.is_empty():
		last_message = "No known recipe selected."
		return
	var station := str(recipe.get("station", "hand"))
	if not _has_station_nearby(station):
		last_message = "Need nearby station: %s." % _station_display_name(station)
		return
	var cost: Dictionary = recipe.get("cost", {})
	for item_id in cost.keys():
		if int(inventory.get(str(item_id), 0)) < int(cost[item_id]):
			last_message = "Missing materials for %s." % _item_display_name(str(recipe.get("result", "")))
			return
	for item_id in cost.keys():
		inventory[str(item_id)] = int(inventory.get(str(item_id), 0)) - int(cost[item_id])
	var result := str(recipe.get("result", ""))
	var amount := int(recipe.get("amount", 1))
	_add_item(result, amount)
	_record_recipe_known(str(recipe.get("id", result)))
	if result == "acid_flasks":
		_record_alchemy_result(result, cost)
	selected_inventory_item_id = result
	hotbar[selected_slot] = result
	_update_selection_from_hotbar()
	last_message = "Crafted %s x%d." % [_item_display_name(result), amount]


func _equip_selected_item() -> void:
	var item_id := _selected_item()
	_equip_item_id(item_id)


func _equip_item_id(item_id: String) -> void:
	if tools.has(item_id):
		current_tool = item_id
		last_message = "Equipped tool: %s." % _item_display_name(item_id)
		return
	if not gear_stats.has(item_id):
		last_message = "%s cannot be equipped." % _item_display_name(item_id)
		return
	var gear: Dictionary = gear_stats[item_id]
	var slot := str(gear.get("slot", "weapon"))
	if slot == "weapon":
		equipped_weapon = item_id
	elif slot == "armor" or slot == "chest":
		equipped_armor = item_id
	elif slot == "helmet":
		equipped_helmet = item_id
	elif slot == "legs":
		equipped_legs = item_id
	elif slot == "boots":
		equipped_boots = item_id
	elif slot == "accessory":
		equipped_accessory = item_id
	active_class = str(gear.get("class", "Any"))
	if active_class == "Any" and equipped_weapon != "":
		active_class = str((gear_stats.get(equipped_weapon, {}) as Dictionary).get("class", "Warrior"))
	last_message = "Equipped %s." % _item_display_name(item_id)


func _has_station_nearby(station: String) -> bool:
	if station == "hand":
		return true
	var wanted_tile := Tile.WORKBENCH
	if station == "furnace":
		wanted_tile = Tile.FURNACE
	elif station == "anvil":
		wanted_tile = Tile.ANVIL
	var player_tile := Vector2i(floori(player_position.x / TILE_SIZE), floori(player_position.y / TILE_SIZE))
	for y in range(player_tile.y - 5, player_tile.y + 6):
		for x in range(player_tile.x - 5, player_tile.x + 6):
			if _in_bounds(x, y) and _get_tile(x, y) == wanted_tile:
				return true
	return false


func _selected_recipe() -> Dictionary:
	if recipes.is_empty():
		return {}
	_ensure_selected_recipe_known()
	if selected_recipe_index < 0 or selected_recipe_index >= recipes.size():
		return {}
	return recipes[selected_recipe_index]


func _recipe_is_known(recipe: Dictionary) -> bool:
	var recipe_id := str(recipe.get("id", recipe.get("result", "")))
	return bool(known_recipes.get(recipe_id, false))


func _known_recipe_indices() -> Array[int]:
	var indices: Array[int] = []
	for i in range(recipes.size()):
		if _recipe_is_known(recipes[i]):
			indices.append(i)
	return indices


func _ensure_selected_recipe_known() -> void:
	if selected_recipe_index >= 0 and selected_recipe_index < recipes.size() and _recipe_is_known(recipes[selected_recipe_index]):
		return
	var known_indices := _known_recipe_indices()
	selected_recipe_index = known_indices[0] if not known_indices.is_empty() else -1


func _recipe_id_exists(recipe_id: String) -> bool:
	for recipe in recipes:
		if str(recipe.get("id", recipe.get("result", ""))) == recipe_id:
			return true
	return false


func _learn_all_recipes() -> int:
	var learned_count := 0
	for recipe in recipes:
		var recipe_id := str(recipe.get("id", recipe.get("result", "")))
		if not bool(known_recipes.get(recipe_id, false)):
			known_recipes[recipe_id] = true
			learned_count += 1
	if learned_count > 0:
		journal_unread_count += learned_count
	_ensure_selected_recipe_known()
	if journal_open:
		_refresh_journal()
	_update_hud()
	return learned_count


func _recipe_cost_text(recipe: Dictionary) -> String:
	var cost: Dictionary = recipe.get("cost", {})
	var parts: Array[String] = []
	for item_id in cost.keys():
		parts.append("%s x%d" % [_item_display_name(str(item_id)), int(cost[item_id])])
	return ", ".join(parts)


func _station_display_name(station: String) -> String:
	if station == "hand":
		return "Hands"
	return _item_display_name(station)


func _item_display_name(item_id: String) -> String:
	return str(item_names.get(item_id, item_id))


func _tool_power() -> int:
	var tool: Dictionary = tools.get(current_tool, tools["wooden_pickaxe"])
	return int(tool.get("power", 1))


func _tool_speed() -> float:
	var tool: Dictionary = tools.get(current_tool, tools["wooden_pickaxe"])
	return float(tool.get("speed", 1.0)) * _temperature_action_multiplier()


func _total_damage() -> int:
	var total := 1
	for item_id in [equipped_weapon, equipped_accessory]:
		if gear_stats.has(item_id):
			total += int((gear_stats[item_id] as Dictionary).get("damage", 0))
	return total


func _equipped_gear_ids() -> Array:
	# Every worn piece, in one place, so defense and weather protection cannot
	# drift apart from each other as slots are added.
	return [equipped_helmet, equipped_armor, equipped_legs, equipped_boots,
			equipped_accessory]


func _total_defense() -> int:
	var total := 0
	for item_id in _equipped_gear_ids():
		if gear_stats.has(item_id):
			total += int((gear_stats[item_id] as Dictionary).get("defense", 0))
	return total


func _can_interact(tile_pos: Vector2i) -> bool:
	if not _in_bounds(tile_pos.x, tile_pos.y):
		return false
	var player_tile := player_position / TILE_SIZE
	return player_tile.distance_to(Vector2(tile_pos)) <= INTERACT_RANGE_TILES


func _mouse_tile() -> Vector2i:
	if _mobile_controls_enabled() and mobile_target_valid:
		return mobile_target_tile
	return Vector2i(floori(get_global_mouse_position().x / TILE_SIZE), floori(get_global_mouse_position().y / TILE_SIZE))


func _update_camera() -> void:
	if camera == null:
		return
	camera.position = player_position


func _adjust_camera_zoom(delta_zoom: float) -> void:
	if camera == null:
		return
	var next_zoom := clampf(camera.zoom.x + delta_zoom, MIN_CAMERA_ZOOM, MAX_CAMERA_ZOOM)
	camera.zoom = Vector2(next_zoom, next_zoom)


func _save_game() -> void:
	var data := {
		"seed": seed,
		"world": world,
		"surface_heights": surface_heights,
		"surface_biomes": surface_biomes,
		# Partial liquid fill levels; without them a reloaded pool would snap
		# every half-filled tile back to a full block.
		"liquid_levels": liquid_sim.serialize_levels() if liquid_sim != null else {},
		"chest_loot": chest_loot,
		"memory_nodes": _serialize_memory_nodes(),
		"archive_site": _serialize_archive_site(),
		"tree_tile_owners": tree_tile_owners,
		"next_tree_id": next_tree_id,
		"known_recipes": known_recipes,
		"bestiary_knowledge": bestiary_knowledge,
		"material_knowledge": material_knowledge,
		"alchemy_knowledge": alchemy_knowledge,
		"explored_tiles": Marshalls.raw_to_base64(explored_tiles),
		"player_position": [player_position.x, player_position.y],
		"health": health,
		"oxygen": oxygen,
		"body_temperature": body_temperature,
		"inventory": inventory,
		"hotbar": hotbar,
		"selected_slot": selected_slot,
		"current_tool": current_tool,
		"selected_recipe_index": selected_recipe_index,
		"equipped_weapon": equipped_weapon,
		"equipped_armor": equipped_armor,
		"equipped_helmet": equipped_helmet,
		"equipped_legs": equipped_legs,
		"equipped_boots": equipped_boots,
		"equipped_accessory": equipped_accessory,
		"active_class": active_class,
		"world_time": world_time,
		"weather": weather,
		"weather_timer": weather_timer,
		"defeated_enemies": defeated_enemies,
		"boss_spawned": boss_spawned,
		"boss_defeated": boss_defeated,
		"stone_broken_count": stone_broken_count,
		"stone_beast_spawned": stone_beast_spawned,
		"stone_beast_defeated": stone_beast_defeated,
		"archive_warden_spawned": archive_warden_spawned,
		"archive_warden_defeated": archive_warden_defeated,
		"mushroom_path_opened": mushroom_path_opened,
		"leviathan_story_unlocked": leviathan_story_unlocked
	}
	SaveManager.write_json(SAVE_PATH, data)


func _load_game() -> void:
	var data := SaveManager.read_json(SAVE_PATH)
	if data.is_empty():
		return
	seed = int(data.get("seed", seed))
	world = data.get("world", world)
	world_map_dirty = true
	if world.size() != WORLD_HEIGHT or world.is_empty() or (world[0] as Array).size() != WORLD_WIDTH:
		_generate_world()
		last_message = "Old save used a different world size. A new liquid world was generated."
		return
	chest_loot = data.get("chest_loot", {})
	_restore_memory_nodes(data.get("memory_nodes", []))
	_restore_archive_site(data.get("archive_site", {}))
	tree_tile_owners = data.get("tree_tile_owners", {})
	next_tree_id = maxi(1, int(data.get("next_tree_id", 1)))
	_reset_knowledge()
	known_recipes.merge(data.get("known_recipes", {}), true)
	bestiary_knowledge = data.get("bestiary_knowledge", {})
	material_knowledge = data.get("material_knowledge", {})
	alchemy_knowledge = data.get("alchemy_knowledge", {})
	var loaded_heights: Array = data.get("surface_heights", surface_heights)
	surface_heights.clear()
	for h in loaded_heights:
		surface_heights.append(int(h))
	var loaded_surface_biomes: Array = data.get("surface_biomes", [])
	surface_biomes.clear()
	for biome_variant in loaded_surface_biomes:
		surface_biomes.append(str(biome_variant))
	if surface_biomes.size() != WORLD_WIDTH:
		# Saves made before surface biomes existed get a deterministic map from
		# their existing seed without changing the generated terrain.
		_build_surface_biome_map()
	else:
		# The seam metadata is derived data, so it is rebuilt from the loaded
		# biome map instead of being stored in the save file.
		_rebuild_border_metadata()
		_setup_transition_noise()
	var loaded_position: Array = data.get("player_position", [player_position.x, player_position.y])
	if loaded_position.size() >= 2:
		player_position = Vector2(float(loaded_position[0]), float(loaded_position[1]))
	var saved_exploration := str(data.get("explored_tiles", ""))
	var loaded_exploration := Marshalls.base64_to_raw(saved_exploration) if not saved_exploration.is_empty() else PackedByteArray()
	if loaded_exploration.size() == WORLD_WIDTH * WORLD_HEIGHT:
		explored_tiles = loaded_exploration
		last_explored_tile = Vector2i(-999, -999)
	else:
		_reset_exploration()
	_reveal_player_surroundings()
	player_velocity = Vector2.ZERO
	player_statuses.clear()
	health = clampi(int(data.get("health", MAX_HEALTH)), 1, MAX_HEALTH)
	oxygen = clampf(float(data.get("oxygen", MAX_OXYGEN)), 0.0, MAX_OXYGEN)
	body_temperature = clampf(float(data.get("body_temperature", NORMAL_BODY_TEMPERATURE)), MIN_BODY_TEMPERATURE, MAX_BODY_TEMPERATURE)
	ambient_temperature = 20.0
	temperature_sample_timer = 0.0
	temperature_damage_tick = 0.0
	temperature_visual_state = ""
	drowning_tick = 0.0
	lava_tick = 0.0
	inventory = data.get("inventory", inventory)
	hotbar = data.get("hotbar", hotbar)
	selected_slot = clampi(int(data.get("selected_slot", 0)), 0, hotbar.size() - 1)
	current_tool = str(data.get("current_tool", "wooden_pickaxe"))
	selected_recipe_index = clampi(int(data.get("selected_recipe_index", 0)), 0, recipes.size() - 1)
	equipped_weapon = str(data.get("equipped_weapon", ""))
	equipped_armor = str(data.get("equipped_armor", ""))
	# Saves made before armour was split simply have no other pieces worn.
	equipped_helmet = str(data.get("equipped_helmet", ""))
	equipped_legs = str(data.get("equipped_legs", ""))
	equipped_boots = str(data.get("equipped_boots", ""))
	equipped_accessory = str(data.get("equipped_accessory", ""))
	selected_inventory_item_id = ""
	active_class = str(data.get("active_class", active_class))
	world_time = float(data.get("world_time", world_time))
	weather = str(data.get("weather", WEATHER_CLEAR))
	weather_timer = float(data.get("weather_timer", 60.0))
	weather_target_intensity = 1.0 if weather != WEATHER_CLEAR else 0.0
	weather_intensity = weather_target_intensity
	weather_particles.clear()
	defeated_enemies = int(data.get("defeated_enemies", defeated_enemies))
	boss_spawned = bool(data.get("boss_spawned", boss_spawned))
	boss_defeated = bool(data.get("boss_defeated", boss_defeated))
	stone_broken_count = int(data.get("stone_broken_count", stone_broken_count))
	stone_beast_spawned = bool(data.get("stone_beast_spawned", stone_beast_spawned))
	stone_beast_defeated = bool(data.get("stone_beast_defeated", stone_beast_defeated))
	archive_warden_spawned = bool(data.get("archive_warden_spawned", archive_warden_spawned))
	archive_warden_defeated = bool(data.get("archive_warden_defeated", archive_warden_defeated))
	mushroom_path_opened = bool(data.get("mushroom_path_opened", mushroom_path_opened))
	leviathan_story_unlocked = bool(data.get("leviathan_story_unlocked", false))
	_rebuild_sapling_positions()
	if liquid_sim != null:
		liquid_sim.rebuild(world)
		# Saves made before partial fills existed simply keep full blocks.
		liquid_sim.restore_levels(data.get("liquid_levels", {}))
	cached_biome = _compute_current_biome()
	biome_check_timer = 0.0
	hud_update_timer = 0.0
	enemies.clear()
	dying_enemies.clear()
	projectiles.clear()
	enemy_projectiles.clear()
	enemy_impact_effects.clear()
	perception_noise_events.clear()
	dropped_items.clear()
	damage_numbers.clear()
	hit_particles.clear()
	loot_notifications.clear()
	attack_anim_time = 0.0
	attack_anim_kind = ""
	held_item_id = ""
	held_item_amount = 0
	_update_selection_from_hotbar()
	_update_camera()
	_update_minimap(999.0)
	_update_hud()


func _rebuild_sapling_positions() -> void:
	sapling_positions.clear()
	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			if _get_tile(x, y) == Tile.SAPLING:
				sapling_positions["%d,%d" % [x, y]] = Vector2i(x, y)


func _update_selection_from_hotbar() -> void:
	# Picking a hotbar slot is the only thing needed to wield what is in it:
	# tools become the active tool, weapons are equipped, blocks are selected
	# for placing. There is no separate equip step any more.
	var item_id := _selected_item()
	if tools.has(item_id):
		current_tool = item_id
		return
	if gear_stats.has(item_id):
		var gear: Dictionary = gear_stats[item_id]
		if str(gear.get("slot", "")) == "weapon":
			_equip_hotbar_weapon(item_id)
			return
	if item_to_tile.has(item_id):
		selected_block = int(item_to_tile[item_id])


func _equip_hotbar_weapon(item_id: String) -> void:
	if equipped_weapon == item_id:
		return
	equipped_weapon = item_id
	var gear: Dictionary = gear_stats.get(item_id, {})
	active_class = str(gear.get("class", "Warrior"))
	last_message = "Wielding %s." % _item_display_name(item_id)


func _update_hud() -> void:
	_update_chest_open_state()
	var tile_pos := _mouse_tile()
	var tile := _get_tile(tile_pos.x, tile_pos.y)
	var target_name := str(tile_names.get(tile, "Void"))
	var mine_percent := 0
	if mining_target == tile_pos and tile != Tile.AIR:
		mine_percent = int(clampf(mining_progress / _mining_hardness(tile, tile_pos), 0.0, 1.0) * 100.0)
	var recipe := _selected_recipe()
	var result := str(recipe.get("result", ""))
	var station := str(recipe.get("station", "hand"))

	var biome := _current_biome()
	# Only actual information remains on screen; empty status-effect markers are hidden.
	hud_label.text = "HP  %d / %d" % [health, MAX_HEALTH]
	hud_health_bar.value = health
	hud_armor_value.text = "ARMOR  %d" % _total_defense()
	hud_status_label.text = _format_player_statuses().strip_edges()
	var show_oxygen := oxygen < MAX_OXYGEN - 0.5 or _player_overlaps_tile(Tile.WATER)
	oxygen_panel.visible = show_oxygen
	if show_oxygen:
		oxygen_bar.value = oxygen
		oxygen_value.text = "%d%%" % int(round(oxygen))
	_update_temperature_hud()
	minimap_time_label.text = _time_period_text().to_upper()
	var biome_text := _biome_display_name(biome).to_upper()
	if weather != WEATHER_CLEAR and _weather_strength() > 0.15:
		biome_text += " - %s" % _weather_display_name(weather).to_upper()
	minimap_biome_label.text = biome_text
	var prompt := ""
	if not inventory_open and not full_map_open and not journal_open and _can_interact(tile_pos):
		var memory_node_index := _memory_node_index_at_tile(tile_pos)
		if memory_node_index >= 0:
			var node_kind := str((memory_nodes[memory_node_index] as Dictionary).get("kind", "memory"))
			prompt = "RMB  ACTIVATE %s MEMORY NODE" % node_kind.to_upper()
		elif _archive_console_at_tile(tile_pos):
			prompt = "RMB  ACCESS ARCHIVE CONSOLE"
		elif tile == Tile.CHEST:
			prompt = "RMB  OPEN ANCIENT CHEST"
		elif tile == Tile.STONE_ALTAR:
			prompt = "RMB  AWAKEN ALTAR"
	context_hint_panel.visible = prompt != ""
	context_hint_label.text = prompt
	_update_hotbar_buttons()
	var chest_open := inventory_open and active_chest_key != ""
	inventory_backdrop.visible = inventory_open
	inventory_shell.visible = inventory_open
	equipment_overlay.visible = inventory_open
	inventory_panel.visible = inventory_open
	# The chest deliberately takes the crafting column instead of overlapping it.
	crafting_panel.visible = inventory_open and not chest_open
	chest_panel.visible = chest_open
	_update_mobile_controls_visibility()
	if minimap_panel != null:
		minimap_panel.visible = not chest_panel.visible and not full_map_open and not journal_open
	if journal_access_button != null:
		journal_access_button.visible = not inventory_open and not full_map_open and not journal_open
		journal_access_button.text = "FIELD JOURNAL" if journal_unread_count <= 0 else "FIELD JOURNAL  +%d" % journal_unread_count
	if not inventory_open:
		return

	_update_inventory_buttons()
	_update_chest_buttons()
	_update_equipment_buttons()
	_update_recipe_buttons()
	inventory_title_label.text = "BACKPACK"
	equipment_label.text = "EQUIPPED"
	var equipped_damage := _weapon_preview_damage(equipped_weapon) if equipped_weapon != "" else 1
	equipment_environment_label.text = "TIER %d  |  DAMAGE %d  |  ARMOR %d\nCOLD %d%%  |  HEAT %d%%" % [
		_player_progression_tier(),
		equipped_damage,
		_total_defense(),
		int(round(_temperature_protection("cold_protection") * 100.0)),
		int(round(_temperature_protection("heat_protection") * 100.0))
	]
	selected_item_label.text = _format_selected_inventory_item()
	assign_hotbar_button.disabled = selected_inventory_item_id == "" or held_item_id != ""
	drop_inventory_button.disabled = true
	crafting_label.text = _format_recipe_panel(recipe, result, station)
	stations_label.text = _station_status_text()
	message_label.text = "Message: %s" % last_message
	controls_label.text = "TAB/I close | Click inventory item to select | Use buttons for hotbar/equip | Z/X recipe | C craft | E equip hotbar item | F attack"


func _update_boss_bar() -> void:
	var boss := _boss_enemy()
	if boss.is_empty():
		boss_panel.visible = false
		return
	boss_panel.visible = true
	boss_label.text = str(boss.get("name", "Boss"))
	boss_hp_bar.max_value = float(boss.get("max_hp", 1))
	boss_hp_bar.value = maxf(0.0, float(boss.get("hp", 0)))


func _boss_enemy() -> Dictionary:
	for enemy in enemies:
		var data: Dictionary = enemy
		if str(data.get("type", "")) in ["heartwood_boss", "stone_beast", "archive_warden"]:
			return data
	return {}


func _format_player_statuses() -> String:
	if player_statuses.is_empty():
		return ""
	var parts: Array[String] = []
	for status in player_statuses.keys():
		var label := str(status).substr(0, 1).to_upper()
		var data: Dictionary = player_statuses[status]
		parts.append("%s%d" % [label, ceili(float(data.get("time", 0.0)))])
	return " [%s]" % " ".join(parts)


func _update_temperature_hud() -> void:
	if temperature_bar == null or temperature_value == null or temperature_title == null:
		return
	temperature_bar.value = body_temperature
	temperature_value.text = "%.1fC" % body_temperature
	var next_state := "stable"
	var color := Color("d9b969")
	if body_temperature <= 31.0:
		next_state = "freezing"
		color = Color("5aa9c4")
	elif body_temperature < 34.0:
		next_state = "cold"
		color = Color("8ed0e3")
	elif body_temperature >= 43.0:
		next_state = "burning"
		color = Color("e65f45")
	elif body_temperature > 40.0:
		next_state = "hot"
		color = Color("e39a59")
	temperature_title.add_theme_color_override("font_color", color)
	temperature_value.add_theme_color_override("font_color", color)
	if next_state == temperature_visual_state:
		return
	temperature_visual_state = next_state
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(1)
	temperature_bar.add_theme_stylebox_override("fill", fill)


func _format_oxygen_status() -> String:
	if oxygen >= MAX_OXYGEN - 0.5 and not _player_overlaps_tile(Tile.WATER):
		return ""
	return " | AIR %d%%" % int(round(oxygen))


func _biome_display_name(biome: String) -> String:
	if biome == "forest":
		return "Forest"
	if biome == "frost_wasteland":
		return "Frost Wasteland"
	if biome == "marsh":
		return "Mossy Marsh"
	if biome == "ash_desert":
		return "Ash Desert"
	if biome == "ash_ruins":
		return "Ashen Ruins"
	if biome == "frost_caves":
		return "Frost Caves"
	if biome == "mushroom_halls":
		return "Mushroom Halls"
	if biome == "ash_city":
		return "Ash City"
	if biome == "sunken_ruins":
		return "Sunken Ruins"
	if biome == "lava_roots":
		return "Lava Roots"
	if biome == "glass_abyss":
		return "Glass Abyss"
	return "Caves"


func _format_equipment_panel(target_name: String, tile_pos: Vector2i, mine_percent: int) -> String:
	return "Equipment\nClass: %s | Damage: %d | Defense: %d\nSelected tool: %s P%d\nTarget: %s [%d,%d] Mining %d%%" % [
		active_class,
		_total_damage(),
		_total_defense(),
		str(tools.get(current_tool, {"name": current_tool}).get("name", current_tool)),
		_tool_power(),
		target_name,
		tile_pos.x,
		tile_pos.y,
		mine_percent
	]


func _item_tier(item_id: String) -> int:
	if tools.has(item_id):
		return int((tools[item_id] as Dictionary).get("tier", 1))
	if gear_stats.has(item_id):
		return int((gear_stats[item_id] as Dictionary).get("tier", 1))
	if item_id in ["archive_sigil", "ashen_lens", "world_memory", "leviathan_tooth", "guardian_core"]:
		return 6
	if item_id.begins_with("stoneblood_") or item_id in ["beast_core", "ember_root", "abyss_crystal", "drowned_pearl"]:
		return 5
	if item_id in ["ash_relic", "sunken_mechanism", "glass_shard", "night_ember", "ash_memory_shard", "sunken_memory_shard"]:
		return 4
	if item_id in ["iron_ore", "iron_bar", "memory_shard", "spark_shard", "root_core", "glowcap", "fungal_memory_shard"]:
		return 3
	if item_id.contains("copper") or item_id in ["wild_ichor", "moss_fiber", "mushroom_spore", "ruin_brick"]:
		return 2
	return 1


func _tier_label(tier: int) -> String:
	var names := ["FIELD", "CRAFTED", "REFINED", "RELIC", "MYTHIC", "ARCHIVE"]
	return "TIER %s  %s" % [["I", "II", "III", "IV", "V", "VI"][clampi(tier, 1, 6) - 1], names[clampi(tier, 1, 6) - 1]]


func _item_category(item_id: String) -> String:
	if tools.has(item_id):
		return "MINING TOOL"
	if gear_stats.has(item_id):
		var slot := str((gear_stats[item_id] as Dictionary).get("slot", "gear"))
		if slot == "weapon":
			return "WEAPON"
		if slot == "accessory":
			return "CHARM"
		return "ARMOR"
	if item_to_tile.has(item_id):
		return "PLACEABLE"
	if item_id in ["ashen_lens", "archive_sigil", "cracked_memory_core", "fungal_memory_shard", "sunken_memory_shard", "ash_memory_shard", "world_memory"]:
		return "STORY ITEM"
	return "MATERIAL"


func _weapon_combat_profile(weapon: String) -> Dictionary:
	var profile := {"style": "Melee", "range": 28, "cooldown": 0.45, "bonus": 0, "projectile_speed": 0}
	if weapon.contains("sword") or weapon.contains("sickle"):
		profile.merge({"range": 34, "cooldown": 0.38}, true)
	elif weapon.contains("spear"):
		profile.merge({"range": 48, "cooldown": 0.48, "bonus": 2}, true)
	elif weapon in ["stonebreaker_blade", "leviathan_fang"]:
		profile.merge({"range": 42, "cooldown": 0.42, "bonus": 4}, true)
	elif weapon == "tidal_trident":
		profile.merge({"range": 56, "cooldown": 0.46, "bonus": 3}, true)
	elif weapon.contains("bow"):
		profile.merge({"style": "Projectile", "range": 0, "cooldown": 0.55, "projectile_speed": 330}, true)
	elif weapon == "hand_cannon":
		profile.merge({"style": "Projectile", "range": 0, "cooldown": 0.95, "bonus": 5, "projectile_speed": 430}, true)
	elif weapon == "harpoon":
		profile.merge({"style": "Projectile", "range": 0, "cooldown": 0.78, "bonus": 4, "projectile_speed": 390}, true)
	elif weapon == "spark_staff":
		profile.merge({"style": "Projectile", "range": 0, "cooldown": 0.62, "bonus": 4, "projectile_speed": 260}, true)
	elif weapon == "tide_staff":
		profile.merge({"style": "Projectile", "range": 0, "cooldown": 0.66, "bonus": 4, "projectile_speed": 300}, true)
	elif weapon == "root_spirit_rod":
		profile.merge({"style": "Projectile", "range": 0, "cooldown": 0.85, "projectile_speed": 210}, true)
	elif weapon == "acid_flasks":
		profile.merge({"style": "Projectile", "range": 0, "cooldown": 0.72, "projectile_speed": 210}, true)
	elif weapon == "small_turret":
		profile.merge({"style": "Automatic", "range": 220, "cooldown": 0.70}, true)
	return profile


func _weapon_preview_damage(weapon: String) -> int:
	var gear: Dictionary = gear_stats.get(weapon, {})
	var accessory_damage := 0
	if gear_stats.has(equipped_accessory):
		accessory_damage = int((gear_stats[equipped_accessory] as Dictionary).get("damage", 0))
	var profile := _weapon_combat_profile(weapon)
	return 1 + int(gear.get("damage", 0)) + accessory_damage + int(profile.get("bonus", 0))


func _item_special_description(item_id: String) -> String:
	match item_id:
		"cracked_memory_core":
			return "Required to awaken each Memory Node."
		"fungal_memory_shard", "sunken_memory_shard", "ash_memory_shard":
			return "One of three memories required to forge the Ashen Lens."
		"ashen_lens":
			return "Resonates with the sealed Archive and awakens its Warden."
		"archive_sigil":
			return "The Warden's seal. Used with the Ashen Lens at the Archive Console."
		"world_memory":
			return "A concentrated memory left by the Heartwood Core."
		"beast_core":
			return "A dense boss material used for Stoneblood equipment."
	return ""


func _format_selected_inventory_item() -> String:
	if held_item_id != "":
		return "Dragging: %s x%d\nRelease over hotbar/equipment/inventory, or outside menu to drop. Right-click a stack to take half." % [_item_display_name(held_item_id), held_item_amount]
	if selected_inventory_item_id == "" or int(inventory.get(selected_inventory_item_id, 0)) <= 0:
		return "Selected item: none\nLeft-drag a stack. Right-drag takes half."
	var item_id := selected_inventory_item_id
	var parts := ["%s  x%d  |  %s  |  %s" % [
		_item_display_name(item_id),
		int(inventory.get(item_id, 0)),
		_item_category(item_id),
		_tier_label(_item_tier(item_id))
	]]
	if tools.has(item_id):
		var tool: Dictionary = tools[item_id]
		parts.append("Mining power %d  |  speed %.2fx  |  breaks material tier %d" % [
			int(tool.get("power", 1)),
			float(tool.get("speed", 1.0)),
			int(tool.get("power", 1))
		])
	elif gear_stats.has(item_id):
		var gear: Dictionary = gear_stats[item_id]
		var slot := str(gear.get("slot", "gear"))
		parts.append("Slot %s  |  class %s" % [slot.capitalize(), str(gear.get("class", "Any"))])
		if slot == "weapon":
			var profile := _weapon_combat_profile(item_id)
			var preview_damage := _weapon_preview_damage(item_id)
			var cooldown := float(profile.get("cooldown", 0.45))
			parts.append("Damage %d  |  %s  |  interval %.2fs  |  approx. DPS %.1f" % [
				preview_damage,
				_weapon_damage_type(item_id).capitalize(),
				cooldown,
				float(preview_damage) / cooldown
			])
			if int(profile.get("projectile_speed", 0)) > 0:
				parts.append("Projectile speed %d  |  effect %s" % [
					int(profile.get("projectile_speed", 0)),
					(_weapon_status(item_id) if _weapon_status(item_id) != "" else _projectile_status_for_weapon(item_id)).capitalize()
				])
			else:
				parts.append("Reach %d px  |  effect %s" % [
					int(profile.get("range", 28)),
					(_weapon_status(item_id) if _weapon_status(item_id) != "" else "none").capitalize()
				])
		else:
			parts.append("Defense +%d  |  cold %d%%  |  heat %d%%" % [
				int(gear.get("defense", 0)),
				int(round(float(gear.get("cold_protection", 0.0)) * 100.0)),
				int(round(float(gear.get("heat_protection", 0.0)) * 100.0))
			])
			var specials: Array[String] = []
			if bool(gear.get("water_breathing", false)):
				specials.append("underwater breathing")
			if bool(gear.get("water_affinity", false)):
				specials.append("water affinity")
			if bool(gear.get("heat_resistance", false)):
				specials.append("lava resistance")
			if int(gear.get("damage", 0)) > 0:
				specials.append("damage +%d" % int(gear.get("damage", 0)))
			if not specials.is_empty():
				parts.append("Special: %s" % ", ".join(specials))
	elif item_to_tile.has(item_id):
		parts.append("Building block  |  placeable in the world")
	else:
		var uses := _recipes_using_material(item_id)
		parts.append("Known crafting uses: %d%s" % [
			uses.size(),
			"  |  " + ", ".join(uses.slice(0, mini(3, uses.size()))) if not uses.is_empty() else ""
		])
	var description := _item_special_description(item_id)
	if description != "":
		parts.append(description)
	return "\n".join(parts)


func _projectile_status_for_weapon(weapon: String) -> String:
	if weapon == "acid_flasks":
		return "poison"
	if weapon in ["root_spirit_rod", "harpoon", "tide_staff"]:
		return "slow"
	if weapon.contains("bow") and equipped_accessory == "fire_arrows":
		return "burn"
	return "none"


func _format_item_tooltip(item_id: String, amount: int) -> String:
	if item_id == "":
		return ""
	var lines := ["%s x%d" % [_item_display_name(item_id), amount], "%s | %s" % [_item_category(item_id), _tier_label(_item_tier(item_id))]]
	if tools.has(item_id):
		var tool: Dictionary = tools[item_id]
		lines.append("Power %d | mining speed %.2fx" % [int(tool.get("power", 1)), float(tool.get("speed", 1.0))])
	elif gear_stats.has(item_id):
		var gear: Dictionary = gear_stats[item_id]
		if str(gear.get("slot", "")) == "weapon":
			lines.append("Damage %d | %s" % [_weapon_preview_damage(item_id), _weapon_damage_type(item_id).capitalize()])
		else:
			lines.append("Defense +%d | cold %d%% | heat %d%%" % [
				int(gear.get("defense", 0)),
				int(round(float(gear.get("cold_protection", 0.0)) * 100.0)),
				int(round(float(gear.get("heat_protection", 0.0)) * 100.0))
			])
	var description := _item_special_description(item_id)
	if description != "":
		lines.append(description)
	return "\n".join(lines)


func _format_recipe_panel(recipe: Dictionary, result: String, station: String) -> String:
	if recipe.is_empty():
		return "Select a recipe"
	var can_station := _has_station_nearby(station)
	var can_materials := _has_recipe_materials(recipe)
	var lines: Array[String] = []
	lines.append("%s x%d" % [_item_display_name(result), int(recipe.get("amount", 1))])
	lines.append("Station: %s [%s]" % [
		_station_display_name(station),
		"READY" if can_station else "NOT NEARBY"
	])
	lines.append("Materials:")
	var cost: Dictionary = recipe.get("cost", {})
	for item_id in cost.keys():
		var need := int(cost[item_id])
		var have := int(inventory.get(str(item_id), 0))
		lines.append("%s: %d / %d%s" % [
			_item_display_name(str(item_id)),
			have,
			need,
			"" if have >= need else "  MISSING"
		])
	lines.append("READY TO CRAFT" if can_station and can_materials else "CANNOT CRAFT")
	return "\n".join(lines)


func _has_recipe_materials(recipe: Dictionary) -> bool:
	var cost: Dictionary = recipe.get("cost", {})
	for item_id in cost.keys():
		if int(inventory.get(str(item_id), 0)) < int(cost[item_id]):
			return false
	return true


func _missing_recipe_text(recipe: Dictionary) -> String:
	var cost: Dictionary = recipe.get("cost", {})
	var missing: Array[String] = []
	for item_id in cost.keys():
		var need := int(cost[item_id])
		var have := int(inventory.get(str(item_id), 0))
		if have < need:
			missing.append("%s %d/%d" % [_item_display_name(str(item_id)), have, need])
	return ", ".join(missing)


func _format_hotbar() -> String:
	var parts: Array[String] = []
	for i in range(hotbar.size()):
		var item_id := str(hotbar[i])
		var marker := ">" if i == selected_slot else "-"
		var name := str(item_names.get(item_id, item_id))
		var amount := int(inventory.get(item_id, 0))
		parts.append("%s %d %s x%d" % [marker, i + 1, name, amount])
	return "HOTBAR  " + "     ".join(parts)


func _update_hotbar_buttons() -> void:
	_sanitize_hotbar()
	for i in range(hotbar_buttons.size()):
		var item_id := str(hotbar[i])
		var selected := i == selected_slot
		if int(inventory.get(item_id, 0)) <= 0:
			item_id = ""
		_configure_slot_button(hotbar_buttons[i], item_id, int(inventory.get(item_id, 0)), selected, str(i + 1))
		_apply_compass_hotbar_slot_style(hotbar_buttons[i], selected)


func _update_inventory_buttons() -> void:
	var items := _inventory_item_ids()
	for i in range(inventory_slot_buttons.size()):
		if i < items.size():
			var item_id := str(items[i])
			var selected := item_id == selected_inventory_item_id
			_configure_slot_button(inventory_slot_buttons[i], item_id, int(inventory.get(item_id, 0)), selected, "")
			_apply_compass_inventory_slot_style(inventory_slot_buttons[i], selected)
		else:
			_configure_slot_button(inventory_slot_buttons[i], "", 0, false, "")
			_apply_compass_inventory_slot_style(inventory_slot_buttons[i], false)


func _update_chest_buttons() -> void:
	var items := _active_chest_items()
	for i in range(chest_slot_buttons.size()):
		if i < items.size():
			var item_id := str(items[i])
			var loot: Dictionary = chest_loot.get(active_chest_key, {})
			_configure_slot_button(chest_slot_buttons[i], item_id, int(loot.get(item_id, 0)), false, "")
			_apply_compass_inventory_slot_style(chest_slot_buttons[i], false)
		else:
			_configure_slot_button(chest_slot_buttons[i], "", 0, false, "")
			_apply_compass_inventory_slot_style(chest_slot_buttons[i], false)


func _update_chest_open_state() -> void:
	if active_chest_key == "":
		return
	if not inventory_open:
		_close_chest()
		return
	if not _in_bounds(active_chest_pos.x, active_chest_pos.y) or _get_tile(active_chest_pos.x, active_chest_pos.y) != Tile.CHEST:
		_close_chest()
		return
	if not _can_interact(active_chest_pos):
		_close_chest()


func _update_equipment_buttons() -> void:
	_configure_slot_button(weapon_slot_button, equipped_weapon, int(inventory.get(equipped_weapon, 1)), false, "")
	_apply_compass_inventory_slot_style(weapon_slot_button, equipped_weapon != "", true)
	weapon_slot_button.disabled = true
	weapon_slot_button.tooltip_text = _format_item_tooltip(equipped_weapon, 1) if equipped_weapon != "" else "Weapon: Empty"
	for entry in [
		[helmet_slot_button, equipped_helmet, "Helmet"],
		[armor_slot_button, equipped_armor, "Chest"],
		[legs_slot_button, equipped_legs, "Greaves"],
		[boots_slot_button, equipped_boots, "Boots"],
	]:
		var slot_button: Button = entry[0]
		var worn := str(entry[1])
		_configure_slot_button(slot_button, worn, int(inventory.get(worn, 1)), false, "")
		_apply_compass_inventory_slot_style(slot_button, worn != "", true)
		slot_button.disabled = true
		slot_button.tooltip_text = _format_item_tooltip(worn, 1) if worn != "" else "%s: Empty" % str(entry[2])
	_configure_slot_button(accessory_slot_button, equipped_accessory, int(inventory.get(equipped_accessory, 1)), false, "")
	_apply_compass_inventory_slot_style(accessory_slot_button, equipped_accessory != "", true)
	accessory_slot_button.disabled = true
	accessory_slot_button.tooltip_text = _format_item_tooltip(equipped_accessory, 1) if equipped_accessory != "" else "Charm: Empty"


func _update_recipe_buttons() -> void:
	for i in range(recipe_buttons.size()):
		var button := recipe_buttons[i]
		if i >= recipes.size():
			button.visible = false
			continue
		var recipe: Dictionary = recipes[i]
		var known := _recipe_is_known(recipe)
		button.visible = known
		if not known:
			button.icon = null
			button.text = ""
			button.tooltip_text = ""
			continue
		var result := str(recipe.get("result", ""))
		var ready := _has_station_nearby(str(recipe.get("station", "hand"))) and _has_recipe_materials(recipe)
		var status := "READY" if ready else "LOCKED"
		button.icon = _item_icon(result)
		button.expand_icon = true
		button.text = ""
		button.tooltip_text = "%s x%d [%s]\nStation: %s\nCost: %s\nMissing: %s" % [
			_item_display_name(result),
			int(recipe.get("amount", 1)),
			status,
			_station_display_name(str(recipe.get("station", "hand"))),
			_recipe_cost_text(recipe),
			_missing_recipe_text(recipe)
		]
		button.disabled = false
		_apply_recipe_button_style(button, i == selected_recipe_index, ready)
	if craft_button != null:
		var selected := _selected_recipe()
		craft_button.disabled = selected.is_empty() or not (_has_station_nearby(str(selected.get("station", "hand"))) and _has_recipe_materials(selected))


func _apply_recipe_button_style(button: Button, selected: bool, ready: bool) -> void:
	if selected:
		ui_theme_manager.apply_slot(button, true, true, false)
	elif ready:
		ui_theme_manager.apply_slot(button, false, true, false)
	else:
		ui_theme_manager.apply_slot(button, false, true, true)


func _configure_slot_button(button: Button, item_id: String, amount: int, selected: bool, prefix: String) -> void:
	_apply_slot_style(button, selected)
	if item_id == "":
		button.icon = null
		button.text = ""
		button.tooltip_text = ""
		button.disabled = true
		return
	button.disabled = false
	button.icon = _item_icon(item_id)
	var amount_text := "" if amount <= 1 else str(amount)
	button.text = ("%s\n%s" % [prefix, amount_text]).strip_edges()
	button.tooltip_text = _format_item_tooltip(item_id, amount)


func _item_icon(item_id: String) -> Texture2D:
	if item_icon_cache.has(item_id):
		return item_icon_cache[item_id]
	var file_texture: Texture2D = _load_png_texture("res://assets/textures/items/%s.png" % item_id)
	if file_texture != null:
		item_icon_cache[item_id] = file_texture
		return file_texture
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var main := _item_icon_color(item_id)
	var dark := main.darkened(0.38)
	var light := main.lightened(0.35)
	if item_id.contains("pickaxe"):
		_icon_rect(image, 5, 6, 12, 3, light)
		_icon_rect(image, 14, 9, 3, 3, light)
		_icon_rect(image, 9, 9, 3, 10, dark)
	elif item_id.contains("sword") or item_id.contains("spear") or item_id.contains("sickle"):
		_icon_rect(image, 11, 3, 3, 14, light)
		_icon_rect(image, 8, 14, 9, 3, dark)
		_icon_rect(image, 10, 17, 4, 4, Color("6b4428"))
	elif item_id.contains("bow"):
		_icon_rect(image, 7, 4, 3, 16, main)
		_icon_rect(image, 14, 5, 2, 14, light)
		_icon_rect(image, 10, 11, 7, 2, dark)
	elif item_id.contains("shield") or item_id.contains("armor") or item_id.contains("charm") or item_id.contains("ring"):
		_icon_rect(image, 7, 4, 10, 12, main)
		_icon_rect(image, 9, 16, 6, 4, dark)
		_icon_rect(image, 10, 7, 4, 5, light)
	elif item_id.contains("bar"):
		_icon_rect(image, 5, 9, 14, 7, main)
		_icon_rect(image, 7, 7, 10, 3, light)
	elif item_id.contains("ore") or item_id in ["ash", "root", "stone", "ruin_brick", "memory_shard", "spark_shard", "root_core", "ash_glass"]:
		_icon_rect(image, 5, 7, 13, 10, dark)
		_icon_rect(image, 7, 5, 8, 5, main)
		_icon_rect(image, 12, 12, 5, 4, light)
	elif item_to_tile.has(item_id):
		_icon_rect(image, 5, 5, 14, 14, main)
		_icon_rect(image, 7, 7, 10, 3, light)
		_icon_rect(image, 6, 16, 12, 2, dark)
	else:
		_icon_rect(image, 6, 6, 12, 12, main)
		_icon_rect(image, 9, 9, 6, 6, light)
	var texture := ImageTexture.create_from_image(image)
	item_icon_cache[item_id] = texture
	return texture


func _item_icon_color(item_id: String) -> Color:
	if item_id.begins_with("stoneblood_"):
		return Color("8e5f6b")
	if item_id == "brine_scale":
		return Color("3f7f86")
	if item_id == "leviathan_tooth":
		return Color("cfe0e2")
	if item_id.contains("copper"):
		return Color("c97a45")
	if item_id.contains("iron"):
		return Color("c9c6b7")
	if item_id == "ash_sand":
		return Color("c9b591")
	if item_id == "frozen_dirt":
		return Color("8fa3b8")
	if item_id == "mud":
		return Color("6b5340")
	if item_id == "rubble":
		return Color("8d7f72")
	if item_id.contains("ash") or item_id.contains("memory"):
		return Color("9b7bd8")
	if item_id.contains("root"):
		return Color("8a6638")
	if item_id.contains("spark") or item_id.contains("fire"):
		return Color("ffcf5f")
	if item_id.contains("ruin") or item_id.contains("cannon"):
		return Color("81759a")
	if item_id.contains("chest"):
		return Color("b98746")
	if item_id == "torch":
		return Color("ffd36b")
	if item_id.contains("wood") or item_id == "workbench":
		return Color("a66a35")
	if item_id == "stone" or item_id == "furnace" or item_id == "anvil":
		return Color("69717c")
	if item_id == "dirt":
		return Color("7a4a2a")
	if item_id == "leaf":
		return Color("4a7b50")
	return Color("7fb6d6")


func _icon_rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	for yy in range(y, y + height):
		for xx in range(x, x + width):
			if xx >= 0 and yy >= 0 and xx < image.get_width() and yy < image.get_height():
				image.set_pixel(xx, yy, color)


func _format_inventory_contents() -> String:
	var keys: Array[String] = []
	for item_id in inventory.keys():
		if int(inventory[item_id]) > 0:
			keys.append(str(item_id))
	keys.sort()
	if keys.is_empty():
		return "empty"
	var lines: Array[String] = []
	var current_line := ""
	for item_id in keys:
		var part := "%s x%d" % [_item_display_name(item_id), int(inventory[item_id])]
		if current_line.length() + part.length() > 88:
			lines.append(current_line)
			current_line = part
		elif current_line == "":
			current_line = part
		else:
			current_line += " | " + part
	if current_line != "":
		lines.append(current_line)
	return "\n".join(lines)


func _station_status_text() -> String:
	return "STATIONS NEARBY\nWorkbench: %s\nFurnace: %s\nAnvil: %s" % [
		"YES" if _has_station_nearby("workbench") else "NO",
		"YES" if _has_station_nearby("furnace") else "NO",
		"YES" if _has_station_nearby("anvil") else "NO"
	]


func _empty_name(item_id: String) -> String:
	if item_id == "":
		return "none"
	return _item_display_name(item_id)


func _draw_world_edge_haze() -> void:
	# Layered ash fog over the rim. It hides the point where the map data stops
	# and reads as distance, so the sea looks like it carries on out of view.
	var view_rect := get_viewport_rect()
	var center := camera.get_screen_center_position()
	var half_size := view_rect.size * 0.5 / camera.zoom
	var left_edge := center.x - half_size.x
	var right_edge := center.x + half_size.x
	var haze_width := float(WORLD_EDGE_ZONE * TILE_SIZE)
	var haze := _biome_background_color(_current_biome()).lerp(Color("aeb6c2"), 0.34)
	haze = haze.lerp(Color("05070c"), (1.0 - _daylight_factor()) * 0.62)
	var bands := 9
	for side in [0, 1]:
		var outer := 0.0 if side == 0 else float(WORLD_WIDTH * TILE_SIZE)
		for band in range(bands):
			var near := float(band) / float(bands)
			var far := float(band + 1) / float(bands)
			# Opacity climbs towards the rim, so the fade never has a visible step.
			var alpha := pow(1.0 - near, 2.2) * 0.55
			if alpha <= 0.004:
				continue
			var inner_x := outer + (haze_width * far if side == 0 else -haze_width * far)
			var outer_x := outer + (haze_width * near if side == 0 else -haze_width * near)
			var band_left := minf(inner_x, outer_x)
			var band_right := maxf(inner_x, outer_x)
			if band_right < left_edge or band_left > right_edge:
				continue
			var draw_left := maxf(band_left, left_edge)
			var draw_right := minf(band_right, right_edge)
			draw_rect(
				Rect2(
					Vector2(draw_left, center.y - half_size.y),
					Vector2(draw_right - draw_left, half_size.y * 2.0)
				),
				Color(haze.r, haze.g, haze.b, alpha)
			)


func _draw_background() -> void:
	var view_rect := get_viewport_rect()
	var top_left := camera.get_screen_center_position() - view_rect.size * 0.5 / camera.zoom
	var bottom_right := camera.get_screen_center_position() + view_rect.size * 0.5 / camera.zoom
	var biome := _current_biome()
	var sky := _biome_background_color(biome).lerp(Color("070912"), (1.0 - _daylight_factor()) * 0.55)
	draw_rect(Rect2(top_left, bottom_right - top_left), sky)
	_draw_biome_backdrop(biome, top_left, bottom_right)
	for i in range(18):
		var x := fposmod(float(seed % 997) * 3.0 + float(i) * 173.0, WORLD_WIDTH * TILE_SIZE)
		var y := 38.0 + float((seed + i * 31) % 90)
		if biome == "forest" or _is_night():
			draw_circle(Vector2(x, y), 1.2, Color("d7e4ee", 0.25 + (1.0 - _daylight_factor()) * 0.55))


func _biome_background_color(biome: String) -> Color:
	if biome == "forest":
		return Color("172b2a")
	if biome == "frost_wasteland" or biome == "frost_caves":
		return Color("17283b")
	if biome == "marsh":
		return Color("142722")
	if biome == "ash_desert":
		return Color("30211d")
	if biome == "ash_ruins":
		return Color("211b21")
	if biome == "mushroom_halls":

		return Color("171628")
	if biome == "ash_city":
		return Color("211b21")
	if biome == "sunken_ruins":
		return Color("102633")
	if biome == "lava_roots":
		return Color("241412")
	if biome == "glass_abyss":
		return Color("07151c")
	return Color("151b24")


func _draw_biome_backdrop(biome: String, top_left: Vector2, bottom_right: Vector2) -> void:
	var width := bottom_right.x - top_left.x
	var height := bottom_right.y - top_left.y
	var base_y := top_left.y + height * 0.62
	var parallax_x := camera.get_screen_center_position().x * 0.18
	if biome == "forest":
		# Three parallax forest layers. Small clustered crowns read as trees instead
		# of the oversized faint circles used by the old placeholder backdrop.
		for layer in range(3):
			var layer_factor := 0.10 + float(layer) * 0.12
			var spacing := 86.0 - float(layer) * 11.0
			var trunk_color := Color("0b1b16", 0.42 + float(layer) * 0.11)
			var crown_color := Color("123322", 0.30 + float(layer) * 0.10)
			for i in range(18):
				var x := top_left.x + fposmod(float(i) * spacing - camera.get_screen_center_position().x * layer_factor, width + 120.0) - 60.0
				var h := 52.0 + float((seed + i * 19 + layer * 31) % 48)
				var y := base_y + float(layer) * 12.0 - h
				draw_rect(Rect2(Vector2(x + 9, y + 18), Vector2(6 + layer * 2, h)), trunk_color)
				draw_circle(Vector2(x + 11, y + 15), 18.0 + layer * 3.0, crown_color)
				draw_circle(Vector2(x - 2, y + 24), 13.0 + layer * 2.0, crown_color)
				draw_circle(Vector2(x + 24, y + 25), 14.0 + layer * 2.0, crown_color)
		for i in range(12):
			var fern_x := top_left.x + fposmod(float(i * 71) - parallax_x * 0.55, width + 80.0) - 40.0
			var fern_y := base_y + 34.0
			draw_line(Vector2(fern_x, fern_y), Vector2(fern_x + 4, fern_y - 14), Color("28553a", 0.48), 2.0)
			draw_line(Vector2(fern_x + 3, fern_y - 8), Vector2(fern_x - 4, fern_y - 12), Color("386b45", 0.40), 1.0)
			draw_line(Vector2(fern_x + 3, fern_y - 10), Vector2(fern_x + 10, fern_y - 15), Color("386b45", 0.40), 1.0)
	elif biome == "mushroom_halls":
		for i in range(13):
			var x := top_left.x + fposmod(float(i * 121) - parallax_x, width + 160.0) - 80.0
			var h := 36.0 + float((seed + i * 23) % 50)
			draw_rect(Rect2(Vector2(x, base_y - h), Vector2(8, h)), Color("221b38", 0.62))
			draw_circle(Vector2(x + 4, base_y - h), 22.0, Color("4d315d", 0.38))
			draw_circle(Vector2(x + 10, base_y - h - 4), 2.0, Color("88ffd8", 0.55))
	elif biome == "ash_city":
		for i in range(14):
			var x := top_left.x + fposmod(float(i * 91) - parallax_x, width + 130.0) - 65.0
			var h := 44.0 + float((seed + i * 19) % 70)
			draw_rect(Rect2(Vector2(x, base_y - h), Vector2(24, h)), Color("141015", 0.66))
			draw_rect(Rect2(Vector2(x + 5, base_y - h + 10), Vector2(4, 4)), Color("d07d54", 0.32))
	elif biome == "sunken_ruins":
		for i in range(12):
			var x := top_left.x + fposmod(float(i * 112) - parallax_x, width + 150.0) - 75.0
			draw_line(Vector2(x, top_left.y), Vector2(x - 32, bottom_right.y), Color("6eb7c4", 0.10), 2.0)
			draw_rect(Rect2(Vector2(x, base_y - 42), Vector2(18, 58)), Color("0b1d24", 0.58))
	elif biome == "lava_roots":
		for i in range(18):
			var x := top_left.x + fposmod(float(i * 83) - parallax_x, width + 130.0) - 65.0
			draw_line(Vector2(x, top_left.y), Vector2(x + 26, bottom_right.y), Color("8d2e1e", 0.35), 5.0)
			draw_circle(Vector2(x + 8, base_y), 3.0, Color("ff7d3b", 0.55))
	elif biome == "glass_abyss":
		for i in range(20):
			var x := top_left.x + fposmod(float(i * 73) - parallax_x, width + 120.0) - 60.0
			var y := top_left.y + float((seed + i * 31) % int(maxf(1.0, height)))
			draw_line(Vector2(x, y), Vector2(x + 18, y + 52), Color("b8f4ff", 0.18), 1.0)
			draw_circle(Vector2(x + 8, y + 18), 1.5, Color("e8ffff", 0.35))


func _draw_visible_world() -> void:
	var view_rect := get_viewport_rect()
	var center := camera.get_screen_center_position()
	var half_size := view_rect.size * 0.5 / camera.zoom
	var min_x := clampi(floori((center.x - half_size.x) / TILE_SIZE) - VIEW_PADDING, 0, WORLD_WIDTH - 1)
	var max_x := clampi(ceili((center.x + half_size.x) / TILE_SIZE) + VIEW_PADDING, 0, WORLD_WIDTH - 1)
	var min_y := clampi(floori((center.y - half_size.y) / TILE_SIZE) - VIEW_PADDING, 0, WORLD_HEIGHT - 1)
	var max_y := clampi(ceili((center.y + half_size.y) / TILE_SIZE) + VIEW_PADDING, 0, WORLD_HEIGHT - 1)
	var min_chunk_x := int(floori(float(min_x) / float(CHUNK_SIZE)))
	var max_chunk_x := int(floori(float(max_x) / float(CHUNK_SIZE)))
	var min_chunk_y := int(floori(float(min_y) / float(CHUNK_SIZE)))
	var max_chunk_y := int(floori(float(max_y) / float(CHUNK_SIZE)))

	for chunk_y in range(min_chunk_y, max_chunk_y + 1):
		for chunk_x in range(min_chunk_x, max_chunk_x + 1):
			_draw_chunk(chunk_x, chunk_y, min_x, max_x, min_y, max_y)


func _collect_visible_light_sources() -> void:
	visible_light_sources.clear()
	visible_light_sources.append({
		"pos": player_position / TILE_SIZE,
		"radius": 7.0,
		"intensity": 0.95,
		"kind": "player"
	})
	var view_rect := get_viewport_rect()
	var center := camera.get_screen_center_position()
	var half_size := view_rect.size * 0.5 / camera.zoom
	var light_padding := 13
	var min_x := clampi(floori((center.x - half_size.x) / TILE_SIZE) - light_padding, 0, WORLD_WIDTH - 1)
	var max_x := clampi(ceili((center.x + half_size.x) / TILE_SIZE) + light_padding, 0, WORLD_WIDTH - 1)
	var min_y := clampi(floori((center.y - half_size.y) / TILE_SIZE) - light_padding, 0, WORLD_HEIGHT - 1)
	var max_y := clampi(ceili((center.y + half_size.y) / TILE_SIZE) + light_padding, 0, WORLD_HEIGHT - 1)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var tile := _get_tile(x, y)
			var radius := 0.0
			var intensity := 1.0
			var kind := ""
			if tile == Tile.TORCH:
				radius = 12.0
				kind = "torch"
			elif tile == Tile.LAVA:
				# One strong light per lava tile produced overlapping orange circles.
				# Only exposed surface cells now emit a small, sparse heat glow.
				var exposed := _get_tile(x, y - 1) != Tile.LAVA
				if exposed and _visual_hash(x, y, 47) % 4 == 0:
					radius = 4.5
					intensity = 0.34
					kind = "lava"
			elif tile == Tile.GLOW_MUSHROOM:
				radius = 7.0
				intensity = 0.82
				kind = "mushroom"
			elif tile == Tile.ABYSS_CRYSTAL:
				radius = 6.0
				intensity = 0.72
				kind = "crystal"
			if radius > 0.0:
				visible_light_sources.append({
					"pos": Vector2(x + 0.5, y + 0.5),
					"radius": radius,
					"intensity": intensity,
					"kind": kind
				})


func _tile_texture_at(tile: int, x: int, y: int) -> Texture2D:
	# Surface biome palettes cover the whole upper crust of their column, so an
	# excavated biome still looks like itself instead of only its top row. The
	# palette follows the same blended biome as the terrain, otherwise tinting
	# would repaint a hard vertical seam over ground that was blended.
	if x >= 0 and x < surface_heights.size() and _uses_biome_palette(x, y):
		var surface_biome := _visual_biome_at(x, y)
		var biome_tiles: Dictionary = biome_tile_textures.get(surface_biome, {})
		if biome_tiles.has(tile):
			return biome_tiles[tile] as Texture2D
	var variants: Array = tile_texture_variants.get(tile, [])
	if variants.is_empty():
		return tile_textures.get(tile, null) as Texture2D
	# Deterministic coordinates choose a stable variant, avoiding a repeated tile grid.
	var raw_index: int = x * 31 + y * 17 + tile * 13
	var variant_index: int = ((raw_index % variants.size()) + variants.size()) % variants.size()
	return variants[variant_index] as Texture2D


func _edge_falloff_strength(x: int) -> float:
	# 0.0 inland, 1.0 at the very rim of the map. Smoothstep keeps the coast
	# from starting with a visible kink.
	var distance := mini(x, WORLD_WIDTH - 1 - x)
	if distance >= WORLD_EDGE_ZONE:
		return 0.0
	var t := 1.0 - float(distance) / float(WORLD_EDGE_ZONE)
	return t * t * (3.0 - 2.0 * t)


func _apply_edge_falloff(x: int, height: int) -> int:
	var strength := _edge_falloff_strength(x)
	if strength <= 0.0:
		return height
	# Ragged coastline: the drop is nudged by the same terrain noise so the
	# shore is not a clean mathematical curve.
	var jitter := 0.0
	if topsoil_noise != null:
		jitter = topsoil_noise.get_noise_1d(float(x) * 0.8) * 5.0 * (1.0 - strength)
	var target := float(WORLD_EDGE_FLOOR) + jitter
	var blended := lerpf(float(height), target, strength)
	return clampi(int(round(blended)), 24, WORLD_HEIGHT - 6)


func _is_protected_seabed(x: int, y: int) -> bool:
	# True for any tile that forms the floor or walls of the dead sea. The sea
	# only exists where the falloff has taken hold, so the protected span is
	# derived from the same curve instead of a second hand-tuned number.
	if surface_heights.is_empty():
		return false
	var distance := mini(x, WORLD_WIDTH - 1 - x)
	if distance >= WORLD_EDGE_ZONE:
		return false
	var clamped := clampi(x, 0, surface_heights.size() - 1)
	# Only the ground under and around the water is locked, not the sky above,
	# so surface structures and trees on the beach still work.
	return y >= int(surface_heights[clamped]) - 2


func _column_is_sea(x: int) -> bool:
	return _edge_sea_level_at(x) >= 0


func _edge_sea_level_at(x: int) -> int:
	# Water only appears once the land has dropped below the sea level, which
	# puts the coastline out on the margin rather than in inland valleys. A
	# column whose bed never sinks below the waterline stays dry land, so the
	# shore cannot leave a rock stranded in the middle of the water.
	var strength := _edge_falloff_strength(x)
	if strength < WORLD_EDGE_SEA_START:
		return -1
	if x < 0 or x >= surface_heights.size():
		return -1
	if surface_heights[x] <= WORLD_EDGE_SEA_LEVEL:
		return -1
	return WORLD_EDGE_SEA_LEVEL


func _biome_palette_bottom(x: int) -> int:
	# The palette fades out at a wobbling depth, so the tinted crust does not
	# end on a dead straight horizontal line across the whole world.
	var wobble := 0.0
	if topsoil_noise != null:
		wobble = topsoil_noise.get_noise_1d(float(x) * 0.6) * BIOME_PALETTE_DEPTH_JITTER
	return surface_heights[x] + BIOME_PALETTE_DEPTH + int(round(wobble))


func _uses_biome_palette(x: int, y: int) -> bool:
	# Over the last rows the palette dissolves tile by tile rather than ending
	# on one row, so the bottom of the tinted crust has no visible cut.
	var bottom := _biome_palette_bottom(x)
	if y > bottom:
		return false
	var into_fade := bottom - y
	if into_fade >= BIOME_PALETTE_FADE:
		return true
	if transition_noise == null:
		return true
	var keep_chance := float(into_fade) / float(BIOME_PALETTE_FADE)
	var speckle := transition_noise.get_noise_2d(float(x) * 1.7, float(y) * 1.7) * 0.5 + 0.5
	return speckle < keep_chance


func _visual_hash(x: int, y: int, salt: int) -> int:
	var raw: int = x * 31 + y * 17 + seed * 13 + salt * 97
	return ((raw % 997) + 997) % 997


func _draw_air_decoration(x: int, y: int) -> void:
	if x <= 0 or x >= WORLD_WIDTH - 1 or y <= 0 or y >= WORLD_HEIGHT - 1:
		return
	var below := _get_tile(x, y + 1)
	var above := _get_tile(x, y - 1)
	var depth := y - surface_heights[x]
	var origin := Vector2(x * TILE_SIZE, y * TILE_SIZE)
	var mark := _visual_hash(x, y, 3)
	# Surface tufts, pebbles and small plants are visual only: no movement cost.
	if depth >= -1 and depth <= 1 and (below == Tile.GRASS or below == Tile.MOSS):
		if mark % 17 == 0:
			draw_line(origin + Vector2(7, 15), origin + Vector2(5, 9), Color("5f9d58"), 1.0)
			draw_line(origin + Vector2(8, 15), origin + Vector2(10, 10), Color("77b968"), 1.0)
		elif mark % 29 == 0:
			draw_circle(origin + Vector2(8, 14), 2.0, Color("67706c"))
		elif mark % 41 == 0:
			draw_circle(origin + Vector2(7, 13), 1.0, Color("d6c476"))
		return
	# The ash desert gets its own surface litter: pebbles and dry dead twigs.
	if depth >= -1 and depth <= 1 and below == Tile.ASH_SAND:
		if mark % 23 == 0:
			draw_circle(origin + Vector2(8, 14), 2.0, Color("8f8375"))
		elif mark % 37 == 0:
			draw_line(origin + Vector2(7, 15), origin + Vector2(5, 10), Color("b3a58f"), 1.0)
			draw_line(origin + Vector2(7, 13), origin + Vector2(10, 11), Color("b3a58f"), 1.0)
		return
	if depth < 8:
		return
	# Visual stalactites / stalagmites and biome details inside caves.
	if above != Tile.AIR and mark % 47 == 0:
		draw_colored_polygon(PackedVector2Array([
			origin + Vector2(3, 0), origin + Vector2(13, 0), origin + Vector2(8, 9)
		]), Color("4e5a5d"))
	elif below != Tile.AIR and mark % 53 == 0:
		draw_colored_polygon(PackedVector2Array([
			origin + Vector2(3, 16), origin + Vector2(13, 16), origin + Vector2(8, 7)
		]), Color("566264"))
	elif below == Tile.MUSHROOM_SOIL and mark % 11 == 0:
		draw_rect(Rect2(origin + Vector2(7, 8), Vector2(2, 8)), Color("7c6446"))
		draw_circle(origin + Vector2(8, 7), 4.0, Color("d172aa"))
		draw_circle(origin + Vector2(6, 6), 1.0, Color("f2b4d1"))
	elif below == Tile.SUNKEN_STONE and mark % 19 == 0:
		draw_circle(origin + Vector2(8, 11), 2.0, Color("77c3ca", 0.45))
		draw_circle(origin + Vector2(10, 6), 1.0, Color("a6e7e4", 0.55))
	elif below == Tile.LAVA_ROOT and mark % 23 == 0:
		draw_circle(origin + Vector2(8, 12), 1.5, Color("ff8a45"))
	elif below == Tile.GLASS_STONE and mark % 17 == 0:
		draw_colored_polygon(PackedVector2Array([
			origin + Vector2(7, 15), origin + Vector2(10, 4), origin + Vector2(12, 15)
		]), Color("9ee9e5", 0.72))


func _liquid_fill_ratio(x: int, y: int) -> float:
	# Partially filled liquid tiles report how much of the block they occupy so
	# a pool can settle into a flat surface instead of a stair-stepped edge.
	if liquid_sim == null:
		return 1.0
	var ratio := liquid_sim.get_fill_ratio(x, y)
	if ratio <= 0.0:
		return 1.0
	return ratio


func _liquid_surface_rect(x: int, y: int, rect: Rect2) -> Rect2:
	var ratio := _liquid_fill_ratio(x, y)
	if ratio >= 0.999:
		return rect
	# A partial tile rests on the floor of its block and leaves air above.
	var filled_height := maxf(1.0, float(TILE_SIZE) * ratio)
	return Rect2(
		rect.position + Vector2(0.0, float(TILE_SIZE) - filled_height),
		Vector2(float(TILE_SIZE), filled_height)
	)


func _draw_liquid_motion(x: int, y: int, tile: int, rect: Rect2) -> void:
	var above_air := _get_tile(x, y - 1) == Tile.AIR
	var time := float(Time.get_ticks_msec()) / 1000.0
	var phase := sin(time * (2.0 if tile == Tile.WATER else 3.4) + float(x) * 0.75)
	if above_air:
		var wave_color := Color("91d7d8", 0.72) if tile == Tile.WATER else Color("ffd05d", 0.82)
		draw_line(rect.position + Vector2(0, 2.0 + phase), rect.position + Vector2(TILE_SIZE, 2.0 - phase), wave_color, 1.0)
	var mark := _visual_hash(x, y, 7)
	if tile == Tile.WATER and mark % 31 == 0:
		draw_circle(rect.position + Vector2(7, 8 + phase * 2.0), 1.0, Color("c9ffff", 0.5))
	elif tile == Tile.LAVA and mark % 29 == 0:
		draw_circle(rect.position + Vector2(8, 8 + phase), 1.0, Color("ffb34d", 0.75))


func _draw_chunk(chunk_x: int, chunk_y: int, min_x: int, max_x: int, min_y: int, max_y: int) -> void:
	var start_x := maxi(chunk_x * CHUNK_SIZE, min_x)
	var end_x := mini(start_x + CHUNK_SIZE - 1, max_x)
	var start_y := maxi(chunk_y * CHUNK_SIZE, min_y)
	var end_y := mini(start_y + CHUNK_SIZE - 1, max_y)
	for y in range(start_y, end_y + 1):
		for x in range(start_x, end_x + 1):
			var tile := _get_tile(x, y)
			if tile == Tile.AIR:
				_draw_air_decoration(x, y)
				continue
			var base_color: Color = tile_colors.get(tile, Color.WHITE)
			var rect := Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			var texture: Texture2D = _tile_texture_at(tile, x, y)
			if texture != null:
				var texture_rect := rect
				if _uses_large_station_sprite(tile):
					# Stations stay one collision tile, but use a larger visual sprite.
					texture_rect = Rect2(rect.position + Vector2(-8, -16), Vector2(TILE_SIZE * 2, TILE_SIZE * 2))
					# A grounded shadow prevents stations from reading as loose inventory icons.
					draw_rect(Rect2(rect.position + Vector2(1, TILE_SIZE - 3), Vector2(TILE_SIZE - 2, 3)), Color(0.0, 0.0, 0.0, 0.42))
				if tile == Tile.WATER or tile == Tile.LAVA:
					# Draw only the filled part of the block, so a settled pool
					# ends in one straight waterline instead of a stepped edge.
					var surface_rect := _liquid_surface_rect(x, y, rect)
					var source_rect := Rect2(
						Vector2(0.0, float(texture.get_height()) - surface_rect.size.y),
						Vector2(float(texture.get_width()), surface_rect.size.y)
					)
					draw_texture_rect_region(texture, surface_rect, source_rect, Color.WHITE)
					_draw_liquid_motion(x, y, tile, surface_rect)
				else:
					draw_texture_rect(texture, texture_rect, false, Color.WHITE)
				_draw_exposed_edge_breakup(x, y, tile, rect)
			else:
				draw_rect(rect, base_color)
				draw_rect(rect, base_color.darkened(0.18), false, 1.0)
				_draw_tile_details(rect, tile, base_color)


func _lit_tile_color(x: int, y: int, tile: int) -> Color:
	var base: Color = tile_colors.get(tile, Color.WHITE)
	var light: float = _light_at_tile(x, y)
	return base.lerp(Color("06070a"), 1.0 - light)


func _draw_exposed_edge_breakup(x: int, y: int, tile: int, rect: Rect2) -> void:
	if not _uses_organic_edges(tile):
		return
	var air_color := Color("17202a")
	var above_air := _get_tile(x, y - 1) == Tile.AIR
	var below_air := _get_tile(x, y + 1) == Tile.AIR
	var left_air := _get_tile(x - 1, y) == Tile.AIR
	var right_air := _get_tile(x + 1, y) == Tile.AIR
	if above_air:
		_draw_edge_chip(rect.position, Vector2i(2, 0), Vector2i(3, 1), air_color)
		_draw_edge_chip(rect.position, Vector2i(9, 0), Vector2i(2, 2), air_color)
		if tile == Tile.GRASS:
			draw_rect(Rect2(rect.position + Vector2(4, 0), Vector2(2, 1)), Color("75c86a"))
	if below_air:
		_draw_edge_chip(rect.position, Vector2i(4, 15), Vector2i(4, 1), air_color)
		_draw_edge_chip(rect.position, Vector2i(12, 14), Vector2i(2, 2), air_color)
	if left_air:
		_draw_edge_chip(rect.position, Vector2i(0, 3), Vector2i(1, 4), air_color)
		_draw_edge_chip(rect.position, Vector2i(0, 11), Vector2i(2, 2), air_color)
	if right_air:
		_draw_edge_chip(rect.position, Vector2i(15, 5), Vector2i(1, 4), air_color)
		_draw_edge_chip(rect.position, Vector2i(14, 12), Vector2i(2, 2), air_color)
	if above_air and left_air:
		_draw_edge_chip(rect.position, Vector2i(0, 0), Vector2i(3, 3), air_color)
	if above_air and right_air:
		_draw_edge_chip(rect.position, Vector2i(13, 0), Vector2i(3, 2), air_color)
	if below_air and left_air:
		_draw_edge_chip(rect.position, Vector2i(0, 14), Vector2i(2, 2), air_color)
	if below_air and right_air:
		_draw_edge_chip(rect.position, Vector2i(14, 14), Vector2i(2, 2), air_color)


func _uses_large_station_sprite(tile: int) -> bool:
	return tile == Tile.WORKBENCH or tile == Tile.FURNACE or tile == Tile.ANVIL or tile == Tile.CHEST


func _uses_organic_edges(tile: int) -> bool:
	return tile == Tile.GRASS or tile == Tile.DIRT or tile == Tile.STONE or tile == Tile.COPPER or tile == Tile.IRON or tile == Tile.ASH or tile == Tile.ROOT or tile == Tile.RUIN or tile == Tile.MOSS or tile == Tile.MUSHROOM_SOIL or tile == Tile.ASH_BRICK or tile == Tile.SUNKEN_STONE or tile == Tile.LAVA_ROOT or tile == Tile.GLASS_STONE or tile == Tile.ABYSS_CRYSTAL or _is_biome_topsoil_tile(tile)


func _draw_edge_chip(origin: Vector2, offset: Vector2i, size: Vector2i, color: Color) -> void:
	draw_rect(Rect2(origin + Vector2(offset), Vector2(size)), color)


func _draw_tile_details(rect: Rect2, tile: int, color: Color) -> void:
	if tile == Tile.COPPER:
		_draw_ore_specks(rect, Color("ffb15f"), Color("6c3620"))
	elif tile == Tile.IRON:
		_draw_ore_specks(rect, Color("f0eee2"), Color("7a7a73"))
	elif tile == Tile.ASH:
		_draw_ore_specks(rect, Color("b79cff"), Color("24202e"))
		draw_rect(rect.grow(-2), Color("9276d5", 0.22), false, 1.0)
	elif tile == Tile.RUIN:
		draw_rect(rect.grow(-2), Color("b5a7d8", 0.35), false, 1.0)
		draw_line(rect.position + Vector2(3, 5), rect.position + Vector2(13, 5), Color("b5a7d8", 0.5), 1.0)
		draw_line(rect.position + Vector2(5, 11), rect.position + Vector2(15, 11), Color("342d3e", 0.7), 1.0)
	elif tile == Tile.WORKBENCH:
		draw_rect(rect.grow(-3), Color("d59b55", 0.45), false, 1.0)
		draw_line(rect.position + Vector2(3, 6), rect.position + Vector2(13, 6), Color("3d2414", 0.75), 1.0)
	elif tile == Tile.FURNACE:
		draw_rect(Rect2(rect.position + Vector2(4, 5), Vector2(8, 7)), Color("ff7d3b", 0.75))
		draw_rect(rect.grow(-2), Color("b6c1c8", 0.35), false, 1.0)
	elif tile == Tile.ANVIL:
		draw_rect(Rect2(rect.position + Vector2(3, 5), Vector2(10, 4)), Color("a6b4c8", 0.8))
		draw_rect(Rect2(rect.position + Vector2(6, 9), Vector2(4, 4)), Color("2a3341", 0.8))
	elif tile == Tile.TURRET:
		draw_rect(Rect2(rect.position + Vector2(3, 6), Vector2(10, 5)), Color("bcd8dd", 0.75))
		draw_rect(Rect2(rect.position + Vector2(11, 7), Vector2(5, 2)), Color("e5fbff", 0.8))
	elif tile == Tile.CHEST:
		draw_rect(Rect2(rect.position + Vector2(2, 5), Vector2(12, 8)), Color("b98746"))
		draw_rect(Rect2(rect.position + Vector2(2, 4), Vector2(12, 3)), Color("d0a15c"))
		draw_rect(Rect2(rect.position + Vector2(7, 7), Vector2(2, 3)), Color("f2d47b"))
		draw_rect(Rect2(rect.position + Vector2(2, 11), Vector2(12, 2)), Color("6f4425"))
	elif tile == Tile.STONE_ALTAR:
		draw_rect(Rect2(rect.position + Vector2(3, 8), Vector2(10, 5)), Color("71675d"))
		draw_rect(Rect2(rect.position + Vector2(5, 4), Vector2(6, 5)), Color("94877b"))
		draw_rect(Rect2(rect.position + Vector2(7, 5), Vector2(2, 6)), Color("b7f3dc"))
	elif tile == Tile.STONEBLOOD:
		_draw_ore_specks(rect, Color("8df0d0"), Color("284b48"))
		draw_rect(rect.grow(-2), Color("6fb3a2", 0.18), false, 1.0)
	elif tile == Tile.MOSS:
		_draw_ore_specks(rect, Color("7dcc72"), Color("213d25"))
	elif tile == Tile.MUSHROOM_SOIL:
		_draw_ore_specks(rect, Color("d38acc"), Color("2c2034"))
	elif tile == Tile.GLOW_MUSHROOM:
		draw_rect(Rect2(rect.position + Vector2(6, 6), Vector2(4, 7)), Color("5aa086"))
		draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(10, 5)), Color("88ffd8"))
	elif tile == Tile.ASH_BRICK:
		draw_rect(rect.grow(-2), Color("c0a6c8", 0.25), false, 1.0)
		draw_line(rect.position + Vector2(1, 6), rect.position + Vector2(15, 6), Color("2a222e"), 1.0)
	elif tile == Tile.SUNKEN_STONE:
		_draw_ore_specks(rect, Color("7bc8d2"), Color("18343e"))
	elif tile == Tile.LAVA_ROOT:
		draw_line(rect.position + Vector2(2, 13), rect.position + Vector2(14, 3), Color("ff7d3b"), 2.0)
		draw_line(rect.position + Vector2(5, 15), rect.position + Vector2(13, 8), Color("5d2118"), 2.0)
	elif tile == Tile.GLASS_STONE:
		draw_line(rect.position + Vector2(3, 13), rect.position + Vector2(13, 3), Color("d8ffff", 0.65), 1.0)
		draw_rect(rect.grow(-2), Color("b8f4ff", 0.22), false, 1.0)
	elif tile == Tile.ABYSS_CRYSTAL:
		draw_rect(Rect2(rect.position + Vector2(6, 2), Vector2(4, 12)), Color("d8ffff"))
		draw_rect(Rect2(rect.position + Vector2(4, 6), Vector2(8, 5)), Color("7fc7ff", 0.75))
	elif tile == Tile.WATER:
		draw_rect(rect, Color("327d9b", 0.62))
		draw_line(rect.position + Vector2(1, 3), rect.position + Vector2(10, 3), Color("8ed9ee", 0.55), 1.0)
	elif tile == Tile.LAVA:
		draw_rect(rect, Color("e64b24", 0.92))
		draw_line(rect.position + Vector2(1, 4), rect.position + Vector2(13, 4), Color("ffd05b", 0.85), 2.0)
		draw_rect(Rect2(rect.position + Vector2(5, 10), Vector2(5, 2)), Color("ff8a32"))
	elif tile == Tile.SAPLING:
		draw_rect(Rect2(rect.position + Vector2(7, 7), Vector2(2, 8)), Color("6b4428"))
		draw_rect(Rect2(rect.position + Vector2(3, 4), Vector2(6, 5)), Color("63a75e"))
		draw_rect(Rect2(rect.position + Vector2(8, 2), Vector2(5, 6)), Color("7bc96e"))
	elif tile == Tile.TORCH:
		draw_rect(Rect2(rect.position + Vector2(7, 6), Vector2(2, 9)), Color("754425"))
		draw_rect(Rect2(rect.position + Vector2(6, 4), Vector2(4, 4)), Color("ff9f43"))
		draw_rect(Rect2(rect.position + Vector2(7, 2), Vector2(2, 4)), Color("ffe27a"))
		draw_rect(Rect2(rect.position + Vector2(8, 3), Vector2(1, 2)), Color("fff4b0"))


func _draw_ore_specks(rect: Rect2, bright: Color, dark: Color) -> void:
	draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(3, 3)), bright)
	draw_rect(Rect2(rect.position + Vector2(10, 5), Vector2(2, 2)), bright.lightened(0.15))
	draw_rect(Rect2(rect.position + Vector2(6, 11), Vector2(4, 2)), bright.darkened(0.05))
	draw_rect(Rect2(rect.position + Vector2(2, 10), Vector2(2, 2)), dark)
	draw_rect(rect.grow(-1), bright, false, 1.0)


func _draw_combat_entities() -> void:
	for projectile in projectiles:
		var pos: Vector2 = projectile["pos"]
		var color: Color = projectile.get("color", Color.WHITE)
		var kind := str(projectile.get("kind", "bolt"))
		var radius := 2.0
		if kind == "cannon":
			radius = 3.0
		elif kind == "acid":
			radius = 3.5
		draw_circle(pos, radius, color)
		draw_circle(pos - (projectile["vel"] as Vector2).normalized() * 4.0, maxf(1.0, radius - 1.0), color.darkened(0.35))
	for corpse in dying_enemies:
		_draw_dying_enemy(corpse)
	for projectile in enemy_projectiles:
		var projectile_pos: Vector2 = projectile["pos"]
		var projectile_color: Color = projectile.get("color", Color.WHITE)
		if str(projectile.get("special", "")) == "wild_ichor" and _draw_wild_ichor_projectile(projectile):
			pass
		elif str(projectile.get("special", "")) == "cave_husk_rock" and _draw_cave_husk_rock_projectile(projectile):
			pass
		elif str(projectile.get("special", "")) == "mushroom_poison" and _draw_enemy_pack_projectile(projectile, "mushroom_beetle", "poison_projectile", 0.50):
			pass
		elif str(projectile.get("special", "")) == "ash_phantom_ember" and _draw_enemy_pack_projectile(projectile, "ash_phantom", "ember_projectile", 0.50):
			pass
		elif str(projectile.get("special", "")) == "ash_wisp_ember" and _draw_enemy_pack_projectile(projectile, "ash_wisp", "ember_projectile", 0.44):
			pass
		elif str(projectile.get("special", "")) == "sentinel_ash" and _draw_enemy_pack_projectile(projectile, "ash_sentinel", "sentinel_projectile", 0.50):
			pass
		elif str(projectile.get("special", "")) == "drowned_harpoon" and _draw_enemy_pack_projectile(projectile, "drowned_guard", "harpoon_projectile", 0.50):
			pass
		elif str(projectile.get("special", "")) == "drowned_wave" and _draw_enemy_pack_projectile(projectile, "drowned_guard", "wave_projectile", 0.50):
			pass
		elif str(projectile.get("special", "")) == "ember_seed" and _draw_enemy_pack_projectile(projectile, "ember_rootling", "ember_seed", 0.50):
			pass
		elif str(projectile.get("special", "")) == "glass_shard" and _draw_enemy_pack_projectile(projectile, "glass_wraith", "shard_projectile", 0.50):
			pass
		elif str(projectile.get("special", "")) == "night_fire" and _draw_enemy_pack_projectile(projectile, "night_ember", "fire_projectile", 0.44):
			pass
		elif str(projectile.get("special", "")) == "ruin_bolt" and _draw_enemy_pack_projectile(projectile, "ruin_drone", "drone_bolt", 0.50):
			pass
		elif str(projectile.get("special", "")) == "stone_falling_rock" and _draw_enemy_pack_projectile(projectile, "stone_beast", "falling_rock", 0.72):
			pass
		elif str(projectile.get("special", "")) == "archive_memory" and _draw_enemy_pack_projectile(projectile, "archive_warden", "memory_projectile", 0.70):
			pass
		else:
			draw_circle(projectile_pos, 3.0, projectile_color)
			draw_circle(projectile_pos - (projectile["vel"] as Vector2).normalized() * 4.0, 1.5, projectile_color.darkened(0.35))
	for effect in enemy_impact_effects:
		_draw_enemy_impact(effect)
	for enemy in enemies:
		_draw_enemy(enemy)


func _draw_perception_debug() -> void:
	if not perception_debug_enabled:
		return
	for noise in perception_noise_events:
		var event: Dictionary = noise
		var noise_pos: Vector2 = event.get("pos", Vector2.ZERO)
		var radius := float(event.get("radius", 0.0))
		var life_ratio := clampf(float(event.get("life", 0.0)) / maxf(0.01, float(event.get("max_life", NOISE_EVENT_LIFETIME))), 0.0, 1.0)
		draw_arc(noise_pos, radius, 0.0, TAU, 48, Color(0.35, 0.75, 1.0, 0.22 + life_ratio * 0.42), 1.5)
		if ui_font != null:
			draw_string(ui_font, noise_pos + Vector2(-radius, -5.0), str(event.get("kind", "noise")), HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, 9, Color(0.55, 0.85, 1.0, 0.9))
	for enemy in enemies:
		var data: Dictionary = enemy
		if bool(data.get("burrow_hidden", false)):
			continue
		var pos: Vector2 = data.get("pos", Vector2.ZERO)
		var enemy_type := str(data.get("type", ""))
		var profile := _enemy_perception_profile(enemy_type)
		var state := str(data.get("perception_state", PERCEPTION_CALM))
		var color := Color("8aa0aa")
		if state == PERCEPTION_SUSPICIOUS:
			color = Color("f2d36b")
		elif state == PERCEPTION_INVESTIGATE:
			color = Color("e9a75f")
		elif state == PERCEPTION_COMBAT:
			color = Color("f05b61")
		elif state == PERCEPTION_SEARCH:
			color = Color("c18cff")
		elif state == PERCEPTION_RETURN:
			color = Color("77b8d4")
		var vision_range := float(data.get("debug_vision_range", profile.get("vision_range", 165.0)))
		var half_angle := deg_to_rad(float(profile.get("vision_angle", 120.0)) * 0.5)
		var center_angle := 0.0 if int(data.get("facing", 1)) >= 0 else PI
		draw_arc(pos, vision_range, center_angle - half_angle, center_angle + half_angle, 32, Color(color, 0.42), 1.0)
		draw_line(pos, pos + Vector2.RIGHT.rotated(center_angle - half_angle) * vision_range, Color(color, 0.28), 1.0)
		draw_line(pos, pos + Vector2.RIGHT.rotated(center_angle + half_angle) * vision_range, Color(color, 0.28), 1.0)
		var last_known: Vector2 = data.get("last_known_pos", pos)
		if state in [PERCEPTION_INVESTIGATE, PERCEPTION_COMBAT, PERCEPTION_SEARCH]:
			draw_line(pos, last_known, Color(color, 0.45), 1.0)
			draw_circle(last_known, 3.0, Color(color, 0.80))
		if ui_font != null:
			var suspicion_percent := int(round(float(data.get("suspicion", 0.0)) * 100.0))
			var light_percent := int(round(float(data.get("debug_player_light", 0.0)) * 100.0))
			var label := "%s  S:%d%% L:%d%%" % [state, suspicion_percent, light_percent]
			draw_string(ui_font, pos + Vector2(-62.0, -34.0), label, HORIZONTAL_ALIGNMENT_CENTER, 124.0, 9, color)


func _draw_dying_enemy(corpse: Dictionary) -> void:
	var pos: Vector2 = corpse["pos"]
	var size: Vector2 = corpse["size"]
	var total := maxf(0.01, float(corpse.get("death_total", 0.35)))
	var ratio := clampf(float(corpse.get("death_time", 0.0)) / total, 0.0, 1.0)
	var enemy_type := str(corpse.get("type", "wild_slime"))
	var visual_type := _enemy_visual_type(corpse)
	if enemy_textures.has(visual_type) or enemy_animation_textures.has(visual_type):
		var death_sets: Dictionary = enemy_animation_textures.get(visual_type, {})
		var death_state := "death"
		if enemy_type == "bat":
			death_state = "death_impact" if str(corpse.get("death_phase", "fall")) == "impact" else "death_fall"
		var texture: Texture2D = death_sets.get(death_state, death_sets.get("death", enemy_textures[visual_type])) as Texture2D
		var is_strip := death_sets.has(death_state) or death_sets.has("death")
		var death_spec := _enemy_animation_spec(visual_type, death_state)
		if death_spec.is_empty():
			death_spec = _enemy_animation_spec(visual_type, "death")
		var frame_count := int(death_spec.get("frames", 6)) if is_strip else 4
		var frame_width := maxi(1, int(texture.get_width() / frame_count))
		var frame_height := texture.get_height() if is_strip else maxi(1, int(texture.get_height() / 3))
		var frame_index := mini(frame_count - 1, int(floor((1.0 - ratio) * float(frame_count))))
		if enemy_type in ["bat", "spore_bat"]:
			var death_fps := maxf(1.0, float(death_spec.get("fps", 12.0)))
			frame_index = mini(frame_count - 1, int(floor(float(corpse.get("death_anim_time", 0.0)) * death_fps)))
		var scale := _enemy_sprite_scale(visual_type)
		var draw_size := Vector2(frame_width, frame_height) * scale
		var death_anchor := _enemy_animation_anchor(visual_type, Vector2(frame_width, frame_height))
		var local_x := -death_anchor.x * scale if is_strip else -draw_size.x * 0.5
		var ground_anchor := float(enemy_sprite_ground_anchors.get(visual_type, frame_height))
		var local_y := size.y * 0.5 - ground_anchor * scale - _enemy_animation_ground_clearance(visual_type)
		var fade := Color(1.0, 1.0, 1.0, clampf(ratio * 4.0, 0.0, 1.0))
		if enemy_type == "bat":
			if death_state == "death_fall":
				local_y = -draw_size.y * 0.5
				fade = Color.WHITE
			else:
				local_y = size.y * 0.5 - float(frame_height) * scale
				var impact_total := maxf(0.01, _enemy_animation_duration("bat", "death_impact", 0.50))
				fade = Color(1.0, 1.0, 1.0, clampf(float(corpse.get("death_time", 0.0)) / impact_total * 4.0, 0.0, 1.0))
		elif enemy_type == "spore_bat":
			if str(corpse.get("death_phase", "fall")) == "fall":
				local_y = -draw_size.y * 0.5
				fade = Color.WHITE
			else:
				local_y = size.y * 0.5 - float(frame_height) * scale
				var spore_impact_total := maxf(0.01, _enemy_animation_duration("spore_bat", "death_impact", 0.60))
				fade = Color(1.0, 1.0, 1.0, clampf(float(corpse.get("death_time", 0.0)) / spore_impact_total * 4.0, 0.0, 1.0))
		var facing := int(corpse.get("facing", 1))
		draw_set_transform(pos, 0.0, Vector2(float(facing), 1.0))
		draw_texture_rect_region(texture, Rect2(Vector2(local_x, local_y), draw_size), Rect2(frame_index * frame_width, 0, frame_width, frame_height), fade)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_enemy(enemy: Dictionary) -> void:
	if bool(enemy.get("burrow_hidden", false)):
		return
	var pos: Vector2 = enemy["pos"]
	var size: Vector2 = enemy["size"]
	var color: Color = enemy.get("color", Color("ffffff"))
	if float(enemy.get("hit_timer", 0.0)) > 0.0:
		color = Color("fff0d0")
	var rect := Rect2(pos - size * 0.5, size)
	var hitbox_rect := _enemy_hitbox_rect(enemy)
	var enemy_type := str(enemy.get("type", "wild_slime"))
	var visual_type := _enemy_visual_type(enemy)
	var has_sprite := _draw_enemy_sprite(enemy, visual_type, pos, size)
	if has_sprite and enemy_type == "cave_husk" and str(enemy.get("anim_state", "")) == "attack_1":
		_draw_enemy_overlay_animation(enemy, enemy_type, "reach_vfx", pos)
	if has_sprite:
		pass
	elif enemy_type == "stone_beast":
		draw_rect(Rect2(rect.position + Vector2(3, 10), Vector2(size.x - 6, size.y - 12)), color)
		draw_rect(Rect2(rect.position + Vector2(9, 2), Vector2(size.x - 18, 13)), color.lightened(0.12))
		draw_rect(Rect2(rect.position + Vector2(13, 12), Vector2(5, 5)), Color("b7f3dc"))
		draw_rect(Rect2(rect.position + Vector2(size.x - 18, 12), Vector2(5, 5)), Color("b7f3dc"))
		draw_rect(Rect2(rect.position + Vector2(8, size.y - 6), Vector2(size.x - 16, 4)), Color("4d4640"))
	elif enemy_type == "heartwood_boss":
		draw_rect(Rect2(rect.position + Vector2(8, 0), Vector2(size.x - 16, size.y)), color.darkened(0.18))
		draw_rect(Rect2(rect.position + Vector2(4, 8), Vector2(size.x - 8, size.y - 12)), color)
		draw_rect(Rect2(rect.position + Vector2(13, 13), Vector2(5, 5)), Color("f5cf7b"))
		draw_rect(Rect2(rect.position + Vector2(size.x - 18, 13), Vector2(5, 5)), Color("f5cf7b"))
		draw_rect(Rect2(rect.position + Vector2(10, size.y - 8), Vector2(size.x - 20, 5)), Color("5c3825"))
	elif enemy_type == "bat":
		draw_line(pos + Vector2(-10, 0), pos + Vector2(-2, -4), color.lightened(0.1), 3.0)
		draw_line(pos + Vector2(2, -4), pos + Vector2(10, 0), color.lightened(0.1), 3.0)
		draw_rect(Rect2(pos + Vector2(-4, -3), Vector2(8, 7)), color)
	elif enemy_type == "ruin_drone":
		draw_rect(Rect2(pos - Vector2(7, 7), Vector2(14, 14)), color)
		draw_rect(Rect2(pos - Vector2(3, 3), Vector2(6, 6)), Color("cfe9ff"))
		draw_line(pos + Vector2(-10, 0), pos + Vector2(-7, 0), color.lightened(0.25), 2.0)
		draw_line(pos + Vector2(7, 0), pos + Vector2(10, 0), color.lightened(0.25), 2.0)
	elif bool(enemy.get("flying", false)):
		draw_circle(pos, size.x * 0.45, color)
		draw_circle(pos + Vector2(-4, -2), 2.0, Color("fff6d4"))
		draw_circle(pos + Vector2(4, -2), 2.0, Color("fff6d4"))
		draw_rect(Rect2(pos + Vector2(-8, 4), Vector2(16, 2)), color.darkened(0.35))
	elif enemy_type == "cave_worm":
		draw_rect(Rect2(rect.position + Vector2(1, 3), Vector2(size.x - 2, size.y - 4)), color)
		for x in range(5, int(size.x) - 3, 6):
			draw_rect(Rect2(rect.position + Vector2(x, 4), Vector2(2, size.y - 6)), color.darkened(0.28))
	elif enemy_type == "mushroom_beetle":
		draw_rect(Rect2(rect.position + Vector2(2, 5), Vector2(size.x - 4, size.y - 5)), color)
		draw_rect(Rect2(rect.position + Vector2(5, 1), Vector2(size.x - 10, 7)), Color("d06a7e"))
		draw_rect(Rect2(rect.position + Vector2(8, 3), Vector2(2, 2)), Color("fff3c0"))
	elif enemy_type == "root_crawler":
		draw_rect(Rect2(rect.position + Vector2(2, 4), Vector2(size.x - 4, size.y - 4)), color)
		draw_line(rect.position + Vector2(2, 4), rect.position + Vector2(size.x - 2, 2), color.lightened(0.2), 2.0)
	elif enemy_type == "cave_husk":
		draw_rect(rect.grow(-2), color)
		draw_rect(Rect2(rect.position + Vector2(3, 2), Vector2(size.x - 6, 5)), color.lightened(0.18))
		draw_rect(Rect2(rect.position + Vector2(5, 8), Vector2(2, 2)), Color("ffdc8a"))
		draw_rect(Rect2(rect.position + Vector2(size.x - 7, 8), Vector2(2, 2)), Color("ffdc8a"))
	else:
		draw_rect(Rect2(rect.position + Vector2(2, 4), Vector2(size.x - 4, size.y - 4)), color)
		draw_rect(Rect2(rect.position + Vector2(4, 1), Vector2(size.x - 8, 5)), color.lightened(0.18))
		draw_rect(Rect2(rect.position + Vector2(5, 5), Vector2(2, 2)), Color("13331f"))
		draw_rect(Rect2(rect.position + Vector2(size.x - 7, 5), Vector2(2, 2)), Color("13331f"))
	var hp := maxf(0.0, float(enemy.get("hp", 1)) / float(enemy.get("max_hp", 1)))
	var visual_height := _enemy_visual_size(visual_type).y
	var bar_y := pos.y - maxf(size.y * 0.5 + 6.0, visual_height * 0.5 + 5.0)
	var bar_pos := Vector2(hitbox_rect.position.x, bar_y)
	draw_rect(Rect2(bar_pos, Vector2(hitbox_rect.size.x, 3)), Color("1a1012", 0.9))
	draw_rect(Rect2(bar_pos, Vector2(hitbox_rect.size.x * hp, 3)), Color("d94b52"))
	var statuses: Dictionary = enemy.get("statuses", {})
	var status_x := bar_pos.x
	for status in statuses.keys():
		var status_color := Color("89e36b") if str(status) == "poison" else (Color("ff8a3c") if str(status) == "burn" else Color("9fc5ff"))
		draw_rect(Rect2(Vector2(status_x, bar_pos.y - 4), Vector2(4, 3)), status_color)
		status_x += 5.0


func _draw_enemy_sprite(enemy: Dictionary, enemy_type: String, pos: Vector2, collision_size: Vector2) -> bool:
	# A creature can be drawn either from a single sheet in the enemies folder
	# or purely from an animation pack. Requiring the sheet meant a pack-only
	# creature silently fell back to the placeholder blob.
	if not enemy_textures.has(enemy_type) and not enemy_animation_textures.has(enemy_type):
		return false
	var requested_animation_state := str(enemy.get("anim_state", "idle"))
	var animation_state := _enemy_animation_visual_state(enemy_type, requested_animation_state)
	var animation_sets: Dictionary = enemy_animation_textures.get(enemy_type, {})
	var texture: Texture2D = animation_sets.get(animation_state, null)
	var use_action_strip := texture != null
	var animation_spec := _enemy_animation_spec(enemy_type, animation_state)
	if texture == null:
		# A pack-only creature has no single sheet to fall back to, so the idle
		# strip stands in for any state the pack does not define.
		var sheet_texture: Texture2D = enemy_textures.get(enemy_type, null) as Texture2D
		if animation_state.begins_with("attack_") and sheet_texture != null:
			texture = sheet_texture
			animation_spec = {}
			use_action_strip = false
		else:
			texture = animation_sets.get("idle", sheet_texture) as Texture2D
			animation_spec = _enemy_animation_spec(enemy_type, "idle")
			use_action_strip = animation_sets.has("idle")
		if texture == null:
			return false
	var frame_count := int(animation_spec.get("frames", 6)) if use_action_strip else 4
	var frame_width := maxi(1, int(texture.get_width() / frame_count))
	var frame_height := texture.get_height() if use_action_strip else maxi(1, int(texture.get_height() / 3))
	var source_y := 0
	if not use_action_strip:
		if animation_state == "move":
			source_y = frame_height
		elif animation_state.begins_with("attack_"):
			source_y = frame_height * 2
	var frame_index := 0
	var anim_time := float(enemy.get("anim_time", 0.0))
	if use_action_strip and not animation_spec.is_empty():
		var fps := maxf(1.0, float(animation_spec.get("fps", 8.0)))
		var raw_frame := int(floor(anim_time * fps))
		frame_index = raw_frame % frame_count if bool(animation_spec.get("loop", false)) else mini(frame_count - 1, raw_frame)
	elif animation_state.begins_with("attack_"):
		frame_index = mini(frame_count - 1, int(floor(anim_time * 10.0)))
		if float(enemy.get("attack_flash", 0.0)) > 0.0:
			frame_index = frame_count - 1
	elif animation_state == "hurt":
		frame_index = mini(frame_count - 1, int(floor(anim_time * 14.0)))
	elif animation_state == "move":
		frame_index = int(floor(anim_time * 8.0)) % frame_count
	else:
		frame_index = int(floor(anim_time * 3.5)) % frame_count
	var source_rect := Rect2(frame_index * frame_width, source_y, frame_width, frame_height)
	var flying := bool(enemy.get("flying", false))
	var scale := _enemy_sprite_scale(enemy_type)
	var draw_size := Vector2(frame_width, frame_height) * scale
	var animation_anchor := _enemy_animation_anchor(enemy_type, Vector2(frame_width, frame_height))
	var local_x := -animation_anchor.x * scale if use_action_strip else -draw_size.x * 0.5
	var ground_anchor := float(enemy_sprite_ground_anchors.get(enemy_type, frame_height))
	var local_y := -draw_size.y * 0.5 if flying else collision_size.y * 0.5 - ground_anchor * scale - _enemy_animation_ground_clearance(enemy_type)
	var facing := int(enemy.get("facing", 1))
	var flip_scale := Vector2(-1.0, 1.0) if facing < 0 else Vector2.ONE
	var modulate := Color.WHITE
	if float(enemy.get("hit_timer", 0.0)) > 0.0:
		modulate = Color("fff0d0")
	draw_set_transform(pos, 0.0, flip_scale)
	draw_texture_rect_region(texture, Rect2(Vector2(local_x, local_y), draw_size), source_rect, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true


func _draw_wild_ichor_projectile(projectile: Dictionary) -> bool:
	var animation_sets: Dictionary = enemy_animation_textures.get("wild_slime", {})
	var texture: Texture2D = animation_sets.get("ichor_projectile", null)
	var spec := _enemy_animation_spec("wild_slime", "ichor_projectile")
	if texture == null or spec.is_empty():
		return false
	var frame_count := maxi(1, int(spec.get("frames", 1)))
	var fps := maxf(1.0, float(spec.get("fps", 14.0)))
	var frame_index := int(floor(float(projectile.get("anim_time", 0.0)) * fps)) % frame_count
	var frame_width := maxi(1, int(texture.get_width() / frame_count))
	var frame_height := texture.get_height()
	var draw_size := Vector2(frame_width, frame_height) * 0.32
	var velocity: Vector2 = projectile.get("vel", Vector2.LEFT)
	var rotation := velocity.angle() - PI
	draw_set_transform(projectile["pos"], rotation, Vector2.ONE)
	draw_texture_rect_region(texture, Rect2(-draw_size * 0.5, draw_size), Rect2(frame_index * frame_width, 0, frame_width, frame_height))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true


func _draw_cave_husk_rock_projectile(projectile: Dictionary) -> bool:
	var animation_sets: Dictionary = enemy_animation_textures.get("cave_husk", {})
	var texture: Texture2D = animation_sets.get("rock_projectile", null)
	var spec := _enemy_animation_spec("cave_husk", "rock_projectile")
	if texture == null or spec.is_empty():
		return false
	var frame_count := maxi(1, int(spec.get("frames", 1)))
	var fps := maxf(1.0, float(spec.get("fps", 12.0)))
	var frame_index := int(floor(float(projectile.get("anim_time", 0.0)) * fps)) % frame_count
	var frame_width := maxi(1, int(texture.get_width() / frame_count))
	var frame_height := texture.get_height()
	var draw_size := Vector2(frame_width, frame_height) * 0.50
	var velocity: Vector2 = projectile.get("vel", Vector2.RIGHT)
	var facing_scale := Vector2(1.0 if velocity.x >= 0.0 else -1.0, 1.0)
	draw_set_transform(projectile["pos"], 0.0, facing_scale)
	draw_texture_rect_region(texture, Rect2(-draw_size * 0.5, draw_size), Rect2(frame_index * frame_width, 0, frame_width, frame_height))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true


func _draw_enemy_pack_projectile(projectile: Dictionary, enemy_type: String, state: String, scale: float) -> bool:
	var animation_sets: Dictionary = enemy_animation_textures.get(enemy_type, {})
	var texture: Texture2D = animation_sets.get(state, null)
	var spec := _enemy_animation_spec(enemy_type, state)
	if texture == null or spec.is_empty():
		return false
	var frame_count := maxi(1, int(spec.get("frames", 1)))
	var fps := maxf(1.0, float(spec.get("fps", 14.0)))
	var frame_index := int(floor(float(projectile.get("anim_time", 0.0)) * fps)) % frame_count
	var frame_width := maxi(1, int(texture.get_width() / frame_count))
	var frame_height := texture.get_height()
	var draw_size := Vector2(frame_width, frame_height) * scale
	var velocity: Vector2 = projectile.get("vel", Vector2.RIGHT)
	var facing_scale := Vector2(1.0 if velocity.x >= 0.0 else -1.0, 1.0)
	var anchor := _enemy_animation_state_anchor(enemy_type, state, Vector2(frame_width, frame_height))
	draw_set_transform(projectile["pos"], 0.0, facing_scale)
	draw_texture_rect_region(texture, Rect2(-anchor * scale, draw_size), Rect2(frame_index * frame_width, 0, frame_width, frame_height))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true


func _draw_enemy_overlay_animation(enemy: Dictionary, enemy_type: String, state: String, pos: Vector2) -> void:
	var animation_sets: Dictionary = enemy_animation_textures.get(enemy_type, {})
	var texture: Texture2D = animation_sets.get(state, null)
	var spec := _enemy_animation_spec(enemy_type, state)
	if texture == null or spec.is_empty():
		return
	var frame_count := maxi(1, int(spec.get("frames", 1)))
	var fps := maxf(1.0, float(spec.get("fps", 8.0)))
	var frame_index := mini(frame_count - 1, int(floor(float(enemy.get("anim_time", 0.0)) * fps)))
	var frame_width := maxi(1, int(texture.get_width() / frame_count))
	var frame_height := texture.get_height()
	var scale := _enemy_sprite_scale(enemy_type)
	var frame_size := Vector2(frame_width, frame_height)
	var draw_size := frame_size * scale
	var anchor := _enemy_animation_anchor(enemy_type, frame_size)
	var facing_scale := Vector2(float(int(enemy.get("facing", 1))), 1.0)
	draw_set_transform(pos, 0.0, facing_scale)
	draw_texture_rect_region(texture, Rect2(-anchor * scale, draw_size), Rect2(frame_index * frame_width, 0, frame_width, frame_height))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_enemy_impact(effect: Dictionary) -> void:
	var enemy_type := str(effect.get("enemy_type", "wild_slime"))
	var state := str(effect.get("state", ""))
	var animation_sets: Dictionary = enemy_animation_textures.get(enemy_type, {})
	var texture: Texture2D = animation_sets.get(state, null)
	var spec := _enemy_animation_spec(enemy_type, state)
	if texture == null or spec.is_empty():
		return
	var frame_count := maxi(1, int(spec.get("frames", 1)))
	var fps := maxf(1.0, float(spec.get("fps", 14.0)))
	var frame_index := mini(frame_count - 1, int(floor(float(effect.get("time", 0.0)) * fps)))
	var frame_width := maxi(1, int(texture.get_width() / frame_count))
	var frame_height := texture.get_height()
	var effect_scale := float(effect.get("scale", 0.34))
	var frame_size := Vector2(frame_width, frame_height)
	var draw_size := frame_size * effect_scale
	var anchor := _enemy_animation_state_anchor(enemy_type, state, frame_size) if bool(effect.get("use_pack_anchor", false)) else frame_size * 0.5
	var facing_scale := Vector2(float(int(effect.get("facing", 1))), 1.0)
	draw_set_transform(effect["pos"], 0.0, facing_scale)
	draw_texture_rect_region(texture, Rect2(-anchor * effect_scale, draw_size), Rect2(frame_index * frame_width, 0, frame_width, frame_height))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _enemy_sprite_scale(enemy_type: String) -> float:
	if enemy_type == "stone_beast" or enemy_type == "heartwood_boss":
		return 0.72
	if enemy_type == "archive_warden":
		return 0.64
	if enemy_type in ["bat", "spore_bat", "ash_wisp", "night_ember", "frost_bat"]:
		return 0.44
	if enemy_type == "root_crawler":
		return 0.48
	if enemy_type == "cave_worm":
		return 0.56
	return 0.50


func _enemy_visual_size(enemy_type: String) -> Vector2:
	if not enemy_textures.has(enemy_type) and not enemy_animation_textures.has(enemy_type):
		return Vector2(24, 24)
	var animation_sets: Dictionary = enemy_animation_textures.get(enemy_type, {})
	var idle_texture: Texture2D = animation_sets.get("idle", null)
	var idle_spec := _enemy_animation_spec(enemy_type, "idle")
	if idle_texture != null and not idle_spec.is_empty():
		var frame_count := maxi(1, int(idle_spec.get("frames", 1)))
		return Vector2(float(idle_texture.get_width()) / float(frame_count), float(idle_texture.get_height())) * _enemy_sprite_scale(enemy_type)
	if not enemy_textures.has(enemy_type):
		return Vector2(24, 24)
	var texture: Texture2D = enemy_textures[enemy_type]
	return Vector2(float(texture.get_width()) / 4.0, float(texture.get_height()) / 3.0) * _enemy_sprite_scale(enemy_type)

func _draw_world_loot_and_fx() -> void:
	for item in dropped_items:
		_draw_dropped_item(item)
	for particle in hit_particles:
		var particle_life := clampf(float(particle.get("life", 0.0)) / 0.48, 0.0, 1.0)
		var color: Color = particle.get("color", Color.WHITE)
		color.a = particle_life
		var pos: Vector2 = particle["pos"]
		draw_rect(Rect2(pos - Vector2(1, 1), Vector2(2, 2)), color)
	for number in damage_numbers:
		if ui_font == null:
			continue
		var number_life := clampf(float(number.get("life", 0.0)) / 0.75, 0.0, 1.0)
		var color: Color = number.get("color", Color.WHITE)
		color.a = number_life
		var pos: Vector2 = number["pos"]
		draw_string(ui_font, pos, str(number.get("text", "")), HORIZONTAL_ALIGNMENT_CENTER, 40.0, 12, color)


func _draw_dropped_item(item: Dictionary) -> void:
	var pos: Vector2 = item["pos"]
	var age := float(item.get("age", 0.0))
	var bob := sin(age * 7.0 + float(item.get("bob", 0.0))) * 2.0
	var draw_pos := pos + Vector2(0, bob)
	var to_player := player_position - pos
	var magnet := clampf(1.0 - to_player.length() / LOOT_MAGNET_RADIUS, 0.0, 1.0)
	draw_rect(Rect2(pos + Vector2(-7, 6), Vector2(14, 3)), Color("05070a", 0.22))
	if magnet > 0.0 and float(item.get("pickup_delay", 0.0)) <= 0.0:
		draw_line(pos, pos + to_player.normalized() * 10.0, Color("f5d978", 0.25 + magnet * 0.35), 1.0)
	var item_id := str(item.get("id", ""))
	var icon := _item_icon(item_id)
	var icon_size := 18.0 + sin(age * 10.0) * 0.8
	var icon_rect := Rect2(draw_pos - Vector2(icon_size, icon_size) * 0.5, Vector2(icon_size, icon_size))
	if icon != null:
		draw_texture_rect(icon, icon_rect, false, Color(1, 1, 1, 1))
	else:
		draw_rect(icon_rect.grow(-4), _item_icon_color(item_id))
	var amount := int(item.get("amount", 1))
	if amount > 1 and ui_font != null:
		draw_string(ui_font, draw_pos + Vector2(6, 9), str(amount), HORIZONTAL_ALIGNMENT_LEFT, 28.0, 9, Color("fff1b8"))


func _light_at_tile(x: int, y: int, ignore_player := false) -> float:
	var light := 0.02
	if x >= 0 and x < surface_heights.size() and y <= surface_heights[x] + 2:
		light = maxf(light, _daylight_factor())
	var sample_pos := Vector2(x + 0.5, y + 0.5)
	for source in visible_light_sources:
		if ignore_player and str(source.get("kind", "")) == "player":
			continue
		var source_pos: Vector2 = source["pos"]
		var radius := float(source["radius"])
		var distance := sample_pos.distance_to(source_pos)
		if distance >= radius:
			continue
		var falloff := 1.0 - distance / radius
		var source_light := float(source.get("intensity", 1.0)) * falloff * falloff
		light = maxf(light, source_light)
	return clampf(light, 0.02, 1.0)


func _draw_darkness_overlay() -> void:
	# A single smooth overlay avoids visible seams between tile-sized dark rectangles.
	var view_rect := get_viewport_rect()
	var center := camera.get_screen_center_position()
	var half_size := view_rect.size * 0.5 / camera.zoom
	var player_tile_x := clampi(floori(player_position.x / TILE_SIZE), 0, WORLD_WIDTH - 1)
	var player_tile_y := clampi(floori(player_position.y / TILE_SIZE), 0, WORLD_HEIGHT - 1)
	var underground := player_tile_y > surface_heights[player_tile_x] + 2
	var darkness := (1.0 - _daylight_factor()) * 0.48
	if underground:
		darkness = maxf(darkness, 0.56)
	var world_rect := Rect2(center - half_size - Vector2(2, 2), view_rect.size / camera.zoom + Vector2(4, 4))
	if darkness > 0.01:
		draw_rect(world_rect, Color(0.008, 0.012, 0.02, darkness))
	# Soft light pools retain depth in caves without drawing a grid.
	if underground or darkness > 0.22:
		draw_circle(player_position, 112.0, Color("476756", 0.05))
		draw_circle(player_position, 70.0, Color("6e9679", 0.08))
		draw_circle(player_position, 32.0, Color("a7cf9d", 0.10))
	for source in visible_light_sources:
		var source_pos: Vector2 = (source["pos"] as Vector2) * TILE_SIZE
		var radius := float(source.get("radius", 0.0)) * TILE_SIZE
		var kind := str(source.get("kind", ""))
		if radius <= 0.0 or kind == "player":
			continue
		if kind == "torch":
			draw_circle(source_pos, radius * 0.62, Color("ffbd68", 0.05))
		elif kind == "lava":
			draw_circle(source_pos, radius * 0.45, Color("e84c2a", 0.018))
		elif kind == "mushroom":
			draw_circle(source_pos, radius * 0.55, Color("79c99a", 0.035))
		elif kind == "crystal":
			draw_circle(source_pos, radius * 0.52, Color("86d9f4", 0.032))


func _draw_player() -> void:
	if _draw_player_sprite():
		return
	var rect := Rect2(player_position - PLAYER_SIZE * 0.5, PLAYER_SIZE)
	var skin := Color("d9b47f")
	var skin_shadow := Color("9e744e")
	var hair := Color("2d2530")
	var tunic := Color("7d4b5c")
	var tunic_dark := Color("4a2f44")
	var boot := Color("2b2530")
	var boot_dark := Color("17141b")
	var metal := Color("c6b889")
	var moving := absf(player_velocity.x) > 5.0 and player_on_floor
	var jumping := not player_on_floor and player_velocity.y < -20.0
	var falling := not player_on_floor and player_velocity.y >= -20.0
	var time := float(Time.get_ticks_msec()) / 1000.0
	var walk_wave := sin(time * 13.0)
	var walk_switch := 1 if walk_wave >= 0.0 else -1
	var idle_bob := 1.0 if player_on_floor and not moving and sin(time * 3.0) > 0.65 else 0.0
	var base := rect.position + Vector2(0, idle_bob)

	var head_pos := base + Vector2(3, 1)
	if jumping:
		head_pos.y -= 1.0
	draw_rect(Rect2(head_pos + Vector2(1, 0), Vector2(6, 2)), hair)
	draw_rect(Rect2(head_pos, Vector2(8, 7)), skin)
	draw_rect(Rect2(head_pos + Vector2(0, 0), Vector2(8, 2)), hair)
	draw_rect(Rect2(head_pos + Vector2(0, 2), Vector2(2, 3)), hair)
	draw_rect(Rect2(head_pos + Vector2(6, 3), Vector2(1, 2)), skin_shadow)
	var eye_x := head_pos.x + (5 if facing > 0 else 2)
	draw_rect(Rect2(eye_x, head_pos.y + 3, 1, 1), Color("f7edd0"))

	var body_pos := base + Vector2(2, 9)
	if moving:
		body_pos.y += 1.0 if walk_switch > 0 else 0.0
	elif jumping:
		body_pos.y -= 1.0
	draw_rect(Rect2(body_pos, Vector2(8, 10)), tunic_dark)
	draw_rect(Rect2(body_pos + Vector2(1, 0), Vector2(6, 9)), tunic)
	draw_rect(Rect2(body_pos + Vector2(3, 1), Vector2(2, 7)), Color("b57263"))
	draw_rect(Rect2(body_pos + Vector2(1, 8), Vector2(6, 2)), Color("3c2738"))

	var arm_y := body_pos.y + 2
	var front_arm_swing := 0
	var back_arm_swing := 0
	if moving:
		front_arm_swing = -walk_switch
		back_arm_swing = walk_switch
	elif jumping:
		front_arm_swing = -2
		back_arm_swing = -1
	elif falling:
		front_arm_swing = -1
		back_arm_swing = 1
	if facing > 0:
		draw_rect(Rect2(body_pos.x - 1, arm_y + back_arm_swing, 2, 7), skin_shadow)
		draw_rect(Rect2(body_pos.x + 8, arm_y + front_arm_swing, 2, 7), skin)
		draw_rect(Rect2(body_pos.x + 9, arm_y + 5 + front_arm_swing, 4, 2), metal)
	else:
		draw_rect(Rect2(body_pos.x + 8, arm_y + back_arm_swing, 2, 7), skin_shadow)
		draw_rect(Rect2(body_pos.x - 1, arm_y + front_arm_swing, 2, 7), skin)
		draw_rect(Rect2(body_pos.x - 5, arm_y + 5 + front_arm_swing, 4, 2), metal)

	var leg_y := base.y + 20
	var left_leg := Vector2(base.x + 3, leg_y)
	var right_leg := Vector2(base.x + 7, leg_y)
	var left_len := 6
	var right_len := 6
	var left_foot_x := -1
	var right_foot_x := 0
	if moving:
		left_len = 7 if walk_switch > 0 else 5
		right_len = 5 if walk_switch > 0 else 7
		left_foot_x = -2 if walk_switch > 0 else 0
		right_foot_x = 1 if walk_switch > 0 else -1
	elif jumping:
		left_len = 4
		right_len = 5
		left_foot_x = -1
		right_foot_x = 1
	elif falling:
		left_len = 7
		right_len = 7
		left_foot_x = 0
		right_foot_x = 0
	draw_rect(Rect2(left_leg, Vector2(3, left_len)), boot)
	draw_rect(Rect2(right_leg, Vector2(3, right_len)), boot)
	draw_rect(Rect2(left_leg + Vector2(left_foot_x, left_len), Vector2(4, 2)), boot_dark)
	draw_rect(Rect2(right_leg + Vector2(right_foot_x, right_len), Vector2(4, 2)), boot_dark)


func _draw_player_sprite() -> bool:
	if player_texture == null:
		return false
	var row := 0
	var frame_count := 8
	var frame_index := 0
	var fps := 5.0
	if attack_anim_kind != "" and attack_anim_duration > 0.0:
		var attack_rows := {
			"slash": 4,
			"spear": 5,
			"bow": 6,
			"cannon": 7,
			"staff": 8,
			"flask": 10,
			"turret": 11
		}
		row = int(attack_rows.get(attack_anim_kind, 4))
		var progress := 1.0 - clampf(attack_anim_time / attack_anim_duration, 0.0, 1.0)
		frame_index = mini(frame_count - 1, int(floor(progress * float(frame_count))))
	elif not player_on_floor:
		row = 2
		if player_velocity.y < -140.0:
			frame_index = 0
		elif player_velocity.y < -45.0:
			frame_index = 2
		elif player_velocity.y < 45.0:
			frame_index = 4
		else:
			frame_index = 6
	elif absf(player_velocity.x) > 5.0:
		row = 1
		fps = 10.0
		frame_index = int(floor(float(Time.get_ticks_msec()) / 1000.0 * fps)) % frame_count
	else:
		row = 0
		frame_index = int(floor(float(Time.get_ticks_msec()) / 1000.0 * fps)) % frame_count
	var source_rect := Rect2(
		frame_index * player_frame_size.x,
		row * player_frame_size.y,
		player_frame_size.x,
		player_frame_size.y
	)
	# Keep the physics capsule at 12x28 px (1.75 tiles high), but make the
	# authored sprite match that silhouette instead of rendering over 2 tiles.
	var draw_size := Vector2(player_frame_size) * 0.52
	var destination := Rect2(
		Vector2(-draw_size.x * 0.5, PLAYER_SIZE.y * 0.5 - draw_size.y),
		draw_size
	)
	var flip_scale := Vector2(-1.0, 1.0) if facing < 0 else Vector2.ONE
	var modulate := Color.WHITE
	if player_hurt_timer > 0.0 and int(Time.get_ticks_msec() / 60) % 2 == 0:
		modulate = Color("ffd0c4")
	draw_set_transform(player_position, 0.0, flip_scale)
	draw_texture_rect_region(player_texture, destination, source_rect, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true


func _draw_attack_animation() -> void:
	if attack_anim_kind == "" or attack_anim_duration <= 0.0:
		return
	# Draw the actual equipped item/tool in the character's hand. No generic
	# lines, sticks or semicircle overlays are used for player attacks.
	var weapon_id := equipped_weapon if equipped_weapon != "" else current_tool
	if weapon_id == "":
		return
	var weapon_texture := _item_icon(weapon_id)
	if weapon_texture == null:
		return
	var progress := 1.0 - clampf(attack_anim_time / attack_anim_duration, 0.0, 1.0)
	var hand := player_position + Vector2(float(facing) * 7.0, -4.0)
	var angle := 0.0
	var offset := Vector2(float(facing) * 8.0, 0.0)
	var icon_size := 26.0
	if attack_anim_kind == "slash":
		angle = float(facing) * lerpf(-1.05, 0.95, progress)
		offset += Vector2(float(facing) * sin(progress * PI) * 10.0, -2.0)
	elif attack_anim_kind == "spear":
		angle = float(facing) * 0.15
		offset += Vector2(float(facing) * lerpf(4.0, 26.0, sin(progress * PI)), 0.0)
		icon_size = 30.0
	elif attack_anim_kind == "bow":
		angle = float(facing) * -0.20
		offset += Vector2(float(facing) * lerpf(3.0, -5.0, sin(progress * PI)), -2.0)
	elif attack_anim_kind == "cannon":
		angle = 0.0
		offset += Vector2(float(facing) * (12.0 - sin(progress * PI) * 7.0), 1.0)
		icon_size = 28.0
	elif attack_anim_kind == "staff":
		angle = float(facing) * -0.45
		offset += Vector2(float(facing) * 10.0, -4.0)
	elif attack_anim_kind == "flask":
		angle = float(facing) * lerpf(-0.5, 0.8, progress)
		offset += Vector2(float(facing) * lerpf(4.0, 22.0, progress), -sin(progress * PI) * 10.0)
	elif attack_anim_kind == "turret":
		angle = 0.0
		offset += Vector2(float(facing) * 12.0, 1.0)
	var transform_scale := Vector2(float(facing), 1.0)
	draw_set_transform(hand + offset, angle, transform_scale)
	draw_texture_rect(weapon_texture, Rect2(Vector2(-icon_size * 0.5, -icon_size * 0.5), Vector2(icon_size, icon_size)), false, Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Magic is shown as a compact glow around the actual staff/rod, not a line.
	if attack_anim_kind == "staff":
		var glow_pos := hand + offset + Vector2(float(facing) * 9.0, -7.0)
		draw_circle(glow_pos, 3.0 + sin(progress * PI) * 3.0, attack_anim_color)
		draw_circle(glow_pos, 1.5, Color("fff3c0"))

func _draw_target_cursor() -> void:
	var tile_pos := _mouse_tile()
	if not _can_interact(tile_pos):
		return
	var rect := Rect2(Vector2(tile_pos) * TILE_SIZE, Vector2(TILE_SIZE, TILE_SIZE))
	draw_rect(rect, Color("ffffff", 0.18))
	draw_rect(rect, Color("f4d35e"), false, 1.5)
	var tile := _get_tile(tile_pos.x, tile_pos.y)
	if mining_target == tile_pos and tile != Tile.AIR:
		var percent := int(clampf(mining_progress / _mining_hardness(tile, tile_pos), 0.0, 1.0) * 100.0)
		var label_pos := get_global_mouse_position() + Vector2(14, -18)
		var label_rect := Rect2(label_pos + Vector2(-4, -14), Vector2(48, 20))
		draw_rect(label_rect, Color("0b1016", 0.82))
		draw_rect(Rect2(label_rect.position + Vector2(3, 15), Vector2(42, 3)), Color("263443"))
		draw_rect(Rect2(label_rect.position + Vector2(3, 15), Vector2(42.0 * float(percent) / 100.0, 3)), Color("f0d27a"))
		if ui_font != null:
			draw_string(ui_font, label_pos, "%d%%" % percent, HORIZONTAL_ALIGNMENT_LEFT, 46.0, 12, Color("f6e7ad"))


func _update_minimap(delta: float) -> void:
	if minimap_rect == null or world.is_empty():
		return
	minimap_timer += delta
	if minimap_timer < 1.0:
		return
	minimap_timer = 0.0

	var local_image := _build_local_minimap_image(MINIMAP_WIDTH, MINIMAP_HEIGHT)
	minimap_rect.texture = ImageTexture.create_from_image(local_image)
	if full_map_open and full_map_rect != null:
		_rebuild_world_map_image()
		var large_image := world_map_image.duplicate()
		_draw_map_player_marker(large_image, 4)
		full_map_rect.texture = ImageTexture.create_from_image(large_image)


func _refresh_map_textures() -> void:
	if world.is_empty():
		return
	var local_image := _build_local_minimap_image(MINIMAP_WIDTH, MINIMAP_HEIGHT)
	if minimap_rect != null:
		minimap_rect.texture = ImageTexture.create_from_image(local_image)
	if full_map_rect != null:
		_rebuild_world_map_image()
		var large_image := world_map_image.duplicate()
		_draw_map_player_marker(large_image, 4)
		full_map_rect.texture = ImageTexture.create_from_image(large_image)


func _build_local_minimap_image(width: int, height: int) -> Image:
	# Show a useful neighborhood around the player instead of shrinking the full world.
	# This covers 68×30 tiles: wider than the visible camera, but still local.
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var center_x := floori(player_position.x / TILE_SIZE)
	var center_y := floori(player_position.y / TILE_SIZE)
	const VIEW_TILES_X := 68
	const VIEW_TILES_Y := 30
	for py in range(height):
		var world_y := center_y + int(floor((float(py) / float(maxi(1, height - 1)) - 0.5) * float(VIEW_TILES_Y)))
		for px in range(width):
			var world_x := center_x + int(floor((float(px) / float(maxi(1, width - 1)) - 0.5) * float(VIEW_TILES_X)))
			var color := Color("080a0b")
			if _in_bounds(world_x, world_y) and _is_tile_explored(world_x, world_y):
				var tile := _get_tile(world_x, world_y)
				color = Color("10151d") if tile == Tile.AIR else tile_colors.get(tile, Color.WHITE).darkened(0.15)
			image.set_pixel(px, py, color)
	_draw_local_map_player_marker(image, 2)
	return image


func _draw_local_map_player_marker(image: Image, radius: int) -> void:
	var marker_x := int(image.get_width() / 2)
	var marker_y := int(image.get_height() / 2)
	for yy in range(marker_y - radius, marker_y + radius + 1):
		for xx in range(marker_x - radius, marker_x + radius + 1):
			if xx >= 0 and yy >= 0 and xx < image.get_width() and yy < image.get_height():
				if Vector2(xx - marker_x, yy - marker_y).length() <= float(radius):
					image.set_pixel(xx, yy, Color("ffeb7a"))


func _rebuild_world_map_image() -> void:
	if not world_map_dirty and world_map_image != null:
		return
	world_map_image = Image.create(FULL_MAP_WIDTH, FULL_MAP_HEIGHT, false, Image.FORMAT_RGBA8)
	for py in range(FULL_MAP_HEIGHT):
		var world_y := int(float(py) / float(FULL_MAP_HEIGHT - 1) * float(WORLD_HEIGHT - 1))
		for px in range(FULL_MAP_WIDTH):
			var world_x := int(float(px) / float(FULL_MAP_WIDTH - 1) * float(WORLD_WIDTH - 1))
			var color := Color("080a0b")
			if _is_tile_explored(world_x, world_y):
				var tile := _get_tile(world_x, world_y)
				color = Color("10151d") if tile == Tile.AIR else tile_colors.get(tile, Color.WHITE).darkened(0.15)
			world_map_image.set_pixel(px, py, color)
	world_map_dirty = false


func _draw_map_player_marker(image: Image, radius: int) -> void:
	var marker_x := clampi(int(player_position.x / float(WORLD_WIDTH * TILE_SIZE) * float(image.get_width())), 0, image.get_width() - 1)
	var marker_y := clampi(int(player_position.y / float(WORLD_HEIGHT * TILE_SIZE) * float(image.get_height())), 0, image.get_height() - 1)
	for yy in range(marker_y - radius, marker_y + radius + 1):
		for xx in range(marker_x - radius, marker_x + radius + 1):
			if xx >= 0 and yy >= 0 and xx < image.get_width() and yy < image.get_height():
				if Vector2(xx - marker_x, yy - marker_y).length() <= float(radius):
					image.set_pixel(xx, yy, Color("ffeb7a"))


func _get_tile(x: int, y: int) -> int:
	if not _in_bounds(x, y):
		return Tile.STONE
	return int(world[y][x])


func _set_tile(x: int, y: int, tile: int) -> void:
	if _in_bounds(x, y):
		var key := "%d,%d" % [x, y]
		var previous_tile := int(world[y][x])
		if previous_tile == Tile.SAPLING and tile != Tile.SAPLING:
			sapling_positions.erase(key)
		if previous_tile != tile:
			tree_tile_owners.erase(key)
		world[y][x] = tile
		world_map_dirty = true
		if tile == Tile.SAPLING:
			sapling_positions[key] = Vector2i(x, y)
		if liquid_sim != null and not world_generation_in_progress:
			liquid_sim.on_tile_changed(x, y, tile)


func _is_solid(x: int, y: int) -> bool:
	if not _in_bounds(x, y):
		return true
	return bool(solid_tiles.get(_get_tile(x, y), false))


func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < WORLD_WIDTH and y < WORLD_HEIGHT
