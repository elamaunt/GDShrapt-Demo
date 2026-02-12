## Environmental damage zone (lava, spikes, poison pool).
## Demonstrates: untyped arrays, duck-typed method calls on mixed entity types.
class_name DamageZone
extends Area2D


@export var damage_per_tick: int = 5
@export var tick_interval: float = 0.5
@export var zone_size: Vector2 = Vector2(80, 80)
@export var zone_color: Color = Color(1.0, 0.3, 0.0, 0.3)


signal zone_damage_applied(amount)


# Untyped array — stores mixed entity types (EnemyBasic, EnemyFast, EnemyTank, etc.)
var affected_entities = []


@onready var tick_timer: Timer = $TickTimer
@onready var zone_visual: ColorRect = $ZoneVisual


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	_setup_timer()
	_setup_visual()


func _setup_timer() -> void:
	if tick_timer:
		tick_timer.wait_time = tick_interval
		tick_timer.timeout.connect(_on_tick)
		tick_timer.start()


func _setup_visual() -> void:
	if zone_visual:
		zone_visual.color = zone_color
		zone_visual.size = zone_size
		zone_visual.position = -zone_size / 2


func _on_area_entered(area) -> void:
	if area not in affected_entities:
		affected_entities.append(area)


func _on_area_exited(area) -> void:
	affected_entities.erase(area)


func _on_tick() -> void:
	affected_entities = affected_entities.filter(
		func(e): return is_instance_valid(e)
	)

	for entity in affected_entities:
		if entity.has_method("take_damage"):
			entity.take_damage(damage_per_tick)
			zone_damage_applied.emit(damage_per_tick)


func get_entity_count():
	return affected_entities.size()
