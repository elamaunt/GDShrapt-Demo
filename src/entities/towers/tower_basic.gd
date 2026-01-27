## Basic tower - strict typing.
## Demonstrates: full strict typing, explicit types everywhere.
class_name TowerBasic
extends TowerBase


# === Strictly Typed Constants ===

const MUZZLE_FLASH_DURATION: float = 0.05
const MUZZLE_FLASH_COLOR: Color = Color.WHITE


# === Strictly Typed Variables ===

var shots_fired: int = 0
var total_damage_dealt: int = 0
var enemies_killed: int = 0


# === Lifecycle with Strict Typing ===

func _ready() -> void:
	tower_type = Constants.TowerType.BASIC

	var data: Dictionary = Constants.get_tower_data(tower_type)
	damage = data.get("damage", 15)
	attack_range = data.get("range", 150.0)
	fire_rate = data.get("fire_rate", 1.2)
	entity_color = data.get("color", Color.DODGER_BLUE)
	projectile_color = Color.CYAN

	super._ready()


# === Override with Full Typing ===

func _fire_at(target: EnemyBase) -> void:
	if not target is EnemyBase:
		push_error("TowerBasic: Invalid target type")
		return

	super._fire_at(target)
	_record_shot()
	_show_muzzle_flash()


func _record_shot() -> void:
	shots_fired += 1


func _show_muzzle_flash() -> void:
	if visual == null:
		return

	var original_color: Color = visual.color
	visual.color = MUZZLE_FLASH_COLOR

	var timer: SceneTreeTimer = get_tree().create_timer(MUZZLE_FLASH_DURATION)
	timer.timeout.connect(func(): visual.color = original_color)


# === Statistics with Strict Types ===

func get_shots_fired() -> int:
	return shots_fired


func get_total_damage() -> int:
	return total_damage_dealt


func get_enemies_killed() -> int:
	return enemies_killed


func add_damage_dealt(amount: int) -> void:
	total_damage_dealt += amount


func add_enemy_killed() -> void:
	enemies_killed += 1


func get_stats() -> Dictionary:
	return {
		"shots_fired": shots_fired,
		"total_damage": total_damage_dealt,
		"enemies_killed": enemies_killed,
		"dps": _calculate_dps()
	}


func _calculate_dps() -> float:
	return float(damage) * fire_rate
