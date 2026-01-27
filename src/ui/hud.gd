## Game interface (HUD).
## Demonstrates: CanvasLayer, signals, dynamic UI element creation.
class_name HUD
extends CanvasLayer


# === Preload ===

const TowerButtonScene: PackedScene = preload("res://src/scenes/ui/tower_button.tscn")


# === Onready ===

@onready var gold_label: Label = $TopBar/GoldLabel
@onready var health_label: Label = $TopBar/HealthLabel
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var tower_container: HBoxContainer = $BottomBar/TowerContainer
@onready var start_wave_button: Button = $BottomBar/StartWaveButton
@onready var game_over_panel: Panel = $GameOverPanel


# === Variables ===

var tower_buttons: Array[TowerButton] = []


func _ready() -> void:
	_connect_signals()
	_create_tower_buttons()
	_setup_game_over_panel()
	_update_start_wave_button()


func _connect_signals() -> void:
	Events.gold_changed.connect(_on_gold_changed)
	Events.health_changed.connect(_on_health_changed)
	Events.wave_started.connect(_on_wave_started)
	Events.wave_completed.connect(_on_wave_completed)
	Events.game_over.connect(_on_game_over)
	Events.victory.connect(_on_victory)
	Events.game_started.connect(_on_game_started)

	start_wave_button.pressed.connect(_on_start_wave_pressed)


func _create_tower_buttons() -> void:
	for tower_type in Constants.TowerType.values():
		var button: TowerButton = TowerButtonScene.instantiate()
		button.setup(tower_type)
		button.tower_selected.connect(_on_tower_button_pressed)
		tower_container.add_child(button)
		tower_buttons.append(button)


func _setup_game_over_panel() -> void:
	if game_over_panel:
		game_over_panel.visible = false

		var restart_btn: Button = game_over_panel.get_node_or_null("VBox/RestartButton")
		var menu_btn: Button = game_over_panel.get_node_or_null("VBox/MenuButton")

		if restart_btn:
			restart_btn.pressed.connect(_on_restart_pressed)
		if menu_btn:
			menu_btn.pressed.connect(_on_menu_pressed)


# === Signal Handlers ===

func _on_gold_changed(new_amount: int, _delta) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % new_amount
	_update_tower_buttons()


func _on_health_changed(new_health: int, max_health: int) -> void:
	if health_label:
		health_label.text = "Health: %d/%d" % [new_health, max_health]


func _on_wave_started() -> void:
	_update_wave_label()
	_update_start_wave_button()


func _on_wave_completed() -> void:
	_update_start_wave_button()


func _on_game_started() -> void:
	if game_over_panel:
		game_over_panel.visible = false
	_update_all()


func _on_game_over() -> void:
	_show_end_screen("GAME OVER", "The enemies broke through!")


func _on_victory() -> void:
	_show_end_screen("VICTORY!", "You survived all waves!")


func _on_tower_button_pressed(tower_type: Constants.TowerType) -> void:
	Events.tower_type_selected.emit(tower_type)


func _on_start_wave_pressed() -> void:
	if GameManager.is_between_waves and GameManager.is_game_active():
		var spawner: EnemySpawner = get_tree().current_scene.find_child("EnemySpawner")
		if spawner:
			spawner.start_next_wave()


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")


# === UI Updates ===

func _update_all() -> void:
	_on_gold_changed(GameManager.current_gold, 0)
	_on_health_changed(GameManager.current_health, GameManager.max_health)
	_update_wave_label()
	_update_start_wave_button()


func _update_wave_label() -> void:
	if wave_label:
		wave_label.text = "Wave: %d/%d" % [GameManager.get_current_wave_display(), Constants.MAX_WAVES]


func _update_tower_buttons() -> void:
	for button in tower_buttons:
		button.update_affordability()


func _update_start_wave_button() -> void:
	if start_wave_button:
		start_wave_button.visible = GameManager.is_between_waves and GameManager.is_game_active()
		start_wave_button.text = "Start Wave %d" % GameManager.get_current_wave_display()


func _show_end_screen(title: String, message: String) -> void:
	if game_over_panel == null:
		return

	var title_label: Label = game_over_panel.get_node_or_null("VBox/TitleLabel")
	var message_label: Label = game_over_panel.get_node_or_null("VBox/MessageLabel")

	if title_label:
		title_label.text = title
	if message_label:
		message_label.text = message

	game_over_panel.visible = true
