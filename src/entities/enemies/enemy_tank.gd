## Tank enemy - dynamic typing with Variant.
## Demonstrates: Variant usage, runtime type checking, dynamic behavior.
class_name EnemyTank
extends EnemyBase


# === Variant Variables - Dynamic Typing ===

var damage_reduction: Variant = 0.3
var shield: Variant = null
var shield_regen_rate: Variant = 5.0
var special_ability: Variant = null


# === Typed Variables ===

var max_shield: int = 50
var _shield_regen_timer: float = 0.0


# === Constants ===

const SHIELD_REGEN_INTERVAL: float = 1.0


func _ready() -> void:
	enemy_type = Constants.EnemyType.TANK

	var data: Dictionary = Constants.get_enemy_data(enemy_type)
	max_health = data.get("health", 300)
	move_speed = data.get("speed", 40.0)
	gold_reward = data.get("reward", 25)
	entity_color = data.get("color", Color.PURPLE)

	shield = max_shield

	super._ready()

	entity_size = Vector2(48, 48)
	_setup_visual()
	_setup_collision()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_process_shield_regen(delta)


func _process_shield_regen(delta: float) -> void:
	if shield == null:
		return

	if shield is int and shield < max_shield:
		_shield_regen_timer += delta

		if _shield_regen_timer >= SHIELD_REGEN_INTERVAL:
			_shield_regen_timer = 0.0
			_regenerate_shield()


func _regenerate_shield() -> void:
	if shield is int and shield_regen_rate is float:
		shield = mini(shield + int(shield_regen_rate), max_shield)
	elif shield is int and shield_regen_rate is int:
		shield = mini(shield + shield_regen_rate, max_shield)


func take_damage(amount: int) -> void:
	var final_damage: int = _apply_damage_reduction(amount)
	final_damage = _apply_shield(final_damage)

	if final_damage > 0:
		super.take_damage(final_damage)


func _apply_damage_reduction(amount: int) -> int:
	if damage_reduction is float:
		return int(float(amount) * (1.0 - damage_reduction))
	elif damage_reduction is int:
		return maxi(1, amount - damage_reduction)
	elif damage_reduction is Callable:
		var result = damage_reduction.call(amount)
		if result is int:
			return result
		return amount
	return amount


func _apply_shield(amount: int) -> int:
	if shield == null:
		return amount

	if shield is int:
		if shield <= 0:
			return amount

		var absorbed: int = mini(shield, amount)
		shield = shield - absorbed
		_update_visual_for_shield()
		return amount - absorbed

	elif shield is Dictionary:
		var current: int = shield.get("current", 0)
		if current <= 0:
			return amount

		var absorbed: int = mini(current, amount)
		shield["current"] = current - absorbed
		return amount - absorbed

	return amount


func _update_visual_for_shield() -> void:
	if visual == null:
		return

	if shield is int and shield > 0:
		visual.color = entity_color.lightened(0.3)
	else:
		visual.color = entity_color


func set_shield(value) -> void:
	shield = value


func get_shield():
	return shield


func get_shield_percent() -> float:
	if shield is int:
		return float(shield) / float(max_shield)
	elif shield is Dictionary:
		var current = shield.get("current", 0)
		var max_val = shield.get("max", max_shield)
		return float(current) / float(max_val)
	return 0.0


func set_damage_reduction(value) -> void:
	damage_reduction = value


func set_special_ability(ability) -> void:
	special_ability = ability


func use_special_ability() -> void:
	if special_ability == null:
		return

	if special_ability is Callable:
		special_ability.call(self)
	elif special_ability is String:
		if has_method(special_ability):
			call(special_ability)


func _ability_heal() -> void:
	heal(max_health / 4)


func _ability_shield_burst() -> void:
	shield = max_shield * 2
