## Base class for all enemies.
## Demonstrates: Entity inheritance, PathFollow2D integration, signals, _physics_process.
class_name EnemyBase
extends Entity


signal died(reward: int)
signal reached_end


@export_group("Movement")
@export var move_speed: float = 80.0

@export_group("Reward")
@export var gold_reward: int = 10

@export_group("Enemy Type")
@export var enemy_type: Constants.EnemyType = Constants.EnemyType.BASIC


@onready var health_bar: ColorRect = $HealthBar
@onready var health_bar_fill: ColorRect = $HealthBar/Fill


var path_follow: PathFollow2D = null
var progress_ratio: float = 0.0
var _is_dead: bool = false
var status_effects = []


func _ready() -> void:
	super._ready()
	add_to_group("enemies")
	_setup_health_bar()


func _physics_process(delta: float) -> void:
	if path_follow == null:
		return

	path_follow.progress += move_speed * delta
	progress_ratio = path_follow.progress_ratio

	global_position = path_follow.global_position

	if progress_ratio >= 1.0:
		_reached_end()


func setup_path(pf: PathFollow2D) -> void:
	path_follow = pf
	path_follow.progress = 0.0
	path_follow.rotates = false


func get_progress() -> float:
	return progress_ratio


func apply_status(effect) -> void:
	status_effects.append(effect)


func clear_statuses() -> void:
	status_effects.clear()


func _on_damaged(amount: int) -> void:
	_update_health_bar()
	Events.enemy_damaged.emit(self, amount, _current_health)


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true

	died.emit(gold_reward)
	Events.enemy_killed.emit(self, gold_reward)

	if path_follow:
		path_follow.queue_free()
		path_follow = null

	super._die()


func _reached_end() -> void:
	if _is_dead:
		return
	_is_dead = true

	set_physics_process(false)

	reached_end.emit()
	Events.enemy_reached_end.emit(self)

	if path_follow:
		path_follow.queue_free()
		path_follow = null

	queue_free()


func _setup_health_bar() -> void:
	if health_bar:
		health_bar.size = Vector2(entity_size.x, 4)
		health_bar.position = Vector2(-entity_size.x / 2, -entity_size.y / 2 - 8)
		health_bar.color = Color.DARK_RED

	if health_bar_fill:
		health_bar_fill.size = Vector2(entity_size.x, 4)
		health_bar_fill.position = Vector2.ZERO
		health_bar_fill.color = Color.GREEN


func _update_health_bar() -> void:
	if health_bar_fill:
		var percent: float = get_health_percent()
		health_bar_fill.scale.x = percent
		health_bar_fill.color = Color.GREEN.lerp(Color.RED, 1.0 - percent)
