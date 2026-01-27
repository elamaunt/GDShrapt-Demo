## Basic enemy - strict typing everywhere.
## Demonstrates: full strict typing, explicit parameter and return types.
class_name EnemyBasic
extends EnemyBase


# === Strictly Typed Variables ===

@export var armor: int = 0
@export var armor_percent: float = 0.0


# === Class Constants ===

const DAMAGE_FLASH_DURATION: float = 0.1
const FLASH_COLOR: Color = Color.WHITE


# === Private Typed Variables ===

var _original_color: Color = Color.WHITE
var _is_flashing: bool = false


# === Lifecycle with Explicit Types ===

func _ready() -> void:
	enemy_type = Constants.EnemyType.BASIC

	var data: Dictionary = Constants.get_enemy_data(enemy_type)
	max_health = data.get("health", 100)
	move_speed = data.get("speed", 80.0)
	gold_reward = data.get("reward", 10)
	entity_color = data.get("color", Color.CRIMSON)

	super._ready()
	_original_color = entity_color


# === Override with Full Typing ===

func take_damage(amount: int) -> void:
	var actual_damage: int = _calculate_damage(amount)
	super.take_damage(actual_damage)
	_flash_damage()


func _calculate_damage(raw_damage: int) -> int:
	var after_flat: int = maxi(1, raw_damage - armor)
	var after_percent: float = float(after_flat) * (1.0 - armor_percent)
	return maxi(1, int(after_percent))


# === Visual Effect Methods ===

func _flash_damage() -> void:
	if _is_flashing:
		return

	_is_flashing = true

	if visual:
		visual.color = FLASH_COLOR

	var timer: SceneTreeTimer = get_tree().create_timer(DAMAGE_FLASH_DURATION)
	timer.timeout.connect(_end_flash)


func _end_flash() -> void:
	_is_flashing = false
	if visual:
		visual.color = _original_color


# === Getters with Strict Typing ===

func get_armor() -> int:
	return armor


func get_armor_percent() -> float:
	return armor_percent


func get_effective_health() -> int:
	if armor_percent >= 1.0:
		return 999999
	var effective: float = float(_current_health) / (1.0 - armor_percent)
	return int(effective) + armor
