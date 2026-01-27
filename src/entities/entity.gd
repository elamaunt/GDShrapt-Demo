## Base class for all game entities (enemies, towers).
## Demonstrates: inheritance, @export, @onready, virtual methods, groups.
class_name Entity
extends Area2D


# === Export Variables ===

@export_range(1, 1000) var max_health: int = 100
@export var entity_color: Color = Color.WHITE
@export var entity_size: Vector2 = Vector2(32, 32)


# === Onready Variables ===

@onready var visual: ColorRect = $Visual
@onready var collision: CollisionShape2D = $CollisionShape2D


# === Protected Variables (convention with _) ===

var _current_health: int = 0
var _is_initialized: bool = false


# === Lifecycle Methods ===

func _ready() -> void:
	_current_health = max_health
	_setup_visual()
	_setup_collision()
	_is_initialized = true


# === Virtual Methods for Overriding ===

func _setup_visual() -> void:
	if visual:
		visual.color = entity_color
		visual.custom_minimum_size = entity_size
		visual.size = entity_size
		visual.position = -entity_size / 2


func _setup_collision() -> void:
	if collision:
		var shape := RectangleShape2D.new()
		shape.size = entity_size
		collision.shape = shape


# === Public Methods (interface for Damageable) ===

func take_damage(amount: int) -> void:
	_current_health -= amount
	_on_damaged(amount)

	if _current_health <= 0:
		_die()


func is_alive() -> bool:
	return _current_health > 0


func get_health() -> int:
	return _current_health


func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return float(_current_health) / float(max_health)


func heal(amount: int) -> void:
	_current_health = mini(_current_health + amount, max_health)


# === Virtual Protected Methods ===

func _on_damaged(amount: int) -> void:
	pass


func _die() -> void:
	queue_free()
