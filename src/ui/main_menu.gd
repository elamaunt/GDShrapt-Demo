## Main game menu.
## Demonstrates: scene transitions, simple UI logic.
class_name MainMenu
extends Control


# === Onready ===

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel


func _ready() -> void:
	_connect_buttons()
	_setup_title()


func _connect_buttons() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)

	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)


func _setup_title() -> void:
	if title_label:
		title_label.text = "Tower Defence\nGDShrapt Demo"


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
