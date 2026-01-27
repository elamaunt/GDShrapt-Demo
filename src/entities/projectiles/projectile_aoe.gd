## AOE projectile with area damage.
## Demonstrates: physics queries, duck typing, await.
class_name ProjectileAOE
extends ProjectileBase


# AOE specific variables (without types - duck typing)
var target_position = Vector2.ZERO
var aoe_radius = 80.0
var has_exploded = false
var damage_falloff = true


func _physics_process(delta: float) -> void:
	if has_exploded:
		return

	_move_to_position(delta)
	_update_rotation()
	_check_arrival()


# Alternative setup for AOE
func setup_aoe(start_pos: Vector2, target_pos: Vector2, dmg: int, radius: float, spd: float = 400.0) -> void:
	global_position = start_pos
	target_position = target_pos
	damage_amount = dmg
	aoe_radius = radius
	speed = spd
	target = null  # No specific target

	direction = (target_position - global_position).normalized()


func _move_to_position(delta):
	if direction == Vector2.ZERO:
		return

	position += direction * speed * delta


func _check_arrival():
	var distance = global_position.distance_to(target_position)

	if distance < 15.0:
		_explode()


func _explode():
	if has_exploded:
		return

	has_exploded = true
	_deal_aoe_damage()
	_show_explosion()

	await get_tree().create_timer(0.15).timeout
	queue_free()


func _deal_aoe_damage():
	# Use physics query to find targets
	var space = get_world_2d().direct_space_state

	var query = PhysicsShapeQueryParameters2D.new()
	var shape = CircleShape2D.new()
	shape.radius = aoe_radius
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collide_with_areas = true
	query.collision_mask = collision_mask

	var results = space.intersect_shape(query)

	for result in results:
		var collider = result.get("collider")
		_try_damage(collider)


# Duck typing - try to damage any object
func _try_damage(obj):
	if obj == null:
		return

	if not is_instance_valid(obj):
		return

	# Check through Damageable
	if Damageable.can_take_damage(obj):
		var final_damage = _calculate_damage(obj)
		Damageable.apply_damage(obj, final_damage)


func _calculate_damage(target_obj):
	if not damage_falloff:
		return damage_amount

	# Calculate damage with distance falloff
	if not is_instance_valid(target_obj):
		return damage_amount

	if not "global_position" in target_obj:
		return damage_amount

	var dist = global_position.distance_to(target_obj.global_position)
	var falloff_mult = 1.0 - (dist / aoe_radius) * 0.5
	falloff_mult = clampf(falloff_mult, 0.5, 1.0)

	return int(damage_amount * falloff_mult)


func _show_explosion():
	if visual == null:
		return

	# Quick explosion animation
	var tween = create_tween()

	# Increase size
	var target_scale = Vector2(aoe_radius / 8.0, aoe_radius / 8.0)
	tween.tween_property(visual, "scale", target_scale, 0.1)

	# Fade out
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.15)


# Override - don't use homing for AOE
func _is_target_valid() -> bool:
	return target_position != Vector2.ZERO


# Override - AOE doesn't react to collision directly
func _on_area_entered(area: Area2D) -> void:
	pass  # Ignore, explode on arrival
