extends Control
class_name  MainMenu
@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/start_button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/exit_button as Button
@onready var start_level = preload("res://UI/Scenes/loading_screen.tscn") as PackedScene


func _ready():
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)

func on_start_pressed():
	get_tree().change_scene_to_packed(start_level)
	
func on_exit_pressed():
	get_tree().quit()
