## Global signal bus for communication between components.
## Demonstrates: various signal signatures, typed and untyped parameters.
extends Node


# === Enemy Signals ===

# Signal with typed parameters
signal enemy_spawned(enemy: Node2D)

# Signal with multiple typed parameters
signal enemy_killed(enemy: Node2D, reward: int)

# Signal with untyped parameter (duck typing)
signal enemy_reached_end(enemy)

# Signal for damage dealt
signal enemy_damaged(enemy: Node2D, damage: int, remaining_health: int)


# === Tower Signals ===

# Signal without parameter types (allows passing any objects)
signal tower_placed(tower, position)

# Signal with one parameter
signal tower_sold(tower)

# Tower fired signal
signal tower_fired(tower: Node2D, target: Node2D)


# === Wave Signals ===

# Signals without parameters
signal wave_started
signal wave_completed
signal all_waves_completed


# === Game Signals ===

signal game_started
signal game_over
signal victory
signal game_paused
signal game_resumed


# === Resource Signals ===

# Mixed typing: first parameter is typed, second is not
signal gold_changed(new_amount: int, delta)

# Two typed parameters
signal health_changed(new_health: int, max_health: int)


# === UI Signals ===

# Signal with Dictionary parameter
signal ui_notification(data: Dictionary)

# Signal for tower type selection for placement
signal tower_type_selected(tower_type: int)

# Cancel placement
signal placement_cancelled
