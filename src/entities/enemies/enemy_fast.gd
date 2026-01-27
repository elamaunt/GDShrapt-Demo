## Fast enemy - duck typing style.
## Demonstrates: lack of type annotations, dynamic approach.
class_name EnemyFast
extends EnemyBase


# Variables without types - duck typing style
var speed_multiplier = 1.8
var dodge_chance = 0.15
var afterimage_enabled = true
var last_positions = []
var max_afterimages = 3


func _ready():
	enemy_type = Constants.EnemyType.FAST

	var data = Constants.get_enemy_data(enemy_type)
	max_health = data.get("health", 50)
	move_speed = data.get("speed", 160.0)
	gold_reward = data.get("reward", 15)
	entity_color = data.get("color", Color.YELLOW)

	move_speed *= speed_multiplier

	super._ready()


func _physics_process(delta):
	super._physics_process(delta)

	if afterimage_enabled:
		_update_afterimages()


# Method without type annotations
func take_damage(amount):
	if _try_dodge():
		_show_dodge_effect()
		return

	super.take_damage(amount)


# Dodge check - returns bool but without annotation
func _try_dodge():
	return randf() < dodge_chance


# Show dodge effect
func _show_dodge_effect():
	if visual:
		var original_pos = visual.position
		var tween = create_tween()
		tween.tween_property(visual, "position", original_pos + Vector2(10, 0), 0.05)
		tween.tween_property(visual, "position", original_pos - Vector2(10, 0), 0.05)
		tween.tween_property(visual, "position", original_pos, 0.05)


# Afterimages handling
func _update_afterimages():
	last_positions.append(global_position)

	if last_positions.size() > max_afterimages:
		last_positions.pop_front()


# Method for speed modification - accepts any type
func modify_speed(modifier):
	if modifier is float or modifier is int:
		move_speed *= modifier
	elif modifier is Callable:
		move_speed = modifier.call(move_speed)


# Get dodge chance
func get_dodge_chance():
	return dodge_chance


# Set dodge chance
func set_dodge_chance(value):
	dodge_chance = clampf(value, 0.0, 0.9)


# Enable/disable afterimages
func toggle_afterimages(enabled):
	afterimage_enabled = enabled
	if not enabled:
		last_positions.clear()
