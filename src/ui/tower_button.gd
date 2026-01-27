## Tower selection button for placement.
## Demonstrates: class signals, string formatting, GameManager interaction.
class_name TowerButton
extends Button


# === Class Signal ===

signal tower_selected(tower_type: Constants.TowerType)


# === Variables ===

var tower_type: Constants.TowerType = Constants.TowerType.BASIC
var tower_cost: int = 0
var tower_name: String = ""


func _ready() -> void:
	pressed.connect(_on_pressed)


func setup(type: Constants.TowerType) -> void:
	tower_type = type

	var data: Dictionary = Constants.get_tower_data(type)
	tower_cost = data.get("cost", 0)
	tower_name = data.get("name", "Tower")

	var tower_color: Color = data.get("color", Color.WHITE)

	# Text formatting
	text = "%s\n$%d" % [tower_name, tower_cost]

	# Button color
	add_theme_color_override("font_color", tower_color)

	# Tooltip with information
	tooltip_text = _create_tooltip(data)

	update_affordability()


func _create_tooltip(data: Dictionary) -> String:
	var dmg: int = data.get("damage", 0)
	var rng: float = data.get("range", 0.0)
	var rate: float = data.get("fire_rate", 0.0)

	return "%s Tower\nDamage: %d\nRange: %.0f\nFire Rate: %.1f/s\nCost: $%d" % [
		tower_name, dmg, rng, rate, tower_cost
	]


func update_affordability() -> void:
	var can_afford: bool = GameManager.can_afford(tower_cost)
	disabled = not can_afford

	if disabled:
		modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		modulate = Color.WHITE


func _on_pressed() -> void:
	if not disabled:
		tower_selected.emit(tower_type)


func get_tower_type() -> Constants.TowerType:
	return tower_type


func get_cost() -> int:
	return tower_cost
