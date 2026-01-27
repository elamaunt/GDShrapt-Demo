## Global constants and enumerations for the Tower Defence game.
## Demonstrates: enums, constants, typed arrays and dictionaries.
class_name Constants
extends RefCounted


# Enumeration of tower types with explicit values
enum TowerType {
	BASIC = 0,
	SNIPER = 1,
	AOE = 2
}

# Enumeration of enemy types without explicit values
enum EnemyType {
	BASIC,
	FAST,
	TANK
}

# Game states
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
	VICTORY
}


# Typed constants
const MAX_WAVES: int = 10
const STARTING_GOLD: int = 150
const STARTING_HEALTH: int = 20
const BASE_ENEMY_REWARD: float = 10.0

# Untyped dictionary of tower data for flexibility
const TOWER_DATA = {
	TowerType.BASIC: {
		"name": "Basic",
		"cost": 50,
		"damage": 15,
		"range": 150.0,
		"fire_rate": 1.2,
		"color": Color.DODGER_BLUE
	},
	TowerType.SNIPER: {
		"name": "Sniper",
		"cost": 100,
		"damage": 75,
		"range": 300.0,
		"fire_rate": 0.4,
		"color": Color.DARK_GREEN
	},
	TowerType.AOE: {
		"name": "AOE",
		"cost": 80,
		"damage": 8,
		"range": 120.0,
		"fire_rate": 0.8,
		"color": Color.ORANGE_RED
	}
}

# Enemy data
const ENEMY_DATA = {
	EnemyType.BASIC: {
		"name": "Basic",
		"health": 100,
		"speed": 80.0,
		"reward": 10,
		"color": Color.CRIMSON
	},
	EnemyType.FAST: {
		"name": "Fast",
		"health": 50,
		"speed": 160.0,
		"reward": 15,
		"color": Color.YELLOW
	},
	EnemyType.TANK: {
		"name": "Tank",
		"health": 300,
		"speed": 40.0,
		"reward": 25,
		"color": Color.PURPLE
	}
}

# Typed array of enemy colors
const ENEMY_COLORS: Array[Color] = [
	Color.CRIMSON,   # BASIC
	Color.YELLOW,    # FAST
	Color.PURPLE     # TANK
]

# Typed array of tower colors
const TOWER_COLORS: Array[Color] = [
	Color.DODGER_BLUE,  # BASIC
	Color.DARK_GREEN,   # SNIPER
	Color.ORANGE_RED    # AOE
]


# Static method to get tower data
static func get_tower_data(tower_type: TowerType) -> Dictionary:
	return TOWER_DATA.get(tower_type, {})


# Static method to get enemy data
static func get_enemy_data(enemy_type: EnemyType) -> Dictionary:
	return ENEMY_DATA.get(enemy_type, {})


# Method without return type annotation (duck typing)
static func get_tower_cost(tower_type):
	var data = TOWER_DATA.get(tower_type)
	if data:
		return data.cost
	return 0
