## Base class for projectiles.
## Demonstrates: physics, homing behavior, collisions.
class_name ProjectileBase
extends Area2D


# === Export ===

@export var default_speed: float = 400.0


# === Typed Variables ===

var target: Node2D = null
var damage_amount: int = 0
var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO


# === Onready ===

@onready var visual: ColorRect = $Visual


# === Lifecycle ===

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	add_to_group("projectiles")


func _physics_process(delta: float) -> void:
	if not _is_target_valid():
		_on_target_lost()
		return

	_move_towards_target(delta)
	_update_rotation()


# === Public Methods ===

func setup(start_pos: Vector2, target_node: Node2D, dmg: int, spd: float = 0.0) -> void:
	global_position = start_pos
	target = target_node
	damage_amount = dmg
	speed = spd if spd > 0 else default_speed

	if target:
		direction = _calculate_direction()


# === Private Methods ===

func _is_target_valid() -> bool:
	return target != null and is_instance_valid(target)


func _calculate_direction() -> Vector2:
	if not _is_target_valid():
		return direction

	return (target.global_position - global_position).normalized()


func _move_towards_target(delta: float) -> void:
	# Recalculate direction for homing
	direction = _calculate_direction()
	position += direction * speed * delta


func _update_rotation() -> void:
	if direction != Vector2.ZERO:
		rotation = direction.angle()


func _on_target_lost() -> void:
	# Continue flying in the last direction
	if direction == Vector2.ZERO:
		queue_free()
		return

	position += direction * speed * get_physics_process_delta_time()

	# Remove if flew off screen
	if not get_viewport_rect().grow(100).has_point(global_position):
		queue_free()


# === Collisions ===

func _on_area_entered(area: Area2D) -> void:
	if area == target:
		_hit_target(area)


func _hit_target(target_node: Node2D) -> void:
	if Damageable.can_take_damage(target_node):
		Damageable.apply_damage(target_node, damage_amount)

	_on_hit_effect()
	queue_free()


func _on_hit_effect() -> void:
	pass  # For overriding
