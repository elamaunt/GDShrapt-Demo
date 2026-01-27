## AOE tower - duck typing style.
## Demonstrates: lack of type annotations, dynamic approach.
class_name TowerAOE
extends TowerBase


# Variables without types
var aoe_radius = 80.0
var aoe_damage_falloff = true
var splash_count = 0
var enemies_hit_total = 0


# Preload AOE projectile
var aoe_projectile_scene = preload("res://src/scenes/projectiles/projectile_aoe.tscn")


func _ready():
	tower_type = Constants.TowerType.AOE

	var data = Constants.get_tower_data(tower_type)
	damage = data.get("damage", 8)
	attack_range = data.get("range", 120.0)
	fire_rate = data.get("fire_rate", 0.8)
	entity_color = data.get("color", Color.ORANGE_RED)
	projectile_color = Color.ORANGE

	projectile_scene = aoe_projectile_scene

	super._ready()


# Override without type annotations
func _get_priority_target():
	# AOE targets enemy clusters
	var best_target = null
	var best_score = 0

	for enemy in enemies_in_range:
		var score = _calculate_cluster_score(enemy)
		if score > best_score:
			best_score = score
			best_target = enemy

	return best_target


# Calculate enemy "density" around target
func _calculate_cluster_score(center_enemy):
	var score = 1

	for other in enemies_in_range:
		if other == center_enemy:
			continue

		var dist = center_enemy.global_position.distance_to(other.global_position)
		if dist <= aoe_radius:
			score += 1

	return score


# Fire AOE projectile
func _fire_at(target):
	if projectile_scene == null:
		_direct_aoe_damage(target.global_position)
		return

	var projectile = projectile_scene.instantiate()

	# setup_aoe instead of setup
	if projectile.has_method("setup_aoe"):
		projectile.setup_aoe(
			global_position,
			target.global_position,
			damage,
			aoe_radius,
			projectile_speed
		)
	else:
		projectile.setup(global_position, target, damage, projectile_speed)

	projectile.modulate = projectile_color
	get_tree().current_scene.add_child(projectile)

	splash_count += 1
	Events.tower_fired.emit(self, target)


# Direct area damage (fallback)
func _direct_aoe_damage(center_pos):
	var hit_count = 0

	for enemy in enemies_in_range:
		var dist = center_pos.distance_to(enemy.global_position)

		if dist <= aoe_radius:
			var final_damage = damage

			if aoe_damage_falloff:
				var falloff = 1.0 - (dist / aoe_radius) * 0.5
				final_damage = int(damage * falloff)

			if Damageable.can_take_damage(enemy):
				Damageable.apply_damage(enemy, final_damage)
				hit_count += 1

	enemies_hit_total += hit_count


# Configuration methods - duck typing friendly
func set_aoe_radius(radius):
	aoe_radius = radius


func get_aoe_radius():
	return aoe_radius


func enable_falloff(enabled):
	aoe_damage_falloff = enabled


func get_splash_stats():
	return {
		"splash_count": splash_count,
		"enemies_hit": enemies_hit_total,
		"avg_enemies_per_splash": _calc_avg_enemies()
	}


func _calc_avg_enemies():
	if splash_count == 0:
		return 0.0
	return float(enemies_hit_total) / float(splash_count)
