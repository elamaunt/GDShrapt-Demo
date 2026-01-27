## Interface-like class for working with objects that can take damage.
## Demonstrates: duck typing pattern, static methods, has_method checks.
class_name Damageable
extends RefCounted


# Checks if an object can take damage (duck typing)
static func can_take_damage(obj) -> bool:
	if obj == null:
		return false
	if not is_instance_valid(obj):
		return false
	return obj.has_method("take_damage") and obj.has_method("is_alive")


# Applies damage to an object if possible
static func apply_damage(obj, amount: int) -> bool:
	if can_take_damage(obj):
		obj.take_damage(amount)
		return true
	return false


# Checks if an object is alive
static func check_alive(obj) -> bool:
	if obj == null or not is_instance_valid(obj):
		return false
	if obj.has_method("is_alive"):
		return obj.is_alive()
	return true


# Gets the current health of an object if possible
static func get_health(obj):
	if obj == null or not is_instance_valid(obj):
		return null
	if obj.has_method("get_health"):
		return obj.get_health()
	if "current_health" in obj:
		return obj.current_health
	if "_current_health" in obj:
		return obj._current_health
	return null


# Checks if an object has a method (utility)
static func has_capability(obj, method_name: String) -> bool:
	if obj == null or not is_instance_valid(obj):
		return false
	return obj.has_method(method_name)
