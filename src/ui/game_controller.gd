## Game scene controller.
## Demonstrates: system coordination, game initialization.
class_name GameController
extends Node2D


# === Onready System References ===

@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var tower_placer: TowerPlacer = $TowerPlacer
@onready var enemy_path: Path2D = $EnemyPath
@onready var hud: HUD = $HUD


func _ready() -> void:
	_setup_systems()
	_start_game()


func _setup_systems() -> void:
	if enemy_spawner and enemy_path:
		enemy_spawner.spawn_path = enemy_path


func _start_game() -> void:
	GameManager.start_game()


func _unhandled_input(event: InputEvent) -> void:
	# ESC to cancel placement
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if tower_placer and tower_placer.is_placing():
				Events.placement_cancelled.emit()
				get_viewport().set_input_as_handled()
