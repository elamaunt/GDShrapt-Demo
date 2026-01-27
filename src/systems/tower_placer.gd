## Tower placement system.
## Demonstrates: runtime loading (load), input handling, dynamic typing.
class_name TowerPlacer
extends Node2D


# === Runtime Scene Loading (not preload) ===

var tower_scenes: Dictionary = {}

# === Tower Size and Color Data for Preview ===

var tower_preview_data: Dictionary = {
	Constants.TowerType.BASIC: { "size": Vector2(48, 48), "color": Color(0.117647, 0.564706, 1, 1), "range": 150.0 },
	Constants.TowerType.SNIPER: { "size": Vector2(40, 40), "color": Color(0.8, 0.2, 0.8, 1), "range": 280.0 },
	Constants.TowerType.AOE: { "size": Vector2(56, 56), "color": Color(1, 0.5, 0, 1), "range": 120.0 },
}


# === Dynamically Typed Variables ===

var preview_visual: Node2D = null  # Simple visual without logic
var selected_type: Variant = null
var selected_cost: int = 0
var can_place: bool = false


# === Export ===

@export var build_area: Rect2 = Rect2(100, 100, 1080, 520)
@export var grid_size: Vector2 = Vector2(64, 64)
@export var path_width: float = 50.0  # Forbidden zone width around path


# === Array of Occupied Positions ===

var occupied_positions: Array[Vector2] = []
var path_points: PackedVector2Array = []


func _ready() -> void:
	_load_tower_scenes()
	_connect_signals()
	_cache_path_points()


# Runtime loading (unlike preload)
func _load_tower_scenes() -> void:
	tower_scenes[Constants.TowerType.BASIC] = load("res://src/scenes/towers/tower_basic.tscn")
	tower_scenes[Constants.TowerType.SNIPER] = load("res://src/scenes/towers/tower_sniper.tscn")
	tower_scenes[Constants.TowerType.AOE] = load("res://src/scenes/towers/tower_aoe.tscn")


func _connect_signals() -> void:
	Events.tower_type_selected.connect(_on_tower_type_selected)
	Events.placement_cancelled.connect(_on_placement_cancelled)


func _cache_path_points() -> void:
	# Get path points from PathVisual (Line2D)
	var path_visual: Line2D = get_tree().current_scene.get_node_or_null("PathVisual")
	if path_visual:
		path_points = path_visual.points


func _process(_delta: float) -> void:
	if preview_visual != null:
		_update_preview_position()
		_update_placement_validity()


func _input(event: InputEvent) -> void:
	if preview_visual == null:
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if can_place:
				_try_place_tower()
				get_viewport().set_input_as_handled()

		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()
			get_viewport().set_input_as_handled()


# === Public Methods ===

func start_placement(tower_type: Constants.TowerType) -> void:
	_cancel_placement()

	var data: Dictionary = Constants.get_tower_data(tower_type)
	var cost: int = data.get("cost", 0)

	if not GameManager.can_afford(cost):
		return

	var scene: PackedScene = tower_scenes.get(tower_type)
	if scene == null:
		push_error("No scene for tower type: %s" % tower_type)
		return

	# Create simple preview visual instead of real tower
	preview_visual = _create_preview_visual(tower_type)
	add_child(preview_visual)

	selected_type = tower_type
	selected_cost = cost


func _create_preview_visual(tower_type: Constants.TowerType) -> Node2D:
	var preview := Node2D.new()

	var pdata: Dictionary = tower_preview_data.get(tower_type, {})
	var size: Vector2 = pdata.get("size", Vector2(48, 48))
	var color: Color = pdata.get("color", Color.WHITE)
	var attack_range: float = pdata.get("range", 150.0)

	# Tower visual
	var visual := ColorRect.new()
	visual.size = size
	visual.position = -size / 2
	visual.color = color
	preview.add_child(visual)

	# Attack range visual
	var range_visual := ColorRect.new()
	range_visual.size = Vector2(attack_range * 2, attack_range * 2)
	range_visual.position = -Vector2(attack_range, attack_range)
	range_visual.color = Color(color.r, color.g, color.b, 0.15)
	preview.add_child(range_visual)

	preview.modulate.a = 0.7
	return preview


