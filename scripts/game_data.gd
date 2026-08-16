extends RefCounted
class_name GameData

# ============================================================
# CONSTANTS
# ============================================================
const TILE_SIZE := 16
const WORLD_WIDTH := 1280
const WORLD_HEIGHT := 190
const VIEW_PADDING := 4
const GRAVITY := 1700.0
const MOVE_SPEED := 210.0
const JUMP_SPEED := -520.0
const PLAYER_SIZE := Vector2(12, 28)
const AUTO_STEP_HEIGHT := TILE_SIZE
const INTERACT_RANGE_TILES := 6.0
const SAVE_PATH := "user://ashen_roots_save.json"
const MAX_HEALTH := 100
const FALL_DAMAGE_SPEED := 760.0
const CHUNK_SIZE := 16
const MINIMAP_WIDTH := 180
const MINIMAP_HEIGHT := 70
const FULL_MAP_WIDTH := 1280
const FULL_MAP_HEIGHT := 190
const HOTBAR_SIZE := 5
const INVENTORY_GRID_SIZE := 24
const SLOT_SIZE := 54
const MIN_CAMERA_ZOOM := 1.9
const MAX_CAMERA_ZOOM := 3.1
const DAY_DURATION := 1500.0
const NIGHT_DURATION := 450.0
const FULL_DAY_DURATION := DAY_DURATION + NIGHT_DURATION
const MAX_ENEMIES := 12
const ENEMY_SPAWN_INTERVAL := 2.4
const PLAYER_HURT_COOLDOWN := 0.8
const USE_EXTERNAL_ENEMY_ANIMATION_STRIPS := false
const LOOT_PICKUP_RADIUS := 20.0
const LOOT_MAGNET_RADIUS := 76.0
const LOOT_DESPAWN_TIME := 240.0
const MAX_OXYGEN := 100.0
const NORMAL_BODY_TEMPERATURE := 37.0
const MIN_BODY_TEMPERATURE := 26.0
const MAX_BODY_TEMPERATURE := 46.0

# ============================================================
# TILE ENUM
# ============================================================
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

