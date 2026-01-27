## Sniper tower - mixed typing.
## Demonstrates: combination of strict typing and type inference.
class_name TowerSniper
extends TowerBase


# === Export with Types ===

@export var crit_chance: float = 0.25
@export var crit_multiplier: float = 2.5


# === Variables with Type Inference ===

var crit_count := 0
var normal_hits := 0
var last_crit_damage := 0


# === Typed Variables ===

var targeting_mode: int = 0  # 0 = furthest, 1 = lowest_health, 2 = highest_health


# === Constants ===

const TARGETING_FURTHEST: int = 0
const TARGETING_LOWEST_HP: int = 1
const TARGETING_HIGHEST_HP: int = 2


func _ready() -> void:
	tower_type = Constants.TowerType.SNIPER

	var data: Dictionary = Constants.get_tower_data(tower_type)
	damage = data.get("damage", 75)
	attack_range = data.get("range", 300.0)
	fire_rate = data.get("fire_rate", 0.4)
	entity_color = data.get("color", Color.DARK_GREEN)
	projectile_color = Color.LIME_GREEN

	super._ready()


# Targeting override - mixed style
func _get_priority_target() -> EnemyBase:
	match targeting_mode:
		TARGETING_FURTHEST:
			return _get_furthest_target()
		TARGETING_LOWEST_HP:
			return _get_lowest_health_target()
		TARGETING_HIGHEST_HP:
			return _get_highest_health_target()

	return super._get_priority_target()


# Type inference in local variables
func _get_furthest_target() -> EnemyBase:
	var best: EnemyBase = null
	var best_progress := -1.0  # inferred as float

	for enemy in enemies_in_range:
		var progress := enemy.get_progress()  # inferred
		if progress > best_progress:
			best_progress = progress
			best = enemy

	return best


func _get_lowest_health_target() -> EnemyBase:
	var best: EnemyBase = null
	var lowest := INF  # inferred as float

	for enemy in enemies_in_range:
		var health = enemy.get_health()  # inferred from return type
		if health < lowest:
			lowest = health
			best = enemy

	return best


func _get_highest_health_target() -> EnemyBase:
	var best: EnemyBase = null
	var highest := 0  # inferred as int

	for enemy in enemies_in_range:
		var health = enemy.get_health()
		if health > highest:
			highest = health
			best = enemy

	return best


# Override with crit calculation
func _fire_at(target: EnemyBase) -> void:
	var final_damage := damage  # inferred
	var is_crit := _roll_crit()  # inferred as bool

	if is_crit:
		final_damage = _calculate_crit_damage(damage)
		crit_count += 1
		last_crit_damage = final_damage
	else:
		normal_hits += 1

	var projectile = projectile_scene.instantiate()
	projectile.setup(global_position, target, final_damage, projectile_speed)

	if is_crit:
		projectile.modulate = Color.GOLD
		projectile.scale = Vector2(1.5, 1.5)
	else:
		projectile.modulate = projectile_color

	get_tree().current_scene.add_child(projectile)
	Events.tower_fired.emit(self, target)


func _roll_crit() -> bool:
	return randf() < crit_chance


func _calculate_crit_damage(base_damage: int) -> int:
	return int(float(base_damage) * crit_multiplier)


# Public methods
func set_targeting_mode(mode: int) -> void:
	targeting_mode = clampi(mode, 0, 2)


func get_targeting_mode() -> int:
	return targeting_mode


func get_crit_stats() -> Dictionary:
	var total := crit_count + normal_hits
	var crit_rate := 0.0
	if total > 0:
		crit_rate = float(crit_count) / float(total)

	return {
		"crits": crit_count,
		"normal": normal_hits,
		"actual_crit_rate": crit_rate,
		"last_crit_damage": last_crit_damage
	}
