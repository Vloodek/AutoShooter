extends Control
class_name EndMenu
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/exit_button as Button


func _ready():
	exit_button.button_down.connect(on_exit_pressed)


func on_exit_pressed():
	get_tree().quit()
