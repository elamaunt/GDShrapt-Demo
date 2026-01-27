## Base class for all towers.
## Demonstrates: Area2D, collisions, targeting, timers, preload, lifecycle methods.
class_name TowerBase
extends Entity


# === Export Categories ===

@export_category("Tower Stats")
@export var damage: int = 15
@export var attack_range: float = 150.0
@export var fire_rate: float = 1.0
@export var tower_type: Constants.TowerType = Constants.TowerType.BASIC

@export_subgroup("Projectile")
@export var projectile_color: Color = Color.CYAN
@export var projectile_speed: float = 400.0


# === Preload Projectile Scene ===

var projectile_scene: PackedScene = preload("res://src/scenes/projectiles/projectile_bullet.tscn")


# === Nullable Typed Variable ===

var current_target: EnemyBase = null


# === Onready with Types ===

@onready var fire_timer: Timer = $FireTimer
@onready var range_area: Area2D = $RangeArea
@onready var range_shape: CollisionShape2D = $RangeArea/CollisionShape2D
@onready var range_visual: ColorRect = $RangeVisual


# === Typed Array of Enemies ===

var enemies_in_range: Array[EnemyBase] = []


# === Lifecycle ===

func _ready() -> void:
	super._ready()
	add_to_group("towers")

	_setup_range()
	_connect_range_signals()
	_setup_fire_timer()
	_hide_range_visual()


func _process(_delta: float) -> void:
	_update_target()


# === Setup Methods ===

func _setup_range() -> void:
	if range_shape:
		var shape := CircleShape2D.new()
		shape.radius = attack_range
		range_shape.shape = shape

	if range_visual:
		range_visual.size = Vector2(attack_range * 2, attack_range * 2)
		range_visual.position = -Vector2(attack_range, attack_range)
		range_visual.color = Color(entity_color, 0.1)


func _connect_range_signals() -> void:
	if range_area:
		range_area.area_entered.connect(_on_range_area_entered)
		range_area.area_exited.connect(_on_range_area_exited)


func _setup_fire_timer() -> void:
	if fire_timer:
		fire_timer.wait_time = 1.0 / fire_rate
		fire_timer.timeout.connect(_on_fire_timer_timeout)


# === Targeting ===

func _update_target() -> void:
	enemies_in_range = enemies_in_range.filter(_is_valid_target)

	if enemies_in_range.is_empty():
		current_target = null
		if fire_timer:
			fire_timer.stop()
		return

	current_target = _get_priority_target()

	if fire_timer and fire_timer.is_stopped():
		fire_timer.start()


func _is_valid_target(enemy: EnemyBase) -> bool:
	return is_instance_valid(enemy) and enemy.is_alive()


func _get_priority_target() -> EnemyBase:
	var best_target: EnemyBase = null
	var best_progress: float = -1.0

	for enemy in enemies_in_range:
		var progress: float = enemy.get_progress()
		if progress > best_progress:
			best_progress = progress
			best_target = enemy

	return best_target


# === Firing ===

func _on_fire_timer_timeout() -> void:
	if current_target and is_instance_valid(current_target):
		_fire_at(current_target)


func _fire_at(target: EnemyBase) -> void:
	if projectile_scene == null:
		Damageable.apply_damage(target, damage)
		return

	var projectile = projectile_scene.instantiate()
	projectile.setup(global_position, target, damage, projectile_speed)
	projectile.modulate = projectile_color

	get_tree().current_scene.add_child(projectile)
	Events.tower_fired.emit(self, target)


# === Area2D Callbacks ===

func _on_range_area_entered(area: Area2D) -> void:
	if area is EnemyBase:
		if area not in enemies_in_range:
			enemies_in_range.append(area)


func _on_range_area_exited(area: Area2D) -> void:
	if area is EnemyBase:
		enemies_in_range.erase(area)


# === Range Visual ===

func show_range_visual() -> void:
	if range_visual:
		range_visual.visible = true


func _hide_range_visual() -> void:
	if range_visual:
		range_visual.visible = false


# === Public Methods ===

func get_tower_data() -> Dictionary:
	return Constants.get_tower_data(tower_type)


func get_sell_value() -> int:
	var data: Dictionary = get_tower_data()
	var cost: int = data.get("cost", 0)
	return int(cost * 0.7)
