## Game state manager (singleton).
## Demonstrates: strict typing, export variables, signals, lifecycle methods.
extends Node


@export var starting_gold: int = 150
@export var starting_health: int = 20


var current_gold: int = 0
var current_health: int = 0
var max_health: int = 0
var current_wave: int = 0
var game_state: Constants.GameState = Constants.GameState.MENU

var enemies_alive := 0
var is_spawning := false
var is_between_waves := false

var selected_tower_type: Variant = null


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	Events.enemy_killed.connect(_on_enemy_killed)
	Events.enemy_reached_end.connect(_on_enemy_reached_end)
	Events.wave_completed.connect(_on_wave_completed)
	Events.tower_type_selected.connect(_on_tower_type_selected)
	Events.placement_cancelled.connect(_on_placement_cancelled)


func start_game() -> void:
	current_gold = starting_gold
	current_health = starting_health
	max_health = starting_health
	current_wave = 0
	enemies_alive = 0
	is_spawning = false
	is_between_waves = true
	selected_tower_type = null
	game_state = Constants.GameState.PLAYING

	Events.gold_changed.emit(current_gold, 0)
	Events.health_changed.emit(current_health, max_health)
	Events.game_started.emit()


func reset_game() -> void:
	game_state = Constants.GameState.MENU
	selected_tower_type = null


func can_afford(cost: int) -> bool:
	return current_gold >= cost


func spend_gold(amount: int) -> bool:
	if can_afford(amount):
		var old_gold: int = current_gold
		current_gold -= amount
		Events.gold_changed.emit(current_gold, current_gold - old_gold)
		return true
	return false


func add_gold(amount: int) -> void:
	var old_gold: int = current_gold
	current_gold += amount
	Events.gold_changed.emit(current_gold, current_gold - old_gold)


func take_damage(amount: int) -> void:
	current_health = maxi(0, current_health - amount)
	Events.health_changed.emit(current_health, max_health)

	if current_health <= 0:
		_trigger_game_over()


func register_enemy_spawned() -> void:
	enemies_alive += 1


func start_wave() -> void:
	is_between_waves = false
	is_spawning = true
	Events.wave_started.emit()


func finish_spawning() -> void:
	is_spawning = false
	_check_wave_complete()


func get_current_wave_display() -> int:
	return current_wave + 1


func is_game_active() -> bool:
	return game_state == Constants.GameState.PLAYING


func _on_enemy_killed(_enemy: Node2D, reward: int) -> void:
	enemies_alive -= 1
	add_gold(reward)
	_check_wave_complete()


func _on_enemy_reached_end(_enemy) -> void:
	enemies_alive -= 1
	take_damage(1)
	_check_wave_complete()


func _on_wave_completed() -> void:
	current_wave += 1
	is_between_waves = true

	if current_wave >= Constants.MAX_WAVES:
		_trigger_victory()


func _on_tower_type_selected(tower_type: int) -> void:
	selected_tower_type = tower_type


func _on_placement_cancelled() -> void:
	selected_tower_type = null


func _check_wave_complete() -> void:
	if enemies_alive <= 0 and not is_spawning and not is_between_waves:
		Events.wave_completed.emit()


func _trigger_game_over() -> void:
	game_state = Constants.GameState.GAME_OVER
	Events.game_over.emit()


func _trigger_victory() -> void:
	game_state = Constants.GameState.VICTORY
	Events.victory.emit()
	Events.all_waves_completed.emit()
