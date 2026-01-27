## Enemy wave spawning system.
## Demonstrates: scene preloading, instancing, typed arrays, dictionaries, timers.
class_name EnemySpawner
extends Node


# === Scene Preloading (compile-time loading) ===

const EnemyBasicScene: PackedScene = preload("res://src/scenes/enemies/enemy_basic.tscn")
const EnemyFastScene: PackedScene = preload("res://src/scenes/enemies/enemy_fast.tscn")
const EnemyTankScene: PackedScene = preload("res://src/scenes/enemies/enemy_tank.tscn")


# === Dictionary mapping types to scenes ===

var enemy_scenes: Dictionary = {
	Constants.EnemyType.BASIC: EnemyBasicScene,
	Constants.EnemyType.FAST: EnemyFastScene,
	Constants.EnemyType.TANK: EnemyTankScene
}


# === Export Variables ===

@export var spawn_path: Path2D
@export var spawn_delay_base: float = 1.5
@export var spawn_delay_min: float = 0.4


# === Typed Array of Wave Definitions ===

var wave_definitions: Array[Dictionary] = []


# === Spawn Queue (mixed typing) ===

var spawn_queue: Array = []
var current_wave_index: int = -1


# === Onready Variables ===

@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	_generate_waves()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	Events.wave_completed.connect(_on_wave_completed)


# === Wave Generation ===

func _generate_waves() -> void:
	for wave_num in range(Constants.MAX_WAVES):
		var wave: Dictionary = _create_wave(wave_num)
		wave_definitions.append(wave)


func _create_wave(wave_num: int) -> Dictionary:
	var wave: Dictionary = {
		"enemies": [],
		"spawn_delay": maxf(spawn_delay_min, spawn_delay_base - wave_num * 0.1)
	}

	var enemy_count: int = 5 + wave_num * 3

	for i in range(enemy_count):
		var enemy_type: Constants.EnemyType = _get_enemy_for_wave(wave_num, i)
		wave.enemies.append(enemy_type)

	return wave


func _get_enemy_for_wave(wave_num: int, enemy_index: int) -> Constants.EnemyType:
	if wave_num < 2:
		return Constants.EnemyType.BASIC

	if wave_num < 4:
		if randf() < 0.2:
			return Constants.EnemyType.FAST
		return Constants.EnemyType.BASIC

	var roll: float = randf()

	if roll < 0.15:
		return Constants.EnemyType.TANK
	elif roll < 0.4:
		return Constants.EnemyType.FAST
	else:
		return Constants.EnemyType.BASIC


# === Public Methods ===

func start_wave(wave_index: int) -> void:
	if wave_index < 0 or wave_index >= wave_definitions.size():
		push_warning("Invalid wave index: %d" % wave_index)
		return

	current_wave_index = wave_index
	var wave: Dictionary = wave_definitions[wave_index]

	spawn_queue = wave.enemies.duplicate()
	spawn_timer.wait_time = wave.spawn_delay
	spawn_timer.start()

	GameManager.start_wave()


func start_next_wave() -> void:
	start_wave(GameManager.current_wave)


func get_wave_enemy_count(wave_index: int) -> int:
	if wave_index < 0 or wave_index >= wave_definitions.size():
		return 0
	return wave_definitions[wave_index].enemies.size()


func get_remaining_enemies() -> int:
	return spawn_queue.size()


# === Private Methods ===

func _on_spawn_timer_timeout() -> void:
	if spawn_queue.is_empty():
		spawn_timer.stop()
		GameManager.finish_spawning()
		return

	var enemy_type = spawn_queue.pop_front()
	_spawn_enemy(enemy_type)


func _spawn_enemy(enemy_type: Constants.EnemyType) -> void:
	var scene: PackedScene = enemy_scenes.get(enemy_type)

	if scene == null:
		push_error("No scene for enemy type: %s" % enemy_type)
		return

	if spawn_path == null:
		push_error("Spawn path not set!")
		return

	var path_follow: PathFollow2D = PathFollow2D.new()
	path_follow.rotates = false
	path_follow.loop = false  # Important! Otherwise the enemy will loop around
	spawn_path.add_child(path_follow)

	var enemy: EnemyBase = scene.instantiate()
	enemy.setup_path(path_follow)
	path_follow.add_child(enemy)

	GameManager.register_enemy_spawned()
	Events.enemy_spawned.emit(enemy)


func _on_wave_completed() -> void:
	# Removed auto-start - player starts next wave with button
	pass