# ============================================================
# TILE DATA
# ============================================================
static var tile_names: Dictionary = {
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

static var tile_colors: Dictionary = {
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

static var solid_tiles: Dictionary = {
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

static var tile_hardness: Dictionary = {
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

static var tile_required_power: Dictionary = {
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

static var tile_to_item: Dictionary = {
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

static var item_to_tile: Dictionary = {
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

# ============================================================
# ITEM DATA
# ============================================================
static var item_names: Dictionary = {
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
	"heartwood_core": "Heartwood Core",
	"ancient_chest": "Ancient Chest",
	"torch": "Torch",
	"stone_altar": "Stone Altar",
	"stoneblood_ore": "Stoneblood Ore",
	"stoneblood_bar": "Stoneblood Bar",
	"beast_core": "Beast Core",
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
	"ash_charm": "Ash Charm",
	"root_ring": "Root Ring",
	"wild_badge": "Wild Badge",
	"ash_sand": "Ash Sand",
	"frozen_dirt": "Frozen Dirt",
	"mud": "Mud",
	"rubble": "Rubble"
}

static var tools: Dictionary = {
	"wooden_pickaxe": {"name": "Wooden Pickaxe", "power": 1, "speed": 0.78},
	"copper_pickaxe": {"name": "Copper Pickaxe", "power": 2, "speed": 1.15},
	"iron_pickaxe": {"name": "Iron Pickaxe", "power": 3, "speed": 1.55},
	"ash_pickaxe": {"name": "Ash Pickaxe", "power": 4, "speed": 1.85},
	"stoneblood_pickaxe": {"name": "Stoneblood Pickaxe", "power": 5, "speed": 2.05},
	"builder_hammer": {"name": "Builder Hammer", "power": 1, "speed": 0.75}
}

static var gear_stats: Dictionary = {
	"wooden_sword": {"slot": "weapon", "class": "Warrior", "damage": 6},
	"copper_sword": {"slot": "weapon", "class": "Warrior", "damage": 11},
	"iron_spear": {"slot": "weapon", "class": "Warrior", "damage": 15},
	"wooden_shield": {"slot": "accessory", "class": "Shieldbearer", "defense": 3},
	"copper_shield": {"slot": "accessory", "class": "Shieldbearer", "defense": 6},
	"wooden_bow": {"slot": "weapon", "class": "Archer", "damage": 7},
	"copper_bow": {"slot": "weapon", "class": "Archer", "damage": 12},
	"fire_arrows": {"slot": "accessory", "class": "Archer", "damage": 4},
	"hand_cannon": {"slot": "weapon", "class": "Sniper", "damage": 21},
	"spark_staff": {"slot": "weapon", "class": "Mage", "damage": 13},
	"root_spirit_rod": {"slot": "weapon", "class": "Summoner", "damage": 9},
	"acid_flasks": {"slot": "weapon", "class": "Alchemist", "damage": 10},
	"small_turret": {"slot": "weapon", "class": "Engineer", "damage": 8},
	"ash_sickle": {"slot": "weapon", "class": "Memory Reaper", "damage": 17},
	"stonebreaker_blade": {"slot": "weapon", "class": "Warrior", "damage": 26},
	"copper_armor": {"slot": "armor", "class": "Any", "defense": 5, "cold_protection": 0.08, "heat_protection": 0.06},
	"iron_armor": {"slot": "armor", "class": "Any", "defense": 9, "cold_protection": 0.18, "heat_protection": 0.10},
	"ash_charm": {"slot": "accessory", "class": "Memory Reaper", "damage": 3},
	"root_ring": {"slot": "accessory", "class": "Summoner", "defense": 2},
	"wild_badge": {"slot": "accessory", "class": "Any", "damage": 2, "defense": 1},
	"diving_charm": {"slot": "accessory", "class": "Any", "defense": 1, "water_breathing": true, "cold_protection": 0.12},
	"ember_ward": {"slot": "accessory", "class": "Any", "defense": 2, "heat_resistance": true, "heat_protection": 0.58},
	"harpoon": {"slot": "weapon", "class": "Sniper", "damage": 23},
	"tidal_trident": {"slot": "weapon", "class": "Warrior", "damage": 21},
	"tide_staff": {"slot": "weapon", "class": "Mage", "damage": 19},
	"drowned_armor": {"slot": "armor", "class": "Any", "defense": 13, "water_affinity": true, "cold_protection": 0.45, "heat_protection": 0.04}
}

static var recipes: Array[Dictionary] = [
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
	{"id": "copper_armor", "station": "anvil", "cost": {"copper_bar": 10}, "result": "copper_armor", "amount": 1},
	{"id": "iron_armor", "station": "anvil", "cost": {"iron_bar": 12}, "result": "iron_armor", "amount": 1},
	{"id": "ash_charm", "station": "workbench", "cost": {"memory_shard": 2, "ash": 8}, "result": "ash_charm", "amount": 1},
	{"id": "root_ring", "station": "workbench", "cost": {"root_core": 2, "copper_bar": 1}, "result": "root_ring", "amount": 1},
	{"id": "wild_badge", "station": "workbench", "cost": {"wild_ichor": 4, "night_ember": 2, "wood": 6}, "result": "wild_badge", "amount": 1},
	{"id": "stoneblood_bar", "station": "furnace", "cost": {"stoneblood_ore": 3, "ash": 1}, "result": "stoneblood_bar", "amount": 1},
	{"id": "stoneblood_pickaxe", "station": "anvil", "cost": {"stoneblood_bar": 8, "beast_core": 1, "wood": 4}, "result": "stoneblood_pickaxe", "amount": 1},
	{"id": "stonebreaker_blade", "station": "anvil", "cost": {"stoneblood_bar": 10, "beast_core": 1}, "result": "stonebreaker_blade", "amount": 1},
	{"id": "abyss_lens", "station": "anvil", "cost": {"abyss_crystal": 4, "glass_shard": 6, "drowned_pearl": 1}, "result": "abyss_lens", "amount": 1},
	{"id": "diving_charm", "station": "anvil", "cost": {"drowned_pearl": 2, "sunken_stone": 8, "iron_bar": 4}, "result": "diving_charm", "amount": 1},
	{"id": "ember_ward", "station": "anvil", "cost": {"ember_root": 8, "night_ember": 4, "stoneblood_bar": 2}, "result": "ember_ward", "amount": 1},
	{"id": "harpoon", "station": "anvil", "cost": {"sunken_mechanism": 2, "iron_bar": 7, "kelp_fiber": 4}, "result": "harpoon", "amount": 1},
	{"id": "tidal_trident", "station": "anvil", "cost": {"guardian_core": 1, "drowned_pearl": 3, "stoneblood_bar": 6}, "result": "tidal_trident", "amount": 1},
	{"id": "tide_staff", "station": "anvil", "cost": {"guardian_core": 1, "abyss_crystal": 3, "drowned_pearl": 4}, "result": "tide_staff", "amount": 1},
	{"id": "drowned_armor", "station": "anvil", "cost": {"guardian_core": 1, "sunken_stone": 16, "kelp_fiber": 8}, "result": "drowned_armor", "amount": 1}
]

# ============================================================
# ENEMY SPRITE SPECS
# ============================================================
static var enemy_sprite_specs: Dictionary = {
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
	"stone_beast": {"frame": Vector2i(144, 112), "idle_row": 0, "idle_frames": 8, "move_row": 1, "move_frames": 8, "fps": 6.0, "scale": 0.64},
	"heartwood_boss": {"frame": Vector2i(112, 128), "idle_row": 0, "idle_frames": 8, "move_row": 1, "move_frames": 8, "fps": 6.0, "scale": 0.64}
}

# ============================================================
# TEXTURE PATH TEMPLATES
# ============================================================
static var tile_texture_paths: Dictionary = {}

static func init_tile_texture_paths() -> void:
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
		Tile.SAPLING: "res://assets/textures/tiles/sapling.png"
	}

# ============================================================
# HELPER FUNCTIONS
# ============================================================
static func is_solid_tile(tile: int) -> bool:
	return solid_tiles.has(tile)

static func get_tile_hardness(tile: int) -> float:
	return tile_hardness.get(tile, 0.0)

static func get_tile_required_power(tile: int) -> int:
	return tile_required_power.get(tile, 1)

static func tile_to_item_id(tile: int) -> String:
	return tile_to_item.get(tile, "")

static func item_to_tile_id(item_id: String) -> int:
	return item_to_tile.get(item_id, Tile.AIR)

static func get_item_name(item_id: String) -> String:
	return item_names.get(item_id, item_id)

static func get_tile_name(tile: int) -> String:
	return tile_names.get(tile, "Unknown")

static func get_tile_color(tile: int) -> Color:
	return tile_colors.get(tile, Color.MAGENTA)