func is_placing() -> bool:
	return preview_visual != null


func get_selected_type():
	return selected_type


# === Private Methods ===

func _update_preview_position() -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var snapped_pos: Vector2 = _snap_to_grid(mouse_pos)
	preview_visual.global_position = snapped_pos


func _snap_to_grid(pos: Vector2) -> Vector2:
	# Snap to grid cell center
	var cell_x: int = int(pos.x / grid_size.x)
	var cell_y: int = int(pos.y / grid_size.y)
	var snapped := Vector2(
		cell_x * grid_size.x + grid_size.x / 2,
		cell_y * grid_size.y + grid_size.y / 2
	)
	return snapped


func _update_placement_validity() -> void:
	var pos: Vector2 = preview_visual.global_position
	can_place = _is_valid_position(pos)

	if can_place:
		preview_visual.modulate = Color(0.5, 1.0, 0.5, 0.7)
	else:
		preview_visual.modulate = Color(1.0, 0.5, 0.5, 0.7)


func _is_valid_position(pos: Vector2) -> bool:
	# Check bounds
	if not build_area.has_point(pos):
		return false

	# Check if occupied
	var grid_pos := _snap_to_grid(pos)
	if grid_pos in occupied_positions:
		return false

	# Check path intersection
	if _is_on_path(grid_pos):
		return false

	return true


func _is_on_path(pos: Vector2) -> bool:
	if path_points.size() < 2:
		return false

	# Check distance to each path segment
	for i in range(path_points.size() - 1):
		var p1: Vector2 = path_points[i]
		var p2: Vector2 = path_points[i + 1]
		var dist: float = _distance_to_segment(pos, p1, p2)
		if dist < path_width:
			return true

	return false


func _distance_to_segment(point: Vector2, seg_start: Vector2, seg_end: Vector2) -> float:
	var segment: Vector2 = seg_end - seg_start
	var length_sq: float = segment.length_squared()

	if length_sq == 0.0:
		return point.distance_to(seg_start)

	# Project point onto segment line
	var t: float = clampf(((point - seg_start).dot(segment)) / length_sq, 0.0, 1.0)
	var projection: Vector2 = seg_start + t * segment

	return point.distance_to(projection)


func _try_place_tower() -> void:
	if preview_visual == null or not can_place:
		return

	if not GameManager.spend_gold(selected_cost):
		return

	var pos: Vector2 = preview_visual.global_position
	var grid_pos: Vector2 = _snap_to_grid(pos)

	# Create real tower
	var scene: PackedScene = tower_scenes.get(selected_type)
	if scene == null:
		return

	var tower: TowerBase = scene.instantiate()

	# First add to tree, then set position
	get_tree().current_scene.add_child(tower)
	tower.global_position = grid_pos

	occupied_positions.append(grid_pos)
	Events.tower_placed.emit(tower, grid_pos)

	_cancel_placement()


func _cancel_placement() -> void:
	if preview_visual != null:
		preview_visual.queue_free()
		preview_visual = null

	selected_type = null
	selected_cost = 0
	can_place = false


func _on_tower_type_selected(tower_type: int) -> void:
	start_placement(tower_type as Constants.TowerType)


func _on_placement_cancelled() -> void:
	_cancel_placement()


# === Utilities ===

func is_position_occupied(pos: Vector2) -> bool:
	var grid_pos := _snap_to_grid(pos)
	return grid_pos in occupied_positions


func free_position(pos: Vector2) -> void:
	var grid_pos := _snap_to_grid(pos)
	occupied_positions.erase(grid_pos)
